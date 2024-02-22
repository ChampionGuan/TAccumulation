using NodeCanvas.Framework;
using PapeGames.X3;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle{

    [Category("X3Battle/Actor")]
    [Description("触发FSM事件")]
    public class TriggerFSMEvent : BattleAction
    {
        [Tooltip("目标fsm")] public TargetFSM targetFSM = TargetFSM.AnimFSM;
        [Tooltip("发送的事件名")] public BBParameter<string> sendEventName = "";
        [Tooltip("如果发送事件成功")] public BBParameter<string> sendSucceed = "";
        [Tooltip("如果发送事件失败")] public BBParameter<string> sendFailure = "";

        protected override string info => $"TriggerFSMEvent:\"{sendEventName.value}\"-to:" + (targetFSM == TargetFSM.AnimFSM ? "AnimFSM," : targetFSM == TargetFSM.MainFSM ? "MainFSM" : targetFSM == TargetFSM.Self ? "Self" : "");

        protected override void OnExecute()
        {
            bool? result = null;
            switch (targetFSM)
            {
                case TargetFSM.AnimFSM:
                    LogProxy.LogFormat("[TriggerFSMEvent] 角色[{0}], 当前角色主状态:{1}, 当前异常状态:{2}, 触发事件:{3}", this._actor.name, (_context as ActorCharacterContext)?.actor.mainState.mainStateType ?? ActorMainStateType.Num, (_context as ActorCharacterContext)?.actor.mainState.abnormalType ?? ActorAbnormalType.None, sendEventName.value);
                    result = (_context as ActorCharacterContext)?.locomotionCtrl?.TriggerFSMEvent(sendEventName.value) ?? false;
                    break;
                case TargetFSM.MainFSM:
                    result = (_context as ActorCharacterContext)?.actor.mainState?.TriggerFSMEvent(sendEventName.value) ?? false;
                    break;
                case TargetFSM.Self:
                    result = _fsm.TriggerEvent(sendEventName.value);
                    break;
            }

            if (result.HasValue)
            {
                var eventName = result.Value ? sendSucceed.value : sendFailure.value;
                if (!string.IsNullOrEmpty(eventName))
                {
                    _fsm.TriggerEvent(eventName);
                }
            }

            EndAction(true);
        }

        public enum TargetFSM
        {
            AnimFSM,
            MainFSM,
            Self,
        }
    }
}
