using System.Collections.Generic;

namespace X3Battle
{
    public class SkillDisableController
    {
        private SharedFlagSet _typeDisableData;
        private SharedFlagSet _tagDisableData;
        private SkillOwner _skillOwner;
      
        // 策划单独要求禁男主共鸣技爆发技时也要禁女主
        private HashSet<int> _boyCoopSkillTags;
        private HashSet<int> _boyUltraSkillTags;
        
        public SkillDisableController(SkillOwner owner)
        {
            _boyCoopSkillTags = new HashSet<int>();
            _boyUltraSkillTags = new HashSet<int>();
            _typeDisableData = new SharedFlagSet();
            _tagDisableData = new SharedFlagSet();
            _skillOwner = owner;
        }

        public void OnCreateSkill(ISkill skill)
        {
            // 只记录boy
            if (!_skillOwner.actor.IsBoy())
            {
                return;
            }

            if (skill.config.Type == SkillType.Coop)
            {
                var tags = skill.config.Tags;
                if (tags != null)
                {
                    foreach (var tag in tags)
                    {
                        _boyCoopSkillTags.Add(tag);
                    }   
                }
            }
            else if (skill.config.Type == SkillType.Ultra)
            {
                var tags = skill.config.Tags;
                if (tags != null)
                {
                    foreach (var tag in tags)
                    {
                        _boyUltraSkillTags.Add(tag);
                    }    
                }
            }
        }
        
        public void Clear()
        {
            _typeDisableData.Clear();
            _tagDisableData.Clear();
            _boyCoopSkillTags.Clear();
            _boyUltraSkillTags.Clear();
        }

        public void AcquireDisableFlag(object owner, SkillTypeFlag flag)
        {
            for (int i = 0; i < (int)SkillType.Num; i++)
            {
                var containsFlag = BattleUtil.ContainSkillType(flag, (SkillType)i);
                if (containsFlag)
                {
                    _typeDisableData.Acquire(owner, i);
                }

                // 策划特殊需求：男主共鸣技爆发技被禁时，女主也禁掉
                if (containsFlag && _skillOwner.actor.IsBoy())
                {
                    var skillType = (SkillType)i;
                    if (skillType == SkillType.Coop)
                    {
                        var girl = _skillOwner.actor.battle.actorMgr.girl;
                        girl?.skillOwner.disableController.AcquireDisableFlag(owner, SkillTypeFlag.Coop);        
                    }
                    else if(skillType == SkillType.Ultra)
                    {
                        var girl = _skillOwner.actor.battle.actorMgr.girl;
                        girl?.skillOwner.disableController.AcquireDisableFlag(owner, SkillTypeFlag.Ultra);   
                    }
                }
            }
        }

        public void RemoveDisableFlag(object owner, SkillTypeFlag flag)
        {
            for (int i = 0; i < (int)SkillType.Num; i++)
            {
                var containsFlag = BattleUtil.ContainSkillType(flag, (SkillType)i);
                if (containsFlag)
                {
                    _typeDisableData.Remove(owner, i);     
                }
                
                // 策划特殊需求：男主共鸣技爆发技被禁时，女主也禁掉
                if (containsFlag && _skillOwner.actor.IsBoy())
                {
                    var skillType = (SkillType)i;
                    if (skillType == SkillType.Coop)
                    {
                        var girl = _skillOwner.actor.battle.actorMgr.girl;
                        girl?.skillOwner.disableController.RemoveDisableFlag(owner, SkillTypeFlag.Coop);        
                    }
                    else if(skillType == SkillType.Ultra)
                    {
                        var girl = _skillOwner.actor.battle.actorMgr.girl;
                        girl?.skillOwner.disableController.RemoveDisableFlag(owner, SkillTypeFlag.Ultra);   
                    }
                }
            }
        }

        // 用Tag列表禁用技能
        //tags参数不允许修改
        public void AcquireDisableFlag(object owner, List<int> tags)
        {
            if (tags != null && tags.Count > 0)
            {
                var isBoy = _skillOwner.actor.IsBoy();
                var containBoyCoop = false;
                var containBoyUltra = false;
                
                foreach (var tag in tags)
                {
                    _tagDisableData.Acquire(owner, tag);
                    if (isBoy)
                    {
                        if (!containBoyCoop && _boyCoopSkillTags.Contains(tag))
                        {
                            containBoyCoop = true;
                        }

                        if (!containBoyUltra && _boyUltraSkillTags.Contains(tag))
                        {
                            containBoyUltra = true;
                        }
                    }
                }

                // 影响到了男主共鸣技或爆发技，视为影响到了女主的相同技能
                if (containBoyCoop)
                {
                    var girl = _skillOwner.actor.battle.actorMgr.girl;
                    girl?.skillOwner.disableController.AcquireDisableFlag(owner, SkillTypeFlag.Coop);
                }

                if (containBoyUltra)
                {
                    var girl = _skillOwner.actor.battle.actorMgr.girl;
                    girl?.skillOwner.disableController.AcquireDisableFlag(owner, SkillTypeFlag.Ultra);   
                }
            }
        }
        
        // 用tag列表解除禁用技能
        public void RemoveDisableFlag(object owner, List<int> tags)
        {
            if (tags != null && tags.Count > 0)
            {
                var isBoy = _skillOwner.actor.IsBoy();
                var containBoyCoop = false;
                var containBoyUltra = false;
                
                foreach (var tag in tags)
                {
                    _tagDisableData.Remove(owner, tag);
                    if (isBoy)
                    {
                        if (!containBoyCoop && _boyCoopSkillTags.Contains(tag))
                        {
                            containBoyCoop = true;
                        }

                        if (!containBoyUltra && _boyUltraSkillTags.Contains(tag))
                        {
                            containBoyUltra = true;
                        }
                    }
                }
                
                // 影响到了男主共鸣技或爆发技，视为影响到了女主的相同技能
                if (containBoyCoop)
                {
                    var girl = _skillOwner.actor.battle.actorMgr.girl;
                    girl?.skillOwner.disableController.RemoveDisableFlag(owner, SkillTypeFlag.Coop);
                }

                if (containBoyUltra)
                {
                    var girl = _skillOwner.actor.battle.actorMgr.girl;
                    girl?.skillOwner.disableController.RemoveDisableFlag(owner, SkillTypeFlag.Ultra);   
                }
            }
        }
        
        // 是否禁用技能
        public bool IsDisableSkill(ISkill skill)
        {
            if (skill == null)
            {
                return false;
            }
            
            var key = (int)skill.config.Type;
            var result = _typeDisableData.IsActive(key);
            if (!result)
            {
                result = _IsDisableSkillByTag(skill);
            }
            return result;
        }
        
        // Tag是否禁用技能
        private bool _IsDisableSkillByTag(ISkill skill)
        {
            var result = false;
            var tags = skill.config.Tags;
            if (tags != null && tags.Count > 0)
            {
                for (int i = 0; i < tags.Count; i++)
                {
                    var tag = tags[i];
                    if (_tagDisableData.IsActive(tag))
                    {
                        result = true;
                        break;  
                    }
                }
            }
            return result;
        }
    }
}