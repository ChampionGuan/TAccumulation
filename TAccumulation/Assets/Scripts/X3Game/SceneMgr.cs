using Framework;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using PapeGames.X3;

namespace X3Game
{
    [XLua.LuaCallCSharp]
    public static class SceneMgr
    {
        static Dictionary<GameObject, bool> objMap = new Dictionary<GameObject, bool>();
        static Dictionary<GameObject, Dictionary<GameObject,bool>> restoreMap = new Dictionary<GameObject, Dictionary<GameObject, bool>>();
        public static void SetSceneObjsActive(bool isActive)
        {
            Init();
            SetObjsActive(objMap, isActive);
        }

        public static void ClearObjs()
        {
            objMap.Clear();
        }

        public static GameObject GetSceneObj(string name)
        {
            Init();
            GameObject obj = null;
            foreach (var item in objMap)
            {
                if (item.Key!=null && item.Key.name.Equals(name))
                {
                    obj = item.Key;
                    break;
                }
            }
            return obj;
        }

        public static void RestoreSceneObjs(GameObject obj)
        {
            if (obj == null) return;
            if (restoreMap.TryGetValue(obj, out var map))
            {
                SetObjsActive(map, true);
            }
        }
        public static void AddSceneRootObj(GameObject obj)
        {
            if (obj == null) return;
            List<GameObject> list = ListPool<GameObject>.Get();
            var trans = obj.transform;
            for (int i = 0; i < trans.childCount; i++)
            {
                var res = trans.GetChild(i).gameObject;
                list.Add(res);
            }
            bool isRestore = restoreMap.ContainsKey(obj);
            AddObjs(list, isRestore ? null:obj);
            ListPool<GameObject>.Release(list);
            CheckMapValid();
            if (isRestore)
            {
                RestoreSceneObjs(obj);
            }
        }
        public static void AddSceneObj(GameObject obj, GameObject sceneRoot=null)
        {
            if ( obj != null && !objMap.ContainsKey(obj))
            {
                objMap.Add(obj, obj.activeSelf);
                if (sceneRoot != null)
                {
                    Dictionary<GameObject, bool> rootMap = null;
                    if (!restoreMap.TryGetValue(sceneRoot,  out rootMap))
                    {
                        rootMap = new Dictionary<GameObject, bool>();
                        restoreMap.Add(sceneRoot, rootMap);
                    }
                    if (!rootMap.ContainsKey(obj))
                    {
                        rootMap.Add(obj, obj.activeSelf);
                    }

                }
            }
        }
        public static void RemoveSceneObj(GameObject obj)
        {
            if (objMap.Count > 0 && obj != null && objMap.ContainsKey(obj))
            {
                objMap.Remove(obj);
            }
        }

        static void SetObjsActive(Dictionary<GameObject, bool> objs,bool isActive)
        {
            foreach (var item in objs)
            {
                if (!XLuaHelper.IsNull(item.Key))
                {
                    UIUtility.SetActive(item.Key, isActive && item.Value);
                }
            }
        }

        static void CheckMapValid()
        {
            foreach (var item in restoreMap)
            {
                if (XLuaHelper.IsNull(item.Key))
                {
                    restoreMap.Remove(item.Key);
                    break;
                }
            }
        }
        static void Init()
        {
            if (objMap.Count == 0)
            {
                CheckSceneObjs();
            }
        }

        static void CheckSceneObjs()
        {
            objMap.Clear();
            List<GameObject> list = ListPool<GameObject>.Get();
            SceneManager.GetActiveScene().GetRootGameObjects(list);
            AddObjs(list);
            ListPool<GameObject>.Release(list);
        }

        static void AddObjs(List<GameObject> list,GameObject sceneRoot=null)
        {
            if (list.Count > 0)
            {
                for (int i = 0; i < list.Count; i++)
                {
                    var obj = list[i];
                    if (obj.name.Equals(Common.SceneScriptRootName))
                    {
                        continue;
                    }
                    AddSceneObj(obj, sceneRoot);
                }
            }
        }
    }
}

