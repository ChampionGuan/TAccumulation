using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Function")]
    [Name("获取当前BGM名称\nGetCurBGMName")]
    public class FAGetCurBGMName : FlowAction
    {
        protected override void _OnRegisterPorts()
        {
            AddValueOutput("Name", () =>
            {
                string result = BattleEnv.ClientBridge?.GetCurPlayStateName();
                return result;
            });
        }
    }
}
