using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name("判断两个单位在Y轴上的夹角区间\nCompareActorYAngle")]
    public class FCCompareActorAngleY : FlowCondition
    {
        private ValueInput<Actor> _viSourceActor;
        private ValueInput<Actor> _viTargetActor;

        public BBParameter<float> minValue = new BBParameter<float>();
        public BBParameter<float> maxValue = new BBParameter<float>();
        
        protected override void _OnAddPorts()
        {
            _viSourceActor = AddValueInput<Actor>("SourceActor");
            _viTargetActor = AddValueInput<Actor>("TargetActor");
        }

        protected override bool _IsMeetCondition()
        {
            var sourceActor = _viSourceActor.GetValue();
            if (sourceActor == null)
            {
                _LogError("请联系策划【卡宝】,【判断两个单位在Y轴上的夹角区间 CompareActorYAngle】 节点【SourceActor】引脚未正确配置.");
                return false;
            }

            if (sourceActor.model == null)
            {
                _LogError("请联系策划【卡宝】,【判断两个单位在Y轴上的夹角区间 CompareActorYAngle】 节点【SourceActor】引脚Actor没有ActorModel组件.");
                return false;
            }
            
            var targetActor = _viTargetActor.GetValue();
            if (targetActor == null)
            {
                _LogError("请联系策划【卡宝】,【判断两个单位在Y轴上的夹角区间 CompareActorYAngle】 节点【TargetActor】引脚未正确配置.");
                return false;
            }

            if (targetActor.model == null)
            {
                _LogError("请联系策划【卡宝】,【判断两个单位在Y轴上的夹角区间 CompareActorYAngle】 节点【TargetActor】引脚Actor没有ActorModel组件.");
                return false;
            }

            var min = minValue.GetValue();
            var max = maxValue.GetValue();
            if (min > max)
            {
                _LogError("请联系策划【卡宝】,【判断两个单位在Y轴上的夹角区间 CompareActorYAngle】 节点【minValue】参数应小于等于【maxValue】参数.");
                return false;
            }

            var forward = sourceActor.transform.forward;
            var dir = (targetActor.transform.position - sourceActor.transform.position).normalized;
            var angle = Vector3.Angle(forward, dir);
            if (angle < min || angle > max)
            {
                return false;
            }
            return true;
        }
    }
}
