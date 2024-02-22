using System;
using System.Collections.Generic;
using System.IO;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.VFX;
using Object = UnityEngine.Object;

namespace X3Battle
{
    public abstract class ResAnalyzer
    {
        // TODO for 付强
        public static bool IsSkipSkinReplace { get; set; }
        private static List<ResAnalyzer> _cache; // 资源分析时，cache已经创分析过的分析器
        private static AnalyzeRunEnv _analyzeRunEnv; // 分析器执行环境, 默认RunTimeLogic
        private ResModule _resModule;
        private ResModule _parent;

        public static AnalyzeRunEnv AnalyzeRunEnv
        {
            get => _analyzeRunEnv;
            set => _analyzeRunEnv = value;
        }
        public static bool isDebugModel { get; set; }
        private static FxCfg _fxCfg;

        public static FxCfg FxCfg => _fxCfg;
        public ResModule resModule => _resModule;
        public abstract int ResID { get; } // 唯一资源id，派生类如果没有可返回0
        
        public ResAnalyzer(ResModule parent)
        {
            _parent = parent;
            if (_cache == null)
                _cache = new List<ResAnalyzer>();
            _cache.Add(this);
        }
        
        protected virtual void InitResModule()
        {
            _resModule = new ResModule(this);
            if (_parent != null)
            {
                _parent.AddChild(_resModule);
            }
        }

        /// <summary>
        /// 快速分析，复制一个相同的分析器分析出的数据。优点：优化分析耗时， 避免分析器循环时，逻辑死循环
        /// </summary>
        /// <returns></returns>
        private bool TryQuicklyAnalyze()
        {
            ResAnalyzer sameAnalyzer = null;
            foreach (var analyzer in _cache)
            {
                if (analyzer == this)
                    continue; // 不能自己copy自己的数据
                if (!analyzer.resModule.AnalyzeSuccess())
                    continue; // 需要分析成功， 有可能id配置异常，没有对应的cfg导致分析没有成功。 此时是空数据
                if (!analyzer.IsSameData(this)) 
                    continue; // 数据相同
                // 做两遍相同判断，排除继承关系的影响
                if (!IsSameData(analyzer))  
                    continue; 
                sameAnalyzer = analyzer;
                break;
            }
            if (sameAnalyzer == null)
                return false;
            _resModule = sameAnalyzer.resModule.Clone(this);
            _parent?.AddChild(_resModule);
            return true;
        }

        private bool TryReadOfflineData()
        {
            if (AnalyzeRunEnv != AnalyzeRunEnv.RunTimeOffline)
            {
                // 只有runtime才允许读取离线数据
                return false;
            }
            string typeName = this.GetType().Name;
            if (!AnalyzeDefine.offlineAnalyzeTypes.Contains(typeName))
            {
                return false;
            }
            // 此处设计：支持id类型的分析器，也支持BattleCommonResAnalyzer类型的唯一分析器
            string fileName = ResID.ToString();
            if (ResID == 0)
            {
                fileName = typeName;
            }
            string filePath = typeName + "/" + fileName;
            if (!IsNeedUseOfflineData(filePath))
            {
                return false;
            }
            _resModule = MpUtil.Deserialize<ResModule>(filePath);
            if (_resModule == null)
                LogProxy.LogErrorFormat("资源离线分析数据:{0}不存在，会逻辑实时分析", filePath);
            
            return _resModule != null;
        }

        /// <summary>
        /// 是否需要使用资源分析离线数据
        /// </summary>
        /// <param name="relativePath">离线数据相对路径</param>
        /// <returns></returns>
        public static bool IsNeedUseOfflineData(string relativePath)
        {
            if (AnalyzeRunEnv != AnalyzeRunEnv.RunTimeOffline)
            {
                return false;
            }
# if UNITY_EDITOR
            // 启动器启动战斗时，资源分析是否使用离线分析模式
            bool isUseOffline = PlayerPrefs.GetInt("keyUseOfflineAnalyze", 1) == 1;
            if (!isUseOffline)
            {
                return false;
            }
            
            bool isFileExit = MpUtil.FileExists(relativePath);
            if (Application.isPlaying)
            {
                if (!isFileExit)
                {
                    // Editor 下的主线战斗不支持，离线数据实时生成，仅仅支持预先生成
                    // 所以如果文件不存在， 也不是错误只是没有提前生成。 实时分析即可
                    return false;
                }
            }
# endif
            return true;
        }

        private bool AnalyzePrepare()
        {
            if (Application.isPlaying)
            {
                BattleResMgr.Instance.TryInit();
            }
            
            return true;
        }

        public void Analyze()
        {
            if (!AnalyzePrepare())
            {
                return;
            }
            
            // 优先使用离线分析数据
            if (TryReadOfflineData())
            {
                _parent?.AddChild(_resModule);
            }
            else
            {
                if (TryQuicklyAnalyze())
                    return; // 快速分析Copy到的数据是一个最为精确的数据(已经条件分析过了). 无需在条件分析
                
                if (_resModule == null)
                    InitResModule();
                
                DirectAnalyze();
            }
            ConditionAnalyze();
            OnEndAnalyze();
        }

        /// <summary>
        /// 实时逻辑分析
        /// </summary>
        protected abstract void DirectAnalyze();

        /// <summary>
        /// 分析结束的时机
        /// </summary>
        protected virtual void OnEndAnalyze() { }

