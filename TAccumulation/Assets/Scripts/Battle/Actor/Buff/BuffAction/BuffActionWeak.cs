using System;
using System.Collections;
using System.Collections.Generic;
using MessagePack;
using UnityEngine;

namespace X3Battle
{
    [BuffAction("虚弱")]
    [MessagePackObject]
    [Serializable]
    public class BuffActionWeak:BuffActionBase
    {
        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.Weak;
        }
        public override void OnAdd(int layer)
        {
            _actor.mainState?.TryEnterAbnormal(ActorAbnormalType.Weak, _owner);
        }

        public override void OnDestroy()
        {
            _actor.mainState?.TryEndAbnormal(ActorAbnormalType.Weak, _owner);
            ObjectPoolUtility.BuffActionWeakPool.Release(this);
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.BuffActionWeakPool.Get();
            return action;
        }
    }
}