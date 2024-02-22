using System.IO;
using PapeGames.X3;
using PapeGames.X3UI;
using UnityEngine;
using X3Game;

namespace X3Game
{
    /// <summary>
    /// 统计prefab身上的lua文件
    /// </summary>
    public static class LanguageAnalyze
    {
        private static PrefabLuaManifestFile s_PrefabLuaManifestFile;
        private static string m_BranchName;
        private static bool m_IsInit = false;
       
        public static void Init()
        {
            if (m_IsInit)
            {
                return;
            }

            //找不到文件,不记录
            if (!P4InfoManifestFile.TryGetBranchName(out m_BranchName))
            {
                m_IsInit = true;
                return;
            }

            s_PrefabLuaManifestFile = PrefabLuaManifestFile.ReadFromFile();
            if (s_PrefabLuaManifestFile == null)
            {
                s_PrefabLuaManifestFile = new PrefabLuaManifestFile();
            }
            m_IsInit = true;
        }

        public static void Save()
        {
            if (s_PrefabLuaManifestFile != null)
            {
                s_PrefabLuaManifestFile.SaveToFile();
            }
        }

        public static void Attach(GameObject ins, string luaPath)
        {
            if (!m_IsInit)
            {
                Init();
            }

            if (s_PrefabLuaManifestFile == null)
                return;
            if (ins == null || string.IsNullOrEmpty(luaPath))
                return;
            var uiView = ins.GetComponentInParent<UIView>(true);
            if (uiView == null)
                return;
            s_PrefabLuaManifestFile.Add(m_BranchName,uiView.ViewTag, luaPath);
        }
    }
}