using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public class BattleLevelResAnalyzer : ResAnalyzer
    {
        private int _levelID;
        public override int ResID => _levelID;
        
        public BattleLevelResAnalyzer(int levelID, ResModule parent=null) : base(parent)
        {
            _levelID = levelID;
        }

        protected override void DirectAnalyze()
        {
            BattleLevelConfig levelConfig = TbUtil.GetCfg<BattleLevelConfig>(_levelID);
            if (levelConfig == null)
            {
                LogProxy.LogErrorFormat("关卡分析器启动失败，levelID：{0} 不存在", _levelID);
                return;
            }
            
            var stageConfig = TbUtil.GetCfg<StageConfig>(levelConfig.StageID);

            if (stageConfig == null)
            {
                LogProxy.LogErrorFormat("关卡分析器启动失败，StageID：{0} 不存在", levelConfig.StageID);
                return;
            }
            
			//关卡Actor 预分析
            if (TbUtil.TryGetCfg(levelConfig.StageActorID, out MonsterCfg stageMonsterCfg))
            {
                if (stageMonsterCfg.SkillSlots != null)
                {
                    foreach (var skillSlotItem in stageMonsterCfg.SkillSlots)
                    {
                        var skillAnalyzer = new SkillResAnalyzer(skillSlotItem.Value.SkillID, skillSlotItem.Value.SkillLevel, resModule);
                        skillAnalyzer.Analyze();
                    }
                }
                ResAnalyzeUtil.AnalyzeActionModule(resModule, stageMonsterCfg.BornActionModule);
                ResAnalyzeUtil.AnalyzeActionModule(resModule, stageMonsterCfg.DeadActionModule);
                ResAnalyzeUtil.AnalyzeActionModule(resModule, stageMonsterCfg.HurtLieDeadActionModule);
            }
            
            //关卡 男主女 持有技能分析
            if (levelConfig.GirlActiveSkills != null)
            {
                foreach (S2Int s2Int in levelConfig.GirlActiveSkills)
                {
                    var skillAnalyzer = new SkillResAnalyzer(s2Int.ID, s2Int.Num, resModule);
                    skillAnalyzer.Analyze();
                }
            }
            
            if (levelConfig.BoyActiveSkills != null)
            {
                foreach (S2Int s2Int in levelConfig.BoyActiveSkills)
                {
                    var skillAnalyzer = new SkillResAnalyzer(s2Int.ID, s2Int.Num, resModule);
                    skillAnalyzer.Analyze();
                }
            }

            // 战斗通用资源
            var commonAnalyzer = new BattleCommonResAnalyzer(resModule);
            commonAnalyzer.Analyze();
            
            var tagFxAnalyze = new LevelTagConditionAnalyze();
            resModule.AddConditionAnalyze(tagFxAnalyze);

            // 场景资源相关内容
            _AnalyzeSceneAssets(levelConfig);
            
            // 场景寻路的载体
            resModule.AddResultByPath(BattleConst.PathfinderGoName, BattleResType.Misc);

            //战斗胜利击破PPV资源
            if (!string.IsNullOrEmpty(TbUtil.battleConsts.WinBreakPPV))
            {
                var analyzer = new TimelineResAnalyzer(resModule, TbUtil.battleConsts.WinBreakPPV, BattleResType.Timeline, false, timelineTags: BattleResTag.PPVTimeline);
                analyzer.Analyze();
            }

            //怪物受击材质效果
            resModule.AddResultByPath(TbUtil.battleConsts.MonsterHitEffectPath, BattleResType.MatCurveAsset);

            string levelFlowPath = $"Level/{levelConfig.LogicFilename}";
            ResModule levelFlowResModule = resModule.AddChild("levelFlow");
            levelFlowResModule.AddResultByPath(levelFlowPath, BattleResType.Flow);
            if (!string.IsNullOrEmpty(levelConfig.BackgroundMusic))
            {
                levelFlowResModule.AddResultByPath(levelConfig.BackgroundMusic, BattleResType.BGM);
            }
            AnalyzeFromLoadedRes<GameObject>(levelFlowPath, BattleResType.Flow, ResAnalyzeUtil.AnalyzerGraphPrefab, levelFlowResModule);
            

            var uiResAnalyzer = new UIResAnalyzer(resModule, _levelID);
            uiResAnalyzer.Analyze();
            
            for (int i = 0; i < stageConfig.SpawnPoints.Length; i++)
            {
                // monster
                TbUtil.TryGetCfg(stageConfig.SpawnPoints[i].ConfigID, out MonsterCfg monsterCfg);
                var actorResAnalyzer = new ActorResAnalyzer(resModule, monsterCfg);
                actorResAnalyzer.Analyze();
            }
                
            // Machine
            if (stageConfig.Machines != null)
            {
                for (int i = 0; i < stageConfig.Machines.Length; i++)
                {
                    TbUtil.TryGetCfg(stageConfig.Machines[i].ConfigID, out MachineCfg machineCfg);
                    var actorResAnalyzer = new ActorResAnalyzer(resModule, machineCfg);
                    actorResAnalyzer.Analyze();
                }
            }

            for (int i = 0; i < stageConfig.Obstacles.Length; i++)
            {
                int fxId = stageConfig.Obstacles[i].FxID;
                if (fxId > 0)
                {
                    resModule.AddResultByFxId(fxId);
                }
            }

            for (int i = 0; i < stageConfig.TriggerAreas.Length; i++)
            {
                int fxId = stageConfig.TriggerAreas[i].FxID;
                if (fxId > 0)
                {
                    resModule.AddResultByFxId(fxId);
                }
            }
            //关卡背景音乐bank
            resModule.AddResultByPath(TbUtil.battleConsts.LevelBgmBnkName, BattleResType.UIAudio);
            
            // 动态buff的预分析
            resModule.AddConditionAnalyze(new ServerBuffAnalyze());
            
            //关卡沟通蓝图的预分析
            foreach (var info in levelConfig.Graphs)
            {
                resModule.AddResultByPath(info, BattleResType.Flow);
                ResAnalyzer.AnalyzeFromLoadedRes<GameObject>(info, BattleResType.Flow, ResAnalyzeUtil.AnalyzerGraphPrefab, resModule);
            }
            
            // 关卡相机
            string levelCameraGroup = $"{CameraTrace.levelCameraGroupName}{levelConfig.StageID}";
            if (BattleResMgr.Instance.IsExists(levelCameraGroup, BattleResType.LevelMaker))
                resModule.AddResultByPath(levelCameraGroup, BattleResType.LevelMaker);

            resModule.AddConditionAnalyze(new OfflineSkillAnalyze());
        }
        
        // 与美术场景相关的资源放这里SceneAssets
        private void _AnalyzeSceneAssets(BattleLevelConfig levelConfig)
        {
            ResModule sceneResModule = resModule.AddChild("sceneAssets");
            
            var sceneName = BattleUtil.GetSceneName(levelConfig.ID);
            //场景高度图
            sceneResModule.AddResultByPath(sceneName, BattleResType.SceneAltitudeMap);
            //场景寻路网格图
            sceneResModule.AddResultByPath(sceneName, BattleResType.ScenePathGraph);
            //场景三角形行走网格图
            sceneResModule.AddResultByPath(sceneName + BattleUtil.Walk, BattleResType.ScenePathGraph);
            
            //场景角色灯
            var sceneLightPath = levelConfig.PlayerSceneLightPath ?? levelConfig.SceneName + "_Light";
            if (BattleResMgr.Instance.IsExists(sceneLightPath, BattleResType.ActorSceneLight))
            {
                sceneResModule.AddResultByPath(sceneLightPath, BattleResType.ActorSceneLight);
            }
            
            // 此处添加一条记录，支持分析出场景名字（SceneInfo表中的key值），注意此条记录不用与加载
            sceneResModule.AddResultByPath(levelConfig.SceneName, BattleResType.Scene);
            
            //NavMesh导航网格资源
            if (BattleResMgr.Instance.IsExists(levelConfig.SceneName, BattleResType.NavMesh))
            {
                sceneResModule.AddResultByPath(levelConfig.SceneName, BattleResType.NavMesh);
            }
            
            //地形信息
            _AnalyzerSceneMapData(sceneResModule);
            
            // 场景中的相机碰撞体
            _AnalyzeCameraColliders(sceneResModule);
        }
        
        //地形信息 决定步尘特效与音效
        private void _AnalyzerSceneMapData(ResModule module)
        {
            string sceneMapDataPath = BattleUtil.GetSceneMapRelativePath(_levelID);
            if (BattleResMgr.Instance.IsExists(sceneMapDataPath, BattleResType.SceneMapData))
            {
                module.AddResultByPath(sceneMapDataPath, BattleResType.SceneMapData);
            }
        }
        
        public override bool IsSameData(ResAnalyzer other)
        {
            if (other is BattleLevelResAnalyzer analyzer)
            {
                return analyzer._levelID == _levelID;
            }
            return false;
        }

        private void _AnalyzeCameraColliders(ResModule resModule)
        {
            var sceneName = BattleUtil.GetSceneName(_levelID);

            foreach (var sceneCollider in TbUtil.battleSceneCameraColliders.Values)
            {
                if (sceneCollider.SceneName == sceneName)
                {
                    resModule.AddResultByPath(sceneCollider.SceneCameraColliderName, BattleResType.CameraCollider);
                    break;
                }
            }
        }
    }
}