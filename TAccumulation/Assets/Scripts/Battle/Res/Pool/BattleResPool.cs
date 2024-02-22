using System;
using System.Collections.Generic;
using System.IO;
using PapeGames.X3;
using Unity.Mathematics;
using UnityEngine;
using Object = UnityEngine.Object;

namespace X3Battle
{
    interface IGetFxPlayer
    {
        FxPlayer GetFxPlayer(Object obj);
    }
    
    public class BattleObjInfo
    {
        public string name;
        public int cacheCount;
        public int preloadNum;
        public int loadNum;
        public int unloadNum;
        public int curMinCacheNum=Int32.MaxValue;
        public int useTime;
    }
    
    public partial class BattleResPool 
    {
        protected BattlePoolMgr _poolMgr;
        protected BattleResType _type;
        protected BattleResLoadType _loadType;
        protected IResLoader _resLoader;
        protected Transform poolTrans;
        protected bool _enable;

        protected Dictionary<string, List<Object>> _objList;
        protected Dictionary<string, BattleObjInfo> _objInfos;

        public Dictionary<string, List<Object>> objList => _objList;
        public Dictionary<string, BattleObjInfo> objInfos => _objInfos;
        public IResLoader resLoader => _resLoader;

        public bool enable
        {
            get => _enable;
            set => _enable = value;
        }

        public BattleResPool(BattlePoolMgr mgr, BattleResType type)
        {
            _poolMgr = mgr;
            _objList = new Dictionary<string, List<Object>>();
            _objInfos = new Dictionary<string, BattleObjInfo>();
            this._type = type;
            _enable = true;
            var item = BattleResConfig.GetResConfig(type);
            if (item != null)
                _loadType = item.loadType;
            
        }

        public virtual void SetResLoader(IResLoader resLoader)
        {
            _resLoader = resLoader;
        }

        public virtual void Init()
        {
            string name = Enum.GetName(typeof(BattleResType), _type);
            poolTrans = new GameObject(name).transform;
            poolTrans.SetParent(_poolMgr.poolRoot);
        }

        public virtual void UnInit()
        {
            _resLoader?.UnInit();
            UnloadUnusedAll(false);
            _objList.Clear();
            _objInfos.Clear();
            
            if (poolTrans)
                BattleUtil.DestroyObj(poolTrans.gameObject);
        }
        
        // 清空对象池中未使用的对象
        public virtual void UnloadUnusedAll(bool isUnloadAsset)
        {
            foreach (var item in _objList)
            {
                for (int i = item.Value.Count - 1; i >= 0; i--)
                {
                    Unload(item.Key, item.Value[i], isUnloadAsset);
                }
            }
        }
        
        public virtual void UnloadUnused(ResLoadArg loadArg, bool isUnloadAsset)
        {
            string cachePath = AppendCachePath(loadArg.relativePath, loadArg);
            if (_objList.TryGetValue(cachePath, out var listRes))
            {
                for (int i = listRes.Count - 1; i >= 0; i--)
                {
                    Unload(cachePath, listRes[i], isUnloadAsset);
                }
            }
        }
        
        protected virtual void Unload(string catchPath, Object obj, bool isUnloadAsset=false)
        {
            if (_objList.TryGetValue(catchPath, out var objs))
            {
                objs.Remove(obj);
            }
            if (_objInfos.TryGetValue(catchPath, out var objInfo))
            {
                objInfo.cacheCount -= 1;
                objInfo.unloadNum += 1;
            }
            
            _resLoader?.Unload(_loadType, obj, isUnloadAsset);
        }
        
