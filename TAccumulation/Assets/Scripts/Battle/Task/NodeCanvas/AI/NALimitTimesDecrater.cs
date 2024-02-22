using NodeCanvas.BehaviourTrees;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Name("LimitTimesDecrater")]
    [Description("仅执行N次的装饰节点")]
    [Category("Decorators")]
    public class NALimitTimesDecrater : BTDecorator
    {
        private ActorAIContext _context;
        public int maxTimes = 1;
        private int _executeTimes = 1;

        public override void OnGraphStart()
        {
            _executeTimes = maxTimes;
        }

        protected override Status OnExecute(Component agent, IBlackboard blackboard)
        {
            if (_executeTimes > 0)
            {
                _executeTimes--;
                return decoratedConnection.Execute(agent, blackboard);
            }
            return Status.Success;
        }

        public override void OnGraphStop()
        {
            _executeTimes = maxTimes;
        }
    }
}
