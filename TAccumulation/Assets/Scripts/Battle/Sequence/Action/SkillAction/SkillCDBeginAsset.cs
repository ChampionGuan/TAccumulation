using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("技能动作/开始计算CD")]
    [Serializable]
    public class SkillCDBeginAsset : BSActionAsset<ActionSkillCdBegin>
    {
    }

    public class ActionSkillCdBegin : BSAction<SkillCDBeginAsset>
    {
        protected override void _OnEnter()
        {
            context.skill.BeginCD();
        } 
    }
}