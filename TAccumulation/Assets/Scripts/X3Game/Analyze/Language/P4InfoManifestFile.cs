using System;
using System.IO;
using UnityEngine;

namespace X3Game
{
    [Serializable]
    public class P4InfoManifestFile
    {
        public static readonly string FILE_NAME = "P4Info.json";
        public static readonly string FILE_DIRECTORY = Application.dataPath + "/../../../P4Ignore";
        public static readonly string FILE_PATH = FILE_DIRECTORY + "/" + FILE_NAME;
        [SerializeField] private string branch;

        public static P4InfoManifestFile ReadFromFile(string filePath = null)
        {
            if (string.IsNullOrEmpty(filePath))
            {
                filePath = FILE_PATH;
            }

            if (!File.Exists(filePath))
            {
                return null;
            }

            var strJson = File.ReadAllText(filePath);
            var manifestFile = JsonUtility.FromJson<P4InfoManifestFile>(strJson);
            return manifestFile;
        }

        public static bool TryGetBranchName(out string branchName)
        {
            var manifestFile = ReadFromFile();
            if (manifestFile != null)
            {
               branchName = manifestFile.branch;
               return true;
            }

            branchName = null;
            return false;
        }
    }
}