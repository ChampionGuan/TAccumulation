using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("Battle动作/播放爆发技表演")]
    [Serializable]
    public class PlayPerformAsset : BSActionAsset<ActionPlayPerform>
    {
        [LabelText("表演表ID")]
        public int performID;

        [LabelText("播放速度")]
        public float speed = 1.0f;
    }

    public class ActionPlayPerform : BSAction<PlayPerformAsset>
    {
        protected override void _OnEnter()
        {
            if (TbUtil.HasCfg<PerformConfig>(clip.performID))
            {
                context.battle.sequencePlayer.PlayPerform(clip.performID, speed:clip.speed);
            }
            else
            {
                PapeGames.X3.LogProxy.LogErrorFormat("表演表中不存在key={0}！表演失败", clip.performID);
            }
        }    
    }
}