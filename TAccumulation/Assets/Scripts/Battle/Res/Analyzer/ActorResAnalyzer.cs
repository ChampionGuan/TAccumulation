using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public class ActorResAnalyzer : ResAnalyzer
    {
        private const int _shadowCount = 5;  // 残影的默认预加载数量
        protected ActorCfg _actorCfg;
        public override int ResID => _actorCfg?.ID ?? BattleConst.InvalidActorSuitID;

        public ActorResAnalyzer(ResModule parent, ActorCfg actorCfg):base(parent)
        {
            _actorCfg = actorCfg;
        }

        protected override void DirectAnalyze()
        {
            if (_actorCfg == null)
                return;
            
            // 这里用于分析出动态配置 byte文件（load一次即可）
            TbUtil.GetCfg<ModelInfo>(_actorCfg.ModelKey);

            // Machine
            if (_actorCfg is MachineCfg machineCfg)
            {
                AnalyzeMachine(machineCfg);
            }
            
            // InterActor
            if (_actorCfg is InterActorCfg interActorCfg)
            {
                AnalyzeInterActor(interActorCfg);
            }
            
            // Role
            if (!(_actorCfg is RoleCfg roleCfg))
            {
                return;
            }
            string _animatorFilename = null;
            var battleArg = BattleEnv.StartupArg;
            if (battleArg != null && battleArg.cacheBornCfgs.TryGetValue(_actorCfg.ID, out var actorCacheBornConfig))
            {
                _animatorFilename = actorCacheBornConfig.AnimatorCtrlName;
            }
            
            if (string.IsNullOrEmpty(_animatorFilename))
            {
                _animatorFilename = roleCfg.AnimatorCtrlName;
            }

            // actor 分析器定位变为了 逻辑分析器，所以这里不在进行角色套装的分析
            if (roleCfg.ModelData != null && roleCfg.ModelData.Type != ActorType.Hero)
            {
                ResDesc resDesc = BattleUtil.GetActorResDesc(roleCfg.ModelData);
                resModule.AddResultByPath(resDesc.path, resDesc.type, resDesc.count);
            }

            if (!string.IsNullOrEmpty(roleCfg.CombatAIName))
            {
                resModule.AddResultByPath(roleCfg.CombatAIName, BattleResType.AITree);
                AnalyzeFromLoadedRes<GameObject>(roleCfg.CombatAIName, BattleResType.AITree, ResAnalyzeUtil.AnalyzerGraphPrefab, resModule);
            }

            //actor通用特效
            if (roleCfg.CommonEffect != null && roleCfg.CommonEffect.Count > 0)
            {
                foreach (var fxId in roleCfg.CommonEffect)
                {
                    resModule.AddResultByFxId(fxId);
                }
            }
            
            //受击抖动
            if (!string.IsNullOrEmpty(roleCfg.HurtInfo.HurtShakeName))
            {
                resModule.AddResultByPath(roleCfg.HurtInfo.HurtShakeName, BattleResType.ShakeBone);
            }

            //主状态机
            resModule.AddResultByPath(BattleConst.MainFSMName, BattleResType.Fsm);
            
            // 出生动作模组
            if (roleCfg.BornActionModule != 0)
            {
                ResAnalyzeUtil.AnalyzeActionModule(resModule, roleCfg.BornActionModule);
            }

            // 死亡动作模组
            if (roleCfg.DeadActionModule != 0)
            {
                ResAnalyzeUtil.AnalyzeActionModule(resModule, roleCfg.DeadActionModule);
            }
            
            
            // 死亡动作模组
            var monsterCfg = roleCfg as MonsterCfg; 
            if (monsterCfg != null && monsterCfg.HurtLieDeadActionModule != 0)
            {
                ResAnalyzeUtil.AnalyzeActionModule(resModule, monsterCfg.HurtLieDeadActionModule);
            }
            
            // 男主
            if (roleCfg is BoyCfg boyCfg)
            {
                // 男主完美闪避动作模组
                if (boyCfg.PerfectDodgeActionModule > 0)
                {
                    ResAnalyzeUtil.AnalyzeActionModule(resModule, boyCfg.PerfectDodgeActionModule);
                }
            }
            
            // 角色残影 TODO 策划侧删了功能，程序暂时保留代码，过一段时间稳了彻底删除
            // if (!string.IsNullOrEmpty(roleCfg.ShadowPrefabPath))
            // {
            //     resModule.AddResultByPath(roleCfg.ShadowPrefabPath, BattleResType.Shadow, _shadowCount);    
            // }

            //动画状态机
            bool isGirl = roleCfg.Type == ActorType.Hero && !(roleCfg is BoyCfg);
            var animatorAnalyze = new AnimatorControllerAnalyze(isGirl, _animatorFilename);
            resModule.AddConditionAnalyze(animatorAnalyze);

            //LookAt 仅怪物加载配置
            if(roleCfg.Type == ActorType.Monster && null != monsterCfg)
            {
                if (!string.IsNullOrEmpty(monsterCfg.LookAtBlendSpaceConfig) &&
                    BattleResMgr.Instance.IsExists(monsterCfg.LookAtBlendSpaceConfig, BattleResType.BlendSpaceAsset))
                {
                    resModule.AddResultByPath(monsterCfg.LookAtBlendSpaceConfig, BattleResType.BlendSpaceAsset);
                }

                resModule.AddResultByPath(monsterCfg.WeakSound, BattleResType.UIAudio);
                resModule.AddResultByPath(monsterCfg.CoreBreakSound, BattleResType.UIAudio);

                foreach (var buffID in TbUtil.battleConsts.BattleShieldBreakAddBuff)
                {
                    BuffResAnalyzer analyzer = new BuffResAnalyzer(buffID, parent: resModule);
                    analyzer.Analyze();
                }
            }
            
            // 技能预加载， 注意女主的技能在武器上，和男主身上
            // 男主的技能在套装分析器中分析
            if (!(roleCfg is BoyCfg)) 
            {
                var skillSlots = roleCfg.SkillSlots;
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
            
            // FSM
            resModule.AddResultByPath(roleCfg.AnimFSMFilename, BattleResType.Fsm);
            _AnalyzeAnimatorActionMode(roleCfg);

            // modelInfo
            if(!string.IsNullOrEmpty(_actorCfg.ModelKey))
            {
                ModelInfo modelInfo = TbUtil.GetCfg<ModelInfo>(_actorCfg.ModelKey);
                if (modelInfo?.fxPerformGroups != null)
                {
                    foreach (var group in modelInfo.fxPerformGroups.Values)
                    {
                        foreach (var perform in group.fxPerforms)
                        {
                            resModule.AddResultByPath(perform.fxPath, BattleResType.FX);
                        }
                    }
                }
            }

            if (roleCfg.Type == ActorType.Monster)
            {
                resModule.AddResultByFxId(TbUtil.battleConsts.BreakFx01);
                resModule.AddResultByFxId(TbUtil.battleConsts.BreakFx02);
                // todo:后面让策划配到battleConst表里
                resModule.AddResultByFxId(123);

                if (!string.IsNullOrEmpty(TbUtil.battleConsts.WeakBreakPPV))
                {
                    var analyzer = new TimelineResAnalyzer(resModule, TbUtil.battleConsts.WeakBreakPPV, BattleResType.Timeline, false, timelineTags: BattleResTag.PPVTimeline);
                    analyzer.Analyze();
                }
            }

            // locomotion曲线
            resModule.AddResultByPath(BattleConst.LocomotionRatioAssetName, BattleResType.LocomotionAsset);

            if (roleCfg.Type == ActorType.Hero)
            { 
                // 破冰抖动资源
                resModule.AddResultByPath(TbUtil.battleConsts.IceBreakingShakeAsset, BattleResType.ShakeBone);
            }
        }

        public override bool IsSameData(ResAnalyzer other)
        {
            if (other is ActorResAnalyzer analyzer)
            {
                if (analyzer._actorCfg == null || _actorCfg == null)
                {
                    return false;
                }
                return analyzer._actorCfg.ID == _actorCfg.ID;
            }
            return false;
        }

        private void AnalyzeMachine(MachineCfg cfg)
        {
            if (BattleResMgr.Instance.IsExists(cfg.PrefabName, BattleResType.Machine))
            {
                resModule.AddResultByPath(cfg.PrefabName, BattleResType.Machine); // prefab
            }
            if (BattleResMgr.Instance.IsExists(cfg.FlowName, BattleResType.Flow))
            {
                resModule.AddResultByPath(cfg.FlowName, BattleResType.Flow); // flow
                AnalyzeFromLoadedRes<GameObject>(cfg.FlowName, BattleResType.Flow, ResAnalyzeUtil.AnalyzerGraphPrefab, resModule);
            }
            Dictionary<int, SkillSlotConfig> skillSlots = cfg.SkillSlots;
            // 技能预加载
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
        
        private void AnalyzeInterActor(InterActorCfg roleCfg)
        {
            // actor 分析器定位变为了 逻辑分析器，所以这里不在进行角色套装的分析
            if (roleCfg.ModelData != null && roleCfg.ModelData.Type != ActorType.Hero)
            {
                ResDesc resDesc = BattleUtil.GetActorResDesc(roleCfg.ModelData);
                resModule.AddResultByPath(resDesc.path, resDesc.type, resDesc.count);
            }

            //主状态机
            resModule.AddResultByPath(BattleConst.MainFSMName, BattleResType.Fsm);
            
            // 出生动作模组
            if (roleCfg.BornActionModule != 0)
            {
                ResAnalyzeUtil.AnalyzeActionModule(resModule, roleCfg.BornActionModule);
            }

            // 死亡动作模组
            if (roleCfg.DeadActionModule != 0)
            {
                ResAnalyzeUtil.AnalyzeActionModule(resModule, roleCfg.DeadActionModule);
            }

            //动画状态机
            resModule.AddConditionAnalyze(new AnimatorControllerAnalyze(false, roleCfg.AnimatorCtrlName));

            //LookAt
            if (!string.IsNullOrEmpty(roleCfg.LookAtBlendSpaceConfig) &&
                BattleResMgr.Instance.IsExists(roleCfg.LookAtBlendSpaceConfig, BattleResType.BlendSpaceAsset))
            {
                resModule.AddResultByPath(roleCfg.LookAtBlendSpaceConfig, BattleResType.BlendSpaceAsset);
            }
            
            var skillSlots = roleCfg.SkillSlots;
            if (skillSlots != null)
            {
                foreach (var skillSlot in skillSlots)
                {
                    SkillSlotConfig slot = skillSlot.Value;
                    var skillAnalyzer = new SkillResAnalyzer(slot.SkillID, slot.SkillLevel, resModule);
                    skillAnalyzer.Analyze();
                }
            }

            // modelInfo
            if(!string.IsNullOrEmpty(roleCfg.ModelKey))
            {
                ModelInfo modelInfo = TbUtil.GetCfg<ModelInfo>(_actorCfg.ModelKey);
                if (modelInfo?.fxPerformGroups != null)
                {
                    foreach (var group in modelInfo.fxPerformGroups.Values)
                    {
                        foreach (var perform in group.fxPerforms)
                        {
                            resModule.AddResultByPath(perform.fxPath, BattleResType.FX);
                        }
                    }
                }
            }

            // locomotion曲线
            resModule.AddResultByPath(BattleConst.LocomotionRatioAssetName, BattleResType.LocomotionAsset);
        }
        
        private void _AnalyzeAnimatorActionMode(RoleCfg roleCfg)
        {
            foreach (var config in TbUtil.stateToTimelines.Values)
            {
                if(roleCfg.Type == ActorType.Hero)
                {
                    if (roleCfg.SubType == (int)HeroType.Boy)
                    {
                        if (config.GroupID != 0 && config.GroupID == (roleCfg as BoyCfg)?.BSTTGroupID)
                        {
                            if (Application.isPlaying)
                                LogProxy.Log("动作模组预加载： 男主 + ActionModeID = " + config.ActionModeID + " id = " + roleCfg.ID + " GroupID = " + config.GroupID);
                            ResAnalyzeUtil.AnalyzeActionModule(resModule, config.ActionModeID);
                        }
                    }
                    else if (roleCfg.SubType == (int)HeroType.Girl)
                    {
                        // 分析女主的通用模组
                        if (config.GroupID == 0)
                        {
                            ResAnalyzeUtil.AnalyzeActionModule(resModule, config.ActionModeID);
                            if (Application.isPlaying)
                                LogProxy.Log("动作模组预加载： 女主 + ActionModeID = " + config.ActionModeID + " GroupID = " + config.GroupID);
                        }
                    }
                }
                else
                {
                    if (config.GroupID != 0 && config.GroupID == (roleCfg as MonsterCfg)?.BSTTGroupID)
                    {
                        ResAnalyzeUtil.AnalyzeActionModule(resModule, config.ActionModeID);
                        if (Application.isPlaying)
                            LogProxy.Log("动作模组预加载： 怪物 + ActionModeID = " + config.ActionModeID + " id = " +  (roleCfg as MonsterCfg).ID + " GroupID = " + config.GroupID);
                    }
                }
            }
        }
    }
}