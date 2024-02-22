using MessagePack;
using UnityEngine;

namespace X3Battle
{
    [MessagePackObject]
    public class ActorSwitchTargetCmd : ActorCmd
    {
        protected override void _OnEnter()
        {
            Finish();
            PapeGames.X3.LogProxy.Log("手动模式, 切换目标 指令");
            actor.targetSelector.TryUpdateTarget(TargetSelectorUpdateType.SwitchTarget, null);
        }
    }
}