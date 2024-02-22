using System;
using System.Collections.Generic;
using UnityEngine;
using X3Battle.TargetSelect;

namespace X3Battle
{
    public class SkillActive : ISkill
    {
        private bool _isSinging;  // 是否在吟唱中
        public bool IsSinging => _isSinging;
        private float _playSpeed;
        
        private string _configIDName;
        public Vector3 castActorPos { get; private set; }
        public Vector3 castActorForward{ get; private set; }
        public Quaternion castActorRotation { get; private set; }

        public SkillActive(Actor _actor, DamageExporter _masterExporter, SkillCfg _skillConfig, SkillLevelCfg _levelConfig, int level, SkillSlotType skillSlotType) : base(_actor, _masterExporter, _skillConfig, _levelConfig, level, skillSlotType)
        {
            _playSpeed = GetConfigPlaySpeed();
            _configIDName = Convert.ToString(config.ID);
        }

        // 清除残留的技能特效
        public virtual void ClearRemainFX()
        { }

        public bool IsActiveControlCD()
        {
            return config.IsActiveControlCD;
        }
        
        /// <summary>
        /// 开始计算CD 这里也要使用随机CD
        /// 如果选中 是否使用动作模组中CD控制 才生效
        /// </summary>
        public void BeginCD()
        {
            if(actor == null || actor.skillOwner == null)
                return;
            
            var slot = actor.skillOwner.GetSkillSlot(slotID); 
            if(slot == null)
                return;
            
            if (!config.IsActiveControlCD)
                return;

            SetRandomSlotCD();

            slot.StartPublicGroupCD();
        }

        /// <summary>
        /// 设置CD 这里会增加随机CD
        /// </summary>
        public void SetRandomSlotCD()
        {
            if(actor == null || actor.skillOwner == null)
                return;
            
            var slot = actor.skillOwner.GetSkillSlot(slotID); 
            if(slot == null)
                return;
            
            slot.SetRandomCD();
        }
        
        // 获取技能播放速率
        public float GetPlaySpeed()
        {
            return _playSpeed;
        }


        // 动态改变技能播放速率
        public void SetPlaySpeed(float speed)
        {
            _playSpeed = speed;
        }

        public override float GetDeltaTime()
        {
            return actor.deltaTime * _playSpeed;
        }

        protected override void _OnUpdate()
        {
            var deltaTime = GetDeltaTime();
            this._UpdateDamageBoxes(deltaTime);
        }
        

        protected override void OnCast()
        {
            // 普攻类型速度从属性中取
            if (config.Type == SkillType.Attack && actor.attributeOwner != null)
            {
                var speedRatio = actor.attributeOwner.GetPerthAttrValue(AttrType.ATKSpeedUp) + 1.0f;
                _playSpeed = speedRatio;
            }
            
            _isSinging = false;
            PapeGames.X3.LogProxy.LogFormat("{0} 释放技能 {1}", actor.name, _configIDName);
            RefreshCastPosForward();
            
            var eventData = actor.battle.eventMgr.GetEvent<EventCastSkill>();
            eventData.Init(this);
            actor.battle.eventMgr.Dispatch(EventType.CastSkill, eventData);
        }

        public void RefreshCastPosForward()
        {
            castActorPos = actor.transform.position;
            castActorForward = actor.transform.forward;
            castActorRotation = actor.transform.rotation;
        }

        protected override Vector3 _OnGetCastingPosition()
        {
            return castActorPos;
        }

        protected override Quaternion _OnGetCastingRotation()
        {
            return castActorRotation;
        }

        // 设置Singing状态
        public void SetSinging(bool singing)
        {
            _isSinging = singing;
        }

        
        // actionClip调用过来
        public void TriggerSkillLink(PlayerBtnType playerBtnType, int skillID, float duration, PlayerBtnStateType btnStateType)
        {
            actor.skillOwner.OnSkillLinkEvent(playerBtnType, skillID, duration, btnStateType);
            var slotID = actor.skillOwner.TryGetLinkSlotID(playerBtnType, btnStateType);
            if (slotID != null)
            {
                var eventData = actor.battle.eventMgr.GetEvent<EventCanLinkSkill>();
                eventData.Init(this, slotID.Value);
                actor.battle.eventMgr.Dispatch(EventType.CanLinkSkill, eventData);
            }
        }

        protected override void _OnHitAny(DamageBox damageBox)
        {
            base._OnHitAny(damageBox);
            if (damageBox.lastHitTargets == null || damageBox.lastHitTargets.Count <= 0)
                return;
            if (damageBox.damageBoxCfg.HitScaleDuration > 0)
            {
                actor.SetTimeScale(TbUtil.battleConsts.DuringDamageBoxTimeScale, damageBox.damageBoxCfg.HitScaleDuration);
            }
        }

        protected override void OnStop(SkillEndType skillEndType)
        {
            DiscardTimer();
            _DestroyDamageBoxes();
            SetFinalDamageAddAttr(0);  // 技能结束清理掉增伤
            PapeGames.X3.LogProxy.LogFormat("{0} 技能结束 {1}", actor.name, config.ID);
            var selectData = ObjectPoolUtility.SkillSelectData.Get();
            selectData.Init(this);
            actor.targetSelector?.TryUpdateTarget(TargetSelectorUpdateType.SkillEnd, selectData);
            ObjectPoolUtility.SkillSelectData.Release(selectData);
            
            var eventData = actor.battle.eventMgr.GetEvent<EventEndSkill>();
            eventData.Init(this, skillEndType);
            actor.battle.eventMgr.Dispatch(EventType.EndSkill, eventData);
        }
        public override void Destroy()
        {
            base.Destroy();
        }
    }
    
}