        public virtual Object Get(ResLoadArg arg)
        {
            if (!_enable)
            {
                return null;
            }

            if (_resLoader == null)
            {
                LogProxy.LogFatal("【战斗】【严重错误】资源加载器为空，无法加载资源，请检查！");
                return null;
            }
            string cachePath = AppendCachePath(arg.relativePath, arg);
            if (string.IsNullOrEmpty(cachePath))
            {
                LogProxy.LogErrorFormatWithTag(LogTag.BattleRes, $"战斗资源对象池，get对象时cachePath不能为空，原始路径：{arg.relativePath}");
                return null;
            }
            if (!_objList.TryGetValue(cachePath, out var list))
            {
                list = new List<Object>();
                _objList[cachePath] = list;
            }

            int count = list.Count;
            Object obj = null;
            if (count > 0)
            {
                obj = list[count - 1];
                list.RemoveAt(count - 1);
                if (obj == null)
                    LogProxy.LogErrorFormat("战斗缓存池中的资源被未知销毁，path={0}, name={1}，请检查！", arg.relativePath, arg.name);
            }
            if (!_objInfos.TryGetValue(cachePath, out var info))
            {
                info = new BattleObjInfo();
                _objInfos[cachePath] = info;
            }
            
            if (obj == null)
            {
                if (IsNeedLoadError())
                {
                    bool isPreLoaded = _poolMgr.HasPreloaded(cachePath, _type);
                    if (isPreLoaded)
                    {
                        var str = string.Format("战斗加载(对象不够) Type={0}, Path={1}", _type, cachePath);
                        LogProxy.LogWarningFormatWithTag(LogTag.BattleRes, str);
                    }
                }
                obj = _resLoader.Load(arg);
                
                // 只统计真正load次数
                if (arg.isPreload)
                    info.preloadNum += 1;
                else
                    info.loadNum += 1;
            }
            info.cacheCount = list.Count;
            info.useTime = (int)Time.realtimeSinceStartup;
            if (!arg.isPreload)
                info.curMinCacheNum = math.min(info.cacheCount, info.curMinCacheNum);
            
            OnGet(obj, arg.name);
            TryStreaming();
            return obj;
        }

        public virtual void Recycle(Object obj, ResLoadArg arg)
        {
            string cachePath = AppendCachePath(arg.relativePath, arg);
            if (!_objList.TryGetValue(cachePath, out var list))
            {
                //理论上由对象池创建过对象后，对象列表一定存在, 如果为空，则表明对象不属于对象池
                LogProxy.LogErrorFormat("对象池回收错误：对象列表不存在，回收的对象不属于对象池。path={0}", arg.relativePath);
                return;
            }
            int curCachedNum = list.Count;
            var resConfig = BattleResConfig.GetResConfig(_type);
            if (curCachedNum >= resConfig.maxCacheCount)
            {
                // 超过池的最大容量限制，则直接卸载，不在缓存
                if (_objInfos.TryGetValue(cachePath, out var objInfo))
                    objInfo.unloadNum += 1;
                _resLoader?.Unload(_loadType, obj);
                return;
            }
            list.Add(obj);
            OnRecycle(obj);
            TryStreaming();
            // 统计信息
            if (!_objInfos.TryGetValue(cachePath, out var info))
            {
                info = new BattleObjInfo();
                _objInfos[cachePath] = info;
            }
            info.cacheCount = list.Count;
            info.useTime = (int)Time.realtimeSinceStartup;
        }
        
        protected string AppendCachePath(string path, ResLoadArg arg)
        {
            string cachePath = path;
            if (arg.type == BattleResType.Hero && arg.IsValidActorID())
            {
                cachePath += arg.suitID + "_" + arg.lod;
            }
            return cachePath;
        }
        
        protected virtual void OnGet(Object obj, string name)
        {
        }

        protected virtual void OnRecycle(Object obj)
        {
            GameObject go = obj as GameObject;
            // 编辑器下关闭游戏，可能obj为空，导致报错
            if (go == null)
                return;
            if (obj.GetInstanceID() < 0) // 实例化出的obj，可以在Hierarchy上看到
            {
                go.transform.SetParent(poolTrans, false);
            }
        }
		
		// TODO 思考， preloadNum 是否有可能要支持 0
        public bool IsObjCached(string path)
        {
            if (_objInfos.TryGetValue(path, out var info))
            {
                return info.preloadNum > 0;
            }
            return false;
        }
        
