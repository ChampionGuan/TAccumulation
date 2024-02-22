using System;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Timeline;
using X3Battle.Timeline.Extension;
using X3Battle.Timeline.Preview;

namespace X3Battle
{
    [TimelineMenu("角色动作/怪物出生时间缩放")]
    [Serializable]
    public class BornTimeScaleAsset : BSActionAsset<ActionBornTimeScale>
    {
        [LabelText("缩放率")]
        public float scale;
        [LabelText("缩放时长")]
        public float time;
        [LabelText("启用音频事件")]
        public bool isEnable;
        [LabelText("音频事件名", showCondition = "isEnable")]
        public string eventName;
    }

    public class ActionBornTimeScale : BSAction<BornTimeScaleAsset>
    {
        private float _AudioPauseTime = 0.0f;
        private bool _IsAudioPause = false;
        protected override void _OnEnter()
        {
            if (context.actor.bornCfg.ControlBornPerform)
            {
                // 开启镜头才走这个逻辑
                context.battle.SetTimeScale(clip.scale, clip.time, (int)LevelTimeScaleType.Bullet);
                
                if (clip.isEnable)
                {
                    WwiseManager.Instance.PauseSoundVoice();
                    WwiseManager.Instance.PauseBattleVoice();
                    _AudioPauseTime = Time.realtimeSinceStartup;
                    _IsAudioPause = true;
                    if (!string.IsNullOrEmpty(clip.eventName))
                    {
                        context.battle?.wwiseBattleManager.PlaySound(clip.eventName, actorInsId: context.actor.insID);
                    }
                }
            }
        }

        protected override void _OnUpdate()
        {
            base._OnUpdate();
            // 开启镜头才走这个逻辑
            if (context.actor.bornCfg.ControlBornPerform && _IsAudioPause && clip.isEnable && Time.realtimeSinceStartup - _AudioPauseTime > clip.time)
            {
                WwiseManager.Instance.ResumeSoundVoice();
                WwiseManager.Instance.ResumeBattleVoice();
                _IsAudioPause = false;
            }
        }
    }
}