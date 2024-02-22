using System;
using UnityEngine.Timeline;
using X3Battle.Timeline.Extension;

namespace X3Battle
{
    [TrackClipYellowColor]
    [TimelineMenu("技能动作/创建触发器")]
    [Serializable]
    public class CreateTriggerAsset : BSActionAsset<ActionCreateTrigger>
    {
        [LabelText("触发器ID", jumpType:JumpModuleType.ViewTrigger)]
        public int triggerID;
    }

    public class ActionCreateTrigger : BSAction<CreateTriggerAsset>
    {
        private int _insID;
        private TriggerSkillContext _triggerContext;
        
        protected override void _OnInit()
        {
            _triggerContext = new TriggerSkillContext(context.skill);
            context.battle.triggerMgr.PreloadTrigger(clip.triggerID, _triggerContext);
        }

        protected override void _OnEnter()
        {
            _insID = context.battle.triggerMgr.AddTrigger(clip.triggerID, _triggerContext, false);
            context.battle.triggerMgr.DisableTrigger(_insID, false);
        }

        protected override void _OnExit()
        {
            context.battle.triggerMgr.RemoveTrigger(_insID);
        }   
    }
}