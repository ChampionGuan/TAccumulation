using System;
using System.Collections.Generic;
using MessagePack;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    [MessagePackObject]
    public partial class ResModule
    {
        [Key(0)]public int id;
        [Key(1)]public string moduleName; // 所属模块名字，默认 == ownerType
        [Key(2)]public string ownerType; // 所属分析器类型. 如果是分析器直接持有的resModule,则有值
        [Key(3)]public List<ResDesc> resDescList;
        [Key(4)]public List<ResModule> children;
        [Key(5)]public List<ConditionAnalyze> conditions;
        [Key(6)] public BattleResTag tags;  // 警告：业务逻辑请使用AddTag() 

        public ResModule()
        {
            resDescList = new List<ResDesc>();
            children = new List<ResModule>();
            tags = BattleResTag.Analyzed;
        }
    }

    /// <summary>
    /// 单个资源的描述
    /// </summary>
    [MessagePackObject]
    [Serializable]
    public class ResDesc
    {
        [Key(0)]public BattleResType type;
        [Key(1)]public int count;       
        [Key(2)]public string path;     // 配置的相对路劲
        [Key(3)]public int suitID;     // 男女主套装id
        [Key(4)]public string fullPath; // Asset下的全路径，包括asset
        [Key(5)] public bool isUltraModel; // 是否是爆发技模型
        [Key(6)] public BattleResTag tags; // 警告：业务逻辑请使用AddTag() 
        
        [IgnoreMember]public int loadedCount;
        [IgnoreMember]public string name; 
        [IgnoreMember]public string moduleName;
        [IgnoreMember]public ResLoadArg loadArg;

        public ResDesc()
        {
            suitID = BattleConst.InvalidActorSuitID;
            tags = BattleResTag.Analyzed;
        }

        public ResDesc Clone()
        {
            ResDesc desc = new ResDesc()
            {
                type = this.type,
                count = this.count,
                path = this.path,
                suitID =  this.suitID,
                fullPath =  this.fullPath,
                isUltraModel = this.isUltraModel,
                tags = this.tags,
                
                loadedCount = this.loadedCount,
                name = this.name,
                moduleName = this.moduleName,
            };
            return desc;
        }
        
        public bool EqualTag(BattleResTag tag)
        {
            if (tags == tag)
            {
                return true;
            }

            if (tags == (tag | BattleResTag.Default))
            {
                return true;
            }
            return false;
        }
        
        public bool IsHaveTag(BattleResTag tag)
        {
            return (tags & tag) == tag;
        }
        
        public void ClearTag()
        {
            tags = BattleResTag.Default;
        }
        
        // 不支持添加 Default 标签。  Default标签和其它标签不共存
        public void AddTag(BattleResTag tag)
        {
            if (IsHaveTag(tag) || tag == BattleResTag.Default)
                return;
            if (tags <= BattleResTag.Default)
            {
                tags = tag;
            }
            else
            {
                tags |= tag;
            }
        }
        
        public void RemoveTag(BattleResTag tag)
        {
            if (!IsHaveTag(tag))
            {
                return;
            }
            tags = tags & ~tag;
        }
    }

    [MessagePackObject]
    public partial class FxCfg
    {
        // key 为特效相对路径， value为声音列表
        [Key(0)]
        public Dictionary<string, HashSet<string>> fxSound;
        
        // key 为特效相对路径， value为SVC的全路径。 注意vfx SVC区分华为和非华为
        [Key(1)]
        public Dictionary<string, string> svcCommonCfg;
        [Key(2)]
        public Dictionary<string, string> svcHuaWeiCfg;

        public FxCfg()
        {
            fxSound = new Dictionary<string, HashSet<string>>();
            svcCommonCfg = new Dictionary<string, string>();
            svcHuaWeiCfg = new Dictionary<string, string>();
        }
    }
}