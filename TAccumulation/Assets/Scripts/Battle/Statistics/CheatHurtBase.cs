using System.Collections.Generic;

namespace X3Battle
{
    public class CheatBuff
    {
        public int ID;
        public int SubKey;

        public CheatBuff()
        {
            
        }
    }

    public enum CheatActorType
    {
        Boy = 0,
        Girl,
        Monster,
        Summon,
        Max,
    }
    public class CheatHurtBase
    {
        public float time;
        public int atkType;
        public int atkID;
        public int atkCfgID;
        public int atkSummonLevel;
        public int atkBelongType;//如果是召唤怪 表示召唤怪物的来源
        public int atkBelongId;//如果是召唤怪 表示召唤怪物来源的ID
        public List<CheatBuff> atkBuffs = new List<CheatBuff>(4);

        public int hurtType;
        public int hurtID;
        public int hurtCfgID;
        public int hurtLevel;
        public int hurtBelongType;//如果是召唤怪 表示召唤怪物的来源
        public int hurtBelongId;
        public List<CheatBuff> hurtBuffs = new List<CheatBuff>(4);

        public int skillID;
        public int skillType;
        public int hitParamCfgId;
        public int damagePercent;
        public bool isCritical;//是否暴击
        public bool isWeak;//是否破核

        public int damageNum;

        public void InitAtk(int id, CheatActorType type, int Summonlevel, int belongID, CheatActorType belongType,int cfgId)
        {
            this.atkType = (int)type;
            this.atkSummonLevel = Summonlevel;
            this.atkID = id;
            this.atkBelongId = belongID;
            this.atkBelongType = (int)belongType;
            this.atkCfgID = cfgId;
        }

        public void InitHurt(int id, CheatActorType type, int level, int belongID, CheatActorType belongType,int cfgId)
        {
            this.hurtID = id;
            this.hurtType = (int)type;
            this.hurtLevel = level;
            this.hurtBelongId = belongID;
            this.hurtBelongType = (int)belongType;
            this.hurtCfgID = cfgId;
        }

        public void InitSkill(int skillId, int skillType, int hitParamCfgId, float damagePercent, bool isCritical,
            int damageNum, bool isWeak,float time, int hitParamId)
        {
            this.skillID = skillId;
            this.skillType = skillType;
            this.hitParamCfgId = hitParamCfgId;
            this.damagePercent = (int)(damagePercent * 1000.0f);
            this.isCritical = isCritical;
            this.damageNum = damageNum;
            this.isWeak = isWeak;
            this.time = time;
        }

        public void InitBuff(Actor atker, Actor hurter)
        {
            if (atker.buffOwner != null)
            {
                var atkList = atker.buffOwner.GetBuffs();
                atkBuffs.Clear();
                foreach (var buff in atkList)
                {

                    if (!TbUtil.HasCfg<Dictionary<int, BuffLevelConfig>>(buff.ID))
                        continue;
                    var cheatBuff = ObjectPoolUtility.CheatBuffPool.Get();
                    cheatBuff.ID = buff.ID;
                    cheatBuff.SubKey = buff.level * 100 + buff.layer;
                    atkBuffs.Add(cheatBuff);
                }
            }

            if (hurter.buffOwner != null)
            {
                var hurtList = hurter.buffOwner.GetBuffs();
                hurtBuffs.Clear();
                foreach (var buff in hurtList)
                {

                    if (!TbUtil.HasCfg<Dictionary<int, BuffLevelConfig>>(buff.ID))
                        continue;

                    var cheatBuff = ObjectPoolUtility.CheatBuffPool.Get();
                    cheatBuff.ID = buff.ID;
                    cheatBuff.SubKey = buff.level * 100 + buff.layer;
                    hurtBuffs.Add(cheatBuff);
                }
            }
        }

        public string GetString()
        {
            using (zstring.Block())
            {
                zstring str = "Hurt:";
                str += time;
                str += "|" + atkCfgID;
                str += "|" + hurtCfgID;
                str += "|" + isWeak;
                str += "|" + isCritical;
                str += "|" + damageNum;
                str += "|" + skillID;
                str += "|";
                int index = 0;
                foreach (var buff in atkBuffs)
                {
                    if (index + 1 == atkBuffs.Count)
                    {
                        str += buff.ID;
                    }
                    else
                    {
                        str += buff.ID + "+";
                    }

                    index++;
                }
                str += "|";
                index = 0;
                foreach (var buff in hurtBuffs)
                {
                    if (index + 1 == hurtBuffs.Count)
                    {
                        str += buff.ID;
                    }
                    else
                    {
                        str += buff.ID + "+";
                    }

                    index++;
                }
                str += "|" + hitParamCfgId;
                
                return str;  // 传出去马上就转成byte[]写入了，不需要Intern
            } 
        }
    }
}