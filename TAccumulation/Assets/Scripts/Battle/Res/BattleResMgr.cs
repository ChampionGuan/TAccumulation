using System;
using System.Collections.Generic;
using System.Linq;
using Framework;
using PapeGames.X3;
using UnityEngine;
using XAssetsManager;
using Object = UnityEngine.Object;

namespace X3Battle
{
    public class BattleResMgr
    {
        private static BattleResMgr _instance = new BattleResMgr();
        private BattlePoolMgr _poolMgr;
        private ResTags _resTags;
        private List<Object> _ListNewObj;
        protected Dictionary<Object, ResDesc> _obj2ResDesc;

        public static BattleResMgr Instance => _instance;
        public BattlePoolMgr poolMgr => _poolMgr;
        public ResTags ResTags => _resTags;
        
        //战斗resMgr模块内，加载行为发生时是否打印错误日志
        public static bool isDynamicLoadErring = false;
        // 非战斗resMgr模块内，加载行为发生时是否打印错误日志,例如武器部件，UI依赖的材质资源
        public static bool isDynamicBottomLoadErring = false;

        public bool isInit => _poolMgr.isInit;

        public BattleResMgr()
        {
            _Reset();
        }
        
        private void _Reset()
        {
            _poolMgr = new BattlePoolMgr(CreateResLoader);
            _ListNewObj = new List<Object>();
            _obj2ResDesc = new Dictionary<Object, ResDesc>();
            _resTags = new ResTags();
        }

        public void TryInit()
        {
            if (_poolMgr.isInit)
                return;
            XResourcesImp.OnResourceLoadNotification += XResourcesImpOnOnResourceLoadNotification;
            _poolMgr.Init();
        }
        
        public void TryUninit()
        {
            if (!_poolMgr.isInit && _ListNewObj.Count <= 0)
                return;
            _poolMgr.UnInit();
            foreach (var obj in _ListNewObj)
            {
                BattleUtil.DestroyObj(obj as GameObject);
            }
            _ListNewObj.Clear();
            foreach (var item in _obj2ResDesc)
            {
                var resDesc = item.Value;
                if (resDesc.count <= 0)
                    continue;
                if (Application.isPlaying)
                {
                    LogProxy.LogErrorFormat("资源泄露报错：有对象残留，但已被强制卸载。type={0}, path={1}, name={2}",
                        resDesc.type, resDesc.path, resDesc.name
                    );
                }
                BattleResLoader loader = new BattleResLoader();
                for (int i = 0; i < resDesc.count; i++)
                {
                    BattleResConfigItem cfg = BattleResConfig.GetResConfig(resDesc.type);
                    loader.Unload(cfg.loadType, item.Key);
                }
            }
            _obj2ResDesc.Clear();
            XResourcesImp.OnResourceLoadNotification -= XResourcesImpOnOnResourceLoadNotification;
            _Reset();
        }

        private void OnLoad(Object obj, ResLoadArg arg, LoadedResInfo resInfo)
        {
            // 资源分析阶段的资源加载，不检测该资源是否分析过，因为是正在分析
            if (_resTags.isInit)
                CheckResIsAnalyzed(arg, obj);
            
            if (obj == null)
                return;
            
            // 设置 ResDesc 对象统计
            if (!_obj2ResDesc.ContainsKey(obj))
            {
                _obj2ResDesc[obj] = new ResDesc()
                {
                    path = arg.relativePath,
                    type = arg.type,
                    suitID = arg.suitID,
                    count = 0,
                    loadArg = arg,
                };
            }
            ResDesc des = _obj2ResDesc[obj];
            des.count += 1;
            des.loadedCount++;
        }

        private void OnUnLoad(Object obj, bool isUnLoadAsset)
        {
            if (obj == null)
                return;
            
            if (!_obj2ResDesc.TryGetValue(obj, out var des))
                return;
            
            des.count--;
            if (des.count <= 0 && isUnLoadAsset)
            {
                BattleUtil.ReleasePreloadRef(des.path, des.type);
                _obj2ResDesc.Remove(obj);
                XResources.UnloadUnusedLoaders();
                LogProxy.LogFormat("资源被真正卸载掉，不在占用内存。Path:{0}, type:{1}", des.path, des.type);
            }
        }
        
