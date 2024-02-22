using System;
using System.Collections;
using System.Collections.Generic;
using MessagePack;

namespace X3Battle
{
    [BuffAction("冰冻")]
    [MessagePackObject]
    [Serializable]
    public class BuffActionFrozen:BuffActionBase
    {
        private string _frozenMatEffectPath;
        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.Frozen;
        }
        
        public override void OnAdd(int layer)
        {
            //主角和替身使用主角冰冻材质动画 其他用通用
            if (_actor.type == ActorType.Hero ||
                (_actor.IsCreature() && _actor.subType == (int)CreatureType.Substitute))
            {
                _frozenMatEffectPath = TbUtil.battleConsts.RoleFrozenMatEffectPath;
            }
            else
            {
                _frozenMatEffectPath = TbUtil.battleConsts.FrozenMatEffectPath;
            }
            _actor.frozen?.frozenBuffs.Add(_owner);
            if (_owner.owner.MatAnimBegin(_frozenMatEffectPath))
            {
                //已经有冻结action，这里是重复冰冻
                return;
            }
            //第一次冻结
            
            _actor.frozen?.OnEnterFrozen(_owner);
        }
        public override void OnDestroy()
        {
            _actor.frozen?.frozenBuffs.Remove(_owner);
            if (_owner.owner.MatAnimEnd(_frozenMatEffectPath))
            {
                //还有其他冰冻存在
                ObjectPoolUtility.BuffActionFrozenPool.Release(this);
                return;
            }
            //没有其他冰冻存在了，恢复状态
            
            ObjectPoolUtility.BuffActionFrozenPool.Release(this);
            _actor.frozen?.OnExitFrozen();
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.BuffActionFrozenPool.Get();
            return action;
        }
    }
}