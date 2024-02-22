using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/向目标单位发送射击信号")]
    [Serializable]
    public class SendShootSignalAsset : BSActionAsset<ActionSendShootSignal>
    {
        [LabelText("SignalKey", editorCondition: "false")]
        public string signalKey = "ShootWarning";

        [LabelText("选取目标类型")] public TargetType targetType;

        [LabelText("SignalValue")] public string signalValue;
    }

    public class ActionSendShootSignal : BSAction<SendShootSignalAsset>
    {
        protected override void _OnEnter()
        {
            var target = context.actor.GetTarget(clip.targetType);
            if (target == null)
            {
                return;
            }

            if (target.signalOwner == null)
            {
                PapeGames.X3.LogProxy.LogErrorFormat("请联系程序, 动作模组[角色动作/向目标区域内的所有单位发送攻击信号], 该目标没有信号组件. target.Type={0}", target.config.Type);
                return;
            }

            target.signalOwner.Write(clip.signalKey, clip.signalValue, context.actor);
        }   
    }
}