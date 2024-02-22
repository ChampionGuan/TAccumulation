using FlowCanvas;
using ParadoxNotion.Design;
using NodeCanvas.Framework;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("判断两单位是否在指定距离内\nFACompareActorDistance")]
    public class FACompareActorDistance : FlowAction
    {
        public Operation operation;
        public BBParameter<float> distance = new BBParameter<float>();
        public BBParameter<Actor> actor1 = new BBParameter<Actor>();
        public BBParameter<Actor> actor2 = new BBParameter<Actor>();
        public bool calcActor1Radius;
        public bool calcActor2Radius;

        protected override void _OnRegisterPorts()
        {
            AddValueOutput<bool>("Result", _Compare);
        }
        
        private bool _Compare()
        {
            if (actor1.isNoneOrNull || actor2.isNoneOrNull)
            {
                return false;
            }
            return BattleUtil.CompareActorDistance(distance.value, actor1.value, actor2.value, calcActor1Radius, calcActor2Radius, BattleUtil.OperatorToCompareOperator(operation));
        }
    }
}
