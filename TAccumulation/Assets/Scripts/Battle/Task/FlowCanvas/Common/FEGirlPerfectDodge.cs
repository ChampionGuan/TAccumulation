using System;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Event")]
    [Name("女主完美闪避 (假身被命中或直接触发)\nGirlPerfectDodge")]
    public class FEGirlPerfectDodge : FlowEvent
    {
        private Action<EventBoxHitActors> _actionBoxHitActors;
        private EventBoxHitActors _eventBoxHitActors;
        private Action<ECEventDataBase> _actionPerfectDodge;
        public FEGirlPerfectDodge()
        {
            _actionBoxHitActors = _OnBoxHitActors;
            _actionPerfectDodge = _OnPerfectDodge;
        }
        
        protected override void _OnAddPorts()
        {
            AddValueOutput<Actor>("HitCaster", () => _eventBoxHitActors?.hitCaster);
            AddValueOutput<ISkill>("ISkill", () => _eventBoxHitActors?.hitSkill);
        }
        
        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener(EventType.OnBoxHitActors, _actionBoxHitActors, "FEGirlPerfectDodge._OnBoxHitActors");
            Battle.Instance.eventMgr.AddListener(EventType.OnPerfectDodge, _actionPerfectDodge, "FEGirlPerfectDodge.OnPerfectDodge");            
        }
        
        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener(EventType.OnBoxHitActors, _actionBoxHitActors);
            Battle.Instance.eventMgr.RemoveListener(EventType.OnPerfectDodge, _actionPerfectDodge);
        }

        private void _OnPerfectDodge(ECEventDataBase eventData)
        {
            if (_isTriggering)
                return;
            PapeGames.X3.LogProxy.LogFormat("【完美闪避】{0}的完美闪避事件被触发！", _actor.name);
            _Trigger();
        }
        private void _OnBoxHitActors(EventBoxHitActors eventData)
        {
            if (_isTriggering || eventData == null)
                return;

            var hitGirlDummy = false;
            var boxCfg = eventData.hitBox.damageBoxCfg;
            if (boxCfg.CauseDodge)
            {
                // 这个包围盒是否once模式，并且伤害过女主
                var onceModeDamagedGirl = boxCfg.CheckMode == DamageBoxCheckMode.Once && eventData.hitBox.IsDamagedActor(_actor.battle.actorMgr.girl);
                if (!onceModeDamagedGirl)
                {
                    for (int i = 0; i < eventData.hitTargetInfos.Count; i++)
                    {
                        var hitActor = eventData.hitTargetInfos[i].actor;
                        if (hitActor != null && hitActor.IsFakebody() && hitActor.master.IsGirl())
                        {
                            hitGirlDummy = true;
                            break;
                        }
                    }
                }   
            }

            if (hitGirlDummy)
            {
                PapeGames.X3.LogProxy.LogFormat("【完美闪避】{0}的完美闪避事件被触发！", _actor.name);
                _eventBoxHitActors = eventData;
                _Trigger();
                _eventBoxHitActors = null;
            }
        }
    }
}
