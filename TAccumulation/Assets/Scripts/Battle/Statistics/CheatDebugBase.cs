namespace X3Battle
{
    public class CheatDebugBase
    {
        public int skillID => m_skillID;
        public int atkID => m_atkID;
        public float atkAtk => m_atkAtk;
        public int atkLevel => m_atkLevel;
        public float atkDamage => m_atkDamage;//伤害加成
        public float atkFinalDamage => m_atkFinalDamage;//最终伤害加成
        public float atkSkillDamage => m_atkSkillDamage;//技能加成
        public float atkCritVal => m_atkCritVal;
        public float atkCritHurt => m_atkCritHurt;
        public float atkFinalDamageAdd => m_atkFinalDamageAdd;//怪物用 最终伤害加成系数

        public float hurtDefend => m_hurtDefend;
        public float hurtDamage => m_hurtDamage;//伤害减免
        public float hurtFinalDamage => m_hurtFinalDamage;

        public float damage => m_damage;

        private int m_skillID;//技能ID 有可能是BUFFID
        private int m_atkID;
        private float m_atkAtk;
        private int m_atkLevel;
        private float m_atkDamage;//伤害加成
        private float m_atkFinalDamage;//最终伤害加成
        private float m_atkSkillDamage;//技能加成
        private float m_atkCritVal;
        private float m_atkCritHurt;
        private float m_atkFinalDamageAdd;//怪物用 最终伤害加成系数

        private float m_hurtDefend;
        private float m_hurtDamage;//伤害减免
        private float m_hurtFinalDamage;

        private float m_damage;

        public void InitAtk(int skillID, int atkId, float atkAtk, int atkLevel, float atkDamage, float atkFinalDamage, float atkSkillDamage,
            float atkCritVal, float atkCritHurt, float atkFinalDamageAdd)
        {
            this.m_skillID = skillID;
            this.m_atkID = atkId;
            this.m_atkAtk = atkAtk;
            this.m_atkLevel = atkLevel;
            this.m_atkDamage = atkDamage;
            this.m_atkFinalDamage = atkFinalDamage;
            this.m_atkCritVal = atkCritVal;
            this.m_atkCritHurt = atkCritHurt;
            this.m_atkSkillDamage = atkSkillDamage;
            this.m_atkFinalDamageAdd = atkFinalDamageAdd;
        }

        public void InitHurt(float hurtDefend, float hurtDamage, float hurtFinalDamage, float damage)
        {
            this.m_hurtDefend = hurtDefend;
            this.m_hurtDamage = hurtDamage;
            this.m_hurtFinalDamage = hurtFinalDamage;
            this.m_damage = damage;
        }
    }
}