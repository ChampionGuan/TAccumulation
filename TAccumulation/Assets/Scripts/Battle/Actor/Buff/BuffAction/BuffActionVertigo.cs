using System;
using System.Collections;
using System.Collections.Generic;
using MessagePack;
using UnityEngine;

namespace X3Battle
{
    [BuffAction("眩晕")]
    [MessagePackObject]
    [Serializable]
    public class BuffActionVertigo:BuffActionBase
    {
        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.Vertigo;
        }
        public override void OnAdd(int layer)
        {
            _actor.mainState?.TryEnterAbnormal(ActorAbnormalType.Vertigo, _owner);
        }

        public override void OnDestroy()
        {
            _actor.mainState?.TryEndAbnormal(ActorAbnormalType.Vertigo, _owner);
            ObjectPoolUtility.BuffActionVertigoPool.Release(this);
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.BuffActionVertigoPool.Get();
            return action;
        }
    }
}