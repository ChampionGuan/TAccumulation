using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("引导结束\nGuideEnd")]
    public class FAEndGuide : FlowAction
    {
        protected override void _Invoke()
        {
            BattleEnv.LuaBridge.TryUnregisterGuideEvent();
            LogProxy.LogFormat("【新手引导】【引导开始】结束监听引导事件. Graph:{0}", this._graphOwner.name);
        }
    }
}
