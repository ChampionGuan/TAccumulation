using System;
using PapeGames.X3;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public static class AttrUtil
    {
        //常规属性类型
        private static List<AttrType> _ConventionalAttrTypes = null;

        public static List<AttrType> GetConventionalAttrTypes()
        {
            if (_ConventionalAttrTypes != null)
            {
                return _ConventionalAttrTypes;
            }

            _ConventionalAttrTypes = new List<AttrType>(70);
            foreach (AttrType attrType in Enum.GetValues(typeof(AttrType)))
            {
                if (attrType < AttrType.HP)
                {
                    _ConventionalAttrTypes.Add(attrType);
                }
            }

            return _ConventionalAttrTypes;
        }
        public struct AttrTypeComparer : IEqualityComparer<AttrType>
        {
            public bool Equals(AttrType x, AttrType y)
            {
                return x == y;
            }

            public int GetHashCode(AttrType obj)
            {
                return (int)obj;
            }
        }
        public struct EnergyTypeComparer : IEqualityComparer<EnergyType>
        {
            public bool Equals(EnergyType x, EnergyType y)
            {
                return x == y;
            }

            public int GetHashCode(EnergyType obj)
            {
                return (int)obj;
            }
        }
        // 配置能量属性
        public static Dictionary<AttrType, AttrEnergy> energyDict = new Dictionary<AttrType, AttrEnergy>(new AttrTypeComparer())
        {
            [AttrType.MaleEnergy] = new AttrEnergy(AttrType.MaleEnergy, AttrType.MaleEnergyRecover, AttrType.BoyEnergyMax, AttrType.BoyEnergyInit, AttrType.MaleEnergyGather) ,
            [AttrType.WeaponEnergy] = new AttrEnergy(AttrType.WeaponEnergy, AttrType.WeaponEnergyRecover, AttrType.WeaponEnergyMax, AttrType.WeaponEnergyInit, AttrType.WeaponEnergyGather),
            [AttrType.UltraEnergy] = new AttrEnergy(AttrType.UltraEnergy, AttrType.UltraEnergyRecover, AttrType.UltraEnergyMax, AttrType.UltraEnergyInit, AttrType.UltraEnergyGather),
            [AttrType.SkillEnergy] = new AttrEnergy(AttrType.SkillEnergy, AttrType.SkillEnergyRecover, AttrType.SkillEnergyMax, AttrType.SkillEnergyInit, AttrType.SkillEnergyGather),
        };

        // 对于存在最大值的属性，配置其对应的最大值属性
        private static Dictionary<AttrType, AttrType> _attrTypeMap = new Dictionary<AttrType, AttrType>(new AttrTypeComparer())
        {
            [AttrType.HP] = AttrType.MaxHP,
            [AttrType.MaleEnergy] = AttrType.BoyEnergyMax,
            [AttrType.WeaponEnergy] = AttrType.WeaponEnergyMax,
            [AttrType.UltraEnergy] = AttrType.UltraEnergyMax,
            [AttrType.SkillEnergy] = AttrType.SkillEnergyMax,
        };

        private static Dictionary<EnergyType, AttrType> _energyAttrMap = new Dictionary<EnergyType, AttrType>(new EnergyTypeComparer())
        {
            [EnergyType.Male] = AttrType.MaleEnergy,
            [EnergyType.Weapon] = AttrType.WeaponEnergy,
            [EnergyType.Ultra] = AttrType.UltraEnergy,
            [EnergyType.Skill] = AttrType.SkillEnergy,
        };

        /// <summary>
        /// 返回属性type的最大值的属性类型,若不存在则返回None
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        public static AttrType GetMaxValueType(AttrType type)
        {
            if (_attrTypeMap.ContainsKey(type))
                return _attrTypeMap[type];
            else
                return AttrType.None;
        }

        /// <summary>
        /// 返回最大值属性type所关联的属性类型
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        public static AttrType GetMaxRelatedValueType(AttrType type)
        {
            if (_attrTypeMap.TryGetValue(type, out AttrType res))
                return res;
            else
                return AttrType.None;
        }

        public static AttrType ConvertEnergyToAttr(EnergyType energyType)
        {
            if(_energyAttrMap.ContainsKey(energyType))
            {
                return _energyAttrMap[energyType];
            }
            else
            {
                // 返回默认能量类型
                return AttrType.SkillEnergy;
            }
        }

        /// <summary>
        /// 判断目标的能量是否满了.
        /// </summary>
        /// <param name="target"></param>
        /// <param name="energyType"></param>
        /// <returns></returns>
        public static bool IsEnergyFull(Actor target, EnergyType energyType)
        {
            if (target?.attributeOwner == null)
            {
                return false;
            }
            
            var attrType = AttrUtil.ConvertEnergyToAttr(energyType);
            var maxAttrType = AttrUtil.GetMaxValueType(attrType);
            var maxAttrValue = target.attributeOwner.GetAttrValue(maxAttrType);
            var curAttrValue = target.attributeOwner.GetAttrValue(attrType);
            return curAttrValue >= maxAttrValue;
        }
    }

    public class AttrEnergy
    {
        public AttrType energy { get; private set; }
        public AttrType energyRecover { get; private set; }
        public AttrType energyMax { get; private set; }
        public AttrType energyInit { get; private set; }
        public AttrType energyGather { get; private set; }

        /// <summary>
        /// 能量包含多个属性
        /// </summary>
        /// <param name="energy"></param> 能量属性
        /// <param name="energyRecover"></param> 能量回复属性
        /// <param name="energyMax"></param> 能量最大值属性
        /// <param name="energyInit"></param> 能量初始值属性
        /// <param name="energyGather"></param> 能量获取效率属性
        public AttrEnergy(AttrType energy, AttrType energyRecover, AttrType energyMax, AttrType energyInit, AttrType energyGather)
        {
            this.energy = energy;
            this.energyRecover = energyRecover;
            this.energyMax = energyMax;
            this.energyInit = energyInit;
            this.energyGather = energyGather;
        }
    }
}
