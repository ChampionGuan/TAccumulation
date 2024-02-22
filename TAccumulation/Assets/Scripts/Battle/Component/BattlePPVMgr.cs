using UnityEngine;
using System.Collections.Generic;
using PapeGames.Rendering;
using UnityEngine.Profiling;
using PapeGames.X3;

namespace X3Battle
{
    public class BattlePPVMgr : BattleComponent
    {
        public class PPVInfo
        {
            public string path;
            public BattleSequencer sequencer;
            public GameObject go;
            public bool isLoop;
            public float duration;
            public bool inUse;
        }

        protected bool _isEnable = true;
        protected Transform _cameraGo = null;
        protected List<PPVInfo> ppvList = new List<PPVInfo>();

        public BattlePPVMgr() : base(BattleComponentType.PPVMgr)
        {
            requiredPhysicalJobRunning = true;
        }

        protected override void OnStart()
        {
            base.OnStart();
            _cameraGo = BattleEnv.ClientBridge.GetMainCamera().transform;
        }

        /// 播放一个PPV,
        /// <param name="path">timeline前缀内资源(Art\Timeline\Prefabs)</param>
        /// <param name="duration">duration后stop</param>
        public void Play(string path, float? duration = null)
        {
            if (string.IsNullOrEmpty(path))
                return;

            using (ProfilerDefine.PPVMgrPlay.Auto())
            {
                _TryPlayPPV(path, duration);
            }
        }

        /// 停止一个PPV, 如果是个循环ppv, 会进End阶段
        /// <param name="stopAndClear">立即清除,即使循环</param>
        public void Stop(string path, bool stopAndClear = false)
        {
            if (string.IsNullOrEmpty(path))
                return;

            for (int i = 0; i < ppvList.Count; i++)
            {
                var ppvInfo = ppvList[i];
                if (ppvInfo.inUse == false) continue;
                if (ppvInfo.path != path) continue;

                LogProxy.LogFormat("[BattlePPVMgr] StopLoop : {0}", ppvInfo.go.name);
                if (!stopAndClear)
                    ppvInfo.sequencer.StopLoopState();
                else
                    ppvInfo.sequencer.Stop();
                break;
            }
        }

        public void SetEnable(bool v)
        {
            _isEnable = v;
            if (v)
                return;

            foreach (var playing in ppvList)//关掉其他的
            {
                if (!playing.inUse) continue;
                playing.go.SetVisible(false);
            }
        }

        protected override void OnPhysicalJobRunning()
        {
            bool isLastPreview = false;
            for (int i = ppvList.Count - 1; i >= 0; i--)
            {
                var ppvInfo = ppvList[i];
                if (!ppvInfo.inUse) continue;

                if (ppvInfo.sequencer.bsState == BSState.Playing)
                {
                    ppvInfo.sequencer.Update(battle.deltaTime, true);
                    if (ppvInfo.duration > 0)
                    {
                        ppvInfo.duration -= battle.deltaTime;
                        if (ppvInfo.duration <= 0)
                            Stop(ppvInfo.path);
                    }
                }
                else
                {
                    ppvInfo.inUse = false;
                    continue;
                }

                if (!isLastPreview && ppvInfo.sequencer.bsState == BSState.Playing)//只有最后一个在表现
                {
                    isLastPreview = true;
                    ppvList[i].go.SetVisible(true);
                }
                else
                {
                    ppvList[i].go.SetVisible(false);
                }
            }
        }

        protected override void OnDestroy()
        {
            base.OnDestroy();
            for (int i = ppvList.Count - 1; i >= 0; i--)
            {
                if (ppvList[i].sequencer == null) continue;
                ppvList[i].sequencer.Stop();
            }
            _cameraGo = null;
            ppvList.Clear();
        }

        public override void OnActorBorn(Actor actor)
        {
            if (actor.roleBornCfg == null || !actor.roleBornCfg.IsPlayer)
                return;

            var resList = BattleResMgr.Instance.ResTags.GetDependRes(BattleResTag.PPVTimeline);
            foreach (var res in resList)
            {
                PreInit(res.path);
            }
        }

        //预热 获取ppv信息,timelineSequencer,loop
        public PPVInfo PreInit(string path)
        {
            if (string.IsNullOrEmpty(path))
                return null;

            foreach (var ppv in ppvList)
            {
                if(ppv.path == path)
                    return null;
            }
			//PPV LOD走timeline FX LOD规则
            var sequencer = battle.actorMgr.player.sequencePlayer.EnsurePPVSequencer(path);
            if (sequencer == null)
                return null;
            var resComp = sequencer.GetComponent<BSCRes>();
            if (resComp == null)
                return null;
            var go = resComp.artObject;
            if (go == null)
                return null;
            var clock = sequencer.GetComponent<BSCClock>();
            if (clock == null)
                return null;

            var ppvInfo = new PPVInfo();
            ppvInfo.sequencer = sequencer;
            ppvInfo.path = path;
            ppvInfo.go = go;
            ppvInfo.go.SetVisible(false);
            //ppvInfo.ppv = go.GetComponentInChildren<PostProcessVolume>();
            //ppvInfo.ppv.enabled = false;
            ppvInfo.isLoop = clock.isThreeState;
            ppvList.Add(ppvInfo);
            return ppvInfo;
        }

        protected bool _TryPlayPPV(string path, float? duration = null)
        {
            PPVInfo ppvInfo = null;
            bool isCache = false;
            for (int i = 0; i < ppvList.Count; i++)
            {
                if (ppvList[i].path != path) continue;
                isCache = true;
                ppvInfo = ppvList[i];
                ppvList.Remove(ppvInfo);
                ppvList.Add(ppvInfo);
                break;
            }

            if(!isCache)
            {
                LogProxy.LogError("[BattlePPVMgr] 没有PreInit PPV");
                ppvInfo = PreInit(path);
                if (ppvInfo == null)
                    return false;
            }

            ppvInfo.inUse = true;
            ppvInfo.duration = duration.HasValue ? duration.Value : 0;
            if (ppvInfo.sequencer.bsState == BSState.Playing)
                ppvInfo.sequencer.Stop();
            ppvInfo.sequencer.Play();
            var transform = ppvInfo.go.transform;
            transform.SetParent(_cameraGo);
            transform.localPosition = Vector3.zero;//VFX timeline设置的位置
            transform.localEulerAngles = Vector3.zero;
            ppvInfo.go.SetVisible(_isEnable);
            LogProxy.LogFormat("[BattlePPVMgr] Play : {0}", ppvInfo.go.name);
            return true;
        }
    }
}