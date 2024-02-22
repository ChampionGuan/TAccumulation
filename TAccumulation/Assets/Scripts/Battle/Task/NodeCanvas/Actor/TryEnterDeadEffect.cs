using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description(@"尝试进入死亡效果，检查当前角色死亡效果配置(DeadEffectType)。" +
                 "\n如果配置枚举为默认死亡，检查当前单位是否开启虚弱，如果虚弱标记为2，向AnimFSM发送受击死亡事件，否则发送特制死亡事件。" +
                 "\n如果配置枚举为受击死亡，则向AnimFSM发送受击死亡事件。" +
                 "\n如果配置枚举为特制死亡，则向AnimFSM发送特制死亡事件。" +
                 "\n其他情况，则向自己发送失败事件。")]
    public class TryEnterDeadEffect : BattleAction
    {
        [Tooltip("如果检测条件成功，向AnimFSM发送的事件")]
        public BBParameter<string> hurtDeadEvenToAnimFSM = new BBParameter<string>();

        [Tooltip("如果检测条件成功，向AnimFSM发送的事件")]
        public BBParameter<string> specialDeadEventToAnimFSM = new BBParameter<string>();

        [Tooltip("失败时，向自身发出的事件")]
        public BBParameter<string> failureEventToSelf = new BBParameter<string>();

        protected override string info => "Try Enter Dead Effect";

        protected override void OnExecute()
        {
            var result = true;
            var eventName = string.Empty;
            if (null == _actor.locomotion)
            {
                result = false;
            }
            else if (_actor.IsMonster())
            {
                switch ((DeadEffectType)_actor.monsterCfg.DeadEffectType)
                {
                    case DeadEffectType.Default:
                        eventName = _actor.monsterCfg.EquipShield == 2 ? specialDeadEventToAnimFSM.value : hurtDeadEvenToAnimFSM.value;
                        break;
                    case DeadEffectType.HurtLie:
                        eventName = hurtDeadEvenToAnimFSM.value;
                        break;
                    case DeadEffectType.Special:
                        eventName = specialDeadEventToAnimFSM.value;
                        break;
                }
            }
            else
            {
                eventName = specialDeadEventToAnimFSM.value;
            }

            if (result)
            {
                // 向AnimFSM发送事件
                result = _actor.locomotion.TriggerFSMEvent(eventName);
            }

            if (!result)
            {
                _fsm?.TriggerEvent(failureEventToSelf.value);
            }

            EndAction(result);
        }
    }
}
