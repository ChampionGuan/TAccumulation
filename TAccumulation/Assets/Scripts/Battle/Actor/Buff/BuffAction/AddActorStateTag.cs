using System;
using System.Collections;
using System.Collections.Generic;
using MessagePack;
using UnityEngine;

namespace X3Battle
{
    [BuffAction("添加Buff类型Tag")]
    [MessagePackObject]
    [Serializable]
    public class AddActorStateTag:BuffActionBase
    {
        [BuffLable("Tags")]
        [Key(0)]
        public List<ActorStateTagType> tags;

        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.StateTag;
        }

        public override void OnAdd(int layer)
        {
            if (tags == null || _actor == null)
            {
                return;
            }
            
            for (int i = 0; i < tags.Count; i++)
            {
                _actor.stateTag.AcquireTag(tags[i]);
            }
        }

        
        public override void OnDestroy()
        {
            if (tags == null || _actor == null)
            {
                return;
            }
            
            for (int i = 0; i < tags.Count; i++)
            {
                _actor.stateTag.ReleaseTag(tags[i]);
            }
            ObjectPoolUtility.AddActorStateTagPool.Release(this);
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.AddActorStateTagPool.Get();
            action.tags = this.tags;
            return action;
        }
    }
}


