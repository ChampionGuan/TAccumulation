using System;
using System.Collections.Generic;
using MessagePack;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public interface IAnalyzeWithLevel
    {
        void AnalyzeWithLevel(ResModule resModule, int levelID);
    }
    
    public interface IAnalyzeWithGirl
    {
        void AnalyzeWithGirl(ResModule resModule, int girlSuitID);
    }
    
    public interface IAnalyzeWithWeapon
    {
        void AnalyzeWithWeapon(ResModule resModule, int weaponSkinID);
    }
    
    public interface IAnalyzeWithBoy
    {
        void AnalyzeWithBoy(ResModule resModule, int boySuitID);
    }
    
    public interface IAnalyzeWithWeaponBoy
    {
        void AnalyzeWithWeaponBoy(ResModule resModule, int weaponSkinID, int boyID);
    }
    
    /// <summary>
    /// 条件分析
    /// </summary>
    [Union(0, typeof(FootMoveFxAnalyze))]
    [Union(1, typeof(SkillWeaponPartsAnalyze))]
    [Union(2, typeof(WeaponPartsAnalyze))]
    [Union(3, typeof(DialogSoundAnalyze))]
    [Union(4, typeof(AnimatorControllerAnalyze))]
    [Union(5, typeof(PerformAnalyze))]
    [Union(6, typeof(PhysicWindAnalyze))]
    [Union(7, typeof(LevelTagConditionAnalyze))]
    [Union(8, typeof(PerformLODAnalyze))]
    [Union(9, typeof(UltraModelAnalyze))]
    [Union(10, typeof(GirlSkillAnalyze))]
    [Union(11, typeof(ServerBuffAnalyze))]
    [Union(12, typeof(BoySkillAnalyze))]
    [Union(13, typeof(GhostHDAnalyze))]
    [Union(14, typeof(StageSkillAnalyze))]
    [Union(15, typeof(OfflineSkillAnalyze))]
    [MessagePackObject]
    [Serializable]
    public abstract class ConditionAnalyze
    {
        private bool _isAnalyzed = false;
        protected AnalyzeRunEnv AnalyzeRunEnv => ResAnalyzer.AnalyzeRunEnv;
        // 是否是运行时
        protected bool isRunTimeEnv => AnalyzeRunEnv == AnalyzeRunEnv.RunTimeLogic ||
                                       AnalyzeRunEnv == AnalyzeRunEnv.RunTimeOffline;

        [IgnoreMember] public bool isAnalyzed => _isAnalyzed;

        public void Analyze(ResModule resModule)
        {
            // 用于支持，条件分析时，又创建了新的条件分析
            _isAnalyzed = true;
            if (isRunTimeEnv)
            {
                RunTime(resModule);
            }
            else if (AnalyzeRunEnv == AnalyzeRunEnv.BuildApp)
            {
                BuildApp(resModule);
            }
            else if (AnalyzeRunEnv == AnalyzeRunEnv.BranchMerge)
            {
                BuildApp(resModule);
            }
            // BuildOfflineData: 不需要执行条件分析，只需要记录下来条件分析即可，RunTime时会执行
        }

        private void RunTime(ResModule resModule)
        {
            if (BattleEnv.StartupArg == null)
            {
                LogProxy.LogError("RunTime时，BattleUtil.StartupArg 为null，无法执行对应的条件分析");
                return;
            }
            
            int boyID = BattleEnv.StartupArg.boyID;
            int boySuitID = BattleEnv.StartupArg.boySuitID;
            int girlSuitID = BattleEnv.StartupArg.girlSuitID;
            int levelID = BattleEnv.StartupArg.levelID;
            int weaponSkinID = BattleEnv.StartupArg.girlWeaponID;
            (this as IAnalyzeWithLevel)?.AnalyzeWithLevel(resModule, levelID);
            (this as IAnalyzeWithGirl)?.AnalyzeWithGirl(resModule, girlSuitID);
            (this as IAnalyzeWithWeapon)?.AnalyzeWithWeapon(resModule, weaponSkinID);
            (this as IAnalyzeWithBoy)?.AnalyzeWithBoy(resModule, boySuitID);
            (this as IAnalyzeWithWeaponBoy)?.AnalyzeWithWeaponBoy(resModule, weaponSkinID, boyID);
            
            OnRunTime(resModule);
        }
        
        private void BuildApp(ResModule resModule)
        {
            var analyzerBuildAppResModule = ResAnalyzeUtil.FromAnalyzer<BattleResAnalyzerBuildApp>(resModule);
            
            BuildAppAnalyzePars pars = null;
            if (analyzerBuildAppResModule != null)
            {
                if (analyzerBuildAppResModule.owner is BattleResAnalyzerBuildApp analyzer)
                    pars = analyzer.pars;
                else
                    LogProxy.LogErrorFormat("获取分析参数失败，条件分析将会全部失败");
            }
            else
            {
                if (ResAnalyzer.isDebugModel && !Application.isPlaying)
                    pars = CreateDebugBuildAppAnalyzePars();
            }

            if (pars == null)
                return;
            pars.NotNull();
            
            if (this is IAnalyzeWithLevel analyzeWithLevel)
            {
                foreach (var id in pars.levelIDs)
                {
                    analyzeWithLevel.AnalyzeWithLevel(resModule, id);
                }   
            }
            
            if (this is IAnalyzeWithGirl analyzeWithGirl)
            {
                foreach (var id in pars.girlSuitIDs)
                {
                    analyzeWithGirl.AnalyzeWithGirl(resModule, id);
                }   
            }
            
            if (this is IAnalyzeWithWeapon analyzeWithWeapon)
            {
                foreach (var id in pars.weaponSkinIDs)
                {
                    analyzeWithWeapon.AnalyzeWithWeapon(resModule, id);
                } 
            }
            
            if (this is IAnalyzeWithBoy analyzeWithBoy)
            {
                foreach (var id in pars.boySuitIDs)
                {
                    analyzeWithBoy.AnalyzeWithBoy(resModule, id);
                }   
            }
            
            if (this is IAnalyzeWithWeaponBoy analyzeWithWeaponBoy)
            {
                foreach (var boySuitID in pars.boySuitIDs)
                {
                    var boyIDs = new List<int>();
                    TbUtil.GetActorCfgIDsBySuitID(boySuitID, boyIDs);
                    foreach (var weaponSkinID in pars.weaponSkinIDs)
                    {
                        foreach (var boyID in boyIDs)
                        {
                            analyzeWithWeaponBoy.AnalyzeWithWeaponBoy(resModule, weaponSkinID, boyID);
                        }
                    }
                }   
            }
            OnBuildApp(resModule);
        }

        protected virtual void OnRunTime(ResModule resModule)
        {
        }
        
        protected virtual void OnBuildApp(ResModule resModule)
        {
        }

        public abstract bool IsSameData(ConditionAnalyze otherAnalyze);
        
        private BuildAppAnalyzePars CreateDebugBuildAppAnalyzePars()
        {
            BuildAppAnalyzePars pars = new BuildAppAnalyzePars();
            if (TbUtil.battleLevelConfigs != null)
                pars.levelIDs = new List<int>(TbUtil.battleLevelConfigs.Keys);
            
            if (TbUtil.girlSuitCfgs != null)
                pars.girlSuitIDs = new List<int>(TbUtil.girlSuitCfgs.Keys);
            
            if (TbUtil.boySuitCfgs != null)
                pars.boySuitIDs = new List<int>(TbUtil.boySuitCfgs.Keys);
            
            if (TbUtil.weaponSkinConfigs != null)
                pars.weaponSkinIDs = new List<int>(TbUtil.weaponSkinConfigs.Keys);
            return pars;
        }
    }
}