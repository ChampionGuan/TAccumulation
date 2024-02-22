using System;
using System.Collections;
using System.Collections.Generic;
using MessagePack;
using UnityEngine;

namespace X3Battle
{
    [Union(0, typeof(AddActorStateTag))]
    [Union(1, typeof(BuffEndDamage))]
    // [Union(2, typeof(BasicBuffAction))]
    [Union(3, typeof(BuffHPShield))]
    [Union(4, typeof(BuffActionHalo))]
    [Union(5, typeof(BuffLockHP))]
    [Union(6, typeof(PlayMatAnim))]
    [Union(7, typeof(DynamicChangeAttr))]
    [Union(8, typeof(DynamicDamageModify))]
    [Union(9, typeof(SetToughness))]
    [Union(10, typeof(AddTaunt))]
    [Union(11, typeof(ForbidEnergyRecover))]
    [Union(12, typeof(BuffActionGhost))]
    [Union(13, typeof(BuffActionFrozen))]
    [Union(14, typeof(BuffActionVertigo))]
	[Union(15, typeof(BuffActionWeak))]
    [Union(16, typeof(PlayGroupFx))]
    [Union(17, typeof(BuffActionUnVisibility))]
    [Union(18, typeof(BuffActionRemoveDebuff))]
    [Union(19, typeof(BuffActionDrag))]
    [Union(20, typeof(SkillNoConsumption))]
    [Union(21, typeof(DisableSkill))]
    [Union(22, typeof(BuffActionAttrModifier))]
    [Union(23, typeof(RemoveMatchBuff))]
    [Union(24, typeof(BuffActionPlayFx))]
    [Union(25, typeof(BuffActionChangeMaxHP))]
    [Union(26, typeof(BuffActionWitchTime))]
    [Union(27, typeof(BuffActionPlayPPV))]
    [Union(28, typeof(BuffModifySkillDamage))]
    [MessagePackObject]
    [Serializable]
    public abstract class BuffActionBase
    {
        [NonSerialized]
        protected X3Buff _owner;
        [NonSerialized]
        protected Actor _actor;

        [IgnoreMember] public BuffAction buffActionType;
        
        public virtual void Init(X3Buff buff)
        {
            _owner = buff;
            _actor = _owner.actor;
        }
        
        // TODO 待后期三夕 重构删除
        public virtual void Init (BasicBuffActionConfig config) 
        {
            
        }

        public virtual void OnAddRepeatedly(int layer)
        {

        }
        
        public virtual void OnAdd(int layer)
        {

        }

        public virtual void OnRemoveLayer(int num)
        {

        }

        public virtual void Update(float deltaTime)
        {

        }

        public virtual void OnAddLayer(int num)
        {

        }

        public virtual void OnDestroy()
        {

        }

        /// <summary>
        /// 不能叠层的相同buff重复添加，完全结束自己之前的效果，同时重新开启自己的效果，不需要发销毁和添加事件
        /// </summary>
        public virtual void OnReset()
        {

        }

         public abstract BuffActionBase DeepCopy();

    }
}


