using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using MessagePack;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    
    /// <summary>
    /// 脚底烟尘分析 @雨天
    /// </summary>
    [MessagePackObject]
    [Serializable]
    public class FootMoveFxAnalyze : ConditionAnalyze, IAnalyzeWithLevel
    {
        [Key(0)] public int groupID;

        public FootMoveFxAnalyze(int groupID)
        {
            this.groupID = groupID;
        }

        public override bool IsSameData(ConditionAnalyze otherAnalyze)
        {
            if (otherAnalyze is FootMoveFxAnalyze analyze)
            {
                return analyze.groupID == this.groupID;
            }
            return false;
        }

        public void AnalyzeWithLevel(ResModule resModule, int levelID)
        {
            string sceneMapDataPath = BattleUtil.GetSceneMapRelativePath(levelID);
            if (BattleResMgr.Instance.IsExists(sceneMapDataPath, BattleResType.SceneMapData))
            {
                var mapData =
                    BattleResMgr.Instance.Load<SoundsMapAssets>(sceneMapDataPath, BattleResType.SceneMapData);
                if (mapData != null)
                {
                    //TbUtil.groundMoveFxs.TryGetValue(groupID, out var phyMatDic);
                    var phyMatDic = TbUtil.GetCfg<Dictionary<int, GroundMoveFx>>(groupID);
                    foreach (var matID in phyMatDic.Keys)
                    {
                        if(!mapData.allIDTypes.Contains(matID))
                            continue;
                        if (matID < 0)
                            continue;
                        if (!phyMatDic.TryGetValue(matID, out var groundMoveFxs))
                            continue;
                        resModule.AddResultByFxId(groundMoveFxs.FxID);
                        resModule.AddResultByPath(groundMoveFxs.EventName, BattleResType.ActorAudio);
                    }

                    BattleResMgr.Instance.Unload(mapData);
                }
            }
        }
    }

    /// <summary>
    /// 技能Timeline上的武器部件分析 @长空
    /// </summary>
    [MessagePackObject]
    [Serializable]
    public class SkillWeaponPartsAnalyze : ConditionAnalyze
    {
        [Key(0)] public string weaponPart;
        [Key(1)] public bool isGirl;
        [Key(2)] public bool isPerform;  // 是否是表演解析出来的部件

        public SkillWeaponPartsAnalyze(string weaponPart, bool isGirl, bool isPerform)
        {
            this.weaponPart = weaponPart;
            this.isGirl = isGirl;
            this.isPerform = isPerform;
        }

        protected override void OnRunTime(ResModule resModule)
        {
            // 区分是否男女主，是否表演模型
            BattleEnv.AddHeroExtWeaponPart(isGirl? HeroType.Girl : HeroType.Boy, isPerform, weaponPart);
        }

        protected override void OnBuildApp(ResModule resModule)
        {
            // 高模
            string partAssetPath = BattleCharacterMgr.GetPartAssetPath(weaponPart, CharacterMgr.LOD_HD);
            resModule.AddResultByPath(partAssetPath, BattleResType.Weapon);
            // 低模
            partAssetPath = BattleCharacterMgr.GetPartAssetPath(weaponPart, CharacterMgr.LOD_LD);
            resModule.AddResultByPath(partAssetPath, BattleResType.Weapon);
        }
        
        public override bool IsSameData(ConditionAnalyze otherAnalyze)
        {
            if (otherAnalyze is SkillWeaponPartsAnalyze analyze)
            {
                return analyze.weaponPart == this.weaponPart;
            }
            return false;
        }
    }
    
    /// <summary>
    /// 男，女主的武器上的部件分析  @长空
    /// 该分析和技能上武器部件分析，有一些不同之处。(具体设计可以问 长空)
    /// </summary>
    [MessagePackObject]
    [Serializable]
    public class WeaponPartsAnalyze : ConditionAnalyze
    {
        [Key(0)] public string weaponPart;

        public WeaponPartsAnalyze(string weaponPart)
        {
            this.weaponPart = weaponPart;
        }
        
        protected override void OnRunTime(ResModule resModule)
        {
            if (string.IsNullOrEmpty(weaponPart))
                return;
            var lod = BattleCharacterMgr.GetGlobalLOD();
            string partAssetPath = BattleCharacterMgr.GetPartAssetPath(weaponPart, lod);
            resModule.AddResultByPath(partAssetPath, BattleResType.Weapon);
        }

        protected override void OnBuildApp(ResModule resModule)
        {
            if (string.IsNullOrEmpty(weaponPart))
                return;
            // 高模
            string partAssetPath = BattleCharacterMgr.GetPartAssetPath(weaponPart, CharacterMgr.LOD_HD);
            resModule.AddResultByPath(partAssetPath, BattleResType.Weapon);
            // 低模
            partAssetPath = BattleCharacterMgr.GetPartAssetPath(weaponPart, CharacterMgr.LOD_LD);
            resModule.AddResultByPath(partAssetPath, BattleResType.Weapon);
        }
        
        public override bool IsSameData(ConditionAnalyze otherAnalyze)
        {
            if (otherAnalyze is WeaponPartsAnalyze analyze)
            {
                return analyze.weaponPart == this.weaponPart;
            }
            return false;
        }
    }

    /// <summary>
    /// Tag特效分析 @沧澜
    /// TODO 封装成Tab分析器
    /// </summary>
    [MessagePackObject]
    [Serializable]
    public class LevelTagConditionAnalyze : ConditionAnalyze
    {
        protected override void OnRunTime(ResModule resModule)
        {
            var levelTagAnalyzer = new LevelTagAnalyzer(BattleEnv.StartupArg.levelTags, BattleEnv.StartupArg.scoreTags, resModule);
            levelTagAnalyzer.Analyze();
        }

        protected override void OnBuildApp(ResModule resModule)
        {
            ResAnalyzeUtil.AnalyzeActionModule(resModule, BattleConst.LevelBeforeCameraActionModuleId);
        }

        public override bool IsSameData(ConditionAnalyze otherAnalyze)
        {
            if (otherAnalyze is LevelTagConditionAnalyze analyze)
            {
                return true;
            }
            return false;
        }
    }
    
    /// <summary>
    /// 对话声音分析
    /// </summary>
    [MessagePackObject]
    [Serializable]
    public class DialogSoundAnalyze : ConditionAnalyze,IAnalyzeWithBoy
    {
        [Key(0)] public List<string> keys;
    
        public DialogSoundAnalyze(List<string> keys)
        {
            this.keys = keys;
        }
        
        public void AnalyzeWithBoy(ResModule resModule, int boySuitID)
        {
            if (keys == null)
            {
                return;
            }
            HashSet<string> sounds = new HashSet<string>();
            for (int i = 0; i < keys.Count; i++)
            {
                string key = keys[i];
                _RunTimeRecurseSounds(key, boySuitID, sounds);
            }
            foreach (string sound in sounds)
            {
                resModule.AddResultByPath(sound, BattleResType.ActorAudio);
            }
        }

        private void _RunTimeRecurseSounds(string key, int suitID, HashSet<string> sounds)
        {
            if (string.IsNullOrEmpty(key))
            {
                return;
            }
            
            int scoreIdBoy = 0;
            if (TbUtil.TryGetCfg(suitID, out MaleSuitConfig suitCfg))
            {
                scoreIdBoy = suitCfg.ScoreID;
            }
            var scoreIdGirl = BattleConst.GirlScoreID;//女主ID目前是0

            var dialogueConfigs = GetDialogueConfigsByKey(key, scoreIdBoy, scoreIdGirl);
            List<string> tempSounds = new List<string>();

            foreach (var dialogueConfig in dialogueConfigs)
            {
                tempSounds.Add(dialogueConfig.Sound1);
                tempSounds.Add(dialogueConfig.Sound2);
                tempSounds.Add(dialogueConfig.Sound3);
                tempSounds.Add(dialogueConfig.Sound4);
                foreach (var tempSound in tempSounds)
                {
                    if (!string.IsNullOrEmpty(tempSound))
                    {
                        if (!sounds.Contains(tempSound))
                        {
                            sounds.Add(tempSound);
                        }
                    }
                }
            }
        }
    
        public override bool IsSameData(ConditionAnalyze otherAnalyze)
        {
            if (otherAnalyze is DialogSoundAnalyze analyze)
            {
                bool isSameKes = false;
                if (analyze.keys.Count == keys.Count)
                {
                    for (int i = 0; i < keys.Count; i++)
                    {
                        if (!analyze.keys[i].Equals(keys[i]))
                        {
                            return false;
                        }
                    }
                    isSameKes = true;
                }
                return isSameKes;
            }
            return false;
        }
        
        private List<DialogueConfig> GetDialogueConfigsByKey(string key, int scoreIdBoy, int scoreIdGirl)
        {
            List<DialogueConfig> list = new List<DialogueConfig>();
            foreach (var configItem in TbUtil.dialogueConfigs)
            {
                if (configItem.Value.Key == key && (configItem.Value.ScoreIDs.Contains(scoreIdBoy) ||
                                                    configItem.Value.ScoreIDs.Contains(scoreIdGirl)))
                {
                    list.Add(configItem.Value);
                }
            }
    
            return list;
        }
    }
    
    /// <summary>
    /// 角色动画控制器名字分析  @三夕，朝冠，付强
    /// 注意：
    /// 女主的 _animatorFilename 是通过接口 GenGirlAnimatorCtrlName， 依赖女主武器id，和男主id生成出来的(启动时Lua端赋值)
    /// 男主和怪物的武器是表里配的固定的
    /// </summary>
    [MessagePackObject]
    [Serializable]
    public class AnimatorControllerAnalyze : ConditionAnalyze, IAnalyzeWithWeaponBoy
    {
        [Key(0)] public bool isGirl;
        [Key(1)] public string animatorFileName;

        public AnimatorControllerAnalyze(bool isGirl, string animatorFileName)
        {
            this.isGirl = isGirl;
            this.animatorFileName = animatorFileName;
        }
        
        public void AnalyzeWithWeaponBoy(ResModule resModule, int weaponSkinID, int boyID)
        {
            if (!isGirl)
            {
                resModule.AddResultByPath(animatorFileName, BattleResType.RoleAnimatorController);
            }
            else
            {
                string girlAnimatorFileName = BattleUtil.GenGirlAnimatorCtrlName(weaponSkinID, boyID);
                resModule.AddResultByPath(girlAnimatorFileName, BattleResType.RoleAnimatorController);
            }
        }

        public override bool IsSameData(ConditionAnalyze otherAnalyze)
        {
            if (otherAnalyze is AnimatorControllerAnalyze analyze)
            {
                return analyze.isGirl == this.isGirl && analyze.animatorFileName == this.animatorFileName;
            }
            return false;
        }
    }
    
    /// <summary>
    /// 战斗表演技能，特殊需要
    /// </summary>
    [MessagePackObject]
    [Serializable]
    public class PerformAnalyze : ConditionAnalyze
    {
        [Key(0)] public int performID;
        
        public PerformAnalyze(int performID)
        {
            this.performID = performID;
        }

        protected override void OnRunTime(ResModule resModule)
        {
            BattleEnv.AddPerformID(performID);
        }

        public override bool IsSameData(ConditionAnalyze otherAnalyze)
        {
            if (otherAnalyze is PerformAnalyze analyze)
            {
                return analyze.performID == performID;
            }
            return false;
        }
    }

    /// <summary>
    /// 风场预分析 @老艾
    /// </summary>
    [MessagePackObject]
    [Serializable]
    public class PhysicWindAnalyze : ConditionAnalyze, IAnalyzeWithGirl, IAnalyzeWithBoy
    {
        [Key(0)] public int physicWindID;
        
        public PhysicWindAnalyze(int physicWindID)
        {
            this.physicWindID = physicWindID;
        }
        
        public void AnalyzeWithGirl(ResModule resModule, int girlSuitID)
        {
            if (!TbUtil.TryGetCfg(girlSuitID, out FemaleSuitConfig girlSuitCfg))
                return;
            PhysicsAnalyze(resModule, girlSuitID, girlSuitCfg.ScoreID);
        }

        public void AnalyzeWithBoy(ResModule resModule, int boySuitID)
        {
            if (!TbUtil.TryGetCfg(boySuitID, out MaleSuitConfig boySuitCfg))
                return;
            PhysicsAnalyze(resModule, boySuitID, boySuitCfg.ScoreID);
        }

        private void PhysicsAnalyze(ResModule resModule, int suitID, int scoreID)
        {
            var go = BattleResMgr.Instance.Load<PhysicsWindConfigAsset>(BattleConst.PhysicsWindConfigName, BattleResType.PhysicsWindConfigAsset, isPreload:true);
            if (go == null)
                return;
            
            var parts = BattleCharacterMgr.GetPartKeysByTypeID(suitID, scoreID, PartType.Body);
            var physicsWindName = PhysicsWindDynamicClip.FindPhysicsWindName(physicWindID, parts, go);
            if (!string.IsNullOrEmpty(physicsWindName))
            {
                resModule.AddResultByPath(physicsWindName, BattleResType.PhysicsWind);
            }
            BattleResMgr.Instance.Unload(go);
        }

        public override bool IsSameData(ConditionAnalyze otherAnalyze)
        {
            if (otherAnalyze is PhysicWindAnalyze analyze)
            {
                return analyze.physicWindID == physicWindID;
            }
            return false;
        }
    }
    
    /// <summary>
    /// 战斗表演技能，特殊需要
    /// </summary>
    [MessagePackObject]
    [Serializable]
    public class PerformLODAnalyze : ConditionAnalyze
    {
        [Key(0)] public bool isGirl;
        [Key(1)] public LODUseType lodUseType;
        
        public PerformLODAnalyze(bool isGirl, LODUseType lodUseType)
        {
            this.isGirl = isGirl;
            this.lodUseType = lodUseType;
        }
        
        protected override void OnRunTime(ResModule resModule)
        {
            BattleEnv.SetHeroLODUseType(isGirl ? HeroType.Girl : HeroType.Boy, lodUseType);
        }
        
        public override bool IsSameData(ConditionAnalyze otherAnalyze)
        {
            if (otherAnalyze is PerformLODAnalyze analyze)
            {
                return analyze.isGirl == isGirl && analyze.lodUseType == lodUseType;
            }

            return false;
        }
    }
    
    [MessagePackObject]
    [Serializable]
    public class UltraModelAnalyze : ConditionAnalyze
    {
        protected override void OnRunTime(ResModule resModule)
        {
            if (BattleEnv.StartupArg != null && BattleEnv.LuaBridge != null)
            {
                if (!TbUtil.TryGetCfg(BattleEnv.StartupArg.boyID, out BoyCfg boyCfg))
                {
                    return;
                }

                var boySuit = new SuitResAnalyzer(BattleEnv.StartupArg.boySuitID, resModule);
                boySuit.Analyze();

                var girlSuitID = BattleEnv.StartupArg.girlSuitID;
                var boySuitID = BattleEnv.StartupArg.boySuitID;
                var boyScoreID = boyCfg.ScoreID;
                var targetSuitID = BattleEnv.LuaBridge.GetFemaleUltraSuitID(girlSuitID, boySuitID, boyScoreID);
                
                if (!TbUtil.HasCfg<FemaleSuitConfig>(targetSuitID))
                {
                    return;
                }
                
                var girlSuit = new SuitResAnalyzer(targetSuitID, resModule);
                girlSuit.Analyze();
            }
        }
        
        public override bool IsSameData(ConditionAnalyze otherAnalyze)
        {
            if (otherAnalyze is UltraModelAnalyze analyze)
            {
                return true;
            }

            return false;
        }
    }

    [MessagePackObject]
    [Serializable]
    public class GirlSkillAnalyze : ConditionAnalyze
    {
        [Key(0)] public int weaponLogicID;
        
        public GirlSkillAnalyze(int weaponLogicID)
        {
            this.weaponLogicID = weaponLogicID;
        }

        protected override void OnRunTime(ResModule resModule)
        {
            var battleArg = BattleEnv.StartupArg;
            if (battleArg.cacheBornCfgs.TryGetValue(battleArg.girlID, out var actorCacheBornConfig))
            {
                // 技能预分析，在线时女主的技能是服务器下发的
                var skillSlots = actorCacheBornConfig.SkillSlots;
                if (skillSlots != null)
                {
                    foreach (var skillSlot in skillSlots)
                    {
                        SkillSlotConfig slot = skillSlot.Value;
                        var skillAnalyzer = new SkillResAnalyzer(slot.SkillID, slot.SkillLevel, resModule);
                        skillAnalyzer.Analyze();
                    }
                }
            }
        }

        protected override void OnBuildApp(ResModule resModule)
        {
            // 分析武器的技能（女主的部分技能和武器绑定，另外的技能由男主确定）
            var logicCfg = TbUtil.GetCfg<WeaponLogicConfig>(weaponLogicID);
            if (logicCfg == null)
            {
                LogProxy.LogErrorFormat("错误的weaponLogicID:{0},导致无法进行武器的技能分析", weaponLogicID);
                return;
            }
            
            for (int i = 0; i < logicCfg.AttackIDs.Length; i++)
            {
                int skillID = logicCfg.AttackIDs[i];
                int level = 1;
                var skillAnalyzer = new SkillResAnalyzer(skillID, level, resModule);
                skillAnalyzer.Analyze();
            }
            for (int i = 0; i < logicCfg.ActiveSkillIDs.Length; i++)
            {
                int skillID = logicCfg.ActiveSkillIDs[i];
                int level = 1;
                var skillAnalyzer = new SkillResAnalyzer(skillID, level, resModule);
                skillAnalyzer.Analyze();
            }
            for (int i = 0; i < logicCfg.PassiveSkillIDs.Length; i++)
            {
                int skillID = logicCfg.PassiveSkillIDs[i];
                int level = 1;
                var skillAnalyzer = new SkillResAnalyzer(skillID, level, resModule);
                skillAnalyzer.Analyze();
            }
            for (int i = 0; i < logicCfg.DodgeSkillIDs.Length; i++)
            {
                int skillID = logicCfg.DodgeSkillIDs[i];
                int level = 1;
                var skillAnalyzer = new SkillResAnalyzer(skillID, level, resModule);
                skillAnalyzer.Analyze();
            }
            for (int i = 0; i < logicCfg.BornSkillIDs.Length; i++)
            {
                int skillID = logicCfg.BornSkillIDs[i];
                int level = 1;
                var skillAnalyzer = new SkillResAnalyzer(skillID, level, resModule);
                skillAnalyzer.Analyze();
            }
            for (int i = 0; i < logicCfg.DeadSkillIDs.Length; i++)
            {
                int skillID = logicCfg.DeadSkillIDs[i];
                int level = 1;
                var skillAnalyzer = new SkillResAnalyzer(skillID, level, resModule);
                skillAnalyzer.Analyze();
            }
        }

        public override bool IsSameData(ConditionAnalyze otherAnalyze)
        {
            if (otherAnalyze is GirlSkillAnalyze analyze)
            {
                return analyze.weaponLogicID == weaponLogicID;
            }

            return false;
        }
    }
    
    /// <summary>
    /// 这里只处理，服务器下发的男主的被动技能。 和ServerBuff类似
    /// </summary>
    [MessagePackObject]
    [Serializable]
    public class BoySkillAnalyze : ConditionAnalyze
    {
        [Key(0)]  public int boyCfgID;

        public BoySkillAnalyze(int boyCfgID)
        {
            this.boyCfgID = boyCfgID;
        }
        
        protected override void OnRunTime(ResModule resModule)
        {
            var battleArg = BattleEnv.StartupArg;
            
            if (battleArg.startupType != BattleStartupType.Online)
            {
                // 离线战斗，技能分析来源与配置
                AnalyzeCfgSkill(resModule);
                return;
            }
            
            // 在线战斗，技能分析全部来源与服务器，用于支持动态技能
            if (battleArg.cacheBornCfgs.TryGetValue(battleArg.boyID, out var actorCacheBornConfig))
            {
                var skillSlots = actorCacheBornConfig.SkillSlots;
                if (skillSlots != null)
                {
                    foreach (var skillSlot in skillSlots)
                    {
                        SkillSlotConfig slot = skillSlot.Value;
                        var skillAnalyzer = new SkillResAnalyzer(slot.SkillID, slot.SkillLevel, resModule);
                        skillAnalyzer.Analyze();
                    }
                }
            }
        }

        protected override void OnBuildApp(ResModule resModule)
        {
            AnalyzeCfgSkill(resModule);
        }

        private void AnalyzeCfgSkill(ResModule resModule)
        {
            if (!TbUtil.TryGetCfg(boyCfgID, out BoyCfg boyCfg))
            {
                LogProxy.LogErrorFormat("错误的BoyCfgID:{0},导致无法进行男主的技能分析", boyCfgID);
                return;
            }
            // 分析男主给女主的技能
            foreach (var item in boyCfg.GirlSkillSlots)
            {
                int skillID = item.Value.SkillID;
                int level = item.Value.SkillLevel;
                var skillAnalyzer = new SkillResAnalyzer(skillID, level, resModule);
                skillAnalyzer.Analyze();
            }
                
            // 分析男主自己的技能
            var skillSlots = boyCfg.SkillSlots;
            if (skillSlots != null)
            {
                foreach (var skillSlot in skillSlots)
                {
                    SkillSlotConfig slot = skillSlot.Value;
                    var skillAnalyzer = new SkillResAnalyzer(slot.SkillID, slot.SkillLevel, resModule);
                    skillAnalyzer.Analyze();
                }
            }
        }

        public override bool IsSameData(ConditionAnalyze otherAnalyze)
        {
            if (otherAnalyze is BoySkillAnalyze)
            {
                return true;
            }

            return false;
        }
    }

    [MessagePackObject]
    [Serializable]
    public class ServerBuffAnalyze : ConditionAnalyze
    {
        protected override void OnRunTime(ResModule resModule)
        {
            var battleArg = BattleEnv.StartupArg;
            foreach (var item in battleArg.cacheBornCfgs)
            {
                if (item.Value.BuffDatas == null)
                {
                    continue;
                }
                foreach (var buff in item.Value.BuffDatas)
                {
                    var buffAnalyze = new BuffResAnalyzer(buff.ID, parent:resModule);
                    buffAnalyze.Analyze();
                }
            }
        }
        
        public override bool IsSameData(ConditionAnalyze otherAnalyze)
        {
            if (otherAnalyze is ServerBuffAnalyze)
            {
                return true;
            }

            return false;
        }
    }
    
    [MessagePackObject]
    [Serializable]
    public class GhostHDAnalyze : ConditionAnalyze
    {
        [Key(0)]
        public bool isGirl;

        public GhostHDAnalyze(bool isGirl)
        {
            this.isGirl = isGirl;
        }
        
        protected override void OnRunTime(ResModule resModule)
        {
            var battleArg = BattleEnv.StartupArg;
            
            if (isGirl)
            {
                if (!TbUtil.HasCfg<HeroCfg>(battleArg.girlID))
                {
                    return;
                }
                
                var suit = new SuitResAnalyzer(battleArg.girlSuitID, parent:resModule);
                suit.Analyze();
            }
            else
            {
                if (!TbUtil.HasCfg<BoyCfg>(battleArg.boyID))
                {
                    return;
                }
                var suit = new SuitResAnalyzer(battleArg.boySuitID, parent:resModule);
                suit.Analyze();
            }
        }

        public override bool IsSameData(ConditionAnalyze otherAnalyze)
        {
            if (otherAnalyze is GhostHDAnalyze)
            {
                return true;
            }

            return false;
        }
    }

    [MessagePackObject]
    [Serializable]
    public class StageSkillAnalyze : ConditionAnalyze
    {
        protected override void OnRunTime(ResModule resModule)
        {
            var battleArg = BattleEnv.StartupArg;
            if (battleArg == null)
            {
                return;
            }

            if (battleArg.affixesSkillSlotConfigs != null && battleArg.affixesSkillSlotConfigs.Count > 0)
            {
                // 技能预分析，在线时词缀的技能是服务器下发的
                foreach (var skillSlot in battleArg.affixesSkillSlotConfigs)
                {
                    SkillSlotConfig slot = skillSlot;
                    var skillAnalyzer = new SkillResAnalyzer(slot.SkillID, slot.SkillLevel, resModule);
                    skillAnalyzer.Analyze();
                }
            }
        }

        public override bool IsSameData(ConditionAnalyze otherAnalyze)
        {
            if (otherAnalyze is StageSkillAnalyze)
            {
                return true;
            }

            return false;
        }
    }
    
    [MessagePackObject]
    [Serializable]
    public class OfflineSkillAnalyze: ConditionAnalyze
    {
        protected override void OnRunTime(ResModule resModule)
        {
            var battleArg = BattleEnv.StartupArg;
            if (battleArg == null)
            {
                return;
            }
            
            if (battleArg.startupType == BattleStartupType.Online)
            {
                return;
            }
            
            BattleLevelConfig levelConfig = TbUtil.GetCfg<BattleLevelConfig>(battleArg.levelID);
            if (levelConfig == null)
            {
                return;
            }
            
            
            var battleStageConfig =  TbUtil.GetCfg<StageConfig>(levelConfig.StageID);
            if (battleStageConfig == null)
            {
                return;
            }

            _AnalyzeDynamicSkill(resModule, battleArg, levelConfig, battleStageConfig, HeroType.Girl);
            _AnalyzeDynamicSkill(resModule, battleArg, levelConfig, battleStageConfig, HeroType.Boy);
        }

        private void _AnalyzeDynamicSkill(ResModule resModule, BattleArg battleArg, BattleLevelConfig battleLevelConfig, StageConfig stageConfig, HeroType heroType)
        {
            var pointConfig = _GetBornPointConfig(stageConfig.Points, heroType);
            if (pointConfig == null)
            {
                return;
            }
            
            int propertyID = 0;
            if (battleArg.isNumberMode)
            {
                if (battleLevelConfig.OfflineHeroPropertyIDs == null)
                {
                    PapeGames.X3.LogProxy.LogError("BattleLevel表,单机男女主属性缺失配置");
                }
                else if (battleLevelConfig.OfflineHeroPropertyIDs.Length != 2)
                {
                    PapeGames.X3.LogProxy.LogError($"BattleLevel表,单机男女主属性配置长度错误:Length = {battleLevelConfig.OfflineHeroPropertyIDs.Length}");
                }
                else
                {
                    switch (pointConfig.RoleType)
                    {
                        case RoleType.Boy:
                            propertyID = battleLevelConfig.OfflineHeroPropertyIDs[0];
                            break;
                        case RoleType.Girl:
                            propertyID = battleLevelConfig.OfflineHeroPropertyIDs[1];
                            break;
                    }
                }
            }
            else
            {
                propertyID = pointConfig.PropertyID;
            }
            
            S2Int[] passiveSkillConfigs = BattleEnv.LuaBridge.GetCardSetPassiveSkillConfigs(propertyID, pointConfig.RoleType);
            if (passiveSkillConfigs == null || passiveSkillConfigs.Length <= 0)
            {
                return;
            }
            
            // DONE: 调用技能分析器.
            foreach (var passiveSkillConfig in passiveSkillConfigs)
            {
                var skillAnalyzer = new SkillResAnalyzer(passiveSkillConfig.ID, passiveSkillConfig.Num, resModule);
                skillAnalyzer.Analyze();
            }
        }
        
        private PointConfig _GetBornPointConfig(PointConfig[] pointConfigs, HeroType heroType)
        {
            PointConfig point = null;
            foreach (var pointConfig in pointConfigs)
            {
                if (pointConfig.PointType != PointType.BornPoint)
                {
                    continue;
                }

                if ((pointConfig.RoleType != RoleType.Girl || heroType != HeroType.Girl) && (pointConfig.RoleType != RoleType.Boy || heroType != HeroType.Boy))
                {
                    continue;
                }

                point = pointConfig;
                break;
            }

            return point;
        }
        
        public override bool IsSameData(ConditionAnalyze otherAnalyze)
        {
            if (otherAnalyze is OfflineSkillAnalyze)
            {
                return true;
            }

            return false;
        }
    }
}