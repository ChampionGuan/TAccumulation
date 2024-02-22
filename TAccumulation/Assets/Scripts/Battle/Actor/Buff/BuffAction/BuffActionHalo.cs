using System;
using System.Collections;
using System.Collections.Generic;
using MessagePack;
using UnityEngine;

namespace X3Battle
{
    [BuffAction("buff创建光环")]
    [MessagePackObject]
    [Serializable]
    public class BuffActionHalo : BuffActionBase
    {
        [BuffLable("光环id")]
        [Key(0)]
        public int HaloID;

        private int _insID;
        
        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.Halo;
        }
        
        public override void OnAdd(int layer)
        {
            if(_actor.haloOwner==null)
                PapeGames.X3.LogProxy.LogError("doesn't have haloOwner");
            _insID = _actor.haloOwner.AddHalo(HaloID, _owner.level, lifeTime:-1, casterExporter: _owner);
        }

        public override void OnDestroy()
        {
            _actor.haloOwner.RemoveHalo(_insID);
            ObjectPoolUtility.BuffActionHaloPool.Release(this);
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.BuffActionHaloPool.Get();
            action.HaloID = this.HaloID;
            return action;
        }
    }
}
