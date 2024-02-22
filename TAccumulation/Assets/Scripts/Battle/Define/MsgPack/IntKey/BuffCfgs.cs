using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.Serialization.Formatters.Binary;
using MessagePack;
using PapeGames.X3;
using UnityEngine.Serialization;
using XAssetsManager;

namespace X3Battle
{
#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class BuffCfg // Buff配置
    {
        [Key(0)] public int ID;
        [Key(1)] public string Name;
        [Key(2)] public string Description;

        [Key(3)] public float Time;
        [Key(4)] public bool StackClear;
        [Key(5)] public MutexRelationType MutexRelation;
        [Key(6)] public TimeConditionType ClearCondition;  //清除条件 
        [Key(7)] public bool MultiplyStack;  // 层数是否叠加
        [Key(8)] public int MaxStack;  // 最大层数
        [Key(9)] public string BuffIcon;
        [Key(10)] public IconShowType IconFlag;
        [Key(11)] public int IconLevel;
        [Key(12)] public BuffTriggerConfig[] Triggers;
        [Key(13)] public List<BuffActionBase> BuffActions;
        /// <summary>
        /// 编辑器用的虚拟目录字段
        /// </summary>
        [Key(14)] public string VirtualPath;
        [Key(15)] public List<LayersData> LayersDatas;
        [Key(16)] public BuffType BuffType = BuffType.Attribute;
        [Key(17)] public int BuffConflictTag;
        [Key(18)] public BuffTag BuffTag = BuffTag.Buff;
        [Key(19)] public bool FxOnlyOne = true;
        // 多选的免疫类型Tag
        [Key(20)] public List<int> BuffMultipleTags;
        [Key(21)] public bool NoToSummon = false;//不对召唤物生效
        
        /// <summary>
        /// 肉鸽玩法，上百层buff配置，如果对应层数是空，使用往上最近不为空的层数数据
        /// </summary>
        /// <returns></returns>
        public LayersData GetLayerData(int layer)
        {
            if (layer == 1)
            {
                return LayersDatas[0];
            }
            
            if (layer > MaxStack||layer > LayersDatas.Count)
            {
                LogProxy.LogError($"buff {ID}, 层数数据获取错误 layer = {layer}");
                return null;
            }

            var data = LayersDatas.GetLayerDataInClosestNoNull(layer);
            if (data == null)
            {
                LogProxy.LogError($"buff {ID}, 层数数据获取错误 layer = {layer} ,层数数据全空");
            }
            return data;
        }
    }
    
    
#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    //跟随层数变化的数据
    public class LayersData
    {
        [Key(0)] public int DamageBoxID;
        [Key(1)] public List<AttrParam> AttrParamsList;
        [Key(2)] public int FxID;//废弃
        [Key(3)] public List<int> FxIDList;

        public LayersData()
        {
            DamageBoxID = 0;
            AttrParamsList = new List<AttrParam>();
            FxID = 0;
            FxIDList = new List<int>();
        }
        
        public LayersData Clone()
        {
            //TODO,优化
            BinaryFormatter bf = new BinaryFormatter();
            MemoryStream ms = new MemoryStream();
            bf.Serialize(ms, this);
            ms.Position = 0;
            return (LayersData)bf.Deserialize(ms);
        }
    }

    public static class BattleBuffCfgExtension
    {
        public static LayersData GetLayerDataInClosestNoNull(this List<LayersData> LayersDatas,int layer)
        {
            if (layer > LayersDatas.Count || layer < 0)
            {
                return null;
            }

            if (LayersDatas[layer - 1] == null)
            {
                //取往上最近不为空的层数数据
                for (int i = layer-2; i >= 0; i--)
                {
                    var data = LayersDatas[i];
                    if (data!= null)
                    {
                        return data;
                    }
                }
            }

            return LayersDatas[layer - 1];
        }

        public class AttrParamComparer : IEqualityComparer<AttrParam>
        {
            public bool Equals(AttrParam x, AttrParam y)
            {
                if (x == null || y == null)
                {
                    return false;
                }
                return x.AttrS == y.AttrS;
            }

            public int GetHashCode(AttrParam obj)
            {
                return obj.AttrS.GetHashCode();
            }
        }
    }

#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class BuffTriggerConfig
    {
        // TriggerID
        [Key(0)] public int ID;
        // 持续时间 
        [Key(1)] public float time;
        // 持续时间与buff绑定
        [Key(2)] public bool attachToBuff; 
    }


#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class BasicBuffActionConfig
    {
        [Key(0)] public AttrParam[] AttrParams;
    }

#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class BuffActionConfig
    {
        [Key(0)] public BuffActionType type;
        [Key(1)] public BasicBuffActionConfig basicConfig;
    }

#if UNITY_EDITOR
    [Serializable]
#endif
    [MessagePackObject]
    public class AttrParam
    {
        [Key(0)] public string AttrS;
        [Key(1)] public float[] AttrF;
    }
}