        private void CheckResIsAnalyzed(ResLoadArg arg, Object loadObj)
        {
            if (!Application.isPlaying)
                return;
            var type = arg.type;
            if (type == BattleResType.Hero) // hero是一个分析器，而非一个资源
                return;
            
            var relativePath = arg.relativePath;
            bool isResAnalyzed = ResTags.IsResAnalyzed(type, relativePath);
            if (!isResAnalyzed)
            {
                string fullPath = BattleUtil.GetResPath(relativePath, type);
                if (Application.isEditor || loadObj == null)
                {
                    var str = string.Format("战斗加载(资源分析遗漏)*Type={0}*Path={1}*", type, fullPath);
                    LogProxy.LogErrorFormatWithTag(LogTag.BattleRes, str);
                    return;
                }
                // obj != null
                var str2 = string.Format("资源分析离线数据生成遗漏*Type={0}*Path={1}*", type, fullPath);
                LogProxy.LogErrorFormatWithTag(LogTag.BattleRes, str2);
                return;
            }
        }
        
        private IResLoader CreateResLoader(BattleResType type)
        {
            var item = BattleResConfig.GetResConfig(type);
            if (item == null)
                return null;
            IResLoader loader = null;
            switch (item.loaderType)
            {
                case BattleResLoaderType.CommonLoader:
                    loader = new BattleResLoader();
                    break;
                case BattleResLoaderType.BattleFxLoader:
                    loader = new BattleFxLoaderPro();
                    break;
                case BattleResLoaderType.InstAssetLoader:
                    loader = new BattleInstantiateAssetLoader();
                    break;
                case BattleResLoaderType.SameResLoadOnceLoader:
                    loader = new SameResLoadOnceLoader();
                    break;
                default:
                    return null;
            }

            loader.eventOnLoad += OnLoad;
            loader.eventOnUnLoad += OnUnLoad;
            return loader;
        }
        
        private void XResourcesImpOnOnResourceLoadNotification(ResourceLoadType type, string path, bool loadFirstly)
        {
            if (!isDynamicBottomLoadErring)
            {
                return;
            }

            if (!loadFirstly)
            {
                return;
            }

            if (type != ResourceLoadType.LoadScene)
            {
                return;
            }

            string strErr = $"战斗中-发现资源动态加载（底层接口）：path={path}";
            if (Application.isEditor)
            {
                LogProxy.LogErrorFormatWithTag(LogTag.BattleRes, strErr);
            }
            else
            {
                LogProxy.LogWarningFormatWithTag(LogTag.BattleRes, strErr);
            }
        }
        
        public void UnloadUnusedAll(bool unloadAsset = false)
        {
            if (!_poolMgr.isInit)
                return;
            _poolMgr.UnloadUnusedAll(unloadAsset);
        }
        
        public void UnloadUnused(BattleResType type, bool unloadAsset)
        {
            if (!_poolMgr.isInit)
                return;
            _poolMgr.UnloadUnused(type, unloadAsset);   
        }

        /// <summary>
        /// 卸载无用的指定tag的资源
        /// </summary>
        /// <param name="tag"></param>
        /// <param name="equalTag">true:限定资源只有该Tag, false:资源有该Tag</param>
        /// <param name="unloadAsset">卸载从ab中load出的asset</param>
        public void UnloadUnusedTagRes(BattleResTag tag, bool equalTag=true, bool unloadAsset=false)
        {
            // 获取该资源，依赖的全部资源
            var dependRes = _resTags.GetDependRes(tag);
            if (dependRes == null)
            {
                return;
            }
            
            // 需要卸载的全部资源
            HashSet<string> allResPath = new HashSet<string>() { };
            foreach (var item in dependRes)
            {
                if (equalTag && !item.EqualTag(tag))
                {
                    continue; // 限定只有tag 的资源
                }
                allResPath.Add(item.path);
            }
            
            // 需要卸载的全部资源的描述信息
            List<ResDesc> allResDesc = new List<ResDesc>();
            foreach (var item in _obj2ResDesc)
            {
                if (allResPath.Contains(item.Value.path))
                {
                    allResDesc.Add(item.Value);
                }
            }
            
            for (int i = allResDesc.Count - 1; i >= 0; i--)
            {
                _poolMgr.UnloadUnused(allResDesc[i].loadArg, unloadAsset);
            }
        }
        
