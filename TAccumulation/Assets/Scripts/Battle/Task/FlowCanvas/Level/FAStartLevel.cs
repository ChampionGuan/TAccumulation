using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("关卡开始\nLevelBegin")]
    public class FAStartLevel : FlowAction
    {
        protected override void _Invoke()
        {
            _battle.actorMgr.OnLevelStart();
            BattleUtil.SetUIActive(true);
            _battle.dialogue.OnLevelStart();
        }
    }
}
