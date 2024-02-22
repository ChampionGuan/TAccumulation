using System.Collections.Generic;
using System.IO;
using System.Linq;
using Framework;
using UnityEngine;
using PapeGames.X3;
using TMPro;
using UnityEngine.UI;
using PapeGames.X3UI;

namespace X3Game
{
    public static partial class UIViewUtility
    {
        /// <summary>
        /// 在游戏重启的时候, 界面的缓存
        /// </summary>
        private static Dictionary<string, GameObject> s_RebootInsCache = new Dictionary<string, GameObject>();

        /// <summary>
        /// 设置UIPrefab的AssetPath
        /// </summary>
        /// <param name="viewTag"></param>
        /// <param name="assetPath"></param>
        /// <returns></returns>
        public static bool SetUIPrefabAssetPath(string viewTag, string assetPath)
        {
            if (string.IsNullOrEmpty(viewTag) || string.IsNullOrEmpty(assetPath))
                return false;
            s_ViewTagToUIPrefabAssetPathDict[viewTag] = assetPath;
            return true;
        }

        public static string GetUIPrefabAssetPath(string viewTag)
        {
            if (!s_ViewTagToUIPrefabAssetPathDict.TryGetValue(viewTag, out string assetPath))
            {
                assetPath = Res.GetAssetPath(string.Format("UIView_{0}", viewTag), ResType.T_UIView);
#if DEBUG_GM
                if (!Res.IsAssetExist(assetPath))
                {
                    assetPath = Res.GetAssetPath(string.Format("UIView_{0}", viewTag), ResType.T_UIViewDebug);
                }
#endif

                s_ViewTagToUIPrefabAssetPathDict[viewTag] = assetPath;
            }

            return assetPath;
        }

        #region Delegates

        public class UIMgrSharpResDelegate : IUIMgrResDelegate
        {
            public GameObject OnGetUIViewIns(Transform root, string viewTag)
            {
                if (!s_ViewTagToUIPrefabAssetPathDict.TryGetValue(viewTag, out string assetPath))
                {
                    assetPath = GetUIPrefabAssetPath(viewTag);
                    s_ViewTagToUIPrefabAssetPathDict[viewTag] = assetPath;
                }

                if (s_GameReboot)
                {
                    if (s_RebootInsCache.TryGetValue(viewTag, out var gameObj))
                    {
                        return gameObj;
                    }
                }

                var prefab = Res.Load<GameObject>(assetPath);
                if (prefab == null)
                {
                    X3Debug.LogFatalFormat("Load ui prefab({0}) failed.", assetPath);
                    return null;
                }

#if !UNITY_EDITOR
                if (!assetPath.Contains("Debug"))
                {
                    UIUtility.ClearUITextComp(prefab);
                }
#endif
                GameObject ins =
                    X3AssetInsProvider.Instance.GetInsWithPrefab(prefab, GameObjectPoolLifeMode.Long, false, false,
                        root);
#if UNITY_EDITOR
                if (!assetPath.Contains("Debug"))
                {
                    ins.SetActive(false);
                    UIUtility.ClearUITextComp(ins);
                    ins.SetActive(true);
                }
#endif
                if (ins != null)
                {
                    if (!GridListView.MaskEnable)
                    {
                        List<GridListView> list = ListPool<GridListView>.Get();
                        ins.GetComponentsInChildren(true, list);
                        foreach (var view in list)
                        {
                            var softMaskComp = view.GetComponentInChildren<SoftMask>(true);
                            if (softMaskComp != null)
                                softMaskComp.SafeDestroy();
                            var maskComp = view.GetComponentInChildren<RectMask2D>(true);
                            if (maskComp != null)
                                maskComp.SafeDestroy();
                        }

                        ListPool<GridListView>.Release(list);
                    }

                    ins.transform.localScale = Vector3.one;
                    if (!ins.activeSelf)
                        ins.SetActive(true);
                }

                return ins;
            }

            public void OnReleaseUIViewIns(string viewTag, GameObject ins)
            {
                if (ins == null)
                    return;

                if (s_GameReboot)
                {
                    if (!s_RebootInsCache.ContainsKey(viewTag))
                    {
                        s_RebootInsCache[viewTag] = ins;
                    }

                    return;
                }

                GameObjReleaseDelegate.Release(ins);
                if (X3AssetInsProvider.Instance.ReleaseIns(ins, false, false, false))
                {
                    ins.SetActive(false);
#if UNITY_EDITOR
                    ins.name = ins.name + " [released]";
#endif
                }
            }
        }

        #endregion
    }
}