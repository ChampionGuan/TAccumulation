using UnityEngine;
namespace X3Game.AILab
{
    [XLua.LuaCallCSharp]
    public static class AILabHelper
    {
        public static string FolderPath = "TC";
        public static string ModelPath = "models";
        private static string s_RootPath = "";
        public static string RootPath
        {
            get
            {
                if (!string.IsNullOrEmpty(s_RootPath))
                {
                    return s_RootPath;
                }
#if UNITY_EDITOR
                return "DefaultRes";
#else
                return Application.persistentDataPath;
#endif
            }
        }
        
        public static void SetPath(string rootPath, string folderPath, string modelPath)
        {
            s_RootPath = rootPath;
            FolderPath = folderPath;
            ModelPath = modelPath;
        }
    }
}