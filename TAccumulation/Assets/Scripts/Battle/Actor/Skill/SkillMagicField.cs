using System;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public class SkillMagicField:SkillTimeline
    {
        private MagicFieldCfg _magicFieldCfg;
        public MagicFieldCfg magicFieldCfg => _magicFieldCfg;
        // private List<Actor> _reuseActors = new List<Actor>(20);
        private ShapeBox _shapeBox;
        public ShapeBox shapeBox => _shapeBox;
        private CreateMagicFieldParam _createParam;
        private float _duration;  // 最大持续时间 -1无限
        private float _startTime;  // 当前持续时间
        private float _maxHitTimes;  // 最大Hit次数 -1 无限
        private float _curHitTimes;  // 当前hit次数

        public float duration => _duration;
        public float startTime => _startTime;

        private Action<EventActorEnterStateBase> _actionActorEnterDeadState;

        public SkillMagicField(Actor _actor, DamageExporter _masterExporter, SkillCfg _skillConfig,
            SkillLevelCfg _levelConfig, int level, MagicFieldCfg magicFieldCfg) :
            base(_actor, _masterExporter, _skillConfig, _levelConfig, level, SkillSlotType.Attack)
        {
            _actionActorEnterDeadState = _OnActorEnterDeadState;
            _magicFieldCfg = magicFieldCfg;

            _magicFieldCfg.ShapeBoxInfo.ShapeInfo.SetDebugInfo("【Alt+Z/法术场/{0}】", magicFieldCfg.ID);

            _shapeBox = ObjectPoolUtility.ShapeBoxPool.Get();
            LogProxy.Log("Create SkillMagicField skilltype = " + this.GetSkillType() + " SkillMagicField id = " + _magicFieldCfg.ID);
        }

        public void SetCreateParam(CreateMagicFieldParam createParam)
        {
            _createParam = createParam;
        }
        
        public override void Destroy()
        {
            ObjectPoolUtility.ShapeBoxPool.Release(_shapeBox);
            base.Destroy();
        }

        protected override void OnCast()
        {
            // 命中次数与生命周期重置
            _startTime = actor.time;
            _curHitTimes = 0;
            if (_magicFieldCfg.IsDynamicLife)
            {
                // 走配置，或时间覆盖逻辑
                _maxHitTimes = magicFieldCfg.MaxHit;
                if (_createParam != null && _createParam.isCoverDuration)
                {
                    _duration = _createParam.duration;
                }
                else
                {
                    _duration = _magicFieldCfg.Duration;
                }
            }
            else
            {
                // 没有配置走默认无限
                _duration = -1;
                _maxHitTimes = -1;
            }
            
            _shapeBox.Init(_magicFieldCfg.ShapeBoxInfo, new VirtualTrans(actor.GetDummy()));
            base.OnCast();
            actor.battle.eventMgr.AddListener<EventActorEnterStateBase>(EventType.OnActorEnterDeadState, _actionActorEnterDeadState, "SkillMagicField._OnActorEnterDeadState");
            
            //发送法术场作用开始事件
            var eventData = Battle.Instance.eventMgr.GetEvent<EventMagicFieldState>();
            eventData.Init(this, MagicFieldStateType.Begin);
            Battle.Instance.eventMgr.Dispatch(EventType.MagicFieldStateChange, eventData);
        }

        protected override void OnStop(SkillEndType skillEndType)
        {
            //发送法术场作用结束事件
            var eventData = Battle.Instance.eventMgr.GetEvent<EventMagicFieldState>();
            eventData.Init(this, MagicFieldStateType.End);
            Battle.Instance.eventMgr.Dispatch(EventType.MagicFieldStateChange, eventData);
            
            actor.battle.eventMgr.RemoveListener<EventActorEnterStateBase>(EventType.OnActorEnterDeadState, _actionActorEnterDeadState);
            base.OnStop(skillEndType);
        }

        protected override void _OnUpdate()
        {
            base._OnUpdate();
            _shapeBox.Update();

            // 生命周期判断
            if (_duration > 0 && actor.time - _startTime >= _duration)
            {
                LogProxy.LogFormat("法术场{0}, 因为持续时间已到而销毁", _magicFieldCfg.ID);
                actor.Dead();
            }
        }

        // 主人死亡事件监听，配了随主人死亡则销毁自己所在的actor
        public void _OnActorEnterDeadState(EventActorEnterStateBase arg)
        {
            if (arg.actor == actor.master)
            {
                if (_magicFieldCfg.EndWithMaster)
                {
                    actor.battle.actorMgr.RecycleActor(actor);  
                }
            }
        }
        
        // timeline结束销毁自己
        protected override void _OnTimelineStop()
        {
            base._OnTimelineStop();
            actor.battle.actorMgr.RecycleActor(actor);
            this.ClearRemainFX();
        }

        // 外部调用，法术场生效一次，输出伤害、buff、光环
        public void Hit(int damageBoxID, int haloID)
        {
            CastDamageBox(null, damageBoxID, this.level, out _, null, null, shapeBoxInfo: _magicFieldCfg.ShapeBoxInfo);

            // 创建光环
            if (haloID > 0)
            {
                var shapeInfo = _magicFieldCfg.ShapeBoxInfo;
                actor.haloOwner.AddHalo(haloID, level, shapeInfo, casterExporter: this);
            }
        }

        protected override void _OnHitAny(DamageBox damageBox)
        {
            base._OnHitAny(damageBox);
            
            // Hit次数判断
            var hitTargets = damageBox.lastHitTargets;
            for (int i = 0; i < hitTargets.Count; i++)
            {
                if (hitTargets[i].actor != null)
                {
                    _curHitTimes += 1;
                }
            }
            if (_maxHitTimes > 0 && _curHitTimes >= _maxHitTimes)
            {
                LogProxy.LogFormat("法术场{0}, 因为生效次数已满而销毁", _magicFieldCfg.ID);
                actor.Dead();
            }
        }
    }
}