using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/开关角色战场灯")]
    [Serializable]
    public class SwitchActorSceneLightAsset : BSActionAsset<ActionSwitchActorSceneLight>
    {
        public bool enable;
        public bool isEndRevert = true;
    }

    public class ActionSwitchActorSceneLight : BSAction<SwitchActorSceneLightAsset>
    {
        //不支持播放多个同样ID的特效/音效
        protected override void _OnEnter()
        {
            context.actor.model.SwitchSceneLight(clip.enable);
        }

        protected override void _OnExit()
        {
            if (clip.isEndRevert)
                context.actor.model.SwitchSceneLight(!clip.enable);
        }
    }
}