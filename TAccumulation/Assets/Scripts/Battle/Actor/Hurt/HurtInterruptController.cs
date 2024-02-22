namespace X3Battle
{
    /// <summary>
    /// 受击状态的打断控制器
    /// </summary>
    public class HurtInterruptController
    {
        //受击态能否被技能打断
        private bool _hurtInterruptBySkill;
        public bool hurtInterruptBySkill => _hurtInterruptBySkill;
        private SkillTypeFlag _hurtInterruptBySkillFlag;
        //受击态能否被移动打断
        private bool _hurtInterruptByMove;
        public bool hurtInterruptByMove => _hurtInterruptByMove;
        private Actor _actor;
        
        public HurtInterruptController()
        {
            _hurtInterruptBySkill = false;
            _hurtInterruptBySkillFlag = 0;
            _hurtInterruptByMove = false;
        }

        public void Init(Actor actor)
        {
            _actor = actor;
        }

        public void Clear()
        {
            _hurtInterruptBySkill = false;
            _hurtInterruptBySkillFlag = 0;
            _hurtInterruptByMove = false;
            _actor = null;
        }
        
        /// <summary>
        /// 标记受击态能否被技能打断
        /// </summary>
        /// <param name="canInterrupt"></param>
        /// <param name="flag"></param>
        public void SetHurtInterruptBySkill(bool canInterrupt, SkillTypeFlag flag = 0)
        {
            _hurtInterruptBySkill = canInterrupt;
            _hurtInterruptBySkillFlag = flag;
            if (canInterrupt)
            {
                if (_hurtInterruptBySkillFlag == flag)
                {
                    return;
                }
                _hurtInterruptBySkillFlag = flag;
            }
            else
            {
                if (_hurtInterruptBySkillFlag == 0)
                {
                    return;
                }
                _hurtInterruptBySkillFlag = 0;
            }
        }

        /// <summary>
        /// 标记受击态能否被移动打断
        /// </summary>
        /// <param name="canInterrupt"></param>
        public void SetHurtInterruptByMove(bool canInterrupt)
        {
            _hurtInterruptByMove = canInterrupt;
        }
        
        /// <summary>
        /// 受伤状态能否被移动打断
        /// </summary>
        public bool HurtTryEndByMove()
        {
            if (_hurtInterruptByMove && _actor.hurt != null && _actor.HasDirInput())
            {
                _actor.hurt.StopHurt();
                return true;
            }

            return false;
        }
        /// <summary>
        /// 受击状态能否被技能打断
        /// </summary>
        /// <param name="otherType"></param>
        /// <returns></returns>
        public bool HurtInterruptBySkill(SkillType otherType)
        {
            var result = BattleUtil.ContainSkillType(_hurtInterruptBySkillFlag, otherType);
            return result;
        }
    }
}