        private bool IsNeedLoadError()
        {
            if (!Application.isPlaying)
            {
                return false;
            }
            if (!BattleResMgr.isDynamicLoadErring)
            {
                return false;
            }
            
            BattleResConfigItem cfg = BattleResConfig.GetResConfig(_type);
            return cfg == null || !cfg.disableLoadError;
        }

        public void EditorWriteInfoToFile(StreamWriter writer)
        {
            foreach (var item in _objInfos)
            {
                BattleObjInfo info = item.Value;
                int maxUsedNum = info.preloadNum + info.loadNum - info.curMinCacheNum;
                maxUsedNum = Mathf.Max(maxUsedNum, 0);
                BattleResConfigItem cfg = BattleResConfig.GetResConfig(_type);
                //title信息： 资源类型,文件夹位置,资源Path,预加载数量,使用峰值,战斗中加载数量,当前缓存数量
                // 固定长度，左对齐
                string str = string.Format("{0}, {1},{2,-70}, {3,-2}, {4,-2}, {5,-2}, {6}"
                    , _type, cfg.dir,item.Key,info.preloadNum, maxUsedNum,info.loadNum,info.cacheCount);
                writer.WriteLine(str);
            }

            // writer.WriteLine("--------------------");
            // var poolInfo =  string.Format("-----缓存池类型:{0}, 缓存池对象数量：{1},缓存池特效对象数量：{2},缓存池类型：{3}", _type, GetCacheCount(), GetParticleNum(), this.GetType());
            // if (this is StreamingGOPool)
            // {
            //     var pool = this as StreamingGOPool;
            //     poolInfo += " 缓存池最大缓存数量:" + pool.GetMaxObjNum();
            // }
            // else if(this is StreamingVsbGOPool)
            // {
            //     var pool = this as StreamingVsbGOPool;
            //     poolInfo += " 缓存池最大缓存数量:" + pool.GetMaxObjNum();
            // }
            // writer.WriteLine(poolInfo);
            // foreach (var objs in _objList)
            // {
            //     var Info =  string.Format("-----缓存池类型:{0}, 缓存池对象名字：{1}, 缓存池对象数量：{2},", _type, objs.Key, objs.Value.Count);
            //     writer.WriteLine(Info);
            // }
            // writer.WriteLine("--------------------");
        }
    }

    /// <summary>
    /// streaming 机制
    /// </summary>
    public partial class BattleResPool
    {
        private int m_maxObjNum;
        private bool m_enableStreaming;
        
        public int maxObjNum => m_maxObjNum;
        public bool enableStreaming => m_enableStreaming;
        
        public void TryEnableStreaming()
        {
            m_maxObjNum = GetPoolSize(_type);
            m_enableStreaming = m_maxObjNum > 0;
        }

        // streaming 
        public void TryStreaming()
        {
            if (m_enableStreaming && Check())
            {
                TrimPool(0.1f);
            }
        }
        
        /// <summary>
        /// 获取缓存资源的大小
        /// </summary>
        /// <returns></returns>
        private int GetCacheCount()
        {
            int count = 0;
            foreach (var objInfo in _objInfos)
            {
                count += objInfo.Value.cacheCount;
            }
            return count;
        }
        
        /// <summary>
        /// 检查当前缓存池对象是否超出限制
        /// </summary>
        /// <returns></returns>
        private bool Check()
        {
            if (GetCacheCount() > m_maxObjNum)
                return true;
            return false;
        }
        
        public int GetParticleNum()
        {
            int count = 0;
            foreach (var objInfo in _objList)
            {
                foreach (var obj in objInfo.Value)
                {
                    if (obj != null && obj is GameObject)
                    {
                        var gameobj = obj as GameObject;
                        if (gameobj == null)
                            continue;
                        var particles = gameobj.GetComponentsInChildren<ParticleSystem>();
                        if (particles != null)
                            count += particles.Length;
                    }
                }
            }
            return count;
        }

        /// <summary>
        /// 减少缓存池 
        /// </summary>
        /// <param name="percent"></param>
        private void TrimPool(float percent)
        {
            if (Battle.Instance == null || !Battle.Instance.isBegin)
            {
                TrimNumPool(percent);
            }
            else
            {
                TrimTimePool(percent);
            }
        }


