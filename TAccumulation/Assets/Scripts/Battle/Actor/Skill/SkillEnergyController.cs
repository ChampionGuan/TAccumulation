namespace X3Battle
{
    public class SkillEnergyController
    {
        private SharedFlagSet _data;
        public SkillEnergyController()
        {
            _data = new SharedFlagSet();
        }

        public void Clear()
        {
            _data.Clear();
        }
        
        // skillType计算hashCode
        private static int _CalculateHashCode(SkillType skillType, AttrType attrType)
        {
            return (int)skillType << 6 & (int)attrType;
        }

        // skillID计算HashCode
        private static int _CalculateHashCode(int skillID, AttrType attrType)
        {
            return -(skillID << 3 & (int)attrType);
        }
        
        /// <summary>
        /// 添加技能释放无消耗信息
        /// </summary>
        /// <param name="owner"></param>
        /// <param name="skillType"></param>
        /// <param name="attrType"></param>
        public void AddNoConsumption(object owner, SkillType skillType, AttrType attrType)
        {
            var hashCode = _CalculateHashCode(skillType, attrType);
            _data.Acquire(owner, hashCode);
        }

        // 使用技能ID添加
        public void AddNoConsumption(object owner, int skillID, AttrType attrType)
        {
            var hashCode = _CalculateHashCode(skillID, attrType);
            _data.Acquire(owner, hashCode);
        }

        /// <summary>
        /// 移除技能释放无消耗信息
        /// </summary>
        /// <param name="owner"></param>
        /// <param name="skillType"></param>
        /// <param name="attrType"></param>
        public void RemoveNoConsumption(object owner, SkillType skillType, AttrType attrType)
        {
            var hashCode = _CalculateHashCode(skillType, attrType);
            _data.Remove(owner, hashCode);
        }
        
        // 使用技能ID移除
        public void RemoveNoConsumption(object owner, int skillID, AttrType attrType)
        {
            var hashCode = _CalculateHashCode(skillID, attrType);
            _data.Remove(owner, hashCode);
        }

        /// <summary>
        /// 某种技能类型+属性类型是否无消耗
        /// </summary>
        /// <param name="skillType"></param>
        public bool HasNoConsumptionInfo(SkillType skillType, AttrType attrType)
        {
            var hashCode = _CalculateHashCode(skillType, attrType);
            var result = _data.IsActive(hashCode);
            return result;
        }
        
        // 使用技能ID查询
        public bool HasNoConsumptionInfo(int skillID, AttrType attrType)
        {
            var hashCode = _CalculateHashCode(skillID, attrType);
            var result = _data.IsActive(hashCode);
            return result;
        }
    }
}