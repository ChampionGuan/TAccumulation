using System;
using System.Collections.Generic;
using MessagePack;

namespace X3Battle
{
    [BuffAction("禁止能量回复")]
    [MessagePackObject]
    [Serializable]
    public class ForbidEnergyRecover : BuffActionBase
    {
        [BuffLable("禁止回复能量类型")]
        [Key(0)]
        public List<EnergyType> energys;

        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.ForbidEnergyRecover;
        }

        public override void OnAdd(int layer)
        {
            base.OnAdd(layer);
            foreach (var energy in energys)
            {
                _actor.energyOwner.ForbidEnergyRecover(energy, true);
                if(energy == EnergyType.Male && _actor.IsBoy())
                {
                    Battle.Instance.actorMgr.girl.energyOwner.ForbidEnergyRecover(energy, true);
                }
            }
        }

        public override void OnDestroy()
        {
            base.OnDestroy();
            foreach (var energy in energys)
            {
                _actor.energyOwner.ForbidEnergyRecover(energy, false);
                if (energy == EnergyType.Male && _actor.IsBoy())
                {
                    Battle.Instance.actorMgr.girl.energyOwner.ForbidEnergyRecover(energy, false);
                }
            }
            ObjectPoolUtility.ForbidEnergyRecoverPool.Release(this);
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.ForbidEnergyRecoverPool.Get();
            action.energys = energys;
            return action;
        }
    }
}
