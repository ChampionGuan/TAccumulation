using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("QTE技能被激活事件\nQTESkillActive")]
    public class FEQTESkillActive : FlowEvent
    {
        private Action<EventSetQTEActive> _actionOnSetQTEActive;

        public FEQTESkillActive()
        {
            _actionOnSetQTEActive = _OnQTEActive;
        }
        
        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventSetQTEActive>(EventType.SetQTEActive, _actionOnSetQTEActive, "FEQTESkillActive._OnQTEActive");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener<EventSetQTEActive>(EventType.SetQTEActive, _actionOnSetQTEActive);
        }

        private void _OnQTEActive(EventSetQTEActive eventSetQTEActive)
        {
            if (eventSetQTEActive.active)
            {
                _Trigger();
            }
        }
    }
}
