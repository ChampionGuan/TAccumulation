using MessagePack;
using UnityEngine;

namespace X3Battle
{
    [MessagePackObject]
    public class ActorCancelLockCacheCmd : ActorCmd
    {
        protected override void _OnEnter()
        {
            Finish();
            PapeGames.X3.LogProxy.Log("手动模式, 取消缓存队列 指令");
            actor.targetSelector.TryUpdateTarget(TargetSelectorUpdateType.CancelLockCache, null);
        }
    }
}