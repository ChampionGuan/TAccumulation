using UnityEngine;
using MessagePack;
using System;
using System.Collections.Generic;

namespace X3Battle
{
    [BuffAction("美术表现挂载")]
    [MessagePackObject]
    [Serializable]
    public class PlayGroupFx : BuffActionBase
    {
        [BuffLable("表现名称")]
        [Key(0)] public List<string> groupNames;
        [BuffLable("是否打开")]
        [Key(1)] public bool enable;

        public override void Init(X3Buff buff)
        {
            base.Init(buff);
            buffActionType = BuffAction.PlayGroupFx;
        }

        public override void OnAdd(int layer)
        {
            base.OnAdd(layer);
            if(enable)
            {
                foreach(var name in groupNames)
                    _actor.effectPlayer.PlayGroupFx(name);
            }
            else
            {
                foreach (var name in groupNames)
                    _actor.effectPlayer.StopGroupFx(name);
            }
        }

        public override void OnDestroy()
        {
            if (enable)
            {
                foreach (var name in groupNames)
                    _actor.effectPlayer.StopGroupFx(name);
            }
            else
            {
                foreach (var name in groupNames)
                    _actor.effectPlayer.PlayGroupFx(name);
            }
            base.OnDestroy();
            ObjectPoolUtility.PlayGroupFxPool.Release(this);
        }

        public override BuffActionBase DeepCopy()
        {
            var action = ObjectPoolUtility.PlayGroupFxPool.Get();
            action.groupNames = groupNames;
            action.enable = enable;
            return action;
        }
    }
}
