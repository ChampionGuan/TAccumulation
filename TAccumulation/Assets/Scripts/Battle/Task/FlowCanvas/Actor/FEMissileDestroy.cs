using System;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("子弹销毁事件\nMissileDestroyEvent")]
    public class FEMissileDestroy : FlowEvent
    {
        public BBParameter<EEventTarget> EventTarget = new BBParameter<EEventTarget>(EEventTarget.Self);

        public MissileBlastCondition missileBlastCondition = MissileBlastCondition.LifeOver;

        [GatherPortsCallback] public bool enableMissileID;

        private ValueInput<int> _viMissileID;

        // 子弹销毁位置.
        private Vector3 _destroyPos;

        private EventEndSkill _eventEndSkill;
        private Action<EventEndSkill> _actionOnEventSkill;

        public FEMissileDestroy()
        {
            _actionOnEventSkill = _OnEventEndSkill;
        }

        protected override void _OnAddPorts()
        {
            if (enableMissileID)
            {
                _viMissileID = this.AddValueInput<int>("MissileID");
            }

            AddValueOutput<Actor>("Master", () => _eventEndSkill?.skill?.actor?.master);
            AddValueOutput<Vector3>("DestroyPos", () => _destroyPos);
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventEndSkill>(EventType.EndSkill, _actionOnEventSkill, "FEMissileDestroy._OnEventEndSkill");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventEndSkill>(EventType.EndSkill, _actionOnEventSkill);
        }

        private void _OnEventEndSkill(EventEndSkill args)
        {
            if (_isTriggering || args == null || args.skill == null)
                return;
            if (!(args.skill is SkillMissile skillMissile))
            {
                return;
            }

            // DONE: 判断子弹的主人是否为关注的.
            if (!_IsMainObject(this.EventTarget.GetValue(), args.skill.actor.master))
                return;

            // DONE: 判断子弹ID是否为关注的.
            if (enableMissileID)
            {
                var missileId = _viMissileID.GetValue();
                if (skillMissile.MissileCfgID != missileId)
                {
                    return;
                }
            }

            // DONE: 判断销毁类型
            if ((skillMissile.missile.blastCondition & missileBlastCondition) == 0)
            {
                return;
            }

            _eventEndSkill = args;
            _destroyPos = skillMissile.missile.GetDestroyPos();
            _Trigger();
            _eventEndSkill = null;
        }
    }
}
