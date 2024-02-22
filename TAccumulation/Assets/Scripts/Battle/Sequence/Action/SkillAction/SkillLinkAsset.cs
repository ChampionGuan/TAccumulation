using System;
using UnityEngine.Timeline;

namespace X3Battle
{
    // TimelineClip
    [TrackClipYellowColor]
    [TimelineMenu("技能动作/激活技能连招")]
    [Serializable]
    public class SkillLinkAsset : BSActionAsset<ActionSkillLink>
    {
        [LabelText("技能ID", jumpType:JumpModuleType.ViewSkill)] public int skillID;

        [LabelText("按键类型")] public PlayerBtnType playerBtnType;

        [LabelText("输入状态")] public PlayerBtnStateType btnStateType = PlayerBtnStateType.Down;
       
        [LabelText("Hold时长", showCondition = "enum:btnStateType==1")] 
        public float holdTime;

        [LabelText("时长不满足跳转", showCondition = "enum:btnStateType==1")]
        public bool invert;

        [LabelText("最大按住时长(-1无限制)", showCondition = "enum:btnStateType==3")]
        public float tapDuration = -1;
    }
    
    // playable
    public class ActionSkillLink : BSAction<SkillLinkAsset>
    {
        private bool isSkip = false;//是否一帧跳时间
        protected override void _OnInit()
        {
            // 开启后会调用SequencerStart和SequencerEnd
            needSequencerLifeNotify = true;  
        }

        protected override void _OnSequencerStart()
        {
            // 记录DogeOffset数据
            context.actor.skillOwner.AddDodgeOffsetData(clip.playerBtnType, clip.btnStateType, clip.skillID);
        }

        protected override void _OnEnter()
        {
            isSkip = false;
            //如果invert 等于true 并且AI处于激活状态 skillink不生效 策划潜规则
            if (clip.invert && context.actor.aiOwner != null && context.actor.aiOwner.enabled)
            {
                return;
            }
            
            // 此处写逻辑
            var speed = context.skill.GetPlaySpeed();
            var time = remainTime / speed;
            if (time == 0)
            {
                // 跳时间的情况，保留一帧数据
                time = BattleConst.FrameTime;
                isSkip = true;
            }

            context.skill?.TriggerSkillLink(clip.playerBtnType, clip.skillID, time, clip.btnStateType);
            if (isSkip)
            {
                context.actor.skillOwner.interruptLinkController.AddSkillLinkAssetFlag(this);
            }
            else
            {
                context.actor.skillOwner.interruptLinkController.AddSkillLinkAsset(this);
            }
        }

        protected override void _OnExit()
        {
            base._OnExit();
            //如果invert 等于true 并且AI处于激活状态 skillink不生效 策划潜规则
            if (clip.invert&& context.actor.aiOwner != null && context.actor.aiOwner.enabled)
            {
                return;
            }

            if (!isSkip)
            {
                context.actor.skillOwner.interruptLinkController.RemoveSkillLinkAsset(this);
            }
        }

        // 当技能连招被触发时尝试消耗输入缓存
        private bool _OnSkillCanLink()
        {
            // 获取按钮状态对应的连招ID
            var actor = context.actor;
            var success = false;

            var slotID = actor.skillOwner.TryGetLinkSlotID(clip.playerBtnType, clip.btnStateType);
            // 判断连招是否可用
            if (slotID != null && actor.skillOwner.CanCastSkillBySlot(slotID.Value))
            {
                if (_IsBtnCanUse())
                {
                    // 走到这里，表示输入缓存也能用。直接释放技能即可
                    actor.skillOwner.TryCastSkillBySlot(slotID.Value, safeCheck: false);
                    success = true;
                }
            }

            return success;
        }

        private bool _CanConsumeHoldCache()
        {
            var actor = context.actor;
            var canUseCache = false;
            var timeElapse = clip.holdTime;
            if (clip.invert)
            {
                var haveHold = actor.input.CanConsumeCache(clip.playerBtnType, clip.btnStateType);
                if (haveHold)
                {
                    // 有hold但是hold时长不满足放出
                    canUseCache = !actor.input.CanConsumeCache(clip.playerBtnType, clip.btnStateType, timeElapse);
                }
                else
                {
                    // 没hold可以放出
                    canUseCache = true;
                }
            }
            else
            {
                // hold时长满足跳转
                canUseCache = actor.input.CanConsumeCache(clip.playerBtnType, clip.btnStateType, timeElapse);
            }
            return canUseCache;
        }

        /// <summary>
        /// 执行连招逻辑
        /// </summary>
        /// <param name="btnType"></param>
         public bool DoLink(PlayerBtnType btnType)
        {
            if (btnType != clip.playerBtnType)
            {
                return false;
            }
            var actor = context.actor;
            if (actor.input == null)
            {
                return false;
            }
            
            if (clip.btnStateType != PlayerBtnStateType.Down)
            {
                bool res = false;
                var canUseCache = false;
                if (clip.btnStateType == PlayerBtnStateType.Hold)
                {
                    canUseCache = _CanConsumeHoldCache();
                }
                else
                {
                    canUseCache = _IsBtnCanUse( );
                }
                
                if (canUseCache)
                {
                    var slotID = actor.skillOwner.TryGetLinkSlotID(clip.playerBtnType, clip.btnStateType);
                    if (slotID != null && actor.skillOwner.CanCastSkillBySlot(slotID.Value))
                    {
                        actor.input.TryConsumeCache(clip.playerBtnType, clip.btnStateType);
                        res = actor.skillOwner.TryCastSkillBySlot(slotID.Value, safeCheck: false);      
                    }
                }

                return res;
            }
            else
            {
                return _OnSkillCanLink();
            }
        }

        private bool _IsBtnCanUse()
        {
            var actor = context.actor;
            var btnTime = 0.0f;
            //先判断按钮在输入系统中能否使用
            var success = actor.input.CanUseBtn(clip.playerBtnType, clip.btnStateType, context.actor.time, out btnTime,
                clip.tapDuration);
                    
            if (success)
            {
                //判断是否有输入缓存轨道
                if (bsSharedVariables.activeInputCache.IsHaveShared(clip.playerBtnType,
                    clip.btnStateType))
                {
                    //再判断按钮能否在输入轨道中使用
                    success = bsSharedVariables.activeInputCache.CanUseBtn(clip.playerBtnType,
                        clip.btnStateType, btnTime, context.actor.time);
                }
                else
                {
                    //如果没有输入缓存直接判断当前帧按钮能否使用
                    success = actor.input.TryConsumeCache(clip.playerBtnType, clip.btnStateType, 0, tapDuration:clip.tapDuration, tapDownElapse:0);
                }
            }

            return success;
        }
    }
}