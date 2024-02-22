using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Name("获取此触发器蓝图所属被动技能的ISkill\nGetTriggerSkill")]
    public class FAGetTriggerSkill : FlowAction
    {
        protected override void _OnRegisterPorts()
        {
            AddValueOutput("ISkill", () =>
            {
                var skill = _source as SkillPassive;
                return skill;
            });
        }
    }
}