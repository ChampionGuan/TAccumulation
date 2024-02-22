using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Function")]
    [Name("获取男主\nGetBoy")]
    public class FAGetBoy : FlowAction
    {
        protected override void _OnRegisterPorts()
        {
            AddValueOutput<Actor>("Actor", () => Battle.Instance.actorMgr.boy);
        }
    }
}
