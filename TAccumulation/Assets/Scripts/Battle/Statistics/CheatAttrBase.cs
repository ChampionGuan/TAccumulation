using System.Collections.Generic;
using System.Text;

namespace X3Battle
{
    
    // configID
    // 时间
    // HP
    // MaxHP
    // WeakPoint
    // PhyAttack
    // PhyDefence
    // CritVal = 4, //---暴击值 
    // CritHurtAdd 暴击伤害
    // ATKSpeedUp = 9,//---普攻速度加成
    // HurtAdd = 21, //---伤害加成
    // HurtDec = 22, //---受到伤害减免
    // CDDec = 25, //---技能冷却缩减
    // AttackSkillAdd = 26,
    // ActiveSkillAdd = 27, //---主动技能伤害提升
    // CoopSkillAdd = 28, //---连携技伤害提升
    // UltraSkillAdd = 29, //---爆发技伤害提升
    // FinalDamageAdd = 34, // 最终伤害加成
    // FinalDamageDec = 35, // 最终伤害减免
    // IgnoreDefence = 36, // 忽视防御百分比
    // FinalDmgAddRate = 51, //---最终伤害修正倍率
    // HpShield = 1005, //---血量护盾
    // MaleEnergy = 1009, // 男主能量
    // WeaponEnergy = 1012, // 武器能量
    // UltraEnergy = 1015, // 爆发技能量
    // CoreDamageRatio = 1018, // 芯核伤害倍率
    // SkillEnergy = 1101, // 协作技能量
    
    /// <summary>
    /// 防作弊的统计属性信息
    /// </summary>
    public class CheatAttrBase
    {
        public List<float> attrs = new List<float>(27);

        public void Init(Actor actor)
        {
            if(actor == null)
                return;
            
            attrs.Add(Battle.Instance.time);
            attrs.Add(actor.cfgID);
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.HP).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.MaxHP).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.WeakPoint).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.PhyAttack).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.PhyDefence).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.CritVal).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.CritHurtAdd).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.ATKSpeedUp).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.HurtAdd).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.HurtDec).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.CDDec).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.AttackSkillAdd).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.ActiveSkillAdd).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.CoopSkillAdd).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.UltraSkillAdd).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.FinalDamageAdd).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.FinalDamageDec).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.IgnoreDefence).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.FinalDmgAddRate).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.HpShield).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.MaleEnergy).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.WeaponEnergy).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.UltraEnergy).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.CoreDamageRatio).GetValue());
            attrs.Add(actor.attributeOwner.GetAttr(AttrType.SkillEnergy).GetValue());
        }

        public string GetString()
        {
            using (zstring.Block())
            {
                if (attrs == null || attrs.Count <= 0)
                    return "";
                
                zstring str = "Attr:";
                foreach (var attr in attrs)
                {
                    str += attr + "|";
                }
                
                return str;  // 马上就写入的不需要intern，节省性能
            }
        }
    }
}