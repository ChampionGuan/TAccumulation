using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色运动/开关旋转")]
    [Serializable]
    public class SetCharacterCtrlPauseAsset : BSActionAsset<ActionSetCharacterCtrlPause>
    {
        [LabelText("是否开启")]
        public bool isUse;
    }

    public class ActionSetCharacterCtrlPause : BSAction<SetCharacterCtrlPauseAsset>
    {
        protected override void _OnEnter()
        {
            context.actor.locomotion.SetPause(!clip.isUse);
        }    
    }
}
