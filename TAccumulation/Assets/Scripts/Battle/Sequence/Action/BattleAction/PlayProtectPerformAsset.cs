using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("Battle动作/播放援护技升格表演")]
    [Serializable]
    public class PlayProtectPerformAsset : BSActionAsset<ActionPlayProtectPerform>
    {
        [LabelText("表演表ID")]
        public int performID;
    }

    public class ActionPlayProtectPerform : BSAction<PlayProtectPerformAsset>
    {
        protected override void _OnEnter()
        {
            if (TbUtil.HasCfg<PerformConfig>(clip.performID))
            {
                context.battle.sequencePlayer.PlayPerform(clip.performID, isProtectPerform:true);
            }
            else
            {
                PapeGames.X3.LogProxy.LogErrorFormat("表演表中不存在key={0}！表演失败", clip.performID);
            }
        }    
    }
}