using System;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/发送信号")]
    [Serializable]
    public class WriteSignalAsset : BSActionAsset<ActionWriteSignal>
    {
        [LabelText("SignalKey")] public string signalKey;

        [LabelText("SignalValue")] public string signalValue;

        [LabelText("ReceiverType")] public TargetType targetType;
    }

    public class ActionWriteSignal : BSAction<WriteSignalAsset>
    {
     
        protected override void _OnEnter()
        {
            var target = context.actor.GetTarget(clip.targetType);
            if (target == null || target.signalOwner == null)
                return;
            target.signalOwner.Write(clip.signalKey, clip.signalValue, context.actor);
        }   
    }
}