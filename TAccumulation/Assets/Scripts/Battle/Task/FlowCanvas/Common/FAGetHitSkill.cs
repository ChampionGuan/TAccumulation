using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Function")]
    [Name("获取该次Hit的来源Skill\nGetHitSkill")]
    public class FAGetHitSkill : FlowAction
    {
        private ValueInput<HitInfo> _viHitInfo;

        protected override void _OnRegisterPorts()
        {
            _viHitInfo = AddValueInput<HitInfo>(nameof(HitInfo));
            AddValueOutput<ISkill>(nameof(ISkill), _GetISkill);
        }

        private ISkill _GetISkill()
        {
            if (_viHitInfo == null)
                return null;
            var hitInfo = _viHitInfo.GetValue();
            if (hitInfo == null)
                return null;
            if (!(hitInfo.damageExporter is ISkill skill))
                return null;
            // DONE: 递归找子技能的根技能.
            while (skill.masterExporter != null && skill.masterExporter is ISkill parentSkill)
            {
                skill = parentSkill;
            }
            return skill;
        }
    }
}
