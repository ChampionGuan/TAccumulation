using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using PapeGames.X3UI;
using X3Game;

namespace PapeGames.X3Editor
{
    public static class DynamicAssetsRecordMgr
    {
        private static Dictionary<string, Dictionary<string, string>> m_dataDic =
            new Dictionary<string, Dictionary<string, string>>();
        
        private static string m_uiEndLess = "UIView_";

        //UIWindow // UIPanel // UIPopup // UITips
        public static void RecordData(GameObject go, string resPath)
        {
            
            //运行时预制体信息会被打破，只能在编辑状态使用
            // string prefabName = "";
            // var temp = PrefabUtility.GetNearestPrefabInstanceRoot(go);
            // PapeGames.X3.X3Debug.LogError($"go {go.name} temp -- {temp}");
            // if (temp != null)
            // {
            //     var t = PrefabUtility.GetCorrespondingObjectFromOriginalSource(temp);
            //     var path = AssetDatabase.GetAssetPath(t);
            //     prefabName = System.IO.Path.GetFileNameWithoutExtension(path);
            //     PapeGames.X3.X3Debug.LogError($"prefabName {prefabName} --- {path}");
            // }

            string prefabName = GetFatherName(go.transform);
            if (!m_dataDic.ContainsKey(prefabName))
            {
                m_dataDic.Add(prefabName, new Dictionary<string, string>());
            }
            
            string resName = System.IO.Path.GetFileNameWithoutExtension(resPath);
            var resDic = m_dataDic[prefabName];
            // PapeGames.X3.X3Debug.LogError("prefabName--------------------- " + prefabName + " resPath " + resPath + " ------- " +
            //                resName);

            if ((!string.IsNullOrEmpty(resName)) && !resDic.ContainsKey(resName))
            {
                resDic.Add(resName, resPath);
            }
        }
        
        public static Dictionary<string, Dictionary<string, string>> GetResultData()
        {
            return m_dataDic;
        }

        public static string GetFatherName(Transform ts)
        {
            //这里应该不用查看自身，根节点挂图也太怪了。
            string name = "";
            while (ts.parent && string.IsNullOrEmpty(name))
            {
                Transform parent = ts.parent;
                ResLoadListener loaderCom = parent.GetComponent<ResLoadListener>();
                UIView viewCom = parent.GetComponent<UIView>();
                if (loaderCom)
                {
                    name = loaderCom.PrefabName;
                    break;
                }
                else if (viewCom)
                {
                    //有的预制体没填viewtag,还是使用名称过滤吧,顺便过滤下括号
                    var splitList = viewCom.name.Split('(');
                    name = string.IsNullOrEmpty(splitList[0]) ? "null" : splitList[0];
                    //由于是tag创建，是没有前缀的
                    if (!name.Contains("UIView_"))
                    {
                        name = m_uiEndLess + name;
                    }
                    break;
                }
                
                ts = ts.parent;
            }

            return name;
        }
    }
}