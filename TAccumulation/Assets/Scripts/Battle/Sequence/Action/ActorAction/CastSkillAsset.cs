using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/让指定Actor释放技能")]
    [Serializable]
    public class CastSkillAsset : BSActionAsset<ActionCastSkill>
    {
        [LabelText("技能释放者(当前Actor为基准)")]
        public TargetType casterType;

        [LabelText("释放目标(当前Actor为基准)")]
        public TargetType targetType;

        [LabelText("技能槽位类型")]
        public SkillSlotType skillSlotType;

        [LabelText("技能槽位ID", jumpType:JumpModuleType.ViewSkill)]
        public int skillSlotIndex;

        [LabelText("重置释放者状态")] 
        public bool resetCaster;

        [LabelText("忽略优先级检测")] 
        public bool notCheckPriority;
    }

    public class ActionCastSkill : BSAction<CastSkillAsset>
    {
        protected override void _OnEnter()
        {
            var caster = context.actor.GetTarget(clip.casterType);
            if (caster == null)
            {
                PapeGames.X3.LogProxy.LogWarning("ActionCastSkill技能释放着或者目标找不到，直接跳出！");
                return;
            }
            
            var slotId = caster.skillOwner.GetSlotID(clip.skillSlotType, clip.skillSlotIndex);
            if (slotId == null)
            {
                PapeGames.X3.LogProxy.LogWarningFormat("ActionCastSkill, type:{0}, index:{1}对应的槽位不存在，直接跳出!", clip.skillSlotType, clip.skillSlotIndex);
                return;
            }
            
            // 不在CD中并且能量满足，才会重置单位
            var slot = caster.skillOwner.GetSkillSlot(slotId.Value);
            if (clip.resetCaster && !slot.IsCD() && slot.IsEnergyFull())
            {
                caster.ForceIdle();
            }

            var target = context.actor.GetTarget(clip.targetType);
            caster.skillOwner.TryCastSkillBySlot(slotId.Value, target, forceSetTarget:true, notCheckPriority:clip.notCheckPriority);
        }    
    }
}