using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Function")]
    [Name("获取关卡Actor\nGetStage")]
    public class FAGetStage : FlowAction
    {
        protected override void _OnRegisterPorts()
        {
            AddValueOutput<Actor>("Actor", () => Battle.Instance.actorMgr.stage);
        }
    }
}
