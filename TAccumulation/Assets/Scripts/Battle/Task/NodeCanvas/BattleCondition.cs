using NodeCanvas.BehaviourTrees;
using NodeCanvas.Framework;
using NodeCanvas.StateMachines;

namespace X3Battle
{
    public class BattleCondition : ConditionTask
    {
        protected GraphContext _context { get; private set; }
        protected Battle _battle => (_context is IBattleContext battleContext) ? battleContext.battle : null;
        protected Actor _actor => (_context is IActorContext actorContext) ? actorContext.actor : null;
        protected FSM _fsm => ownerSystem as FSM;
        protected BehaviourTree _aiTree => ownerSystem as BehaviourTree;

        public sealed override void OnGraphStart()
        {
            base.OnGraphStart();
            _context = blackboard.GetVariable(BattleConst.ContextVariableName).value as GraphContext;
            _OnGraphStart();
        }

        protected virtual void _OnGraphStart()
        {

        }

        public sealed override void OnGraphStop()
        {
            base.OnGraphStop();
            _OnGraphStop();
        }
        protected virtual void _OnGraphStop()
        {

        }
    }
}
