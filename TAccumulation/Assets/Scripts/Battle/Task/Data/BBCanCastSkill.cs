using System;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Serializable]
    public class BBCanCastSkill
    {
        public BBParameter<Actor> skillCaster = new BBParameter<Actor>();
        public BBParameter<Actor> skillTarget = new BBParameter<Actor>();
        public BBParameter<SkillSlotType> skillType = new BBParameter<SkillSlotType>();
        public BBParameter<int> skillIndex = new BBParameter<int>();
        public BBParameter<bool> distance = new BBParameter<bool>();

        public bool CheckCastSkill(Actor actor)
        {
            Actor curActor = skillCaster.isNoneOrNull ? actor : skillCaster.value;
            int slotId = _GetSlotID(curActor);
            if (slotId == -1)
            {
                return false;
            }
            SkillSlot slot = curActor.skillOwner.GetSkillSlot(slotId);
            if (slot == null)
            {
                PapeGames.X3.LogProxy.LogErrorFormat("配置了【角色】：{0}不存在的【技能】：skillType：{1}， skillIndex：{2}，请检查行为树的CanCastSkill节点，模块策划【楚门】！", actor.config.Name, skillType.value, skillIndex.value);
                return false;
            }

            if (!slot.IsEnergyFull())
            {
                return false;
            }

            if (slot.HasMultiSegmentSkill() && slot.GetCanCastCount() <= 0)
            {
                return false;
            }

            if (!slot.HasMultiSegmentSkill() && slot.IsCD())
            {
                return false;
            }

            if (distance.value)
            {
                if (skillTarget.isNoneOrNull || skillTarget.value == null)
                {
                    PapeGames.X3.LogProxy.LogErrorFormat("【角色】：{0}的【技能】：skillType：{1}， skillIndex：{2}的目标未配置，请检查行为树的CanCastSkill节点，请找策划【楚门】或【卡宝】！", actor.config.Name, skillType.value, skillIndex.value);
                    return false;
                }
                Actor targetActor = skillTarget.value;
                float curDistance = Vector3.Distance(curActor.transform.position, targetActor.transform.position);
                if (curDistance < slot.skill.config.MinRange || curDistance > slot.skill.config.MaxRange)
                {
                    return false;
                }
            }
            return true;
        }
        
        private int _GetSlotID(Actor actor)
        {
            int slotId;
            var slotIdVar = actor.skillOwner.GetSlotID(skillType.value, skillIndex.value);
            if (slotIdVar == null)
            {
                PapeGames.X3.LogProxy.LogErrorFormat("【技能】：skillType：{0}， skillIndex：{1},未从角色：{2}中查到，请检查行为树的CanCastSkill节点，请找策划【楚门】或【卡宝】！", skillType.value, skillIndex.value, actor.config.Name);
                slotId = -1;
            }
            else
            {
                slotId = slotIdVar.Value;
            }
            return slotId;
        }
    }
}
