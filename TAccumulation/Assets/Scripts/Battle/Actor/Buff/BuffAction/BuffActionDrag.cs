using System;
using MessagePack;
using UnityEngine;

namespace X3Battle
{
    [BuffAction("往目的地拖拽,目前是策划需求自动实现,不能配置")]
    [MessagePackObject]
    [Serializable]
    public class BuffActionDrag:BuffActionBase
    {
        //传入参数
        [NonSerialized]
        private Vector3 _targetPosition;
        private float _dragTime;
        private float _speed;
        private TweenEaseType _tweenEaseType;
        //计算用变量
        private float _distance;
        public override void Init(X3Buff buff)
        {
            _targetPosition = Vector3.zero;
            _dragTime = 0;
            _speed = 0;
            _distance = 0;
            base.Init(buff);
            buffActionType = BuffAction.Drag;
        }

        /// <summary>
        /// 设置拖拽数据，在这个时候计算移动速度
        /// </summary>
        /// <param name="position">世界坐标</param>
        /// <param name="dragTime">拖拽持续时间</param>
        /// <param name="tweenEaseType">曲线类型</param>
        public void SetDragData(Vector3 position,float dragTime,TweenEaseType tweenEaseType)
        {
            _targetPosition = position;
            _dragTime = dragTime;
            _tweenEaseType = tweenEaseType;
            
            //基于初始距离计算
            _distance = (position-_actor.transform.position).magnitude;
        }

        public override void Update(float deltaTime)
        {
            if (_owner.curTime > _dragTime)
            {
                return;
            }
            if (_actor.isDead)
                return;

            if (_actor.stateTag == null || _actor.stateTag.IsActive(ActorStateTagType.TractionImmunity))
            {
                return;
            }

            if (_actor.model == null)
            {
                return;
            }

            float deltaProgress = BattleUtil.CalculateTweenValue(_owner.curTime/_dragTime,_tweenEaseType)- BattleUtil.CalculateTweenValue((_owner.curTime-deltaTime)/_dragTime,_tweenEaseType);
            
            // DONE: 向心方向
            Vector3 centerForward = _targetPosition- _actor.transform.position;
            centerForward.y = 0f;
            float truncationSqr = centerForward.sqrMagnitude;
            centerForward.Normalize();
            //算出当前移动距离
            float s = _distance * deltaProgress;
            
            //计算质量是否超过最大值
            float weight = 0;
            if (_actor.type == ActorType.Hero || _actor.type == ActorType.Monster)
            {
                weight = _actor.config.Weight;
            }
            
            if (weight <= 0 || weight > TbUtil.battleConsts.TractionWeight)
            {
                return;
            }
            
            //截断
            if (s * s > truncationSqr)
            {
                s = Mathf.Sqrt(truncationSqr);
            }
            _actor.transform.SetPosition(_actor.transform.position + centerForward * s, true);
        }

        public override void OnDestroy()
        {
            _targetPosition = Vector3.zero;
            _dragTime = 0;
            _speed = 0;
            _distance = 0;
            ObjectPoolUtility.BuffActionDragPool.Release(this);
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.BuffActionDragPool.Get();
            action._targetPosition = this._targetPosition;
            action._dragTime = this._dragTime;
            action._speed = this._speed;
            action._distance = this._distance;
            return action;
        }
    }
}