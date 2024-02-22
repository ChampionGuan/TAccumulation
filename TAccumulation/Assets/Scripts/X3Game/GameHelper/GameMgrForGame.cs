using System;
using System.Collections;
using PapeGames.X3UI;
using UnityEngine;
using PapeGames.X3;
using TMPro;
using UnityEngine.UI;
using X3Game.Platform;
using XAssetsManager;
#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.Experimental.SceneManagement;
using Newtonsoft.Json;
#endif

namespace X3Game
{
    public partial class GameMgr
    {
        /// <summary>
        /// 是否重启
        /// </summary>
        private static bool s_GameReboot = false;
        
        private void OnInit()
        {
            InitApp();

            //cache main cam
            MainCamera = CameraUtility.MainCamera;
            var mainCamera = WwiseEnvironment.MainCamera;
            InitForUISystem();
            //注册EventMgr向Lua端发送事件的逻辑
            EventMgr.SetOnFired((string eventName, object data) =>
            {
                X3Lua.X3LuaGameDelegate?.OnEvent(eventName, data);
            });
            PapeGames.CutScene.CutSceneHelper.IsInGame = true;

            //是否开启AB检测
            m_IsMarkAB = PlayerPrefs.GetInt(SET_AB_MARK_ALL) > 0;
            if (IsMarkAB)
            {
                m_MarkABManifestFile.Clear();
                XAssetsManager.XResources.OnResourceLoadNotification -= OnResLoad;
                XAssetsManager.XResources.OnResourceLoadNotification += OnResLoad;
            }

#if ProfilerEnable
            Paper.U3dProfiler.MemoryProfiler.WWiseMemoryGetter = ()=>
            {
                return WwiseManager.HasInstance() ? WwiseManager.Instance.GetWwiseMemorySize() : 0;
            };
#endif
        }

        private void InitApp()
        {
#if UNITY_EDITOR
            if (Application.isBatchMode)
            {
                AppInfoMgr.Instance.InitAppInfo();
            }
#endif
            InitAppInfo();
            Res.Lang = AppInfoMgr.Instance.Lang;
            Res.SoundLang = AppInfoMgr.Instance.SoundLang;
            Res.Region = AppInfoMgr.Instance.AppInfo.Region;
            Res.Init(new ResExtension());
        }

        private static void InitForUISystem()
        {
            UISystem.MainCamera = MainCamera;
            UISystem.Lang = AppInfoMgr.Instance.Lang;
            UISystem.Region = AppInfoMgr.Instance.Region;
            UISystem.SoundFXDelegate = new X3Game.X3UISoundFXImp();
            UISystem.MiscDelegate = new X3UIMiscImp();
            UISystem.Settings = X3GameSettings.Instance.UISettings;
#if UNITY_EDITOR || ProfilerEnable
            UISystem.SetOnProfileBeginAction((val) => { GameMgr.BeginPerformanceLog(val); });
            UISystem.SetOnProfileEndAction((val) => { GameMgr.EndPerformanceLog(val); });
#endif
            
#if UNITY_EDITOR
            string leadingCharacters = TMP_Settings.leadingCharacters.text;
            string followingCharacters = TMP_Settings.followingCharacters.text;
            RichText.SetLeadingAndFollowingWords(leadingCharacters, followingCharacters);
#endif
        }

        /// <summary>
        /// 设置是否重启
        /// </summary>
        /// <param name="reboot"></param>
        public static void SetGameReboot(bool reboot)
        {
            s_GameReboot = reboot;
            UIViewUtility.SetGameReboot(reboot);
            InputComponent.IsRebooting = reboot;
        }
        
        /// <summary>
        /// 等待资源加载完成
        /// </summary>
        /// <param name="callBack">等待资源加载完成回调</param>
        public static void WaitAssetLoadFinished(Action callBack)
        {
            CoroutineProxy.StartCoroutine(OnWaitAssetLoadFinished(callBack));
        }

        private static IEnumerator OnWaitAssetLoadFinished(Action callBack)
        {
            int tryFrameCount = Res.WaitMaxFrameCountBeforeTryDestroy;
            while (Res.IsAssetInLoadingState() && tryFrameCount > 0)
            {
                yield return null;
                tryFrameCount--;
            }
            callBack?.Invoke();
        }

        /// <summary>
        /// 重启卸载所有资源
        /// </summary>
        /// <param name="isForce">是否强制重启</param>
        /// <param name="callBack">卸载完成回调</param>
        public static void RebootResUnload(bool isForce , Action callBack)
        {
            CoroutineProxy.StartCoroutine(OnRebootResUnload(isForce, callBack));
        }

