using System;
using System.Collections.Generic;
using MessagePack;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    /// <summary>
    /// 资源分析树
    /// </summary>
    public partial class ResModule
    {
        // 仅分析器内持有的ResModule，拥有owner。 
        private ResAnalyzer _owner;
        private ResModule _parent;

        [IgnoreMember]public ResModule parent => _parent;
        [IgnoreMember]public ResAnalyzer owner => _owner;
        
        public ResModule(ResAnalyzer owner)
        {
            if (owner != null)
            {
                _owner = owner;
                id = owner.ResID;
                ownerType = owner.GetType().Name;
                moduleName = ownerType;
            }

            tags = BattleResTag.Analyzed;
            resDescList = new List<ResDesc>();
            children = new List<ResModule>();
        }

        public ResModule AddChild(string moduleName)
        {
            // 这里的child的或者独立存在时，无owner
            ResModule resModule = new ResModule(null);
            resModule.moduleName = moduleName;
            resModule._parent = this;
            AddChild(resModule);
            return resModule;
        }

        public void AddChild(ResModule child)
        {
            child._parent = this;
            children.Add(child);
        }

        public ResModule Clone(ResAnalyzer owner)
        {
            ResModule resModule = new ResModule(owner)
            {
                id = this.id,
                ownerType = this.ownerType,
                moduleName = this.moduleName,
                tags = this.tags,
            };
            foreach (var resDesc in resDescList)
            {
                resModule.resDescList.Add(resDesc.Clone());
            }
            if (conditions != null && conditions.Count > 0)
            {
                var list = new List<ConditionAnalyze>(conditions);
                resModule.conditions = list;
            }
            
            foreach (var module in children)
            {
                var childModule = module.Clone(null);
                resModule.AddChild(childModule);
            }
            return resModule;
        }

        public bool AnalyzeSuccess()
        {
            return resDescList.Count > 0 || children.Count > 0;
        }

        public void AddResultByPath(string path, BattleResType type, int count = 0, BattleResTag tag = BattleResTag.Analyzed)
        {
            if (type == BattleResType.Hero)
            {
                LogProxy.LogError("Hero不支持直接AddResult, 请使用SuitResAnalyzer完成");
                return;
            }
            
            if (string.IsNullOrEmpty(path))
                return;

            if (BattleUtil.IsFxResType(type))
                AddResultByFxName(path, count, type, tag);
            else
            {
                AddResult(path, type, count, tag);
                TryAddResSVC(type, path, tag);
            }
        }
        
        /// <summary>
        /// 加载配置特效务必使用此接口，否则路径、皮肤替换等规则会失败
        /// 通过id 分析对应的特效
        /// 注意：皮肤替换特效，仅支持 fxID替换
        /// </summary>
        /// <param name="fxId"></param>
        public void AddResultByFxId(int fxId, int count = 0, BattleResType type = BattleResType.FX, BattleResTag tag = BattleResTag.Analyzed)
        {
            if (fxId == 0)
                return;
            FXConfig fxConfig = TbUtil.GetCfg<FXConfig>(fxId);
            if (fxConfig == null)
                return;
            if (fxConfig.IsFullPath == 1)
                type = BattleResType.AllFX;

            // 这里newResModule主要目的使为了id引用查找工具，支持fxID的引用查找. 仅支持查找替换后的fxID。
            var fxResModule = AddChild(BattleConst.FxResModule);
            fxResModule.id = fxId;
            string fxName = fxConfig.PrefabName;
            fxResModule.AddResultByFxName(fxName, count, type, tag);
        }

        private void AddResultByFxName(string fxName, int count = 0, BattleResType type = BattleResType.FX, BattleResTag tag = BattleResTag.Analyzed)
        {
            if (string.IsNullOrEmpty(fxName))
                return;

            //特效音效分析
            ResAnalyzer.AnalyzeFxGo(fxName, type, this);
            AddResult(fxName, type, count, tag);
            //添加中低档次的特效
            AddMidAndLowFx(fxName, type, count, tag);
        }
        
        private bool TryAddResSVC(BattleResType type, string relativePath, BattleResTag tag)
        {
            switch (type)
            {
                case BattleResType.Monster:
                    string resFullPath = BattleUtil.GetResPath(relativePath, type);
                    string svcFullPath = ResAnalyzeUtil.GetShaderSVCPath(resFullPath);
                    AddResult(svcFullPath, BattleResType.MonsterSVC, 1, tag);
                    return true;
                case BattleResType.Scene:
                    resFullPath = BattleUtil.GetResPath(relativePath, type);
                    svcFullPath = ResAnalyzeUtil.GetShaderSVCPath(resFullPath);
                    AddResult(svcFullPath, BattleResType.SceneSVC, 1, tag);
                    return true;
            }
            return false;
        }

        /// <summary>
        /// 添加中，低档次的特效
        /// </summary>
        private void AddMidAndLowFx(string path, BattleResType type, int count, BattleResTag tag)
        {            
            if (ResAnalyzer.AnalyzeRunEnv != AnalyzeRunEnv.BranchMerge &&
                ResAnalyzer.AnalyzeRunEnv != AnalyzeRunEnv.BuildApp)
            {
                return;
            }
            var config = BattleResConfig.GetResConfig(type);
            
            // MD 特效
            string tempPathMD = BattleUtil.GetResPathByLodType(path, type, FxSetting.LodType.mid);
            var resPathMD = null == config ? path : BattleUtil.StrConcat(config.dir, tempPathMD, config.ext);
            ResDesc resDescMD = new ResDesc()
            {
                path = tempPathMD,
                type = type,
                count = count,
                fullPath = resPathMD,
                moduleName = moduleName,
            };
            resDescMD.AddTag(tag);
            resDescList.Add(resDescMD);
            
            // LD特效
            string tempPathLD = BattleUtil.GetResPathByLodType(path, type, FxSetting.LodType.low);
            var resPathLD = null == config ? path : BattleUtil.StrConcat(config.dir, tempPathLD, config.ext);
            ResDesc resDescLD = new ResDesc()
            {
                path = tempPathLD,
                type = type,
                count = count,
                fullPath = resPathLD,
                moduleName = moduleName,
            };
            resDescLD.AddTag(tag);
            resDescList.Add(resDescLD);
        }
        
        private ResDesc AddResult(string path, BattleResType type, int count, BattleResTag tag)
        {
            if (string.IsNullOrEmpty(path))
                return null;
            
            // TODO fullPath 运行时不需要计算fullPath，用不到
            string fullPath = BattleUtil.GetResPath(path, type);
            ResDesc resDesc = new ResDesc()
            {
                path = path,
                type = type,
                count = count,
                fullPath = fullPath,
                moduleName = moduleName,
            };
            resDesc.AddTag(tag);
#if UNITY_EDITOR
            path = BattleUtil.GetResPathByLodType(path, type, FxSetting.GetEffectQuality());
            string resName = path.Substring(path.LastIndexOf("/") + 1);
            resDesc.name = resName;
#endif
            resDescList.Add(resDesc);
            return resDesc;
        }

        public void AddConditionAnalyze(ConditionAnalyze analyze)
        {
            if (conditions == null)
            {
                conditions = new List<ConditionAnalyze>();
            }
            // 这里处理，当条件分析时，又产生一个相同的条件分析，条件分析死循环
            // TODO 考虑这里是否需要支持数量累加
            foreach (var condition in conditions)
            {
                if (condition.IsSameData(analyze))
                {
                    return;
                }
            }
            conditions.Add(analyze);
        }
        
        public bool IsHaveTag(BattleResTag tag)
        {
            return (tags & tag) == tag;
        }
        
        public void ClearTag()
        {
            tags = BattleResTag.Analyzed;
        }
        
        // analyzed 标签不与其它tag共存，且不能主动添加
        public void AddTag(BattleResTag tag)
        {
            if (IsHaveTag(tag) || tag == BattleResTag.Analyzed)
                return;
            if (tags <= BattleResTag.Analyzed)
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

        public void InitParent()
        {
            foreach (var child in children)
            {
                child._parent = this;
            }
        }
    }

    /// <summary>
    /// 特效预制体上配置的声音，离线生成配置。 分析的时候不在load出来分析了
    /// </summary>
    public partial class FxCfg
    {
        [IgnoreMember] public const string OfflineDataDir = "FxAnalyzer";
        [IgnoreMember] public const string OfflineDataFilePath = OfflineDataDir + "/FxCfg";
        
        public void AddFxSound(string fxName, ICollection<string> strs)
        {
            if (strs == null || strs.Count <= 0)
                return;
            var hashStr = new HashSet<string>();
            foreach (var sound in strs)
            {
                if (!string.IsNullOrEmpty(sound))
                {
                    hashStr.Add(sound);
                }
            }
            if (hashStr.Count <= 0)
                return;

            if (fxSound.TryGetValue(fxName, out var sounds))
            {
                if (sounds.Count == strs.Count)
                    return;
            }
            // 同名特效，应属异常情况直接覆盖
            fxSound[fxName] = hashStr;
        }
        
        public void AddVfxSVC(string fxName, string svcPath, string hwSvcPath)
        {
            if (string.IsNullOrEmpty(fxName))
                return;

            // 通用SVC
            if (!svcCommonCfg.TryGetValue(fxName, out var svc))
            {
                svcCommonCfg[fxName] = svcPath;
            }
            // 华为SVC
            if (!svcHuaWeiCfg.TryGetValue(fxName, out var svcHW))
            {
                svcHuaWeiCfg[fxName] = hwSvcPath;
            }
        }

        public HashSet<string> GetFxSound(string fxName)
        {
            if (fxSound == null)
                return null;
            fxSound.TryGetValue(fxName, out var sounds);
            return sounds;
        }
        
        public string GetFxSVC(string fxName, bool isHuaWei)
        {
            string fullPath = string.Empty;
            if (isHuaWei)
                svcHuaWeiCfg.TryGetValue(fxName, out fullPath);
            else
                svcCommonCfg.TryGetValue(fxName, out fullPath);
            return fullPath;
        }

        public void Serialize()
        {
#if UNITY_EDITOR
            MpUtil.Serialize(this, OfflineDataFilePath);
            string dir = System.IO.Path.Combine(Environment.CurrentDirectory, "MessagePack", OfflineDataFilePath);
            LogProxy.LogFormat("分析器离线数据本地生成完成，位置：{0}", dir);
            // 测试代码， 可以生成一个json 到同样的目录下
            // MpUtil.EditorSerializeToJson(this, MpUtil.rootDir, fileName);
#endif
        }

        public static FxCfg DeSerialize()
        {
            var soundCfg = MpUtil.Deserialize<FxCfg>(OfflineDataFilePath);
            return soundCfg;
        }
    }
}