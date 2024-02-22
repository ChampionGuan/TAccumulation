using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TrackClipYellowColor]
    [TimelineMenu("角色动作/攻击吸附")]
    [Serializable]
    public class AttackAdsorbAsset : BSActionAsset<ActionAttackAdsorb>
    {
        [LabelText("目标类型")]
        public TargetType targetType;
        
        [LabelText("吸附生效最大距离")]
        public float adsorbMaxDistance;

        [LabelText("吸附生效最小距离")]
        public float adsorbMinDistance;
        
        [LabelText("吸附距离")]
        public float adsorbDistance;
        
        [LabelText("停止吸附距离")]
        public float stopAdsorbDistance;
    }

    public class ActionAttackAdsorb : BSAction<AttackAdsorbAsset>
    {
        private bool _isUpdate;//是否Update
        protected override void _OnEnter()
        {
            _isUpdate = true;
            
            var target = context.actor.GetTarget(clip.targetType);
            if (target == null || context.actor == null)
            {
                _isUpdate = false;
                return;
            }
            
            //如果目标等于自身 或者自身已经死亡
            if (target == context.actor || context.actor.isDead)
            {
                _isUpdate = false;
                return;
            }

            if (clip.adsorbDistance <= 0)
            {
                _isUpdate = false;
                return;
            }
            
            //如果不满足距离直接失效
            var distance = BattleUtil.GetActorDistance(context.actor, target);
            if (distance <= 0 || distance < clip.adsorbMinDistance || distance > clip.adsorbMaxDistance)
            {
                _isUpdate = false;
                return;
            }
            
            //卡帧补偿位移
            if (startOffsetTime > 0 && _isUpdate)
            {
                var moveLength = startOffsetTime / duration * clip.adsorbDistance;
                moveLength = _DistanceCheck(moveLength, distance);
                _EvalMove(moveLength);
            }
        }

        protected override void _OnUpdate()
        {
            if (!_isUpdate)
                return;

            if (context.actor == null || context.actor.isDead)
            {
                _isUpdate = false;
                return;
            }
            
            //小于停止吸附距离离直接停止
            var distance = BattleUtil.GetActorDistance(context.actor, context.actor.GetTarget(clip.targetType));
            if (distance <= clip.stopAdsorbDistance)
            {
                _isUpdate = false;
                return;
            }
            
            //移动位置
            var movePos = deltaTime / duration * clip.adsorbDistance;
            movePos = _DistanceCheck(movePos, distance);
            _EvalMove(movePos);
        }

        ///检查移动的距离是否合理
        private float _DistanceCheck(float moveLength, float distance)
        {
            if (distance <= clip.stopAdsorbDistance)
                return 0;
            
            if (moveLength > distance - clip.stopAdsorbDistance)
                moveLength = distance - clip.stopAdsorbDistance;
            
            return moveLength;
        }
        // 计算位移
        private void _EvalMove(float moveLength)
        {
            var forward = context.actor.transform.forward;
            var movePosV3 = forward.normalized * moveLength;
            context.actor.transform.SetPosition(context.actor.transform.position + movePosV3);
        }      
    }
}