using System;
using MessagePack;
using UnityEngine;

namespace X3Battle
{
    [BuffAction("锁血")]
    [MessagePackObject]
    [Serializable]
    public class BuffLockHP : BuffActionBase
    {
        [BuffLable("锁血值类型")] 
        [Key(0)] public LockHPType lockType;
        [BuffLable("锁血值")] 
        [Key(1)] public float LockHP;
        
        [NonSerialized]
        private Action<EventPreExportDamage> _actionOnDamage;
        
        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.LockHP;
            _actionOnDamage = _OnDamage;
        }

        public override void OnAdd(int layer)
        {
            _actor.battle.eventMgr.AddListener<EventPreExportDamage>(EventType.OnPreExportDamage, _actionOnDamage, "BuffLockHP._OnDamage");
        }

        public override void OnDestroy()
        {
            _actor.battle.eventMgr.RemoveListener<EventPreExportDamage>(EventType.OnPreExportDamage, _actionOnDamage);
            ObjectPoolUtility.BuffLockHPPool.Release(this);
        }

        private void _OnDamage(EventPreExportDamage args)
        {
            if (args.damageInfo.actor != _owner.actor)
                return;
  
            float res = 0;
            args.dynamicDamageInfo.isLockHp = true;
            if (lockType == LockHPType.Fixed)
            {
                res = LockHP;
            }
            else
            {
                res = _actor.attributeOwner.GetAttrValue(AttrType.MaxHP) * LockHP / 1000f;
            }

            if (res <= 0)
            {
                PapeGames.X3.LogProxy.LogError($"buff锁血配置错误");
            }
            //传递出去给Damage模块使用，Todo:优化写法
            //传最高锁血值的buff
            if (args.dynamicDamageInfo.lockHpValue > res )
            {
                return;
            }
            args.dynamicDamageInfo.lockHpBuffId = _owner.ID;
            args.dynamicDamageInfo.lockHpValue = res;
        }
        
        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.BuffLockHPPool.Get();
            action.lockType = lockType;
            action.LockHP = LockHP;
            return action;
        }
    }
}