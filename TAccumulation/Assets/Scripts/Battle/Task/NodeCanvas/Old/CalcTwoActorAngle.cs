using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Old")]
    [Description("计算角色当前面向与目标连线之间的夹角")]
    public class CalcTwoActorAngle : BattleAction
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<Actor> target = new BBParameter<Actor>();
        public BBParameter<float> storeResult = new BBParameter<float>();

        /*
        protected override string info => "计算source与target目标直接的xz平面夹角";
        */

        protected override void OnExecute()
        {
            if (source.isNoneOrNull || target.isNoneOrNull)
            {
                EndAction(false);
                return;
            }

            var dirA = source.value.transform.forward;
            var dirB = target.value.transform.position - source.value.transform.position;

            dirA.y = 0;
            dirB.y = 0;
            storeResult.value = Vector3.Angle(dirA, dirB);
            EndAction(true);
        }
    }
}
