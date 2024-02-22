using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/AI行为队列")]
    [Description("阻塞行为队列")]
    [Name("AddActionGoal_Wait")]
    public class NAAction_Wait : NActorAIDecorator
    {
        public AIActionParams wait = new AIActionParams();

        protected override Status OnExecute(Component agent, IBlackboard blackboard)
        {
            var result = AddAction<AIWaitActionGoal>(wait, agent, blackboard);
            return result ? Status.Success : Status.Failure;
        }
    }

    [Category("X3Battle/AI/行为队列")]
    [Description("阻塞行为队列")]
    [Name("AddActionGoal_Wait")]
    public class NAAddActionGoalWait : NActorAIAction
    {
        public AIActionParams wait = new AIActionParams();

        protected override void OnExecute()
        {
            var result = AddAction<AIWaitActionGoal>(wait);
            EndAction(result);
        }
    }
}
