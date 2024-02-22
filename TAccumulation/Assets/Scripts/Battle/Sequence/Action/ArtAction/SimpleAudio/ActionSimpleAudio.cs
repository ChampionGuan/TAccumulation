using System;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Profiling;
using X3Sequence;

namespace X3Battle
{
    public class ActionSimpleAudio : BSAction
    {
        [HideInInspector] public string EventName;
        [HideInInspector] public string StopEventName;

        public float playSpeed = 1f;
        public float cacheSpeed = 0;
        [NonSerialized]
        public bool isBornCamPlay = false;

        protected override void _OnInit()
        {
            // 获取playable绑定的clip
            var clip = GetClipAsset<SimpleAudioPlayableClip>();
            playSpeed = clip.playSpeed;
            EventName = clip.EventName;
            StopEventName = clip.StopEventName;
            // 禁用掉原生逻辑的生成
            var track = GetTrackAsset<SimpleAudioTrack>();
            isBornCamPlay = track.isBornCamPlay;

            // 获取轨道绑定的对象 缓存AkGameObj组件
            var obj = GetTrackBindObj<GameObject>();
            if (obj != null && obj.GetComponent<AkGameObj>() == null)
            {
                obj.AddComponent<AkGameObj>();
            }
        }

        protected override void _OnEnter()
        {
            var enableBorn = context.actor?.bornCfg?.ControlBornPerform;
            if (isBornCamPlay && enableBorn != null && !enableBorn.Value)
            {
                return;
            }

            if (string.IsNullOrEmpty(EventName))
            {
                return;
            }

            var insID = context.actor == null ? 0 : context.actor.insID;
            
            // 获取轨道绑定的对象
            var obj = GetTrackBindObj<GameObject>();
        
            // 非运行时需要loadbank运行时预加载阶段已经提前load过了
            if (!Application.isPlaying)
            {
                WwiseManager.Instance.LoadBankWithEventName(EventName);   
            }
        
            if(WwiseManager.LogEnable)
                LogProxy.LogFormat("SimpleAudioPlayableBehaviour.OnStart.PlaySound.{0}", EventName);
        
            using (ProfilerDefine.ActionSimpleAudioPlaySoundMarker.Auto())
            {
                //战斗过程中load时候不播放音频
                if (Application.isPlaying && X3Battle.Battle.Instance != null && X3Battle.Battle.Instance.isPreloading)
                {
                    return;
                }
                else
                {
                    Battle.Instance?.wwiseBattleManager.PlaySound(EventName, obj, actorInsId: insID);
                }
            }
        
            using (ProfilerDefine.ActionSimpleAudioSetSpeedMarker.Auto())
            {
                __RefreshSpeed(playSpeed);
            }
        }

        protected override void _OnExit()
        {
            if (string.IsNullOrEmpty(EventName))
            {
                return;
            }

            // DONE: 调用音频打断事件. 只有是打断状态进来才调用
            if (exitType == ExitType.Abnormal)
            {
                if (!string.IsNullOrEmpty(StopEventName) && !string.IsNullOrWhiteSpace(StopEventName))
                {
                    var insID = context.actor == null ? 0 : context.actor.insID;
                    // 获取轨道绑定的对象
                    var obj = GetTrackBindObj<GameObject>();
                    Battle.Instance?.wwiseBattleManager.PlaySound(StopEventName, obj, actorInsId: insID);
                }
            }

            cacheSpeed = 0;
            RefreshPlaySpeed(1f);
        }

        protected override void _OnUpdate()
        {
            base._OnUpdate();
        }

        private AKRESULT __RefreshSpeed(float pSpeed)
        {
            return WwiseManager.Instance.SetSpeed(EventName, pSpeed);  
        }
        
        public void RefreshPlaySpeed(float speed)
        {
            uint playingId = WwiseManager.Instance.GetPlayingId(EventName);
            if (playingId == 0)
            {
                if(playSpeed != speed)
                {
                    cacheSpeed = speed;
                }
                return;
            }
            if (playSpeed == speed)
            {
                return;
            }
            AKRESULT result = __RefreshSpeed(speed);
            if (result == AKRESULT.AK_Success)
            {
                playSpeed = speed;
                cacheSpeed = 0;
            }
            else
            {
                cacheSpeed = speed;
            }
        }
    }
}