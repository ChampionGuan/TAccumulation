using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    ///<summary>x3项目组新增，用于控制不同图中使用计时器时的ID限制</summary>
    /// 通用计时器：1~100
    /// 行为树计时器：101~200
    /// 蓝图计时器：201~300
    /// 触发器计时器：301~400
    [Serializable]
    public class BBStartTimer
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();
        [X3TimerID]
        public BBParameter<int> id = new BBParameter<int>();
        public BBParameter<float> time = new BBParameter<float>();
        public BBParameter<string> description = new BBParameter<string>();
        public BBParameter<bool> requiredSendTimerCompleteEvent = new BBParameter<bool>();
        private Action<int> _actionTimerComplete;
        private Actor _curActor;

        public BBStartTimer()
        {
            _actionTimerComplete = _TimerComplete;
        }

        public bool Start(Actor actor)
        {
            if (id.value > 400 || id.value < 1)
            {
                PapeGames.X3.LogProxy.LogError($"计时器ID{id.value}配置异常，请找策划【楚门】");
                return false;
            }
            _curActor = source.isNoneOrNull ? actor : source.value;
            if (_curActor == null)
            {
                PapeGames.X3.LogProxy.LogError($"计时器的载体异常，请找策划【楚门】");
                return false;
            }

            if (requiredSendTimerCompleteEvent == null || requiredSendTimerCompleteEvent.isNoneOrNull || !requiredSendTimerCompleteEvent.value)
            {
                _curActor.timer.AddTimer(null, id.value, 0, time.value, 1, description.value);
            }
            else
            {
                _curActor.timer.AddTimer(null, id.value, 0, time.value, 1, description.value, null, null, _actionTimerComplete);
            }
            return true;
        }

        private void _TimerComplete(int timerId)
        {
            if (_curActor == null)
            {
                return;
            }
            var eventData = _curActor.eventMgr.GetEvent<EventTimerOver>();
            eventData.Init(timerId);
            _curActor.eventMgr.Dispatch(EventType.TimerOver, eventData, false);
        }
    }
}
