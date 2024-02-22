using System;
using System.Collections;
using System.Collections.Generic;
using MessagePack;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    [BuffAction("移除所有Debuff")]
    [MessagePackObject]
    [Serializable]
    public class BuffActionRemoveDebuff:BuffActionBase,IBuffAddSection
    {
        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.RemoveDebuff;
        }
        public override void OnAdd(int layer)
        {
            _actor.buffOwner.RemoveAllDebuff();
            _actor.buffOwner.AddBuffAddSection(this);
        }

        public override void OnDestroy()
        {
            _actor.buffOwner.RemoveBuffAddSection(this);
            ObjectPoolUtility.BuffActionRemoveDebuffPool.Release(this);
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.BuffActionRemoveDebuffPool.Get();
            return action;
        }

        public override void OnReset()
        {
            _actor.buffOwner.RemoveAllDebuff();
        }

        public bool InterceptBuffAdd(BuffCfg config)
        {
            if (config.BuffTag == BuffTag.Debuff)
            {
                LogProxy.Log($"BuffActionRemoveDebuff :{_owner.ID} 阻止了debuff: {config.ID} 的添加");
                return true;
            }

            return false;
        }
    }
}