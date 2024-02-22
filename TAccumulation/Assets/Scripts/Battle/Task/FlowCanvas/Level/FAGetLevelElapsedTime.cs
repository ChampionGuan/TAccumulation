using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("获取从关卡开始度过的时间\nGetLevelElapsedTime")]
    public class FAGetLevelElapsedTime : FlowAction
    {
        protected override void _OnRegisterPorts()
        {
            AddValueOutput<float>("float", () => Battle.Instance.levelFlow.levelTime);
        }
    }
}
