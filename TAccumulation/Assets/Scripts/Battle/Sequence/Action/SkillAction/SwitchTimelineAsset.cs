using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("技能动作/切换动作模组 (下标)")]
    [Serializable]
    public class SwitchTimelineAsset : BSActionAsset<ActionSwitchTimeline>
    {
        [LabelText("动作模组下标")]
        public int actionModuleIdx;
    }

    public class ActionSwitchTimeline : BSAction<SwitchTimelineAsset>
    {
        protected override void _OnEnter()
        {
            var skill = context.skill as SkillTimeline;
            if (skill != null)
            {
                skill.SwitchActionModule(clip.actionModuleIdx);   
            }
        }
    }
}