using System;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Listener")]
    [Name("女主完美闪避监听器\nOnGirlPerfectDodge")]
    public class OnGirlPerfectDodge : FlowListener
    {
        private Action<EventBoxHitActors> _actionBoxHitActors;
        private EventBoxHitActors _eventBoxHitActors;
        
        public OnGirlPerfectDodge()
        {
            _actionBoxHitActors = _OnBoxHitActors;
        }
        
        protected override void _OnAddPorts()
        {
            AddValueOutput<Actor>("HitCaster", () => _eventBoxHitActors?.hitCaster);
            AddValueOutput<ISkill>("ISkill", () => _eventBoxHitActors?.hitSkill);
        }
        
        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener(EventType.OnBoxHitActors, _actionBoxHitActors, "OnGirlPerfectDodge._OnBoxHitActors");
        }
        
        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener(EventType.OnBoxHitActors, _actionBoxHitActors);
        }

        private void _OnBoxHitActors(EventBoxHitActors eventData)
        {
            if (IsReachMaxCount() || eventData == null)
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
