using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Description("只有第一次满足条件时才会触发， 例：LessThan：距离只有从大于到小于时触发一次，始终小于不会触发")]
    [Category("X3Battle/通用/Event")]
    [Name("距离判断触发器\nCheckActorsDisance")]
    public class FCCheckActorsDisance : FlowEvent
    {
        public BBParameter<ECompareOperator> eCompareOperator = new BBParameter<ECompareOperator>();
        public BBParameter<float> limitDis = new BBParameter<float>();
        public BBParameter<float> tickInterval = new BBParameter<float>();
        public BBParameter<ChooseActorType> _one = new BBParameter<ChooseActorType>();
        public BBParameter<ChooseActorType> _two = new BBParameter<ChooseActorType>();
        
        private bool _active = true;
        private float _preTickTime;
        private int _timerId;
        private Action<int, int> _actionTick;

        public FCCheckActorsDisance()
        {
            _actionTick = _TickAction;
        }
        
        protected override void _RegisterEvent()
        {
            _timerId = _actor.timer.AddTimer(null, 0f, 0f, -1, "", null, _actionTick);
        }

        protected override void _UnRegisterEvent()
        {
            _actor.timer.Discard(null, _timerId);
            _timerId = 0;
        }

        protected override void _OnGraphStart()
        {
            base._OnGraphStart();
            _active = true;
        }

        private void _TickAction(int id, int repeatCount)
        {
            // tick 频率控制
            float curTime = _battle.time;
            if (tickInterval.value > 0 && curTime - _preTickTime < tickInterval.value)
            {
                return;
            }
            _preTickTime = curTime;
            var one = BattleUtil.GetActor(_one.value, _actor);
            var two = BattleUtil.GetActor(_two.value, _actor);
            if (one == null || two == null)
                return;
            
            bool checkOk = false;
            float limitDis = this.limitDis.value;
            var compareOperator = eCompareOperator.value;
            float dis = BattleUtil.GetActorDistance(one, two);

            // 从大于到小于触发一次关闭检测，从小于到大于开启检测，支持下一次的大于到小于
            // 同理：
            // 从不等于 到 等于触发一次
            // 从大于到小于，触发一次
            // TODO： 考虑阈值控制，避免边界反复触发
            if (!_active)
            {
                if (dis > limitDis)
                {
                    _active = compareOperator == ECompareOperator.LessThan ||
                              compareOperator == ECompareOperator.LessOrEqualTo;
                }
                else if (dis == limitDis)
                {
                    _active = compareOperator == ECompareOperator.NotEqual;
                }
                else if (dis < limitDis)
                {
                    _active = compareOperator == ECompareOperator.GreaterThan ||
                              compareOperator == ECompareOperator.GreaterOrEqualTo;
                }
                else
                {
                    _active = compareOperator == ECompareOperator.EqualTo;
                }
            }

            if (!_active)
            {
                return;
            }
            checkOk = BattleUtil.IsCompareSize(dis, limitDis, compareOperator);

            if (checkOk)
            {
                _Trigger();
                _active = false;
            }
        }

    }
}
