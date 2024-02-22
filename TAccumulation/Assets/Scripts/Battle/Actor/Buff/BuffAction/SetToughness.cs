using System;
using System.Collections.Generic;
using MessagePack;
using UnityEngine;

namespace X3Battle
{
    [BuffAction("修改受击等级")]
    [MessagePackObject]
    [Serializable]
    public class SetToughness : BuffActionBase
    {
        [BuffLable("修改模式")]
        [Key(0)] public ToughnessSetType setType;
        [BuffLable("数值")]
        [Key(1)] public float value;
        [BuffLable("是否永久性修改")]
        [Key(2)] public bool eternal;
        private float _addValue;

        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.SetToughness;
        }

        public override void OnAdd(int layer)
        {
            base.OnAdd(layer);
            if(_owner.actor.hurt == null)
            {
                return;
            }
            if (setType == ToughnessSetType.Add)
                _addValue = value;
            else
                _addValue = value - _owner.actor.hurt.toughness;
            _owner.actor.hurt.AddToughness(_addValue);
        }

        public override void OnDestroy()
        {
            if (_owner.actor.hurt == null)
            {
                return;
            }
            base.OnDestroy();
            _owner.actor.hurt.AddToughness(-_addValue);
            ObjectPoolUtility.SetToughnessPool.Release(this);
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.SetToughnessPool.Get();
            action.setType = setType;
            action.value = value;
            action.eternal = eternal;
            return action;
        }
    }
}
