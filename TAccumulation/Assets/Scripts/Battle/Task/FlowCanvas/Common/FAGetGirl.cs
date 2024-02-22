using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Function")]
    [Name("获取女主\nGetGirl")]
    public class FAGetGirl : FlowAction
    {
        protected override void _OnRegisterPorts()
        {
            AddValueOutput<Actor>("Actor", () => Battle.Instance.actorMgr.girl);
        }
    }
}
