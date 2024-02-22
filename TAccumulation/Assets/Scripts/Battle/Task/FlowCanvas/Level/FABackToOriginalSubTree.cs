using NodeCanvas.BehaviourTrees;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("恢复角色当前的子树到动态切换前的状态")]
    public class FABackToOriginalSubTree : FlowAction
    {
        public BBParameter<Actor> targetActor = new BBParameter<Actor>();

        protected override void _Invoke()
        {
            var combatAI =  targetActor.value?.aiOwner?.combatAI;
            if (combatAI != null) combatAI.BackToOriginalSubTree();
        }
    }
}
