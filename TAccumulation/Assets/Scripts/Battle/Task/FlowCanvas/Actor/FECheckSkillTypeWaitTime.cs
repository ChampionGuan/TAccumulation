using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("长时间没有使用指定技能类型触发器\nCheckSkillTypeWaitTime")]
    public class FECheckSkillTypeWaitTime : FlowEvent
    {
        public BBParameter<SkillType> skillType = new BBParameter<SkillType>();
        [Name("TimeLimit(秒)")]
        public BBParameter<float> timeLimit = new BBParameter<float>();
        private float _startWaitingTime;
        private int _timerId;
        private Action<int, int> _actionTick;

        public FECheckSkillTypeWaitTime()
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
        
        private void _TickAction(int id, int repeatCount)
        {
            var skillOwner = _actor.skillOwner;
            if (skillOwner == null)
            {
                return;
            }
            var slots = skillOwner.slots;
            bool isHaveSkillType = false;
            foreach (var slotItem in slots)
            {
                if (slotItem.Value is SkillSlot slot)
                {
                    if (slot.skill.config.Type != skillType.value)
                    {
                        continue;
                    }
                    isHaveSkillType = true;
                    if (slot.IsCD() || slot.skill.IsRunning())
                    {
                        _startWaitingTime = _battle.time;
                    }
                }
            }
            var curWaitingTime = _battle.time - _startWaitingTime;
            if (isHaveSkillType && curWaitingTime > timeLimit.value)
            {
                _startWaitingTime = _battle.time;
                _Trigger();
            }
        }
    }
}
