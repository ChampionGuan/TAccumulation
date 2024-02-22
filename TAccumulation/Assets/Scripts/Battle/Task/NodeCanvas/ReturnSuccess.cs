using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;
using NodeCanvas.BehaviourTrees;

namespace X3Battle
{
    [Name("ReturnSuccess")]
    [Category("Decorators")]
    [Description("无论孩子节点是成功或失败，此节点返回成功")]
    [ParadoxNotion.Design.Icon("UpwardsArrow")]
    public class ReturnSuccess : BTDecorator
    {
        protected override Status OnExecute(Component agent, IBlackboard blackboard)
        {
            if (decoratedConnection == null)
            {
                return Status.Optional;
            }

            status = decoratedConnection.Execute(agent, blackboard);
            return status == Status.Running ? Status.Running : Status.Success;
        }
    }
}
