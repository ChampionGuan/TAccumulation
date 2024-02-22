using System;
using PapeGames.X3;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/打断音频")]
    [Serializable]
    public class StopAudioAsset : BSActionAsset<ActionStopAudio>
    {
        [LabelText("是否根据出身镜头打断")]
        public bool isByBornCam;
    }

    public class ActionStopAudio : BSAction<StopAudioAsset>
    {
        protected override void _OnEnter()
        {
            if (clip.isByBornCam)
            {
                if (context.actor.bornCfg.ControlBornPerform)
                {
                    LogProxy.Log("出身镜头打断音频 time = " + Battle.Instance.frameCount);
                    _StopSound();
                }
            }
            else
            {
                _StopSound();
            }
        }

        private void _StopSound()
        {
            Battle.Instance?.wwiseBattleManager.StopSound();
            if (Battle.Instance != null && Battle.Instance.dialogue != null)
            {
                Battle.Instance.dialogue.StopCurNode();
            }
        }
    }
}