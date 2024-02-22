using FlowCanvas;
using NodeCanvas.Framework;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name("判断伤害Type\nCompareDamageType")]
    public class FACompareDamageType : FlowCondition
    {
        private ValueInput<HitInfo> _viHitInfo;
        public BBParameter<DamageSkillType> skillType = new BBParameter<DamageSkillType>();

        protected override void _OnAddPorts()
        {
            _viHitInfo = AddValueInput<HitInfo>(nameof(HitInfo));
        }

        protected override bool _IsMeetCondition()
        {
            var hitInfo = _viHitInfo.GetValue();
            if (hitInfo == null)
                return false;
            var type = skillType.GetValue();
            
            DamageSkillType damageSkillType = DamageSkillType.None;
            
            if (hitInfo.hitParamConfig.SkillDamageType >= 0)
            {
                damageSkillType = (DamageSkillType) hitInfo.hitParamConfig.SkillDamageType;
                LogProxy.Log("FACompareDamageType hitParamConfig.SkillDamageType == " + damageSkillType);
            }
            else
            {
                damageSkillType = (DamageSkillType)hitInfo.damageExporter.GetSkillType();
                LogProxy.Log("FACompareDamageType damageSkillType == " + damageSkillType);
            }
            LogProxy.Log("FACompareDamageType  type = " + type);
            if (damageSkillType == type)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
    }
}