        /// <summary>
        /// 卸载资源,卸载完成后开启资源加载
        /// </summary>
        /// <param name="isForce"></param>
        /// <param name="callBack"></param>
        /// <returns></returns>
        private static IEnumerator OnRebootResUnload(bool isForce , Action callBack)
        {
            //Res在reboot过程中不在加载资源
            Res.Available = false;
            
            Res.ForceUnloadAllLoaders();
            yield return null;
            
            System.GC.Collect();
            System.GC.WaitForPendingFinalizers();
            yield return null;
            System.GC.Collect();
            System.GC.WaitForPendingFinalizers();
            Resources.UnloadUnusedAssets();
            yield return null;
            //Res开启资源加载
            Res.Available = true;

            callBack?.Invoke();
        }

        /// <summary>
        /// 重启调用
        /// </summary>
        /// <param name="isForce"></param>
        /// <returns></returns>
        private void OnReboot(bool isForce)
        {
            CriticalLog.LogFormat("GameMgr.OnReboot.Begin: isForce={0}", isForce);
            DG.Tweening.DOTween.KillAll();
            CinemachineUtility.ClearAllListener(GameMgr.MainCamera.gameObject);
            MaskCopiedMaterialProvider.Clear();
            EventMgr.Clear();
            if (isForce)
            {
                //热更新后调用, 会unloadAllLua
                X3Lua.Clear();
                X3Lua.RequireLuaScript("LuaStart", "X3Lua", true);
                X3Lua.RequireLuaScript("GameInit", "X3Lua",  true);
            }
            X3Lua.RequireLuaScript("GameStart","X3Lua", true);
            CriticalLog.Log("GameMgr.OnReboot.End");
        }

        #region AppInfo

        public static bool OverrideAppInfo { set; get; } = false;
        public static string AppVer { set; get; } = "dev";

        /// <summary>
        /// inner is true
        /// </summary>
        public static bool InnerOrOutter { set; get; } = true;

        public static string Platform { private set; get; }

        private void InitAppInfo()
        {
            if (!OverrideAppInfo)
            {
                #region define appVer

                //OUT_TEST 使用uwa目录下的资源、不开启uwa，用来做外网的一些兼容测试之类的需求
#if UWA_LAUNCHER || OUT_TEST
            AppVer = "uwa";
#elif PUBLICATION
            AppVer = "publication";
#elif STAGE
            AppVer = "stage";
#endif

                #endregion

                #region define inner or outer

#if OUTER_NET
            InnerOrOutter = false;
#elif INNER_NET
            InnerOrOutter = true;
#endif

                #endregion
            }

            #region define platform

#if !UNITY_EDITOR
#if UNITY_ANDROID
            Platform = "android";
#elif UNITY_IOS
            Platform = "ios";
#endif
#endif

            #endregion

            //使用Platform来做release和rc，外网测试包的入口区分
#if RC_WIN
            Platform = "RC_WIN";//rc_engine在windows上出的包，使用
#elif RC_MAC
            Platform = "RC_MAC";//rc_engine在mac上出的包，使用
#elif STAGERLEASE
            Platform = "STAGERLEASE";//给到运维的外网正式包，使用prd下的资源，ServerUrl下配置对应的入口url
#endif
        }

        #endregion

        public static void RefreshForLangChanging(Locale.Language lang, Locale.Language soundLang,
            Locale.RegionType region)
        {
            UISystem.Lang = lang;
            Res.Lang = lang;
            Res.SoundLang = soundLang;
#if DEBUG_GM
            UISystem.Region = region;
#endif
            if (UIMgr.HasInstance())
                UIMgr.Instance.RefreshUIsForLangChanging();

            if (WwiseManager.HasInstance())
                WwiseManager.Instance.SetLanguage(soundLang);

#if UNITY_EDITOR
            var prefabStage = PrefabStageUtility.GetCurrentPrefabStage();
            if (prefabStage != null && prefabStage.prefabContentsRoot != null)
            {
                var localeComps = prefabStage.prefabContentsRoot.GetComponentsInChildren<IUILocaleComponent>(true);
                foreach (var localeComp in localeComps)
                {
                    localeComp.RefreshUIsForLangChanging();
                }
            }

            //不调用会因为Scene失焦没有及时刷新，强制刷新一下
            foreach (EditorWindow sceneView in SceneView.sceneViews)
            {
                sceneView.Repaint();
            }
#endif
        }

        public static void ChangeRegionEditorOnly(int region)
        {
#if UNITY_EDITOR
            AppInfo appInfo = AppInfoHelper.LoadAppInfo();
            appInfo.Region = region;
            var txt = JsonConvert.SerializeObject(appInfo);
            string filePath =
                System.IO.Path.Combine(Application.streamingAssetsPath, GameDefines.APPINFO_FILE_NAME);
            FileUtility.WriteText(filePath, txt);
#endif
        }
        #region Optimize Main Camera