        /// <summary>
        /// 以数量百分比减少缓存池 
        /// </summary>
        /// <param name="percent"></param>
        private void TrimNumPool(float percent)
        {
            if(_objList.Values.Count <= 0)
                return;
            
            var curNum = GetCacheCount();
            int subNum = (int)(curNum * percent);
            
            //先百分比减少缓存数量
            foreach (var objs in _objList)
            {
                var subValue = objs.Value.Count * percent;
                if(subValue < 1)
                    continue;

                for (int i = 0; i < subValue; i++)
                {
                    
                    if(objs.Value.Count <= 1)
                        continue;
                    var removeObj = objs.Value[objs.Value.Count - 1];
                    if (removeObj == null)
                        continue;
                    
                    //删除末尾的元素
                    Unload(objs.Key, removeObj);
                }
            }

            //再减少数量最大的缓存对象
            int curSubNum = curNum - GetCacheCount();
            if (subNum > curSubNum)
            {
                for (int i = 0; i < subNum - curSubNum; i++)
                {
                    List<Object> maxList = null;
                    string key = "";
                    foreach (var objs in _objList)
                    {
                        if (maxList == null || maxList.Count < objs.Value.Count)
                        {
                            maxList = objs.Value;
                            key = objs.Key;
                        }
                    }
                                        
                    if(maxList == null || maxList.Count <= 1)
                        continue;
                    var removeObj = maxList[maxList.Count - 1];
                    if (removeObj == null)
                        continue;
                    
                    //删除末尾的元素
                    Unload(key, removeObj);
                }
            }
        }

        /// <summary>
        /// 以时间百分比减少缓存池 
        /// </summary>
        /// <param name="percent"></param>
        private void TrimTimePool(float percent)
        {
            if (_objList.Values.Count <= 0)
                return;

            var curNum = GetCacheCount();
            int subNum = (int) (curNum * percent);

            //减少时间最小的缓存对象
            for (int i = 0; i < subNum; i++)
            {
                BattleObjInfo maxInfo = null;
                string maxKey = "";

                foreach (var objs in _objInfos)
                {
                    if (maxInfo == null || maxKey == "")
                    {
                        maxInfo = objs.Value;
                        maxKey = objs.Key;
                    }
                    if (maxInfo.useTime > objs.Value.useTime && objs.Value.cacheCount > 1)
                    {
                        maxInfo = objs.Value;
                        maxKey = objs.Key;
                    }
                    //如果使用时间相等 找缓存数量最多的
                    else if (maxInfo.useTime == objs.Value.useTime && objs.Value.cacheCount > maxInfo.cacheCount)
                    {
                        maxInfo = objs.Value;
                        maxKey = objs.Key;
                    }
                }

                var tempList = _objList[maxKey];
                if (!_objList.ContainsKey(maxKey) || tempList.Count <= 1)
                    continue;
                var removeObj = tempList[tempList.Count - 1];
                if (removeObj == null)
                    continue;
                    
                //删除末尾的元素
                Unload(maxKey, removeObj);
            }
        }
        
        private int GetPoolSize(BattleResType type)
        {
            if (TbUtil.battleConsts == null)
                return 0;
            
            int memory = BattleUtil.GetMemorySizeLevel();
                
            switch (type)
            {
                case BattleResType.FX:
                case BattleResType.AllFX:
                    if (memory < TbUtil.battleConsts.PoolFxNums.Length)
                    {
                        return TbUtil.battleConsts.PoolFxNums[memory];
                    }
                    break;
                case BattleResType.HurtFX:
                    if (memory < TbUtil.battleConsts.PoolHurtFxNums.Length)
                    {
                        return TbUtil.battleConsts.PoolHurtFxNums[memory];
                    }
                    break;
                case BattleResType.TimelineFx:
                    if (memory < TbUtil.battleConsts.PoolTimelineFxNums.Length)
                    {
                        return TbUtil.battleConsts.PoolTimelineFxNums[memory];
                    }
                    break;
            }

            return 0;
        }
    }
}