        public bool IsExists(string relativePath, BattleResType type)
        {
            string fullPath = BattleUtil.GetResPath(relativePath, type);
            return Res.IsAssetFileExist(fullPath);
        }

        public ResDesc GetObjResDesc(Object obj)
        {
            if (obj == null)
                return null;
            _obj2ResDesc.TryGetValue(obj, out var des);
            return des;
        }
        
        // Lua代码有使用
        public Object LoadObj(ResDesc resDesc, bool isPreload = false)
        {
            // TODO for付强 整理该处业务脏代码.
            string path = resDesc.path;
            int lod = BattleCharacterMgr.GetGlobalLOD();
            if (resDesc.isUltraModel)
            {
                if (!string.IsNullOrEmpty(path))
                {
                    path = path.Replace("_UltraModel", "");
                }
                
                TbUtil.TryGetCfg(resDesc.suitID, out ActorSuitCfg suitCfg);
                lod = BattleUtil.GetHeroLOD(suitCfg.ScoreID != BattleConst.GirlScoreID ? HeroType.Boy : HeroType.Girl);
            }

            var resLoadArg = new ResLoadArg()
            {
                relativePath = path,
                type = resDesc.type,
                name = resDesc.name,
                suitID = resDesc.suitID,
                isPreload = isPreload,
                lod = lod,
            };
            
            return Load<Object>(resLoadArg);
        }

        // Lua代码有使用
        public bool UnloadObj(Object obj)
        {
            return Unload(obj);
        }

        public T Load<T>(string relativePath, BattleResType type, string name = null, object arg = null, bool isPreload = false)
            where T:Object
        {
            var resLoadArg = new ResLoadArg()
            {
                relativePath = relativePath,
                type = type,
                name = name,
                suitID = Convert.ToInt32(arg),
                isPreload = isPreload,
                lod = BattleCharacterMgr.GetGlobalLOD(),
            };
            return Load<T>(resLoadArg);
        }
        
        public T Load<T>(ResLoadArg arg) where T:Object
        {
            Object obj = _poolMgr.Get(arg);
            return obj as T;
        }

        public FxPlayer LoadFxPlayer(string relativePath, BattleResType type)
        {
            var obj = Load<GameObject>(relativePath, type);
            return poolMgr.GetFxPlayer(type, obj);
        }

        public bool Unload<T>(T obj)where T : Object
        {
            if (obj == null)
            {
                LogProxy.LogError("BattleResMgr不支持unload空对象");
                return false;
            }
            if (_ListNewObj.Contains(obj))
            {
                BattleUtil.DestroyObj(obj as GameObject);
                _ListNewObj.Remove(obj);
                return true;
            }
            ResDesc des = GetObjResDesc(obj);
            if (des == null)
            {
                LogProxy.LogErrorFormat("非BattleResMgr加载obj:{0},无法使用其卸载", obj.name);
                return false;
            }
            _poolMgr.Recycle(des, obj);
            return true;
        }
        

        public GameObject LoadActorGO(ModelCfg config, int lod)
        {
            if (string.IsNullOrEmpty(config.PrefabName) && config.Type != ActorType.Hero)
            {
                var newObj = new GameObject(string.Format("{0}_{1}", config.Name, config.SuitID));
                _ListNewObj.Add(newObj);
                return newObj;
            }
            ResDesc des = BattleUtil.GetActorResDesc(config);
            // Hero 的加载，非Res加载
            if (des.type != BattleResType.Hero && !IsExists(des.path, des.type))
            {
                var fullPath = BattleUtil.GetResPath(des.path, des.type);
                PapeGames.X3.LogProxy.LogErrorFormat("资源缺失,类型：{0}  全路径：{1}", des.type, fullPath);
                var newObj = new GameObject(string.Format("{0}_{1}", config.Name, config.SuitID));
                _ListNewObj.Add(newObj);
                return newObj;
            }
            var resLoadArg = new ResLoadArg()
            {
                relativePath = des.path,
                type = des.type,
                name = des.name,
                suitID = des.suitID,
                isPreload = false,
                lod = lod,
            };
            GameObject obj = Load<GameObject>(resLoadArg);
            if (obj)
            {
                if (des.type == BattleResType.Hero)   
                {
                    // hero类型加载进来，将战斗分支权重设置为1（后期如果需要权重过渡过程，此处需要移除
                    PlayableAnimationManager.Instance()?.SetBlendingWeight(obj, EStaticSlot.Battle, 1);
                }
                return obj;
            }
            obj = new GameObject(string.Format("{0}_{1}", config.Name, config.SuitID));
            _ListNewObj.Add(obj);
            return obj;
        }

