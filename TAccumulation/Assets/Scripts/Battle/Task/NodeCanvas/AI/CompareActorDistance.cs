using System;
using ParadoxNotion.Design;
using NodeCanvas.Framework;

namespace X3Battle
{
    [Category("X3Battle/AI")]
    [Description("---两角色之间的碰撞体距离比较，碰撞体距离为两者模型表面之间最近的距离")]
    public class CompareActorDistance : BattleCondition
    {
        public Operation operation;
        public BBParameter<float> distance = new BBParameter<float>();
        public BBParameter<Actor> actor1 = new BBParameter<Actor>();
        public BBParameter<Actor> actor2 = new BBParameter<Actor>();

        protected override bool OnCheck()
        {
            if (actor1.isNoneOrNull || actor2.isNoneOrNull)
            {
                return false;
            }
            return BattleUtil.CompareActorDistance(distance.value, actor1.value, actor2.value, true, true, BattleUtil.OperatorToCompareOperator(operation));
        }

        protected override string info
        {
            
            get 
            { 
                switch(operation)
                {
                    case Operation.EqualTo:
                        return string.Format("Distance = {0}", distance);
                    case Operation.GreaterThan:
                        return string.Format("Distance > {0}", distance);
                    case Operation.GreaterThanOrEqualTo:
                        return string.Format("Distance >= {0}", distance);
                    case Operation.LessThan:
                        return string.Format("Distance < {0}", distance);
                    case Operation.LessThanOrEqualTo:
                        return string.Format("Distance <= {0}", distance);
                    case Operation.NotEqualTo:
                        return string.Format("Distance != {0}", distance);
                    default:
                        return string.Format("格式错误");
                }
            
            }
        }
    }
}
