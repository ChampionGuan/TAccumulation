using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/播放动作")]
    [Serializable]
    public class PlayAnimAsset : BSActionAsset<ActionPlayAnim>
    {
        [LabelText("动画名称")]
        public string animName;

        [LabelText("过渡时间")]
        public float fadeTime;
    }

    public class ActionPlayAnim : BSAction<PlayAnimAsset>
    {
        protected override void _OnEnter()
        {
            if (string.IsNullOrEmpty(clip.animName))
            {
                PapeGames.X3.LogProxy.LogError("错误！，动画名称为空"); 
                return;
            }

            var speed = 1f;
            if (context.skill != null)
            {
                speed = context.skill.GetPlaySpeed();
            }
            
            context.actor.animator.PlayAnim(clip.animName, skipSameState:false, stateSpeed:speed, fadeTime:clip.fadeTime);
        }    
    }
}