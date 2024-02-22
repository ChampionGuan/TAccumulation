using UnityEngine;
using UnityEditor;
using UnityEditor.Experimental;
using LitJson;
using System.IO;
using System.Collections.Generic;
using UnitySerializedFile;

public class CheckCacheSerializedFile
{
    public SortedDictionary<string, string> ErrorMessages = new SortedDictionary<string, string>();
    public SortedDictionary<string, string> InvalidFiles = new SortedDictionary<string, string>();
    public SortedDictionary<string, string> MissingFiles = new SortedDictionary<string, string>();
    public SortedDictionary<string, string> Snapshots = new SortedDictionary<string, string>();

    [MenuItem("TestbedTool/杂项/清空GameObject缓存", false, 904)]
    static void ClearAllGameObjectCache()
    {
        CheckCacheSerializedFile Datas = new CheckCacheSerializedFile();

        string[] searchInFolders = new string[]
        {
            "Assets",
        };
        List<string> prefabGuids = new List<string>();
        prefabGuids.AddRange(AssetDatabase.FindAssets("t:Prefab", searchInFolders));
        prefabGuids.AddRange(AssetDatabase.FindAssets("t:Scene", searchInFolders));
        for (int i = 0; i < prefabGuids.Count; i++)
        {
            string guid = prefabGuids[i];
            string assetPath = AssetDatabase.GUIDToAssetPath(guid);

            Hash128 hash = AssetDatabaseExperimental.GetArtifactHash(guid);
            if (AssetDatabaseExperimental.GetArtifactPaths(hash, out var paths))
            {
                {
                    string cachePath = Path.GetFullPath(paths[0]);
                    if(!File.Exists(cachePath))
                    {
                        Datas.MissingFiles.Add(assetPath, paths[0]);
                    }
                    else
                    {
                        Datas.CheckCacheData(assetPath, cachePath);
                    }
                }
                {
                    string cachePath = Path.GetFullPath(paths[1]);
                    if (!File.Exists(cachePath))
                    {
                        Datas.MissingFiles.Add(assetPath, paths[1]);
                    }
                }
            }
            else
            {
                Datas.MissingFiles.Add(assetPath, "missing");
            }
            EditorUtility.DisplayProgressBar("Hold On", assetPath, (i + 1) / (float)prefabGuids.Count);
        }
        EditorUtility.ClearProgressBar();       

        string file = Path.GetFullPath("Temp/ClearCacheInfo.txt");
        string jsonStr = JsonMapper.ToPrettyJson(Datas);
        File.WriteAllText(file, jsonStr);
        Application.OpenURL(file);

        Datas.ReimportInvalidAssets();
    }

    public void CheckCacheData(string assetPath, string cachePath)
    {
        byte[] data = File.ReadAllBytes(cachePath);

        ReadBinaryHeader btf = new ReadBinaryHeader();
        SerializedFileLoadError loadError = btf.ReadHeader(cachePath, data);
        if (loadError != SerializedFileLoadError.kSerializedFileLoadError_None)
        {
            string errorMessage = ReadBinaryHeader.PrintSerializedFileLoadError(cachePath, data.Length, loadError);
            ErrorMessages.Add(assetPath, errorMessage);
            return;
        }

        foreach (SerializedType type in btf.Types)
        {
            TypeTree typeTree = type.m_OldType;
            string typeName = typeTree.m_Type;

            if (typeName == "GameObject")
            {
                TypeTree field = typeTree.m_Children.Find(x => x.m_Name == "m_IsActive" && x.m_Type == "bool");
                if(field != null)
                {
                    InvalidFiles.Add(assetPath, cachePath);
                }
            }
            else if (typeName == "MonoBehaviour")
            {
                
            }
        }
    }

    private void ReimportInvalidAssets()
    {
        if (InvalidFiles.Count == 0 && MissingFiles.Count == 0)
            return;

        try
        {
            //Place the Asset Database in a state where
            //importing is suspended for most APIs
            AssetDatabase.StartAssetEditing();

            foreach (var path in InvalidFiles.Keys)
            {
                AssetDatabase.ImportAsset(path);
            }
            foreach (var path in MissingFiles.Keys)
            {
                AssetDatabase.ImportAsset(path);
            }
        }
        finally
        {
            //By adding a call to StopAssetEditing inside
            //a "finally" block, we ensure the AssetDatabase
            //state will be reset when leaving this function
            AssetDatabase.StopAssetEditing();
        }
    }

    [MenuItem("TestbedTool/杂项/检查Snapshot资源", false, 904)]
    static void CheckAllSnapshotPrefab()
    {
        CheckCacheSerializedFile Datas = new CheckCacheSerializedFile();

        string[] searchInFolders = new string[]
        {
            "Assets",
        };
        List<string> prefabGuids = new List<string>();
        prefabGuids.AddRange(AssetDatabase.FindAssets("t:Prefab", searchInFolders));
        prefabGuids.AddRange(AssetDatabase.FindAssets("t:Scene", searchInFolders));
        for (int i = 0; i < prefabGuids.Count; i++)
        {
            string guid = prefabGuids[i];
            string assetPath = AssetDatabase.GUIDToAssetPath(guid);

            Datas.CheckAssetData(assetPath);

            EditorUtility.DisplayProgressBar("Hold On", assetPath, (i + 1) / (float)prefabGuids.Count);
        }
        EditorUtility.ClearProgressBar();

        string file = Path.GetFullPath("Temp/ClearCacheInfo.txt");
        string jsonStr = JsonMapper.ToPrettyJson(Datas);
        File.WriteAllText(file, jsonStr);
        Application.OpenURL(file);
    }

    public void CheckAssetData(string assetPath)
    {
        byte[] data = File.ReadAllBytes(assetPath);

        ReadBinaryHeader btf = new ReadBinaryHeader();
        SerializedFileLoadError loadError = btf.ReadHeader(assetPath, data);
        if (loadError != SerializedFileLoadError.kSerializedFileLoadError_None)
        {
            string errorMessage = ReadBinaryHeader.PrintSerializedFileLoadError(assetPath, data.Length, loadError);
            ErrorMessages.Add(assetPath, errorMessage);
            return;
        }

        foreach (long fileID in btf.Objects.Keys)
        {
            ObjectInfo fileValue = btf.Objects[fileID];
            TypeTree typeTree = btf.GetTypeTree(fileValue);

            TypeTree field = typeTree.m_Children.Find(x => x.m_Name == "references" && x.m_Type == "ManagedReferencesRegistry");
            if (field == null)
                continue;

            int offset = (int)fileValue.byteStart;
            using (StringWriter writer = new StringWriter())
            {
                BinaryToText.RecursiveOutput(btf, writer, typeTree, data, ref offset);

                var refType = field.m_Children[1].m_Children[0];
                var kclass = refType.m_Children[0];
                var ns = refType.m_Children[1];
                var asm = refType.m_Children[2];
                if (kclass.m_DebugValue.Contains("Snapshot") && ns.m_DebugValue == "PapeGames.X3")
                {
                    Snapshots.Add(assetPath, kclass.m_DebugValue);
                }
            }
        }
    }
}