using System;
using System.Collections.Generic;
using System.Numerics;
using PapeGames.X3;
using ProceduralAnimation;

namespace X3Battle
{
    public class ActorShield : ActorComponent
    {
        private Dictionary<X3Buff, float> _shieldBuffDict = new Dictionary<X3Buff, float>(3);

        public ActorShield() : base(ActorComponentType.Shield)
        {
        }

        public void AddHpShield(X3Buff buff, float addValue)
        {
            // 发送即将添加护盾事件
            // 添加值和效率
            var addInfo = ObjectPoolUtility.ShieldAddInfoPool.Get();
            addInfo.addValue = addValue;
            addInfo.addEfficiency = actor.attributeOwner.GetAttrValue(AttrType.HpShieldObtainEfficiency) + 1f;
            // 发送事件外部进行修饰
            var eventData = battle.eventMgr.GetEvent<EventOnAddShield>();
            eventData.Init(buff, actor, addInfo);
            battle.eventMgr.Dispatch(EventType.OnAddShield, eventData);
            // 获取最终的添加值
            addValue = addInfo.addValue * addInfo.addEfficiency;
            ObjectPoolUtility.ShieldAddInfoPool.Release(addInfo);
            
            LogProxy.Log($"获得护盾，buff {buff.ID}, 护盾数值 = {addValue}, 护盾获取系数{addInfo.addEfficiency}");
            if (_shieldBuffDict.ContainsKey(buff))
            {
                _shieldBuffDict[buff] += addValue;
            }
            else
            {
                _shieldBuffDict.Add(buff, addValue);
            }
            _UpdateHpShield();
        }

        public void RemoveHpShield(X3Buff buff)
        {
            if (_shieldBuffDict.Remove(buff))
            {
                LogProxy.Log($"血量护盾移除，buff {buff.ID}");
                _UpdateHpShield();
            }
        }

        /// <summary>
        /// 获取剩余时间最少的护盾
        /// </summary>
        private X3Buff _GetMinimumTimeShield()
        {
            X3Buff result = null;
            foreach (var shieldBuff in _shieldBuffDict)
            {
                if (result == null || shieldBuff.Key.leftTime < result.leftTime)
                {
                    result = shieldBuff.Key;
                }
            }

            return result;
        }

        /// <summary>
        /// 伤害打在血量护盾上（扣除血量护盾）
        /// </summary>
        /// <param name="damage">伤害</param>
        /// <param name="damageFactor">护盾角度系数</param>
        /// <returns></returns>
        public float DamageHpShield(float damage, float damageFactor)
        {
            var hpShieldRatio = actor.attributeOwner.GetAttrValue(AttrType.HpShieldRatio) + 1f;
            while (_shieldBuffDict.Count > 0 && damage > 0)
            {
                var minimumTimeBuff = _GetMinimumTimeShield();
                if (minimumTimeBuff.isDestroyed)
                {
                    LogProxy.LogError($"出现护盾生命周期错误。{minimumTimeBuff}");
                    _shieldBuffDict.Remove(minimumTimeBuff);
                    continue;
                }

                float hpShieldValue = _shieldBuffDict[minimumTimeBuff] * hpShieldRatio * damageFactor;
                if (hpShieldValue > damage)
                {
                    LogProxy.Log($"血量护盾伤害抵挡但没有破盾，护盾buff{minimumTimeBuff.ID},原始护盾值{_shieldBuffDict[minimumTimeBuff]},计算护盾值{hpShieldValue},伤害值{damage}，护盾剩余值{(hpShieldValue - damage) / (hpShieldRatio * damageFactor)}");
                    _shieldBuffDict[minimumTimeBuff] = (hpShieldValue - damage) / (hpShieldRatio * damageFactor);
                    damage = 0f;
                }
                else
                {
                    LogProxy.Log($"血量护盾伤害破盾，破盾buff{minimumTimeBuff.ID},原始护盾值{_shieldBuffDict[minimumTimeBuff]},计算护盾值{hpShieldValue},伤害值{damage}");
                    damage -= hpShieldValue;
                    _shieldBuffDict.Remove(minimumTimeBuff);
                    minimumTimeBuff.Destroy();
                }
            }

            LogProxy.Log($"血量护盾扣除逻辑，护盾角度系数{damageFactor},护盾伤害减免系数{hpShieldRatio},溢出伤害{damage}");

            _UpdateHpShield();
            return damage;
        }

        /// <summary>
        /// 更新血量护盾
        /// </summary>
        private void _UpdateHpShield()
        {
            var shieldAttr = actor.attributeOwner.GetAttr(AttrType.HpShield);
            var oldValue = shieldAttr.GetValue();
            shieldAttr.Set(_GetShieldValue());
            var newValue = shieldAttr.GetValue();
            if (oldValue != newValue)
            {
                // 发送护盾变化事件
                var eventData = battle.eventMgr.GetEvent<EventShieldChange>();
                eventData.Init(actor, oldValue, newValue);
                battle.eventMgr.Dispatch(EventType.ShieldChange, eventData);
            }
        }

        private float _GetShieldValue()
        {
            if (_shieldBuffDict.Count == 0)
            {
                return 0f;
            }
            float currentShield = 0f;
            foreach (var shield in _shieldBuffDict)
            {
                currentShield += shield.Value;
            }
            return currentShield;
        }
    }

    // 护盾添加信息，抛事件出去让外部修改值
    public class ShieldAddInfo :IReset
    {
        public float addValue;
        public float addEfficiency;
        
        public void Reset()
        {
            addValue = 0;
            addEfficiency = 0;
        }
    }
}