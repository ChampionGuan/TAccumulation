namespace X3Battle
{
    /// <summary>
    /// 防作弊统计的技能信息
    /// </summary>
    public class CheatSkillBase
    {
        public int skillID;
        public int useNum;
        public int damage;

        public CheatSkillBase()
        {
        }
        public void Init(int skillId, int useNum, float damage)
        {
            this.skillID = skillId;
            this.useNum = useNum;
            this.damage = (int)damage;
        }
        
        public void AddData(int useNum, float damage)
        {
            this.useNum += useNum;
            this.damage += (int)damage;
        }
    }
    
}