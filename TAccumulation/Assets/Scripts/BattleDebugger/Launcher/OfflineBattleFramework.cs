#if DEBUG_GM || UNITY_EDITOR
using System.Collections;
using System.Reflection;
using Framework;
using PapeGames.X3;
using UnityEngine;
using XLua;

namespace X3Battle
{
    public class OfflineBattleFramework : MonoBehaviour
    {
        private ILuaBridge _luaBridge;
        [SerializeField] private BattleArg _arg;

        public AutoBattle autoTest { get; } = new AutoBattle();

        public BattleArg arg
        {
            get => _arg;
            set => _arg = value;
        }

        private void Awake()
        {
            DontDestroyOnLoad(gameObject);
            StartCoroutine(_Awake());
        }

        private IEnumerator _Awake()
        {
            yield return new WaitForSeconds(0.2f);
            _Startup();
        }

        public void Update()
        {
            autoTest.Update();
            _luaBridge?.Update();
        }

        public void LateUpdate()
        {
            autoTest.LateUpdate();
            _luaBridge?.LateUpdate();
        }

        public void Startup(BattleArg arg)
        {
            _arg = arg;
            _Startup();
        }

        public bool CanReload()
        {
            return _luaBridge != null && _luaBridge.CanReload();
        }

        public void Shutdown()
        {
            _luaBridge?.Shutdown();
        }

        private void _Startup()
        {
            if (!Application.isPlaying)
            {
                // 非热启动战斗时， StartUp在Awake中调用
                return;
            }

            if (_arg == null)
            {
                LogProxy.LogFatal("离线战斗启动失败，缺少BattleArg");
                return;
            }

            // TODO B哥.
            if (_arg.gameplayType == BattleGameplayType.Rogue)
            {
                var localData = BattleUtil.ReadRogueLocalData();
                if (localData != null && BattleRandom.instance == null)
                {
                    // DONE: 初始化随机数. TODO 之后移到Server中.
                    var rogueRandom = new BattleRandom(localData.StepSeed);
                    BattleRandom.instance = rogueRandom;
                }
            }

            var isRestartLuaEnv = PlayerPrefs.GetInt("KeyReStartLuaEnv", 0) == 1;
            if (isRestartLuaEnv)
            {
                _luaBridge = null;
            }

            BattleEnv.ClientBridge.RestartLuaEnv(isRestartLuaEnv);
            if (null == _luaBridge)
            {
                _luaBridge = BattleEnv.ClientBridge.GetLuaValue<ILuaBridge>(BattleEnv.ClientBridge.DoLuaString("return require('Editor.Battle.OfflineBattleFramework')")[0], "Instance");
            }

            if (null == _luaBridge)
            {
                return;
            }

            _CreateAnalyzeData(_arg);
            _luaBridge?.Startup(_arg);
        }

        private void _CreateAnalyzeData(BattleArg battleArg)
        {
            // 启动时，资源分析是否使用离线分析模式
            bool useOfflineAnalyze = PlayerPrefs.GetInt("keyUseOfflineAnalyze", 1) == 1;
            if (!useOfflineAnalyze)
            {
                // 如果不适用离线分析，会删掉所有的离线数据，数据不存在时逻辑会实时分析
                ResAnalyzerExtension.ClearOfflineAnalyzeData();
                LogProxy.Log("战斗流程：实时分析，资源分析离线数据清理完成");
            }
            else
            {
                using (ProfilerDefine.CreateAnalyzeOfflineDataPMarker.Auto())
                {
                    float startTime = Time.realtimeSinceStartup;
                    // 此时只是分析，不需要 分析遗漏日志
                    bool preIsDynamicLoadErring = BattleResMgr.isDynamicLoadErring;
                    bool preIsDynamicBottomLoadErring = BattleResMgr.isDynamicBottomLoadErring;
                    BattleResMgr.isDynamicLoadErring = false;
                    BattleResMgr.isDynamicBottomLoadErring = false;

                    // 重新生成离线数据
                    ResAnalyzeEnv.TryInitResAnalyzeEnv(AnalyzeRunEnv.BuildOfflineData);
                    ResAnalyzeUtil.WriteOfflineData(typeof(BattleLevelResAnalyzer), battleArg.levelID);
                    ResAnalyzeUtil.WriteOfflineData(typeof(HeroResAnalyzer), battleArg.girlID);
                    ResAnalyzeUtil.WriteOfflineData(typeof(SuitResAnalyzer), battleArg.girlSuitID);
                    ResAnalyzeUtil.WriteOfflineData(typeof(HeroResAnalyzer), battleArg.boyID);
                    ResAnalyzeUtil.WriteOfflineData(typeof(SuitResAnalyzer), battleArg.boySuitID);
                    ResAnalyzeUtil.WriteOfflineData(typeof(WeaponResAnalyzer), battleArg.girlWeaponID);

                    // 生成特效声音离线配置. 以运行时的模式全部跑一次，包括条件分析 耗时较久， TODO 待优化
                    ResAnalyzeEnv.TryInitResAnalyzeEnv(AnalyzeRunEnv.BuildApp);
                    BuildAppAnalyzePars pars = new BuildAppAnalyzePars();
                    pars.Init();
                    pars.levelIDs.Add(battleArg.levelID);
                    pars.girlSuitIDs.Add(battleArg.girlSuitID);
                    pars.girlCfgIDs.Add(battleArg.girlID);

                    pars.boySuitIDs.Add(battleArg.boySuitID);
                    pars.boyCfgIDs.Add(battleArg.boyID);
                    pars.weaponSkinIDs.Add(battleArg.girlWeaponID);
                    pars.battleTags.AddRange(battleArg.levelTags);
                    var analyzer = new BattleResAnalyzerBuildApp(pars);
                    analyzer.Analyze();
                    ResAnalyzer.FxCfg?.Serialize();

                    BattleResMgr.isDynamicLoadErring = preIsDynamicLoadErring;
                    BattleResMgr.isDynamicBottomLoadErring = preIsDynamicBottomLoadErring;
                    LogProxy.Log("战斗流程：资源分析离线数据生成完成,耗时：" + (Time.realtimeSinceStartup - startTime));
                }
            }
        }

        public class AutoBattle
        {
            private const float CaptureDeltaTime = 1 / 30f;

            private int? _timeScale;
            private MethodInfo _updateMethod;
            private MethodInfo _lateUpdateMethod;

            public void SetTimeScale(bool isOpen, int timeScale)
            {
                var type = typeof(FrameworkMainEntry);
                _updateMethod = type.GetMethod("Update", BindingFlags.Instance | BindingFlags.NonPublic);
                _lateUpdateMethod = type.GetMethod("LateUpdate", BindingFlags.Instance | BindingFlags.NonPublic);

                _timeScale = isOpen ? timeScale : (int?)null;
                FrameworkMainEntry.Instance.enabled = !isOpen;
            }

            public void Update()
            {
                if (null == _timeScale || null == _updateMethod) return;
                Time.captureDeltaTime = CaptureDeltaTime;

                for (var i = 0; i < _timeScale; i++)
                {
                    _updateMethod.Invoke(FrameworkMainEntry.Instance, null);
                }
            }

            public void LateUpdate()
            {
                if (null == _timeScale || null == _lateUpdateMethod) return;

                for (var i = 0; i < _timeScale; i++)
                {
                    _lateUpdateMethod.Invoke(FrameworkMainEntry.Instance, null);
                }
            }
        }

        [CSharpCallLua]
        public interface ILuaBridge
        {
            void Update();
            void LateUpdate();
            void Startup(BattleArg arg);
            void Shutdown();
            bool CanReload();
        }
    }
}
#endif