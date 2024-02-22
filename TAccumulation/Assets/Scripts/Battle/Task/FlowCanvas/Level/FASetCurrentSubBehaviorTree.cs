using NodeCanvas.BehaviourTrees;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("切换角色当前的子树")]
    public class FASetCurrentSubBehaviorTree : FlowAction
    {
        public enum TargetType
        {
            boy = 1,
            girl = 2
        }
        
        public BBParameter<TargetType> targetType = new BBParameter<TargetType>(TargetType.boy);
        public BBParameter<BehaviourTree> subTree = new BBParameter<BehaviourTree>();
        
        protected override void _Invoke()
        {
            var combatAI = targetType.value == TargetType.boy ? _battle.actorMgr.boy.aiOwner.combatAI : _battle.actorMgr.girl.aiOwner.combatAI;
            //在图层开始的时候设置子树会失败，因为那个时候还没有子树
            if (combatAI != null) combatAI.SwitchCurrentSubTree(subTree.value);
        }


        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            if (!subTree.isNoneOrNull)
            {
                if (targetType.value == TargetType.boy)
                {
                    BattleEnv.BoySubTreeList.Add(subTree.value);
                }
                else
                {
                    BattleEnv.GirlSubTreeList.Add(subTree.value);
                }
            }
        }
        
    }
}
