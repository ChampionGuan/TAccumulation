// Name：InputEffectMgr_Pool
// Created by jiaozhu
// Created Time：2022-07-10 20:45

using System.Collections.Generic;
using PapeGames.X3LuaKit;
using UnityEngine;
using PapeGames.X3;

namespace X3Game
{
    public partial class InputEffectMgr
    {
        static Dictionary<string, GameObject> s_ObjTemplate = new Dictionary<string, GameObject>();
        static Dictionary<string, List<GameObject>> s_ObjMap = new Dictionary<string, List<GameObject>>();

        private static Transform s_RootTrans;
        private static Transform s_PoolTrans;

        /// <summary>
        /// 设置rootTrans;
        /// </summary>
        /// <param name="rootTrans"></param>
        public static void SetRootTrans(Transform rootTrans, Transform poolTrans)
        {
            s_RootTrans = rootTrans;
            s_PoolTrans = poolTrans;
        }

        public static void SetTemplate(GameObject obj)
        {
            SetTemplate(obj.name, obj);
        }

        public static void SetTemplate(string effectName, GameObject obj)
        {
            if (s_ObjTemplate.ContainsKey(effectName))
            {
                X3Debug.LogWarningFormat("替换特效模板[{0}]", effectName);
                s_ObjTemplate.Remove(effectName);
            }

            s_ObjTemplate.Add(effectName, obj);
        }

        public static void RemoveTemplate(string effectName)
        {
            if (s_ObjTemplate.ContainsKey(effectName))
            {
                s_ObjTemplate.Remove(effectName);
            }
        }

        public static void RemoveTemplate(GameObject obj)
        {
            RemoveTemplate(obj.name);
        }

        static void ClearObj()
        {
            s_ObjTemplate.Clear();
            s_ObjMap.Clear();
            s_RootTrans = null;
            s_PoolTrans = null;
        }

        static GameObject Get(string effectName)
        {
            if (string.IsNullOrEmpty(effectName)) return null;
            GameObject res = null;
            if (s_ObjMap.TryGetValue(effectName, out var list))
            {
                if (list.Count > 0)
                {
                    res = list[0];
                    list.Remove(res);
                }
            }

            if (res == null)
            {
                if (s_ObjTemplate.TryGetValue(effectName, out var obj))
                {
                    res = GameObject.Instantiate(obj);
                }
            }

            if (res != null)
            {
                GameObjectTransformUtility.ResetLocalTSR(res.transform);
                res.transform.SetParent(s_RootTrans, false);
            }

            return res;
        }

        static void Release(string effectName, GameObject obj)
        {
            if (obj == null || string.IsNullOrEmpty(effectName) || s_PoolTrans==null) return;
            obj.transform.SetParent(s_PoolTrans, false);
            if (s_ObjMap.TryGetValue(effectName, out var list))
            {
                list.Add(obj);
            }
            else
            {
                var tempList = ListPool<GameObject>.Get();
                tempList.Add(obj);
                s_ObjMap.Add(effectName, tempList);
            }
        }
    }
}