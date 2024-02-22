namespace X3Battle.TargetSelect
{
    public class SkillSelectData : IReset
    {
        // 技能ID
        public int skillId;
        // 技能选择类型
        public TargetSelectType targetSelectType;
        // 技能锁定类型
        public SkillLockChangeType lockChangeType;

        public void Init(SkillActive skill)
        {
            var config = skill.config;
            this.skillId = config.ID;
            this.targetSelectType = (TargetSelectType) config.TargetSelectType;
            this.lockChangeType = (SkillLockChangeType) config.LockChangeType;
        }

        public void Reset()
        {
            skillId = 0;
            targetSelectType = TargetSelectType.Nothing;
            lockChangeType = SkillLockChangeType.Update;
        }
    }
}