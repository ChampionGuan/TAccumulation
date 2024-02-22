using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Profiling;

namespace X3Battle
{
    /// <summary>
    /// 资源测试类 只在测试环境中使用正常流程不能使用
    /// </summary>
    public class BattleResTest
    {
        private static GameObject _obj;
        private static List<GameObject> _prefabs = new List<GameObject>();
        private static List<GameObject> _objs = new List<GameObject>();

        public static void HideUI()
        {
            var root = GameObject.Find("UIMgr/X3UI/RootCanvas/Content");
            if (root == null)
                return;
            var childrens = root.GetComponentsInChildren<Transform>();
            if (childrens == null)
                return;
            foreach (var children in childrens)
            {
                children.gameObject.SetActive(false);
            }
            root.gameObject.SetActive(true);
        }
        
        /// <summary>
        /// 加载prefab 并显示
        /// </summary>
        public static void LoadPrefabAndShow(string path)
        {
            _obj = Res.Load<GameObject>(path, Res.AutoReleaseMode.GameObject);
            if (_obj == null)
                return;
            var root = GameObject.Find("UIMgr/X3UI/RootCanvas/Content");
            if (root == null)
                return;
            _obj.transform.parent = root.transform;
            _obj.transform.localPosition = new Vector3(0,0,-1000);
            var fxPlayer = _obj.GetComponent<FxPlayer>();
            if(fxPlayer != null)
                fxPlayer.Play();
            _objs.Add(_obj);
        }

        public static void TestSetRootActiveTrue()
        {
            using (ProfilerDefine.TestSetRootActiveTruePMarker.Auto())
            {
                _obj.SetActive(true);
            }
        }
        
        public static void TestSetRootActiveFalse()
        {
            using (ProfilerDefine.TestSetRootActiveFalsePMarker.Auto())
            {
                _obj.SetActive(false);
            }
        }
        
        public static void TestSetRootVisibleFalse()
        {
            using (ProfilerDefine.TestSetRootVisibleFalsePMarker.Auto())
            {
                _obj.SetVisible(false);
            }
        }
        public static void TestSetRootVisibleTrue()
        {
            using (ProfilerDefine.TestSetRootVisibleTruePMarker.Auto())
            {
                _obj.SetVisible(true);
            }
        }
        
        public static void AllActiveTrue()
        {
            using (ProfilerDefine.AllActiveTruePMarker.Auto())
            {
                foreach (var obj in _objs)
                {
                    obj.SetActive(true);
                }
            }
        }
        
        public static void AllActiveFalse()
        {
            using (ProfilerDefine.AllActiveFalsePMarker.Auto())
            {
                foreach (var obj in _objs)
                {
                    obj.SetActive(false);
                }
            }
        }
        
        public static void AllVisibleFalse()
        {
            using (ProfilerDefine.AllVisibleFalsePMarker.Auto())
            {
                foreach (var obj in _objs)
                {
                    obj.SetVisible(false);
                }
            }
        }
        public static void AllVisibleTrue()
        {
            using (ProfilerDefine.AllVisibleTruePMarker.Auto())
            {
                foreach (var obj in _objs)
                {
                    obj.SetVisible(true);
                }
            }
        }
        
        /// <summary>
        /// 加载prefab
        /// </summary>
        public static void LoadPrefab(string path)
        {
            _obj = Res.Load<GameObject>(path, Res.AutoReleaseMode.GameObject);
            if (_obj != null)
            {
                _prefabs.Add(_obj);
            }
        }

        
        public static void ClearAllPrefab()
        {
            foreach (var prefab in _prefabs)
            {
                if (prefab != null)
                {
                    ParticleSystem.Stop(prefab.transform,true, ParticleSystemStopBehavior.StopEmittingAndCleanup);
                }
            }
        }
        
        public static void DestroyAllPrefab()
        {
            for (int i = _prefabs.Count - 1; i >= 0; i--)
            {
                if (_prefabs[i] != null)
                {
                    GameObject.DestroyImmediate(_prefabs[i]);
                }
            }
        }
    }
}