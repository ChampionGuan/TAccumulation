namespace X3Battle
{
    public abstract class FActorAIAction : FlowAction
    {
        private ActorAIContext _aiContext;

        protected override void _OnGraphStart()
        {
            _aiContext = _context as ActorAIContext;
        }
        
        public void AddAction<T>(IAIGoalParams @params) where T : class, IAIActionGoal
        {
            _aiContext?.AddAction<T>(false, @params);
        }
        
        public void AddCondition<T>(IAIGoalParams @params) where T : class, IAIConditionGoal
        {
            _aiContext?.AddCondition<T>(@params);
        }
        
        public void ClearAllActions()
        {
            _aiContext?.ClearAllActions();
        }
    }
}
