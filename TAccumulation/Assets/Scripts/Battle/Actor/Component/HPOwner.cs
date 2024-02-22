using System;
using System.Collections.Generic;


namespace X3Battle
{
    public enum HpChangeType
    {
        Recover = 1,
        Damage = 2,
        Deduct = 3,
        Other = 4,
    }
    
    [Flags]
    public enum HpChangeTypeFlag
    {
        Recover = 1 << HpChangeType.Recover,
        Damage = 1 << HpChangeType.Damage,
        Deduct = 1 << HpChangeType.Deduct,
        Other = 1 << HpChangeType.Other,
    }
    
    public class HPOwner : ActorComponent
    {
        public bool hpRecoverEnable = true;
        private const float PerthRatio = 0.001f;
        private const float RecoverInterval = 0.2f;//先写死固定0.2s的回血间隔
        private float _currentInterval = 0f;

        public HPOwner() : base(ActorComponentType.HP)
        {
        }

        public override void OnBorn()
        {
            //回血当前版本默认初始是0
            actor.attributeOwner.SetAttrValue(AttrType.HpRecoverPerth, 0);
        }

        protected override void OnUpdate()
        {
            if (!hpRecoverEnable || actor.isDead)
            {
                return;
            }

            if (_currentInterval < RecoverInterval)
            {
                _currentInterval += battle.deltaTime;
                return;
            }
            //TODO ,事件开启
            float recoverValue = actor.attributeOwner.GetAttrValue(AttrType.HpRecoverPerth);
            if (recoverValue > 0f)
            {
                var hpRecover = actor.attributeOwner.GetAttrValue(AttrType.MaxHP) * recoverValue * PerthRatio;
                Add(0, 0.0f, hpRecover * RecoverInterval);
            }
            _currentInterval -= RecoverInterval;
        }

        public void Add(float addition, float percent, float basic,HpChangeType changeType = HpChangeType.Recover)
        {
            if (actor.stateTag.IsActive(ActorStateTagType.RecoverIgnore))
            {
                if (addition > 0) addition = 0;
                if (percent > 0) percent = 0;
                if (basic > 0) basic = 0;
            }

            var hpAttr = actor.attributeOwner.GetAttr(AttrType.HP);
            //满血时不再让自动回血发消息
            var maxHP = actor.attributeOwner.GetAttr(AttrType.MaxHP);
            if (hpAttr.GetValue() >= maxHP.GetValue())
            {
                return;
            }

            float oldValue = hpAttr.GetValue();
            hpAttr.Add(addition, percent, basic);
            _SendHpChangeEvent(changeType,hpAttr.GetValue() - oldValue);
        }

        public void Sub(float addition, float percent, float basic,HpChangeType changeType = HpChangeType.Damage)
        {
            if (actor.stateTag.IsActive(ActorStateTagType.RecoverIgnore))
            {
                if (addition < 0) addition = 0;
                if (percent < 0) percent = 0;
                if (basic < 0) basic = 0;
            }

            var hpAttr = actor.attributeOwner.GetAttr(AttrType.HP);
            float oldValue = hpAttr.GetValue();
            hpAttr.Sub(addition, percent, basic);
            _SendHpChangeEvent(changeType,hpAttr.GetValue() - oldValue);
        }
        
        /// <summary>
        /// 跳过判断，直接扣血
        /// </summary>
        public void DeductHp(float value)
        {
            var hpAttr = actor.attributeOwner.GetAttr(AttrType.HP);
            hpAttr.Sub(value, 0);
            _SendHpChangeEvent(HpChangeType.Deduct,-value);
        }

        private void _SendHpChangeEvent(HpChangeType changeType, float changeValue)
        {
            var eventData = actor.eventMgr.GetEvent<EventActorHealthChange>();
            eventData.Init(actor);
            eventData.changeType = changeType;
            eventData.changeValue = changeValue;
            actor.eventMgr.Dispatch(EventType.ActorHealthChange, eventData);
        }
    }
}