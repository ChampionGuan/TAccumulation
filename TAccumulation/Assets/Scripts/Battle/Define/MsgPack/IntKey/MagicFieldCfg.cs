using System;
using System.Collections.Generic;
using MessagePack;
using UnityEngine.Serialization;

namespace X3Battle
{
#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class MagicFieldCfg
    {
        [Key(0)] public int ID;
        [Key(1)] public string Name;   
        [Key(2)] public string VirtualPath;  // 虚拟目录
        [Key(3)] public List<FactionRelationship> Relationships = new List<FactionRelationship>()
        {
            FactionRelationship.Enemy,
        };  // 阵营关系
        [Key(4)] public bool EndWithMaster;  // 随着主人死亡结束
        [Key(5)] public int ActionModule;  // 动作模组ID
        [Key(6)] public ShapeBoxInfo ShapeBoxInfo;  // 形状信息
        [Key(7)] public bool IsDynamicLife;  // 是否动态生命周期
        [Key(8)] public float Duration = - 1f;  // 当是动态生命周期时的持续时长
        [Key(9)] public int MaxHit = -1;  // 当是动态生命周期时的最大hit次数（不是命中，是法术场hit行为）
        [Key(10)] public bool boyAgentAvoid;  // 男主寻路是否规避
        [Key(11)] public float agentRadius;  // 寻路参考半径
        [Key(12)] public bool isDown = true;//
    }
}