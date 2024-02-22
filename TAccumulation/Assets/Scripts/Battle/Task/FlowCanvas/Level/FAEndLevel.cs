using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("关卡结束\nLevelEnd")]
    public class FAEndLevel : FlowAction
    {
        protected override void _Invoke()
        {
            _battle.levelFlow.EndFlowFinished();
        }
    }
}
