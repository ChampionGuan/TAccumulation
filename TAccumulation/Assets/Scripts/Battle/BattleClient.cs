using UnityEngine;
using X3.CustomEvent;
using PapeGames.X3;

namespace X3Battle
{
    /// <summary>
    /// 客户端战斗的入口类
    /// 战斗生命周期维护，启动、关闭、更新
    /// 客户端战斗同时只允许一场战斗进行！！
    /// 好的框架是一种艺术
    /// </summary>
    public class BattleClient : MonoBehaviour
    {
        public static BattleClient Instance { get; private set; }

        // 战斗状态静态回调
        public static CustomEvent OnStartup { get; } = new CustomEvent();
        public static CustomEvent OnBegin { get; } = new CustomEvent();
        public static CustomEvent OnStartupFinished { get; } = new CustomEvent();
        public static CustomEvent OnShutdown { get; } = new CustomEvent();

        // 在Update中执行的回调
        public CustomEvent onPreUpdate { get; } = new CustomEvent();
        public CustomEvent onPostUpdate { get; } = new CustomEvent();

        // 在Update中，与动画Job线程运行时并行执行的回调
        public CustomEvent onPreAnimationJobRunning { get; } = new CustomEvent();
        public CustomEvent onPostAnimationJobRunning { get; } = new CustomEvent();

        // 在LateUpdate中执行的回调
        public CustomEvent onPreLateUpdate { get; } = new CustomEvent();
        public CustomEvent onPostLateUpdate { get; } = new CustomEvent();

        // 在LateUpdate中，与物理DBJob线程运行时并行执行的回调
        public CustomEvent onPrePhysicalJobRunning { get; } = new CustomEvent();
        public CustomEvent onPostPhysicalJobRunning { get; } = new CustomEvent();

        // 在FixedUpdate中执行的回调
        public CustomEvent onPreFixedUpdate { get; } = new CustomEvent();
        public CustomEvent onPostFixedUpdate { get; } = new CustomEvent();

        public Battle battle { get; private set; }

        public static void Update()
        {
            if (null == Instance) return;
            using (ProfilerDefine.BattleClientUpdatePMarker.Auto())
            {
                Instance.onPreUpdate.Dispatch();
                Instance.battle?.Update(Time.deltaTime);
                Instance.onPostUpdate.Dispatch();
            }
        }

        public static void AnimationJobRunning()
        {
            if (null == Instance) return;
            using (ProfilerDefine.BattleClientAnimationJobRunningPMarker.Auto())
            {
                Instance.onPreAnimationJobRunning.Dispatch();
                Instance.battle?.AnimationJobRunning();
                Instance.onPostAnimationJobRunning.Dispatch();
            }
        }

        public static void LateUpdate()
        {
            if (null == Instance) return;
            using (ProfilerDefine.BattleClientAnimationJobCompletedPMarker.Auto())
            {
                Instance.battle?.AnimationJobCompleted();
            }

            using (ProfilerDefine.BattleClientLateUpdatePMarker.Auto())
            {
                Instance.onPreLateUpdate.Dispatch();
                Instance.battle?.LateUpdate();
                Instance.onPostLateUpdate.Dispatch();
            }
        }

        public static void PhysicalJobRunning()
        {
            if (null == Instance) return;
            using (ProfilerDefine.BattleClientPhysicalJobRunningPMarker.Auto())
            {
                Instance.onPrePhysicalJobRunning.Dispatch();
                Instance.battle?.PhysicalJobRunning();
                Instance.onPostPhysicalJobRunning.Dispatch();
            }
        }

        public static void FixedUpdate()
        {
            if (null == Instance) return;
            using (ProfilerDefine.BattleClientFixedUpdatePMarker.Auto())
            {
                Instance.onPreFixedUpdate.Dispatch();
                Instance.battle?.FixedUpdate();
                Instance.onPostFixedUpdate.Dispatch();
            }
        }

        private void OnDestroy()
        {
            Shutdown();
        }

        private void OnApplicationQuit()
        {
            Shutdown();
        }

        /// <summary>
        /// 启动战斗
        /// </summary>
        /// <param name="startupArg"></param>
        public void Startup(BattleArg startupArg)
        {
            using (ProfilerDefine.BattleClientStartupPMarker.Auto())
            {
                if (null != battle)
                {
                    Shutdown();
                    LogProxy.LogError("【BattleClient.Startup()】警告：当前有战斗正在进行中，目前不允许多场战斗同时进行，此处将关闭当前战斗，重新启动！！请注意检查！！");
                }

                Instance = this;
                battle = new Battle(startupArg, transform);
                battle.Awake();
                battle.Start();
                OnStartup.Dispatch();
            }
        }

        /// <summary>
        /// 启动战斗中，预处理
        /// </summary>
        public void Preload()
        {
            if (null == battle)
            {
                return;
            }

            using (ProfilerDefine.BattleClientPreloadPMarker.Auto())
            {
                battle.Preload();
            }
        }

        /// <summary>
        /// 启动战斗结束
        /// </summary>
        public void StartupFinished()
        {
            if (null == battle)
            {
                return;
            }

            using (ProfilerDefine.BattleClientStartupFinishedPMarker.Auto())
            {
                battle.StartupFinished();
                OnStartupFinished.Dispatch();
            }
        }

        /// <summary>
        /// 关闭战斗
        /// </summary>
        public void Shutdown()
        {
            using (ProfilerDefine.BattleClientShutdownPMarker.Auto())
            {
                if (null != battle)
                {
                    OnShutdown.Dispatch();
                    battle.Destroy();
                }

                Instance = null;
                onPreUpdate.Clear();
                onPostUpdate.Clear();
                onPreAnimationJobRunning.Clear();
                onPostAnimationJobRunning.Clear();
                onPreLateUpdate.Clear();
                onPostLateUpdate.Clear();
                onPrePhysicalJobRunning.Clear();
                onPostPhysicalJobRunning.Clear();
                onPreFixedUpdate.Clear();
                onPostFixedUpdate.Clear();
                battle = null;
                StopAllCoroutines();
            }
        }

        /// <summary>
        /// 开始战斗
        /// </summary>
        public void Begin()
        {
            if (null == battle)
            {
                return;
            }

            using (ProfilerDefine.BattleClientBeginPMarker.Auto())
            {
                battle.Begin();
                OnBegin.Dispatch();
            }
        }

        /// <summary>
        /// 结束战斗
        /// </summary>
        /// <param name="isWin"></param>
        public void End(bool isWin)
        {
            if (null == battle)
            {
                return;
            }

            using (ProfilerDefine.BattleClientEndPMarker.Auto())
            {
                battle.End(isWin);
            }
        }

        /// <summary>
        /// 修改引擎TimeScale，请谨慎使用！
        /// </summary>
        /// <param name="timeScale"></param>
        public void SetUnityTimescale(float timeScale)
        {
            Time.timeScale = timeScale;
        }

        /// <summary>
        /// 获得引擎TimeScale
        /// </summary>
        public float GetUnityTimescale()
        {
            return Time.timeScale;
        }
    }
}