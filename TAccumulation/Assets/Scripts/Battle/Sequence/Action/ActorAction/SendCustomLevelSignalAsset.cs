using System;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/向关卡发送自定义信号")]
    [Serializable]
    public class SendCustomLevelSignalAsset : BSActionAsset<ActionSendCustomLevelSignal>
    {
        public string signalKey;
        public string signalValue;
    }

    public class ActionSendCustomLevelSignal : BSAction<SendCustomLevelSignalAsset>
    {
        protected override void _OnEnter()
        {
            if (string.IsNullOrWhiteSpace(clip.signalKey) || string.IsNullOrEmpty(clip.signalKey))
            {
                PapeGames.X3.LogProxy.LogError("请联系策划【五当】,【动作模组】【向关卡发送自定义信号 SendCustomLevelSignal】节点 【SignalKey】参数配置不合法, 不能为空.");
                return;
            }

            context.battle.actorMgr.stage.signalOwner.Write(clip.signalKey, clip.signalValue, context.actor);
        }   
    }
}