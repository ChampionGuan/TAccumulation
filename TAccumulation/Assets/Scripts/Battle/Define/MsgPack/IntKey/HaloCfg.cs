using System;
using System.Collections.Generic;
using MessagePack;

namespace X3Battle
{
#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class HaloCfg
    {
        // ID
        [Key(0)] public int ID;

        // 名称
        [Key(1)] public string Name;

        // 编辑器用的虚拟目录字段
        [Key(2)] public string VirtualPath;

        // 光环的生存时长
        [Key(3)] public float Duration;

        // 形状盒数据
        [Key(4)] public ShapeBoxInfo ShapeBoxInfo;

        // 光环范围内要添加的BuffID.
        [Key(5)] public List<int> BuffIds;

        // 阵营筛选
        [Key(6)] public FactionRelationship[] FactionRelationship;
        
        // 阵营筛选里是否包括自己
        [Key(7)] public bool IsFactionRelationshipSelf = true;

        // Buff滞留时长
        [Key(8)] public float BuffHoldUpTime = -1;
        
        // 蓝图索引筛选
        [Key(9)] public int TriggerID;

        // 是否忽略召唤物
        [Key(10)] 
        public bool IgnoreCreature;
    }
}