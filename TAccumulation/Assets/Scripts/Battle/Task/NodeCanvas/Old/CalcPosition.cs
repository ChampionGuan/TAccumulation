using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Old")]
    [Description("---通过设置DirType类型，计算目标点\n" +
                 "---DirA：以TargetA为基准点，并且以TargetA的朝向为z轴，旋转Angle角度\n" +
                 "---DirB：以TargetB为基准点，并且以TargetB的朝向为z轴，旋转Angle角度\n" +
                 "---DirAB：以TargetA为基准点，并且以TargetA到TargetB的朝向为z轴，旋转Angle角度\n" +
                 "---DirBA：以TargetB为基准点，并且以TargetB到TargetA的朝向为z轴，旋转Angle角度")]
    public class CalcPosition : BattleAction
    {
        public BBParameter<Actor> targetA = new BBParameter<Actor>();
        public BBParameter<Actor> targetB = new BBParameter<Actor>();
        public DirType dirType;
        public bool calcRadius;
        public BBParameter<float> angle = new BBParameter<float>();
        public BBParameter<Vector3> offset = new BBParameter<Vector3>();
        public BBParameter<Vector3> result = new BBParameter<Vector3>();

        /*
        protected override string info
        {
            get
            {
                switch (dirType)
                {
                    case DirType.DirA: return $"获取以TargetA为基准点，并且以TargetA的朝向，旋转{angle.value}角度后的点";
                    case DirType.DirB: return $"获取以TargetB为基准点，并且以TargetB的朝向，旋转{angle.value}角度后的点";
                    case DirType.DirAB: return $"获取以TargetA为基准点，并且以TargetA到TargetB的朝向，旋转{angle.value}角度后的点";
                    case DirType.DirBA: return $"获取以TargetB为基准点，并且以TargetB到TargetA的朝向，旋转{angle.value}角度后的点";
                }

                return string.Empty;
            }
        }
        */

        protected override void OnExecute()
        {
            if ((dirType == DirType.DirA || dirType == DirType.DirAB || dirType == DirType.DirBA) && targetA.isNoneOrNull)
            {
                EndAction(false);
                return;
            }

            if ((dirType == DirType.DirB || dirType == DirType.DirAB || dirType == DirType.DirBA) && targetB.isNoneOrNull)
            {
                EndAction(false);
                return;
            }

            var radius = 0f;
            var forward = Vector3.zero;
            var position = Vector3.zero;
            if (dirType == DirType.DirA)
            {
                forward = targetA.value.transform.forward;
                position = targetA.value.transform.position;
                radius = targetA.value.radius;
            }
            else if (dirType == DirType.DirB)
            {
                forward = targetB.value.transform.forward;
                position = targetB.value.transform.position;
                radius = targetB.value.radius;
            }
            else if (dirType == DirType.DirAB)
            {
                forward = targetB.value.transform.position - targetA.value.transform.position;
                position = targetA.value.transform.position;
                radius = targetA.value.radius;
            }
            else if (dirType == DirType.DirBA)
            {
                forward = targetA.value.transform.position - targetB.value.transform.position;
                position = targetB.value.transform.position;
                radius = targetB.value.radius;
            }

            if (forward != Vector3.zero)
            {
                //此处忽略y轴
                forward.y = 0;
                forward.Normalize();
                radius = calcRadius ? radius : 0;

                if (angle.value != 0)
                {
                    forward = Quaternion.AngleAxis(angle.value, Vector3.up) * forward;
                }

                var result = Vector3.zero;
                if (offset.value.z != 0)
                {
                    result += forward * (offset.value.z + radius);
                }

                if (offset.value.y != 0)
                {
                    result += Vector3.up * (offset.value.y + radius);
                }

                if (offset.value.x != 0)
                {
                    result += Quaternion.LookRotation(forward) * Vector3.right * (offset.value.x + radius);
                }

                this.result.value = position + result;
            }
            else
            {
                this.result.value = position;
            }

            EndAction(true);
        }

        public enum DirType
        {
            DirA = 0, //目标A的朝向
            DirB = 1, //目标B的朝向
            DirAB = 2, //目标A到B的朝向
            DirBA = 3, //目标B到A的朝向
        }
    }
}
