using System;
using System.Collections.Generic;
using MessagePack;

namespace X3Battle
{
    [BuffAction("添加嘲讽")]
    [MessagePackObject]
    [Serializable]
    public class AddTaunt : BuffActionBase
    {
        [BuffLable("角色类型")] 
        [Key(0)] public ActorType actorType;
        [BuffLable("嘲讽值")] 
        [Key(1)] public int tauntValue;
        
        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.AddTaunt;
        }

        public override void OnAdd(int layer)
        {
            base.OnAdd(layer);
            if (_owner.actor != _owner.actor.battle.player &&  _owner.actor != _owner.caster && _owner.actor.type == actorType)
            {
                var result = _owner.actor.actorTaunt?.AddTaunt(_owner, tauntValue);
                if (result == null || !result.Value)
                {
                    _owner.actor.buffOwner.Remove(_owner.ID);
                }
            }
        }
        
        public override BuffActionBase DeepCopy()
        {
            AddTaunt addTaunt = ObjectPoolUtility.AddTauntPool.Get();
            addTaunt.actorType = actorType;
            addTaunt.tauntValue = tauntValue;
            return addTaunt;
        }
        
        public override void OnDestroy()
        {
            if (_owner.actor != _owner.actor.battle.player &&  _owner.actor != _owner.caster && _owner.actor.type == actorType)
            {
                _owner.actor.actorTaunt?.RemoveTaunt(_owner);
            }
            ObjectPoolUtility.AddTauntPool.Release(this);
        }
    }
}