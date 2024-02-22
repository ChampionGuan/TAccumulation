using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("技能动作/时间跳转", false)]
    [Serializable]
    public class GoToFrameAsset : BSActionAsset<ActionGoToFrame>
    {
        [LabelText("帧号")]
        public int frameCount;
    }

    public class ActionGoToFrame : BSAction<GoToFrameAsset>
    {
        protected override void _OnEnter()
        {
            var time = clip.frameCount * BattleConst.AnimFrameTime;
            if (battleSequencer != null)
            {
                battleSequencer.SetTime(time);    
            }
        }   
    }
}