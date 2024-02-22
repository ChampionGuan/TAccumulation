using System;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TrackClipYellowColor]
    [TimelineMenu("角色动作/动作打断区间")]
    [Serializable]
    public class CanInterruptAsset : BSActionAsset<ActionCanInterrupt>
    {
        // 打断类型（目前只有这个action会用，暂时不放到BattleDefine里）
        public enum InterruptType
        {
            Skill,  // 被任意主动技能打断
            Move,  // 被移动打断
        }
        
        [LabelText("能被什么打断")]
        public InterruptType interruptType = InterruptType.Skill;

        [LabelText("技能类型筛选", showCondition: "enum:interruptType==0")]
        public SkillTypeFlag skillTypeFlag = (SkillTypeFlag)2047;  // TODO 覆盖到当前的技能类型，后续默认值需要删掉
    }

    public class ActionCanInterrupt : BSAction<CanInterruptAsset>
    {
        private bool isSkip = false;
        protected override void _OnEnter()
        {
            //todo 判断是否跳过放在父类里面
            //判断是否处于跳时间的情况
            isSkip = false;
            if (context.skill != null)
            {
                var speed = context.skill.GetPlaySpeed();
                var time = remainTime / speed;
                if (time < 0)
                {
                    isSkip = true;
                }
            }
            
            if (context.skill != null)
            {
                // 技能调过来的，只对技能生效
                if (clip.interruptType == CanInterruptAsset.InterruptType.Skill)
                {
                    // 含有普攻则激活dodgeOffset
                    if (BattleUtil.ContainSkillType(clip.skillTypeFlag, SkillType.Attack))
                    {
                        context.actor.skillOwner.ActiveDodgeOffset(true, this);
                    }

                    if (isSkip)
                    {
                        context.actor.skillOwner.interruptLinkController.SetSkillInterruptBySkillFrame(this, clip.skillTypeFlag);
                    }
                    else
                    {
                        context.actor.skillOwner.interruptLinkController.SetSkillInterruptBySkill(this, clip.skillTypeFlag);
                    }
                }
                else if (clip.interruptType == CanInterruptAsset.InterruptType.Move)
                {
                    context.actor.skillOwner.interruptLinkController.SetSkillInterruptByMove(true);
                }
            }
            else
            {
                // Done 非技能调用过来， 刘夕判断一下是否受击，受击对应处理一下
                if (context.actor.hurt != null)
                {
                    if (clip.interruptType == CanInterruptAsset.InterruptType.Skill)
                    {
                        context.actor.hurt.hurtInterruptController.SetHurtInterruptBySkill(true, clip.skillTypeFlag);
                    }
                    else if (clip.interruptType == CanInterruptAsset.InterruptType.Move)
                    {
                        context.actor.hurt.hurtInterruptController.SetHurtInterruptByMove(true);
                    }
                }
                if (context.actor.locomotion != null)
                {
                    if (clip.interruptType == CanInterruptAsset.InterruptType.Skill)
                    {
                        context.actor.locomotion.SetSkillInterrupt(CtrlInterruptType.Timeline, CanInterruptType.Can, clip.skillTypeFlag);
                    }
                    else if (clip.interruptType == CanInterruptAsset.InterruptType.Move)
                    {
                        context.actor.locomotion.SetMoveInterrupt(CtrlInterruptType.Timeline, CanInterruptType.Can);
                    }
                }
            }
        }

        protected override void _OnExit()
        {
            if (context.skill != null)
            {
                // 技能调过来的，只对技能生效
                if (clip.interruptType == CanInterruptAsset.InterruptType.Skill)
                {
                    // 含有普攻则取消激活dodgeOffset
                    if (BattleUtil.ContainSkillType(clip.skillTypeFlag, SkillType.Attack))
                    {
                        context.actor.skillOwner.ActiveDodgeOffset(false, this);
                    }
                    if (!isSkip)
                    {
                        context.actor.skillOwner.interruptLinkController.StopSkillInterrupt(this);
                    }
                }
                else if(clip.interruptType == CanInterruptAsset.InterruptType.Move)
                {
                    context.actor.skillOwner.interruptLinkController.SetSkillInterruptByMove(false);
                }
            }
            else
            {
                // Done 非技能调用过来， 刘夕判断一下是否受击，受击对应处理一下
                if (context.actor.hurt != null)
                {
                    if (clip.interruptType == CanInterruptAsset.InterruptType.Skill)
                    {
                        context.actor.hurt.hurtInterruptController.SetHurtInterruptBySkill(false);
                    }
                    else if(clip.interruptType == CanInterruptAsset.InterruptType.Move)
                    {
                        context.actor.hurt.hurtInterruptController.SetHurtInterruptByMove(false);
                    }
                }
                if (context.actor.locomotion != null)
                {
                    if (clip.interruptType == CanInterruptAsset.InterruptType.Skill)
                    {
                        context.actor.locomotion.SetSkillInterrupt(CtrlInterruptType.Timeline, CanInterruptType.None, (SkillTypeFlag)(-1));
                    }
                    else if (clip.interruptType == CanInterruptAsset.InterruptType.Move)
                    {
                        context.actor.locomotion.SetMoveInterrupt(CtrlInterruptType.Timeline, CanInterruptType.None);
                    }
                }
            }
        }
        
        // 当技能打断被触发时尝试消耗缓存
        public bool OnSkillCanInterrupt(PlayerBtnType btnType)
        {
            // 获取当前缓存对应的技能SlotID
            var actor = context.actor;
            if (actor.input == null)
            {
                return false;
            }

            bool success = false;
            var slotID = actor.skillOwner.TryGetCurSlotID(btnType, PlayerBtnStateType.Down);
            
            if (slotID != null && actor.skillOwner.CanCastSkillBySlot(slotID.Value))
            {
                var btnTime = 0.0f;
                //先判断按钮在输入系统中能否使用
                success = actor.input.CanUseBtn(btnType, PlayerBtnStateType.Down, context.actor.time, out btnTime);
                    
                if (success)
                {
                    //判断是否有输入缓存轨道
                    if (bsSharedVariables.activeInputCache.IsHaveShared(btnType, PlayerBtnStateType.Down))
                    {
                        //再判断按钮能否在输入轨道中使用
                        success = bsSharedVariables.activeInputCache.CanUseBtn(btnType, PlayerBtnStateType.Down, btnTime, context.actor.time);
                    }
                    else
                    {
                        //如果没有输入缓存直接判断当前帧按钮能否使用
                        success = actor.input.TryConsumeCache(btnType, PlayerBtnStateType.Down, 0, tapDuration:0, tapDownElapse:0);
                    }
                }
                
                if (success)
                {
                    // 走到这里，表示输入缓存也能用并且被使用了。直接释放技能即可
                    success = actor.skillOwner.TryCastSkillBySlot(slotID.Value, safeCheck:false);
                }
            }

            return success;
        } 
    }
}