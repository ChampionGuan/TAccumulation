using System;
using ParadoxNotion.Design;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/AI")]
    [Description("---角色与目标点之间的距离比较\n" +
                 "---与设定Distance值进行比较")]
    public class CompareDistance : BattleCondition
    {
        public Operation operation;
        public BBParameter<float> distance = new BBParameter<float>();
        public BBParameter<Actor> actor = new BBParameter<Actor>();
        public BBParameter<Vector3> targetPos = new BBParameter<Vector3>();
        public bool calcActorRadius;

        protected override bool OnCheck()
        {
            if (actor.isNoneOrNull)
            {
                return false;
            }

            var dis = distance.value;
            if (calcActorRadius)
            {
                dis += actor.value.radius;
            }

            dis *= dis;
            var sqrDis = (targetPos.value - actor.value.transform.position).sqrMagnitude;
            switch (operation)
            {
                case Operation.EqualTo:
                    return sqrDis == dis;
                case Operation.LessThan:
                    return sqrDis < dis;
                case Operation.LessThanOrEqualTo:
                    return sqrDis <= dis;
                case Operation.NotEqualTo:
                    return sqrDis != dis;
                case Operation.GreaterThanOrEqualTo:
                    return sqrDis >= dis;
                case Operation.GreaterThan:
                    return sqrDis > dis;
            }

            return true;
        }
    }
}
