using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("暂停或开启群体策略\nPauseGroupStrategy")]
    [Description("暂停或开启群体策略")]
    public class FAPauseGroupStrategy: FlowAction
    {
        [Name("暂停")] 
        public bool pause;
        protected override void _Invoke()
        {
            _battle.battleStrategy.PauseStrategy(pause);
        }
    }
}
