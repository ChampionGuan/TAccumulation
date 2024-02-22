using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/播放特效组")]
    [Serializable]
    public class PlayFxGroupAsset : BSActionAsset<ActionPlayFxGroup>
    {
        [LabelText("美术表现配置组名")]
        public List<string> GroupNames;
        [LabelText("是否开启")]
        public bool enable;
    }

    public class ActionPlayFxGroup : BSAction<PlayFxGroupAsset>
    {
        protected override void _OnEnter()
        {
            if(clip.enable)
            {
                foreach(var name in clip.GroupNames)
                {
                    context.actor.effectPlayer.PlayGroupFx(name);
                }
            }
            else
            {
                foreach (var name in clip.GroupNames)
                {
                    context.actor.effectPlayer.StopGroupFx(name);
                }
            }
        }
    }
}
