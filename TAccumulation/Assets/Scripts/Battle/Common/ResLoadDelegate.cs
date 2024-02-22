using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public class ResLoadDelegate : IResExtensionDelegate
    {
        public void OnExtensionInit()
        {
            
        }

        public void OnLoadTaskStart(string assetPath)
        {
            
        }

        public void OnLoadTaskComplete(string assetPath, float timeCosts)
        {
            BattleCounterMgr.Instance.Add(CounterType.ABLoad, timeCosts);
        }

        public float OnGetResLoadTime(string assetPath)
        {
            return 0;
        }

        public bool OnWillLoad(string assetPath)
        {
            return true;
        }

        public void OnInstantiate(string assetPath, float timeCosts)
        {
            BattleCounterMgr.Instance.Add(CounterType.Instantiate, timeCosts);
        }
    }

    public class SceneLoadDelegate : IResDelegate
    {
        private float _startTime = 0;
        private bool _isLoadBegan = false;
        
        public void OnSceneLoadBegin(string sceneName)
        {
            _isLoadBegan = true;
            _startTime = Time.realtimeSinceStartup;
        }

        public void OnSceneLoadComplete(string sceneName)
        {
            // 如果场景Prefab是从对象池中取的话， 不在触发began回调
            float usedTime = 0;
            if (_isLoadBegan)
            {
                usedTime = Time.realtimeSinceStartup - _startTime;
            }
            _isLoadBegan = false;
            BattleCounterMgr.Instance.Add(CounterType.SceneLoad, usedTime);
        }

        public void OnSceneUnloaded(string sceneName)
        {
            
        }

        public void OnSceneLoaded(string sceneName)
        {
            
        }
    }
}