        /// <summary>
        /// 条件分析，无法直接通过一个id分析，还需其他条件
        /// </summary>
        protected virtual void ConditionAnalyze()
        {
            if (resModule == null)
            {
                return;
            }
            ResAnalyzeUtil.ConditionAnalyze(resModule);
        }
        
        public static void AnalyzeFromLoadedRes<T2>(string path, BattleResType resType, Action<T2, ResModule> onLoaded, ResModule resModule) where T2 : Object
        {            
            bool isLoadGlobalBlackboard = _TryLoadGlobalBlackboard(resType, out var gameObject);
            if (isLoadGlobalBlackboard && gameObject == null)
            {
                LogProxy.LogError("【战斗程序错误】全局黑板加载失败");
                return;
            }
            
            T2 go = BattleResMgr.Instance.Load<T2>(path, resType, isPreload:true);
            if (go == null)
            {
                return;
            }
            onLoaded(go, resModule);
            BattleResMgr.Instance.Unload(go);
        }
		
        public static void AnalyzeFromLoadedRes<T2>(string path, BattleResType resType, Action<T2, ResModule, object> onLoaded, ResModule resModule, object arg = null) where T2 : Object
        {
            bool isLoadGlobalBlackboard = _TryLoadGlobalBlackboard(resType, out var gameObject);
            if (isLoadGlobalBlackboard && gameObject == null)
            {
                LogProxy.LogError("【战斗程序错误】全局黑板加载失败");
                return;
            }
            
            T2 go = BattleResMgr.Instance.Load<T2>(path, resType, isPreload:true);
            if (go == null)
            {
                return;
            }
            onLoaded(go, resModule, arg);
            BattleResMgr.Instance.Unload(go);
        }

        public abstract bool IsSameData(ResAnalyzer other);
        
        public static void ClearCache()
        {
            _cache = null;
            _fxCfg = null;
        }

        private static bool _TryLoadGlobalBlackboard(BattleResType resType, out GameObject gameObject)
        {
            gameObject = null;
            if (resType == BattleResType.Fsm || resType == BattleResType.TriggerGraph || resType == BattleResType.AITree || resType == BattleResType.Flow)
            {
                gameObject = BattleResMgr.Instance.Load<GameObject>(BattleConst.BattleGlobalBlackboard, BattleResType.GlobalBlackboard, isPreload: true);
                return true;
            }

            return false;
        }
        
        public Dictionary<BattleResType, Dictionary<string, ResDesc>> GetResult()
        {
            var result = new Dictionary<BattleResType, Dictionary<string, ResDesc>>();
            ResAnalyzeUtil.GetResult(result, resModule);
            return result;
        }
        
        //分析特效音效
        public static void AnalyzeFxGo(string path, BattleResType type, ResModule resModule)
        {
            if (IsNeedUseOfflineData(FxCfg.OfflineDataFilePath))
            {
                // 使用特效音效,SVC 的离线数据
                _fxCfg = _fxCfg ?? FxCfg.DeSerialize();
                if (_fxCfg == null)
                    LogProxy.LogError("特效声音离线数据不存在，将会转为实时分析,会增加战斗loading时长");
                else
                {
                    var sounds = _fxCfg.GetFxSound(path);
                    if (sounds != null)
                    {
                        foreach (var sound in sounds)
                            resModule.AddResultByPath(sound, BattleResType.FxAudio);
                    }
                    resModule.AddResultByPath(_fxCfg.GetFxSVC(path, true), BattleResType.HWVFXSVC);
                    resModule.AddResultByPath(_fxCfg.GetFxSVC(path, false), BattleResType.VFXSVC);
                    return;
                }
            }
            // 不使用离线数据时， 或者离线数据不存在时， 使用实时分析
            var go = BattleResMgr.Instance.Load<GameObject>(path, type, isPreload:true);
            if (go == null)
                return;
            BattleResMgr.Instance.Unload(go);
            _fxCfg = _fxCfg ?? new FxCfg();
            // 分析声音
            if (go.TryGetComponent<FxPlayer>(out var fx))
            {
                if (fx.sounds != null)
                {
                    // 这里的cache用于生成离线数据
                    _fxCfg.AddFxSound(path, fx.sounds);
                    foreach (var sound in fx.sounds)
                        resModule.AddResultByPath(sound, BattleResType.FxAudio);
                }
            }
            // 分析vfx
            var vfxs = go.GetComponentsInChildren<VisualEffect>();
            if (vfxs != null)
            {
                bool isHaveAsset = false;
                for (int i = 0; i < vfxs.Length; i++)
                {
                    if (vfxs[i].visualEffectAsset)
                    {
                        isHaveAsset = true;
                        break;
                    }
                }
                if (isHaveAsset)
                {
                    string fxFullPath = BattleUtil.GetResPath(path, type);
                    string fullName = SVCHelper.GetFxComonVfxSVCPath(fxFullPath);
                    string hwfullName = SVCHelper.GetFxHWVfxSVCPath(fxFullPath);
                    _fxCfg.AddVfxSVC(path, fullName, hwfullName);
                    resModule.AddResultByPath(fullName, BattleResType.VFXSVC);
                    resModule.AddResultByPath(hwfullName, BattleResType.HWVFXSVC);
                }
            }
            
        }
    }
}