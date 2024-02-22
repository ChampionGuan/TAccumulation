using PapeGames.X3;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    /// <summary>
    /// 单位音频管理器
    /// </summary>
    public class WwiseBattleManager : BattleComponent
    {
        private enum EActorState
        {
            EPlay = 0,//播放状态
            EPause,//暂停状态
        }
        public struct EventObj
        {
            public string eventName;
            public GameObject obj;

            public EventObj(string eventName, GameObject gameObject)
            {
                this.eventName = eventName;
                this.obj = gameObject;
            }
        }

        public WwiseBattleManager() : base(BattleComponentType.WwiseBattleManager)
        {
        }

        protected override void OnAwake()
        {
            base.OnAwake();
            FxPlayerUtility.PlaySoundEvent += PlaySound;
                        
            //如果是编辑器下启动 打开音频自动加载
#if UNITY_EDITOR
            WwiseManager.AutoLoadBankMode = true;
#endif
        }

        protected override void OnDestroy()
        {
            base.OnDestroy();
            FxPlayerUtility.PlaySoundEvent -= PlaySound;
            Clear();
        }
        /// <summary>
        /// insID 对应的eventNames
        /// </summary>
        private static Dictionary<int, List<EventObj>> _actorAudios = new Dictionary<int, List<EventObj>>();
        
        /// <summary>
        /// actor对应的播放状态
        /// </summary>
        private Dictionary<int, EActorState> _actorStates = new Dictionary<int,EActorState>();

        /// <summary>
        /// actor暂停播放中的音效播放
        /// </summary>
        private Dictionary<int, List<EventObj>> _actorPauses = new Dictionary<int, List<EventObj>>();

        /// <summary>
        /// 播放完成的回调
        /// </summary>
        private WwiseManager.SoundCompleteAction onComplete = OnComplete;

        /// <summary>
        /// 打断音频
        /// </summary>
        public void StopSound()
        {
            WwiseManager.Instance.StopBattleSound();
        }
        
        /// <summary>
        /// 播放音频完成回调
        /// </summary>
        /// <param name="eventName"></param>
        /// <param name="playingID"></param>
        private static void OnComplete(string eventName, uint playingID)
        {
            foreach (var actorAudio in _actorAudios)
            {
                for (int i = actorAudio.Value.Count - 1; i >= 0; i--)
                {
                    if (actorAudio.Value[i].eventName == eventName)
                    {
                        actorAudio.Value.RemoveAt(i);
                    }
                }
            }
        }

        /// <summary>
        /// 播放音频
        /// </summary>
        /// <param name="eventName"></param>
        /// <param name="gameObj"></param>
        /// <param name="onComplete"></param>
        /// <param name="onProgress"></param>
        /// <param name="actorInsId"></param>
        public void PlaySound(string eventName, GameObject gameObj = null,
            WwiseManager.SoundProgressAction onProgress = null,int actorInsId = 0)
        {
            using (ProfilerDefine.WwiseBattleManagerPlaySound1Marker.Auto())
            {
                //预加载阶段不播放音频
                if (Application.isPlaying && Battle.Instance != null && Battle.Instance.isPreloading)
                {
                    return;
                }
                
                if(eventName == "")
                {
                    return;
                }
            
                //如果actor处于pause状态 缓存播放音频eventName
                if (_actorStates.ContainsKey(actorInsId) && _actorStates[actorInsId] == EActorState.EPause)
                {
                    if (_actorPauses.ContainsKey(actorInsId))
                    {
                        _actorPauses[actorInsId].Add(new EventObj(eventName, gameObj));
                    }
                    else
                    {
                        var list = ObjectPoolUtility.WwiseEventList.Get();
                        list.Add(new EventObj(eventName, gameObj));
                        _actorPauses.Add(actorInsId, list);
                    }

                    return;
                }
            }

            using (ProfilerDefine.WwiseBattleManagerPlaySound3Marker.Auto())
            {
                WwiseManager.Instance.PlaySound(eventName, gameObj, onComplete, onProgress);
            }
            
            using (ProfilerDefine.WwiseBattleManagerPlaySound2Marker.Auto())
            {
                //确认eventName的归属
                if (actorInsId > 0)
                {
                    if (!_actorAudios.ContainsKey(actorInsId))
                    {
                        var list = ObjectPoolUtility.WwiseEventList.Get();
                        list.Add(new EventObj(eventName, gameObj));
                        _actorAudios.Add(actorInsId, list);
                    }
                    else
                    {
                        _actorAudios[actorInsId].Add(new EventObj(eventName, gameObj));
                    }
                }
            }
        }
        
        
        /// <summary>
        /// 根据insID 恢复隶属于actor的音频
        /// </summary>
        /// <param name="insID"></param>
        /// <param name="gameObj"></param>
        public void ResumeSoundActor(int insID)
        {
            if (!_actorAudios.ContainsKey(insID))
            {
                return;
            }
            
            if (_actorStates.ContainsKey(insID))
            {
                _actorStates[insID] = EActorState.EPlay;
            }
            else
            {
                _actorStates.Add(insID, EActorState.EPlay);
            }

            if (_actorAudios.ContainsKey(insID))
            {
                foreach (var actorAudio in _actorAudios[insID])
                {
                    WwiseManager.Instance.ResumeSound(actorAudio.eventName, actorAudio.obj);
                }
            }

            if (_actorPauses.ContainsKey(insID))
            {
                foreach (var actorPause in _actorPauses[insID])
                {
                    WwiseManager.Instance.PlaySound(actorPause.eventName, actorPause.obj, onComplete);
                }
                
                _actorPauses[insID].Clear();
            }
        }
        
        /// <summary>
        /// 根据insID 暂停隶属于actor的音频
        /// </summary>
        /// <param name="insID"></param>
        /// <param name="gameObj"></param>
        public void PauseSoundActor(int insID)
        {
            if (!_actorAudios.ContainsKey(insID))
            {
                return;
            }

            if (_actorStates.ContainsKey(insID))
            {
                _actorStates[insID] = EActorState.EPause;
            }
            else
            {
                _actorStates.Add(insID, EActorState.EPause);
            }

            foreach (var actorAudio in _actorAudios[insID])
            {
                //如果已经暂停了就不用再暂停了
                if (WwiseManager.Instance.IsPause(actorAudio.eventName, actorAudio.obj))
                {
                    continue;
                }
                WwiseManager.Instance.PauseSound(actorAudio.eventName, actorAudio.obj);
            }
        }

        /// <summary>
        /// enable == true 为恢复 enable == false 为暂停
        /// </summary>
        /// <param name="enable"></param>
        /// <param name="type"></param>
        public void PauseOrResumeAudio(bool enable, EAudioPauseType type)
        {
            if (!enable)
            {
                switch (type)
                {
                    case EAudioPauseType.EAll:
                        WwiseManager.Instance.PauseSoundVoice();
                        break;
                    case EAudioPauseType.EBattleAll:
                        WwiseManager.Instance.PauseBattleVoice();
                        break;
                    case EAudioPauseType.EBattleSfx:
                        WwiseManager.Instance.PauseBattleSoundSFX();
                        break;
                }
            }
            else
            {
                switch (type)
                {
                    case EAudioPauseType.EAll:
                        WwiseManager.Instance.ResumeSoundVoice();
                        break;
                    case EAudioPauseType.EBattleAll:
                        WwiseManager.Instance.ResumeBattleVoice();
                        break;
                    case EAudioPauseType.EBattleSfx:
                        WwiseManager.Instance.ResumeBattleSoundSFX();
                        break;
                }
            }
        }

        public void Clear()
        {
            _actorAudios.Clear();
            _actorStates.Clear();
            _actorPauses.Clear();
        }
    }
}
