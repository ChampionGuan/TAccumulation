using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("获取Debuff数量\nFAGetDebuffNum")]
    public class FAGetDebuffNum : FlowAction
    {
        private ValueInput<Actor> _viActor;

        protected override void _OnRegisterPorts()
        {
            _viActor = AddValueInput<Actor>("Actor");
            AddValueOutput<int>("DebuffNum", () =>
            {
                var actor = _viActor?.GetValue();
                if (actor == null)
                {
                    _LogError("引脚【Actor】没有正确赋值.");
                    return 0;
                }
                return actor.buffOwner.GetAllMatchBuffNum(BuffType.Attribute,BuffTag.Debuff,0,0, true, false, true);
            });
        }
    }
}