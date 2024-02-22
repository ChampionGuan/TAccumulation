using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("角色是否可以切换到目标状态")]
    public class CanToState : BattleCondition
    {
        public ActorMainStateType tgtState;
        protected override string info => "Can To " + tgtState;

        protected override bool OnCheck()
        {
            return _actor.mainState.CanToState(tgtState);
        }
    }
}
