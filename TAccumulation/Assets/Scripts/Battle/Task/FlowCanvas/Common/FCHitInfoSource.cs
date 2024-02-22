using System;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name("判断伤害类型来源\nCheckHitInfoSource")]
    public class FCHitInfoSource: FlowCondition
    {
        private ValueInput<HitInfo> _vHitInfo;
        public BBParameter<HurtSourceType> hurtSourceType = new BBParameter<HurtSourceType>();

        protected override void _OnAddPorts()
        {
            _vHitInfo = AddValueInput<HitInfo>("HitInfo");
        }

        protected override bool _IsMeetCondition()
        {
            var damageExporter = _vHitInfo.value.damageExporter;
            if (damageExporter is IBuff)
            {
                return hurtSourceType.value == HurtSourceType.Buff;
            }
            else if (damageExporter is SkillMagicField)
            {
                return hurtSourceType.value == HurtSourceType.SkillMagicField;
            }
            else if (damageExporter is SkillMissile)
            {
                return hurtSourceType.value == HurtSourceType.SkillMissile;
            }

            //其他的都作为skill
            return hurtSourceType.value == HurtSourceType.Skill;

        }
    }
}
