using System;
using System.Collections.Generic;
using UnityEngine;
using PapeGames.X3;
using PapeGames.X3UI;
using X3Game;
using NodeCanvas.Framework;
using Unity.Profiling;
using XLua;

namespace X3Battle
{
    public class BattleClientBridge : IBattleClientBridge
    {
        private XLuaEnv _luaEnv;
        private IBattleLuaBridge _luaBridge;

        public IBattleLuaBridge luaBridge
        {
            get
            {
                if (null != _luaBridge && _luaEnv == X3Lua.GetLuaEnv() && _luaEnv.GetLuaEnv().rawL != IntPtr.Zero)
                {
                    return _luaBridge;
                }

                // 该接口可重复调用
                GameMgr.Init();
                // 虚拟机缓存
                _luaEnv = X3Lua.GetLuaEnv();
                // lua文件目录确定，不可轻易移动！
                _luaBridge = ((LuaTable)_luaEnv.DoRequire("Runtime.Battle.Common.BattleLuaBridge")[0]).Get<IBattleLuaBridge>("Instance");
                return _luaBridge;
            }
        }

#if UNITY_EDITOR
        [UnityEditor.InitializeOnLoadMethod]
        private static void InitForEditor()
        {
            Init();
        }
#endif

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
        public static void Init()
        {
            BattleEnv.ClientBridge = new BattleClientBridge();
            X3.CustomEvent.Utils.logFatalFunc = LogProxy.LogFatal;
            X3.CustomEvent.Utils.getProfilerMarkerFunc = GetDelegateProfileTag;
            BBParameter_Integer.customConvertor = ModuleIDToIntConvertor;
            ParadoxNotion.StringUtils.SetInternFunc(zstring.Intern);
        }

        private static Func<int> ModuleIDToIntConvertor(BBParameter<int> bbParameterInt, Variable variable)
        {
            if (variable is Variable<ModuleID> variableModuleID)
            {
                return () => variableModuleID.value.id;
            }

            return null;
        }

        private static readonly Dictionary<Type, string> typeNames = new Dictionary<Type, string>();
        private static Dictionary<Delegate, string> profileMap { get; } = new Dictionary<Delegate, string>();

        private static ProfilerMarker? GetDelegateProfileTag(Delegate @delegate)
        {
#if !ENABLE_PROFILER
            return null;
#else
            // 以下代码真机环境不运行！！
            if (profileMap.TryGetValue(@delegate, out var profileStr))
            {
                return new ProfilerMarker(profileStr);
            }

            //此处会拼接函数名称，如需精确定位函数，可将此注释放开
            var method = @delegate.Method;
            var methodType = method.DeclaringType;
            var methodTypeName = "Null";
            if (null != methodType && !typeNames.TryGetValue(methodType, out methodTypeName))
            {
                methodTypeName = methodType.Name;
                typeNames.Add(methodType, methodTypeName);
            }

            profileStr = BattleUtil.StrConcat(methodTypeName, ".", method.Name, "() [Event.Invoke]");
            profileMap.Add(@delegate, profileStr);
            return new ProfilerMarker(profileStr);
#endif
        }

        public void OnGameReboot()
        {
            _luaBridge = null;
        }

        public void OnBattleDestroy()
        {
            profileMap.Clear();
        }

        public void RestartLuaEnv(bool force)
        {
#if UNITY_EDITOR || DEBUG_GM
            if (force) GameMgr.Destroy();
            // 该接口可重复调用
            GameMgr.Init(force);
#endif
        }

        public object[] DoLuaString(string str)
        {
            return X3Lua.IsInited ? X3Lua.GetLuaEnv().DoString(str) : null;
        }

        public T GetLuaValue<T>(object luaTable, string key)
        {
            if (!X3Lua.IsInited || !(luaTable is LuaTable ins)) return default;
            return ins.Get<T>(key);
        }

        public void CallLuaFunction(string globalFuncName, object[] args, out object[] result)
        {
            CallLuaFunction(X3Lua.GetLuaEnv()?.Global, globalFuncName, args, out result);
        }

        public void CallLuaFunction(object luaTable, string funcName, object[] args, out object[] result)
        {
            result = null;
            var value = GetLuaValue<LuaFunction>(luaTable, funcName);
            result = value?.Call(args);
        }

        public string GetCallstack()
        {
            return X3Lua.GetCallstack();
        }

        public void ReportException(Exception e, string message)
        {
            CrashSightManager.ReportException(e, message);
        }

        public void ReportCustomInfo(string key, string value)
        {
            CrashSightManager.UploadCustomInfo(key, value);
        }

        public Camera GetMainCamera()
        {
            return CameraUtility.MainCamera;
        }

        public Camera GetUICamera()
        {
            return UIViewUtility.GetUICamera();
        }

        public RectTransform GetUIRoot()
        {
            return UIViewUtility.GetUIRoot().GetComponent<RectTransform>();
        }

        public void WindowPlayMotion(BattleUI.WindowData windowData, bool visible, Action<RectTransform> onComplete)
        {
            if (visible)
            {
                windowData.view.PlayMoveIn(() => onComplete?.Invoke(windowData.window));
            }
            else
            {
                windowData.view.PlayMoveOut(() => onComplete?.Invoke(windowData.window));
            }
        }

        public void NodePlayMotion(RectTransform node, bool visible)
        {
            if (visible)
            {
                MotionHandler.Play(node, AutoPlayMode.Enabled);
            }
        }

        public void PlayMusic(string eventName, string stateName, string stateGroup, bool isLoop)
        {
            MusicPlayerMgr.Instance.Play(eventName, stateName, stateGroup, isLoop);
        }

        public string GetCurPlayStateName()
        {
            return MusicPlayerMgr.Instance.CurPlayStateName;
        }

        public string GetUIText(int uiTextID)
        {
            return UITextLanguage.GetUIText(uiTextID);
        }

        public void SetUITouchEnable(GameObject go, bool enabled)
        {
            UIUtility.SetTouchEnable(go, enabled);
        }
    }
}