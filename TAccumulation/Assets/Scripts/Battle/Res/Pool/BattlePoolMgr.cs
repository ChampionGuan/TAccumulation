using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using Object = UnityEngine.Object;

namespace X3Battle
{
    public class BattlePoolMgr
    {
        private Dictionary<BattleResType, BattleResPool> _pools;

        public Transform poolRoot;
        public Dictionary<BattleResType, BattleResPool> pools=>_pools;
        public bool isInit => poolRoot != null;
        
        public BattlePoolMgr(Func<BattleResType, IResLoader> createResLoader)
        {
            _pools = new Dictionary<BattleResType, BattleResPool>();
            for (int i = 0; i < (int)BattleResType.Num; i++)
            {
                BattleResType type = (BattleResType)i;
                BattleResPool resPool = CreatePool(type);
                if (resPool == null)
                    continue;
                resPool.SetResLoader(createResLoader.Invoke(type));
                _pools[type] = resPool;
            }
        }
        
        public void Init()
        {
            string name = "CSBattlePoolRoot";
            var RootObj = GameObject.Find(name);
            BattleUtil.DestroyObj(RootObj);
            poolRoot = new GameObject(name).transform;
            if (Application.isPlaying)
                GameObject.DontDestroyOnLoad(poolRoot.gameObject);
            foreach (var item in _pools)
            {
                item.Value.Init();
            }
        }
        
        public void UnInit()
        {
            EditorWriteInfoToFile();
            foreach (var item in _pools)
            {
                item.Value.UnInit();
            }
            if (poolRoot)
            {
                BattleUtil.DestroyObj(poolRoot.gameObject);
                poolRoot = null;
            }
        }
        
        public void UnloadUnusedAll(bool unloadAsset = false)
        {
            foreach (var item in _pools)
            {
                item.Value.UnloadUnusedAll(unloadAsset);
            }
        }
        
        public void UnloadUnused(BattleResType type, bool unloadAB)
        {
            _pools.TryGetValue(type, out var pool);
            if (pool != null)
            {
                pool.UnloadUnusedAll(unloadAB);    
            }
        }
        
        public void UnloadUnused(ResLoadArg arg, bool unloadAB)
        {
            _pools.TryGetValue(arg.type, out var pool);
            if (pool != null)
            {
                pool.UnloadUnused(arg, unloadAB);    
            }
        }
 
        public void EnablePool(BattleResType type, bool enablePool)
        {
            foreach (var item in _pools)
            {
                if (item.Key == type)
                {
                    item.Value.enable = enablePool;
                }
            }
        }
        
        public Object Get(ResLoadArg arg) 
        {
            if (_pools.TryGetValue(arg.type, out BattleResPool pool))
            {
                return pool.Get(arg);
            }
            return null;
        }
        
        public FxPlayer GetFxPlayer(BattleResType type, GameObject go) 
        {
            if (_pools.TryGetValue(type, out BattleResPool pool))
            {
                if (pool is IGetFxPlayer fxResPool)
                    return fxResPool.GetFxPlayer(go);
            }
            return null;
        }
        
        public void Recycle(ResDesc desc, Object obj)
        {
            if (_pools.TryGetValue(desc.type, out BattleResPool pool))
            {
                pool.Recycle(obj, desc.loadArg);
            }
            else
            {
                LogProxy.LogErrorFormat("对象池Recycle失败，缺失对应类型：{0} 的对象池", desc.type);
            }
        }

        public bool HasPreloaded(string path, BattleResType type)
        {
            BattleResPool resPool = null;
            if (_pools.TryGetValue(type, out resPool))
            {
                return resPool.IsObjCached(path);
            }
            return false;
        }

        private BattleResPool CreatePool(BattleResType type)
        {
            BattleResConfigItem cfg = BattleResConfig.GetResConfig(type);
            if (cfg == null)
                return null;

            BattleResPool resPool = null;
            switch (cfg.poolType)
            {
                case BattleResPoolType.BattleResPool:
                    resPool = new BattleResPool(this, type);
                    break;
                case BattleResPoolType.EmptyPool:
                    resPool = new EmptyPool(this, type);
                    break;
                case BattleResPoolType.GameObjectPool:
                    resPool = new GameObjectPool(this, type);
                    break;
                case BattleResPoolType.GameObjectVisiblePool:
                    resPool = new GameObjectVisiblePool(this, type);
                    break;
                case BattleResPoolType.GraphAssetPool:
                    resPool = new GraphAssetPool(this, type);
                    break;
                case BattleResPoolType.FxResVisiblePool:
                    resPool = new FxResVisiblePool(this, type);
                    break;
                default:
                    PapeGames.X3.LogProxy.LogErrorFormat("不支持的LoadType:{0}", cfg.loadType);
                    break;
            }

            if (cfg.enableStreaming)
            {
                resPool.TryEnableStreaming();
            }
            return resPool;
        }

        public void EditorWriteInfoToFile()
        {
            if (!Application.isEditor)
                return;
            string fullPath = Application.persistentDataPath + "/BattleObjPoolInfo.csv";
            using (System.IO.StreamWriter writer = new System.IO.StreamWriter(fullPath, false))
            {
                var HeadInfo = "资源类型,文件夹位置,资源Path,预加载数量,使用峰值,战斗中加载数量,当前缓存数量";
                writer.WriteLine(HeadInfo);
                foreach (var item in _pools)
                {
                    item.Value.EditorWriteInfoToFile(writer);
                }
            }
            PapeGames.X3.LogProxy.LogFormat("对象池使用信息保存成功，位置：{0}", fullPath);
        }
    }
}