using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Function")]
    [Name("获取蓝图持有者\nGetSelf")]
    public class FAGetSelf : FlowAction
    {
        protected override void _OnRegisterPorts()
        {
            AddValueOutput<Actor>("Actor", () => _actor);
        }
    }
}