        public static bool UpdateMainCameraVisibilityMode { get; set; } = true;

        private static void OptimizeMainCamera()
        {
            if (!IsRunning || !UpdateMainCameraVisibilityMode)
            {
                return;
            }

            var mainCam = MainCamera;
            if (mainCam == null || mainCam.targetTexture != null)
                return;
            if (!UIMgr.HasInstance())
                return;
            var blurController = UIMgr.Instance.BlurController;
            if (blurController != null && blurController.GetBlurEnable())
                return;
            var needMainCamera = UIMgr.NeedMainCamera;

            if (!needMainCamera && mainCam.enabled)
            {
                mainCam.enabled = false;
            }

            if (needMainCamera && !mainCam.enabled)
            {
                mainCam.enabled = true;
                if (!mainCam.gameObject.activeSelf)
                    mainCam.gameObject.SetActive(true);
            }
        }

        #endregion

        #region Qos

        //Qos事件ID，每次开启游戏产生随机数
        private static int qosEventId = 0;

        public static int GetQosEventId()
        {
            if (qosEventId == 0)
            {
                System.Random random = new System.Random();
                qosEventId = random.Next(1, 2000000000);
            }

            return qosEventId;
        }

        private static int qosTime = 0;

        //获取QOS步骤间隔时间
        public static int GetQosTime()
        {
            int time = (int)UnityEngine.Time.time - qosTime;
            if (qosTime == 0)
            {
                time = 0;
            }

            qosTime = (int)UnityEngine.Time.time;
            return time;
        }

        #endregion

        #region Mark AB

        /// <summary>
        /// 是否开启AB检测
        /// </summary>
        private static bool m_IsMarkAB;

        public static bool IsMarkAB
        {
            get { return m_IsMarkAB; }
        }

        private static readonly string SET_AB_MARK_ALL = "SET_AB_MARK_ALL";
        private static readonly string SET_AB_MARK = "SET_AB_MARK";
        private static MarkABManifestFile m_MarkABManifestFile = new MarkABManifestFile();
        //仅仅测试使用
        private static TestMarkABfestFile m_TestMarkABManifestFile = new TestMarkABfestFile();
        /// <summary>
        /// GM开启AB记录
        /// </summary>
        /// <param name="isOpen"></param>
        public static void MarkABAll(bool isOpen)
        {
            PlayerPrefs.SetInt(SET_AB_MARK_ALL, isOpen ? 1 : 0);
            if (isOpen)
            {
                m_MarkABManifestFile.Clear();
                XResources.OnResourceLoadNotification -= OnResLoad;
                XResources.OnResourceLoadNotification += OnResLoad;
            }
            else
            {
                XResources.OnResourceLoadNotification -= OnResLoad;
                m_MarkABManifestFile.SaveToFile();
            }
        }

        /// <summary>
        /// GM开启AB记录
        /// </summary>
        /// <param name="isOpen"></param>
        public static void MarkAB(bool isOpen)
        {
            PlayerPrefs.SetInt(SET_AB_MARK, isOpen ? 1 : 0);
            if (isOpen)
            {
                m_MarkABManifestFile.Clear();
                XResources.OnResourceLoadNotification -= OnResLoad;
                XResources.OnResourceLoadNotification += OnResLoad;
            }
            else
            {
                XResources.OnResourceLoadNotification -= OnResLoad;
                m_MarkABManifestFile.SaveToFile();
            }
        }
        
        /// <summary>
        /// 仅在测试中使用！！！
        /// </summary>
        /// <param name="isOpen"></param>
        public static void TestMarkAB(bool isOpen,string path = "")
        {
            if (isOpen)
            {
                m_TestMarkABManifestFile.Clear();
                XResources.OnResourceLoadNotification -= OnResLoadTest;
                XResources.OnResourceLoadNotification += OnResLoadTest;
            }
            else
            {
                XResources.OnResourceLoadNotification -= OnResLoadTest;
                Debug.LogError("日志保存路径：" + path);
                m_TestMarkABManifestFile.SaveToFile(path);
            }
        }

        private static void OnResLoad(ResourceLoadType loadType, string abName, bool loadFirstly)
        {
            //资源加载
            if (loadType == ResourceLoadType.LoadFile)
            {
                m_MarkABManifestFile.Add(abName, loadType);
            }
        }
        
        private static void OnResLoadTest(ResourceLoadType loadType, string abName, bool loadFirstly)
        {
            //资源加载
            m_TestMarkABManifestFile.Add(abName, loadType);
        }

        #endregion
    }
}