using System;
using UnityEngine;
using UnityEngine.Timeline;
using X3Battle.Timeline.Extension;

namespace X3Battle
{
    [TrackClipYellowColor]
    [TimelineMenu("角色运动/设置RootMotion速率")]
    [Serializable]
    public class RootMotionMultiplierAsset : BSActionAsset<ActionRootMotionMultiplier>
    {
        [LabelText("目标选择")]
        public TargetType targetType;

        [LabelText("最大倍率距离")]
        public float maxMultipleRange;

        [LabelText("最大倍率")]
        [Tooltip("倍率（1.00为1倍）/支持范围0-正无穷")]
        public float maxMultiple;

        [LabelText("最小倍率距离")]
        public float minMultipleRange;

        [LabelText("最小倍率")]
        [Tooltip("倍率（1.00为1倍）/支持范围0-正无穷")]
        public float minMultiple;

        [LabelText("停止位移距离")]
        public float stopRange;
    }

    public class ActionRootMotionMultiplier : BSAction<RootMotionMultiplierAsset>
    {
        private Actor _target;
        
        protected override void _OnEnter()
        {
            _target = context.actor.GetTarget(clip.targetType);
            if (_target != null)
            {
                var distance = _GetDistance();
                var multiplier = 1f;
                if (distance < clip.minMultipleRange)
                {
                    multiplier = clip.minMultiple;
                }
                else if (distance > clip.maxMultipleRange)
                {
                    multiplier = clip.maxMultiple;
                }
                else
                {
                    multiplier = (distance - clip.minMultipleRange) / (clip.maxMultipleRange - clip.minMultipleRange) * (clip.maxMultiple - clip.minMultiple) + clip.minMultiple;
                }
                context.actor.animator.SetRootMotionMultiplier(x: multiplier, z: multiplier);
            }
        }
        
        protected override void _OnUpdate()
        {
            if (_target != null)
            {
                var dis = _GetDistance();
                if (dis < clip.stopRange)
                {
                    context.actor.animator.SetRootMotionMultiplier(x: 0, z: 0);
                }
            }
        }

        protected override void _OnExit()
        {
            if (_target != null)
            {
                context.actor.animator.SetRootMotionMultiplier(x: 1f, z: 1f);
                _target = null;
            }
        }

        private float _GetDistance()
        {
            var pos = context.actor.transform.position - _target.transform.position;
            return pos.magnitude;
        }   
    }
}