        public void UnloadActorGO(GameObject obj, ModelCfg config)
        {
            if (string.IsNullOrEmpty(config.PrefabName) && config.Type != ActorType.Hero)
            {
                BattleUtil.DestroyObj(obj);
            }
            else
            {
                Unload(obj);
            }
        }

        public void WriteFxInfoToFile()
        {
            string fullPath = Application.persistentDataPath + "/FxSizeInfo.csv";
            using (System.IO.StreamWriter writer = new System.IO.StreamWriter(fullPath, false))
            {
                var head = "FxType,Name,ParticleSystem,Count,Size,Total Size";
                writer.WriteLine(head);

                // var fxPool = BattleResMgr.Instance.poolMgr.pools[BattleResType.FX] as FxResVisiblePool;
                // var fxType = "Battle All Fx";
                // Debug.LogError(fxType + fxPool.objList.Count);
                // foreach (var item in fxPool.objList)
                // {
                //     var size = 0f;
                //     dicResFxCopys.TryGetValue(item.Value)
                //     var pss = ( as GameObject)?.GetComponentsInChildren<ParticleSystem>();
                //     foreach (var ps in pss)
                //     {
                //         size += UnityEngine.Profiling.Profiler.GetRuntimeMemorySizeLong(ps);
                //     }
                //     var count = fxPool.objInfos[item.Key].preloadNum + fxPool.objInfos[item.Key].loadNum - fxPool.objInfos[item.Key].unloadNum;
                //     var info = $"{fxType},{item.Key},{pss.Length},{count},{size / 1024f: 0.00},{size / 1024f * count: 0.00}";
                //     writer.WriteLine(info);
                //     Debug.LogError(info);
                // }

                // fxPool = BattleResMgr.Instance.poolMgr.pools[BattleResType.HurtFX] as FxResVisiblePool;
                // fxType = "Hurt Fx";
                // Debug.LogError(fxType + fxPool.objList.Count);
                // foreach (var item in fxPool.objList)
                // {
                //     var size = 0f;
                //     var pss = ((fxPool.resLoader as BattleResCopyLoader).dicResCopys[item.Key] as GameObject).GetComponentsInChildren<ParticleSystem>();
                //     foreach (var ps in pss)
                //     {
                //         size += UnityEngine.Profiling.Profiler.GetRuntimeMemorySizeLong(ps);
                //     }
                //     var count = fxPool.objInfos[item.Key].preloadNum + fxPool.objInfos[item.Key].loadNum - fxPool.objInfos[item.Key].unloadNum;
                //     var info = $"{fxType},{item.Key},{pss.Length},{count},{size / 1024f: 0.00},{size / 1024f * count: 0.00}";
                //     writer.WriteLine(info);
                //     Debug.LogError(info);
                // }
                //
                // fxPool = BattleResMgr.Instance.poolMgr.pools[BattleResType.TimelineFx] as FxResVisiblePool;
                // fxType = "Timeline Fx";
                // Debug.LogError(fxType + fxPool.objList.Count);
                // foreach (var item in fxPool.objList)
                // {
                //     var size = 0f;
                //     var pss = ((fxPool.resLoader as BattleResCopyLoader).dicResCopys[item.Key] as GameObject).GetComponentsInChildren<ParticleSystem>();
                //     foreach (var ps in pss)
                //     {
                //         size += UnityEngine.Profiling.Profiler.GetRuntimeMemorySizeLong(ps);
                //     }
                //     var count = fxPool.objInfos[item.Key].preloadNum + fxPool.objInfos[item.Key].loadNum - fxPool.objInfos[item.Key].unloadNum;
                //     var info = $"{fxType},{item.Key},{pss.Length},{count},{size / 1024f: 0.00},{size / 1024f * count: 0.00}";
                //     writer.WriteLine(info);
                //     Debug.LogError(info);
                // }
                
            }
        }
    }
}