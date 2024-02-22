using UnityEngine;
using PapeGames.X3;
using UnityEditor;

namespace X3Game
{
    public partial class LuaUICtrl : MonoBehaviour
    {
        private string m_LuaPath;
        public static LuaUICtrl Attach(GameObject ins, string luaPath)
        {
            if (ins == null)
                return null;
            var comp = ins.GetOrAddComponent<LuaUICtrl>();
            comp.m_LuaPath = luaPath;
            return comp;
        }

        public static UnityEngine.Object GetObject(int instanceID)
        {
            #if UNITY_EDITOR
            return EditorUtility.InstanceIDToObject(instanceID);
            #endif
            return null;
        }

        public string LuaPath
        {
            get => m_LuaPath;
        }

#if UNITY_EDITOR
        public void OnHierarchyItemIconClicked()
        {
            OpenLuaFile(LuaPath);
        }

        public static void OpenLuaFile(string luaPath)
        {
            var absPath = LuaFileLoader.GetLuaFullPathInProj(luaPath);
            string idePath = UnityEditor.EditorPrefs.GetString("LUAIDEPATH_EDITOR_PREFS_KEY", "");
            if (string.IsNullOrEmpty(idePath))
                UnityEditor.EditorUtility.OpenWithDefaultApp(absPath);
            else
                ExeProc(idePath, absPath);
        }
        
        private static void ExeProc(string fileName, string args)
        {
            if (string.IsNullOrEmpty(fileName) || string.IsNullOrEmpty(args))
                return;
            Debug.LogFormat($"{fileName} {args}");
            var p = new System.Diagnostics.Process
            {
                StartInfo =
                {
                    FileName = fileName,
                    Arguments = args,
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    RedirectStandardInput = true,
                    RedirectStandardError = true,
                    CreateNoWindow = true
                }
            };
            p.Start();
            p.BeginOutputReadLine();
            p.BeginErrorReadLine();
            p.WaitForExit();
            p.Close();
        }

        [SerializeField, Multiline(4)] private string m_FuncStr = "";
#endif
    }
}