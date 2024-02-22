using UnityEngine;
using PapeGames.X3;
using UnityEditor;

namespace X3Game
{
    public class ResLoadListener : MonoBehaviour
    {
        // Start is called before the first frame update
        private string m_prefabName;

        public static ResLoadListener Attach(Object ins, string resPath)
        {
            if (ins == null || !(ins is GameObject))
                return null;
            // Debug.LogError(
            //     $"Attach {resPath} -- {resPath.Contains("UI/DynamicUIPrefab")} -- {resPath.Contains("UI/UIView")} {System.IO.Path.GetFileNameWithoutExtension(resPath)}");
            if (!(resPath.Contains("UI/DynamicUIPrefab") || resPath.Contains("UI/UIView")))
            {
                return null;
            }

            var go = ins as GameObject;
            var comp = go.GetOrAddComponent<ResLoadListener>();
            comp.m_prefabName = System.IO.Path.GetFileNameWithoutExtension(resPath);

            return comp;
        }

        public string PrefabName
        {
            get => m_prefabName;
        }
    }
}