using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

namespace X3Battle
{
    public static partial class TbUtil
    {
        private static TbCfgProxy _proxy => TbCfgProxy.instance;
        private static TbCfgModifyProxy _modifyProxy => TbCfgModifyProxy.instance;
        private static string _rootDir;

        public static string rootDir
        {
            get
            {
                if (string.IsNullOrEmpty(_rootDir))
                {
                    _rootDir = Application.dataPath.Replace("Assets", "MessagePack/");
                }

                return _rootDir;
            }
        }

        private static string _persistentDir;

        public static string persistentDir
        {
            get
            {
                if (string.IsNullOrEmpty(_persistentDir))
                {
                    _persistentDir = $"{Application.persistentDataPath}/MessagePack/";
                }

                return _persistentDir;
            }
        }

        #region --经过后处理的配置--

        public static Dictionary<int, HeroCfg> girlCfgs => GetCfgs<ActorCfgs>()?.girlCfgs;
        public static Dictionary<int, BoyCfg> boyCfgs => GetCfgs<ActorCfgs>()?.boyCfgs;
        public static Dictionary<int, MonsterCfg> monsterCfgs => GetCfgs<ActorCfgs>()?.monsterCfgs;
        public static Dictionary<int, MachineCfg> machineCfgs => GetCfgs<ActorCfgs>()?.machineCfgs;
        
        public static Dictionary<int, InterActorCfg> interActorCfgs => GetCfgs<ActorCfgs>()?.interActorCfgs;
        public static Dictionary<int, ActorCfg> actorCfgs => GetCfgs<Dictionary<int, ActorCfg>>();
        public static Dictionary<int, ActorSuitCfg> actorSuitCfgs => GetCfgs<Dictionary<int, ActorSuitCfg>>();

        #endregion

        #region --战斗内的动态配置--

        public static Dictionary<int, SkillCfg> skillCfgs => GetCfgs<Dictionary<int, SkillCfg>>();
        public static Dictionary<int, MissileCfg> missileCfgs => GetCfgs<Dictionary<int, MissileCfg>>();
        public static Dictionary<int, RogueEntryCfg> rogueEntryCfgs => GetCfgs<Dictionary<int, RogueEntryCfg>>();
        public static Dictionary<int, DamageBoxCfg> damageBoxCfgs => GetCfgs<Dictionary<int, DamageBoxCfg>>();
        public static Dictionary<int, ActionModuleCfg> actionModuleCfgs => GetCfgs<Dictionary<int, ActionModuleCfg>>();
        public static Dictionary<int, SkinCfg> skinCfgs => GetCfgs<Dictionary<int, SkinCfg>>();
        public static Dictionary<int, BuffCfg> buffCfgs => GetCfgs<Dictionary<int, BuffCfg>>();
        public static Dictionary<int, MagicFieldCfg> magicFieldCfgs => GetCfgs<Dictionary<int, MagicFieldCfg>>();
        public static Dictionary<int, ItemCfg> itemCfgs => GetCfgs<Dictionary<int, ItemCfg>>();
        public static Dictionary<int, HaloCfg> haloCfgs => GetCfgs<Dictionary<int, HaloCfg>>();
        public static Dictionary<int, StageConfig> stageCfgs => GetCfgs<Dictionary<int, StageConfig>>();
        public static Dictionary<int, TriggerCfg> triggerCfgs => GetCfgs<Dictionary<int, TriggerCfg>>();
        public static Dictionary<string, ModelInfo> modelInfos => GetCfgs<Dictionary<string, ModelInfo>>();

        #endregion
        
        /// <summary>
        /// 仅在静态配置里面实现
        /// </summary>
        public static Dictionary<Type, HashSet<string>> dynamicCfgPaths => _proxy.dynamicCfgPaths;

        public static void Init()
        {
            _proxy.LoadAllCfgs();
            //临时处理
            _StringIntern();
        }

        public static void UnInit()
        {
            TbCfgProxy.Dispose();
            DisposeModifyCfgs();
        }

        public static void DisposeModifyCfgs()
        {
            TbCfgModifyProxy.Dispose();
        }

        public static byte[] ReadFile(string relativePath)
        {
            var fullPath = "";
            byte[] bytes = null;
#if UNITY_EDITOR
            fullPath = $"{rootDir}{relativePath}.bytes";
            if (File.Exists(fullPath))
            {
                bytes = File.ReadAllBytes(fullPath);
                return bytes;
            }
#endif

#if DEBUG_GM
            fullPath = $"{persistentDir}{relativePath}.bytes";
            if (File.Exists(fullPath))
            {
                bytes = File.ReadAllBytes(fullPath);
                return bytes;
            }
#endif
            fullPath = BattleUtil.GetResPath(relativePath, BattleResType.MessagePack);
            var textAsset = PapeGames.X3.Res.Load<TextAsset>(fullPath);
            if (textAsset != null)
            {
                bytes = textAsset.bytes;
                return bytes;
            }

            return null;
        }

        public static T GetCfgs<T>() where T : class
        {
            T t = _modifyProxy.GetCfgs<T>(true);
            if (t == null)
            {
                return _proxy.GetCfgs<T>();
            }
            return t;
        }
        
        #region --int key--
        public static T GetCfg<T>(int id) where T : class
        {
            return GetCfg<int, T>(id);
        }
        
        public static bool TryGetCfg<T>(int id, out T t) where T : class
        {
            t = GetCfg<T>(id);
            return t != null;
        }

        public static bool HasCfg<T>(int id) where T : class
        {
            return GetCfg<T>(id) != null;
        }
        #endregion
        
        #region --struct key--
        public static T2 GetCfg<T1, T2>(T1 id) where T1 : struct where T2 : class
        {
            T2 t = _modifyProxy.GetCfg<T1, T2>(id, true);
            if (t == null)
            {
                return _proxy.GetCfg<T1, T2>(id);
            }
            return t;
        }
        
        public static bool TryGetCfg<T1, T2>(T1 id, out T2 t) where T1 : struct where T2 : class
        {
            t = GetCfg<T1, T2>(id);
            return t != null;
        }

        public static bool HasCfg<T1, T2>(T1 id) where T1 : struct where T2 : class
        {
            return GetCfg<T1, T2>(id) != null;
        }
        #endregion
        
        #region --int int key--
        public static T GetCfg<T>(int id1, int id2) where T : class
        {
            return GetCfg<int, int, T>(id1, id2);
        }

        public static bool TryGetCfg<T>(int id1, int id2, out T t) where T : class
        {
            t = GetCfg<T>(id1, id2);
            return t != null;
        }
        
        public static bool HasCfg<T>(int id1, int id2) where T : class
        {
            return GetCfg<T>(id1, id2) != null;
        }
        #endregion
        
        #region --int struct key--
        public static T2 GetCfg<T1, T2>(int id1, T1 id2) where T1 : struct where T2 : class
        {
            return GetCfg<int, T1, T2>(id1, id2);
        }
        
        public static bool TryGetCfg<T1, T2>(int id1, T1 id2, out T2 t) where T1 : struct where T2 : class
        {
            t = GetCfg<T1, T2>(id1, id2);
            return t != null;
        }

        public static bool HasCfg<T1, T2>(int id1, T1 id2)  where T1 : struct where T2 : class
        {
            return GetCfg<T1, T2>(id1, id2) != null;
        }
        #endregion
        
        #region --struct int key--
        public static T2 GetCfg<T1, T2>(T1 id1, int id2) where T1 : struct where T2 : class
        {
            return GetCfg<T1, int, T2>(id1, id2);
        }
        
        public static bool TryGetCfg<T1, T2>(T1 id1, int id2, out T2 t) where T1 : struct where T2 : class
        {
            t = GetCfg<T1, T2>(id1, id2);
            return t != null;
        }

        public static bool HasCfg<T1, T2>(T1 id1, int id2)  where T1 : struct where T2 : class
        {
            return GetCfg<T1, T2>(id1, id2) != null;
        }
        #endregion
        
        #region --struct struct key--
        public static T3 GetCfg<T1, T2, T3>(T1 id1, T2 id2) where T1 : struct where T2 : struct where T3 : class
        {
            T3 t = _modifyProxy.GetCfg<T1, T2, T3>(id1, id2, true);
            if (t == null)
            {
                return _proxy.GetCfg<T1, T2, T3>(id1, id2);
            }
            return t;
        }
        
        public static bool TryGetCfg<T1, T2, T3>(T1 id1, T2 id2, out T3 t) where T1 : struct where T2 : struct where T3 : class
        {
            t = GetCfg<T1, T2, T3>(id1, id2);
            return t != null;
        }

        public static bool HasCfg<T1, T2, T3>(T1 id1, T2 id2)  where T1 : struct where T2 : struct where T3 : class
        {
            return GetCfg<T1, T2, T3>(id1, id2) != null;
        }
        #endregion
        
        #region --string key--
        public static T GetCfg<T>(string id) where T : class
        {
            T t = _modifyProxy.GetCfg<T>(id, true);
            if (t == null)
            {
                return _proxy.GetCfg<T>(id);
            }
            return t;
        }
        
        public static bool TryGetCfg<T>(string id, out T t) where T : class
        {
            t = GetCfg<T>(id);
            return t != null;
        }
        
        public static bool HasCfg<T>(string id) where T : class
        {
            return GetCfg<T>(id) != null;
        }
        #endregion
        
        #region --string string key--
        public static T GetCfg<T>(string id1, string id2) where T : class
        {
            T t = _modifyProxy.GetCfg<T>(id1, id2, true);
            if (t == null)
            {
                return _proxy.GetCfg<T>(id1, id2);
            }
            return t;
        }
        
        public static bool TryGetCfg<T>(string id1, string id2, out T t) where T : class
        {
            t = GetCfg<T>(id1, id2);
            return t != null;
        }

        public static bool HasCfg<T>(string id1, string id2) where T : class
        {
            return GetCfg<T>(id1, id2) != null;
        }
        #endregion
        
        #region --string int key--
        public static T GetCfg<T>(string id1, int id2) where T : class
        {
            return GetCfg<int, T>(id1, id2);
        }
        
        public static bool TryGetCfg<T>(string id1, int id2, out T t) where T : class
        {
            t = GetCfg<T>(id1, id2);
            return t != null;
        }

        public static bool HasCfg<T>(string id1, int id2) where T : class
        {
            return GetCfg<T>(id1, id2) != null;
        }
        #endregion
        
        #region --string struct key--
        public static T2 GetCfg<T1, T2>(string id1, T1 id2) where T1 : struct where T2 : class
        {
            T2 t = _modifyProxy.GetCfg<T1, T2>(id1, id2, true);
            if (t == null)
            {
                return _proxy.GetCfg<T1, T2>(id1, id2);
            }
            return t;
        }
        
        public static bool TryGetCfg<T1, T2>(string id1, T1 id2, out T2 t) where T1 : struct where T2 : class
        {
            t = GetCfg<T1, T2>(id1, id2);
            return t != null;
        }

        public static bool HasCfg<T1, T2>(string id1, T1 id2)  where T1 : struct where T2 : class
        {
            return GetCfg<T1, T2>(id1, id2) != null;
        }
        #endregion
        
        #region --int string key--
        public static T GetCfg<T>(int id1, string id2) where T : class
        {
            return GetCfg<int, T>(id1, id2);
        }
        
        public static bool TryGetCfg<T>(int id1, string id2, out T t) where T : class
        {
            t = GetCfg<T>(id1, id2);
            return t != null;
        }

        public static bool HasCfg<T>(int id1, string id2) where T : class
        {
            return GetCfg<T>(id1, id2) != null;
        }
        #endregion
        
        #region --struct string key--
        public static T2 GetCfg<T1, T2>(T1 id1, string id2) where T1 : struct where T2 : class
        {
            T2 t = _modifyProxy.GetCfg<T1, T2>(id1, id2, true);
            if (t == null)
            {
                return _proxy.GetCfg<T1, T2>(id1, id2);
            }
            return t;
        }
        
        public static bool TryGetCfg<T1, T2>(T1 id1, string id2, out T2 t) where T1 : struct where T2 : class
        {
            t = GetCfg<T1, T2>(id1, id2);
            return t != null;
        }

        public static bool HasCfg<T1, T2>(T1 id1, string id2)  where T1 : struct where T2 : class
        {
            return GetCfg<T1, T2>(id1, id2) != null;
        }
        #endregion
        
        #region --load modify method--
        public static T LoadModifyCfg<T>(int id) where T : class
        {
            return LoadModifyCfg<int, T>(id);
        }
        
        public static T2 LoadModifyCfg<T1, T2>(T1 id) where T1 : struct where T2 : class
        {
            return _modifyProxy.GetCfg<T1, T2>(id);
        }
        
        public static T LoadModifyCfg<T>(string id) where T : class
        {
            return _modifyProxy.GetCfg<T>(id);
        }
        
        public static T LoadModifyCfg<T>(int id1, int id2) where T : class
        {
            return LoadModifyCfg<int, int, T>(id1, id2);
        }
        
        public static T2 LoadModifyCfg<T1, T2>(int id1, T1 id2) where T1 : struct where T2 : class
        {
            return LoadModifyCfg<int, T1, T2>(id1, id2);
        }
        
        public static T2 LoadModifyCfg<T1, T2>(T1 id1, int id2) where T1 : struct where T2 : class
        {
            return LoadModifyCfg<T1, int, T2>(id1, id2);
        }
        
        public static T3 LoadModifyCfg<T1, T2, T3>(T1 id1, T2 id2) where T1 : struct where T2 : struct where T3 : class
        {
            return _modifyProxy.GetCfg<T1, T2, T3>(id1, id2);
        }
        
        public static T LoadModifyCfg<T>(string id1, string id2) where T : class
        {
            return _modifyProxy.GetCfg<T>(id1, id2);
        }
        
        public static T LoadModifyCfg<T>(string id1, int id2) where T : class
        {
            return LoadModifyCfg<int, T>(id1, id2);
        }
        
        public static T2 LoadModifyCfg<T1, T2>(string id1, T1 id2) where T1 : struct where T2 : class
        {
            return _modifyProxy.GetCfg<T1, T2>(id1, id2);
        }
        
        public static T LoadModifyCfg<T>(int id1, string id2) where T : class
        {
            return LoadModifyCfg<int, T>(id1, id2);
        }
        
        public static T2 LoadModifyCfg<T1, T2>(T1 id1, string id2) where T1 : struct where T2 : class
        {
            return _modifyProxy.GetCfg<T1, T2>(id1, id2);
        }
        #endregion

        private static void _StringIntern()
        {
            zstring.Init();
            foreach (var maleSuitConfigItem in boySuitCfgs)
            {
                MaleSuitConfig maleSuitConfig = maleSuitConfigItem.Value;
                for (int i = 0; i < maleSuitConfig.RelaxWeight.Length; i++)
                {
                    maleSuitConfig.RelaxWeight[i].StrVal = zstring.Intern(maleSuitConfig.RelaxWeight[i].StrVal);
                }
            }

            foreach (var boyCfgItem in boyCfgs)
            {
                BoyCfg boyCfg = boyCfgItem.Value;
                boyCfg.GirlAnimCtrlKey = zstring.Intern(boyCfg.GirlAnimCtrlKey);
                boyCfg.AnimatorCtrlName = zstring.Intern(boyCfg.AnimatorCtrlName);
                boyCfg.AnimFSMFilename = zstring.Intern(boyCfg.AnimFSMFilename);
                boyCfg.CombatAIName = zstring.Intern(boyCfg.CombatAIName);
                boyCfg.TalkFlowName = zstring.Intern(boyCfg.TalkFlowName);
                boyCfg.MaleEnergyFillUI = zstring.Intern(boyCfg.MaleEnergyFillUI);
                boyCfg.MaleEnergyBGUI = zstring.Intern(boyCfg.MaleEnergyBGUI);
                boyCfg.MaleEnergyGlowUI = zstring.Intern(boyCfg.MaleEnergyGlowUI);
                boyCfg.PrefabName = zstring.Intern(boyCfg.PrefabName);
            }

            foreach (var monsterCfgItem in monsterCfgs)
            {
                MonsterCfg monsterCfg = monsterCfgItem.Value;
                monsterCfg.AnimatorCtrlName = zstring.Intern(monsterCfg.AnimatorCtrlName);
                monsterCfg.AnimFSMFilename = zstring.Intern(monsterCfg.AnimFSMFilename);
                monsterCfg.CombatAIName = zstring.Intern(monsterCfg.CombatAIName);
                monsterCfg.TalkFlowName = zstring.Intern(monsterCfg.TalkFlowName);
                monsterCfg.FxSizeName = zstring.Intern(monsterCfg.FxSizeName);
                monsterCfg.PrefabName = zstring.Intern(monsterCfg.PrefabName);
                monsterCfg.ModelKey = zstring.Intern(monsterCfg.ModelKey);
                monsterCfg.IconName = zstring.Intern(monsterCfg.IconName);
                monsterCfg.CoreBreakSound = zstring.Intern(monsterCfg.CoreBreakSound);
                monsterCfg.WeakSound = zstring.Intern(monsterCfg.WeakSound);
                monsterCfg.HurtInfo.HurtShakeName = zstring.Intern(monsterCfg.HurtInfo.HurtShakeName);
                for (int i = 0; i < monsterCfg.HurtShakeBone.Length; i++)
                {
                    monsterCfg.HurtShakeBone[i] = zstring.Intern(monsterCfg.HurtShakeBone[i]);
                }

                for (int i = 0; i < monsterCfg.FootEffect.Length; i++)
                {
                    monsterCfg.FootEffect[i] = zstring.Intern(monsterCfg.FootEffect[i]);
                }

                monsterCfg.UltraSkillHurtAnim = zstring.Intern(monsterCfg.UltraSkillHurtAnim);
                monsterCfg.LookAtBlendSpaceConfig = zstring.Intern(monsterCfg.LookAtBlendSpaceConfig);
                monsterCfg.CreatureMaterial = zstring.Intern(monsterCfg.CreatureMaterial);
            }

            foreach (var girlCfgItem in girlCfgs)
            {
                HeroCfg girlCfg = girlCfgItem.Value;
                girlCfg.PrefabName = zstring.Intern(girlCfg.PrefabName);
            }

            foreach (var weaponSkinConfigItem in weaponSkinConfigs)
            {
                WeaponSkinConfig weaponSkinConfig = weaponSkinConfigItem.Value;
                weaponSkinConfig.FadeInMat = zstring.Intern(weaponSkinConfig.FadeInMat);
                weaponSkinConfig.FadeOutMat = zstring.Intern(weaponSkinConfig.FadeOutMat);
                weaponSkinConfig.FadeOutSound = zstring.Intern(weaponSkinConfig.FadeOutSound);
                for (int i = 0; i < weaponSkinConfig.RelaxWeight.Length; i++)
                {
                    weaponSkinConfig.RelaxWeight[i].StrVal = zstring.Intern(weaponSkinConfig.RelaxWeight[i].StrVal);
                }
            }

            foreach (var weaponLogicConfigItem in weaponLogicConfigs)
            {
                WeaponLogicConfig weaponLogicConfig = weaponLogicConfigItem.Value;
                weaponLogicConfig.GirlAnimCtrlKey = zstring.Intern(weaponLogicConfig.GirlAnimCtrlKey);
                weaponLogicConfig.AI = zstring.Intern(weaponLogicConfig.AI);
            }

            foreach (var levelConfigItem in battleLevelConfigs)
            {
                BattleLevelConfig levelConfig = levelConfigItem.Value;
                levelConfig.SceneName = zstring.Intern(levelConfig.SceneName);
                levelConfig.PlayerSceneLightPath = zstring.Intern(levelConfig.PlayerSceneLightPath);
                levelConfig.BackgroundMusic = zstring.Intern(levelConfig.BackgroundMusic);
                levelConfig.LogicFilename = zstring.Intern(levelConfig.LogicFilename);
                for (int i = 0; i < levelConfig.Graphs.Length; i++)
                {
                    levelConfig.Graphs[i] = zstring.Intern(levelConfig.Graphs[i]);
                }
            }

            foreach (var dialogueConfigItem in dialogueConfigs)
            {
                DialogueConfig dialogueConfig = dialogueConfigItem.Value;
                dialogueConfig.Key = zstring.Intern(dialogueConfig.Key);
                dialogueConfig.Sound1 = zstring.Intern(dialogueConfig.Sound1);
                dialogueConfig.Sound2 = zstring.Intern(dialogueConfig.Sound2);
                dialogueConfig.Sound3 = zstring.Intern(dialogueConfig.Sound3);
                dialogueConfig.Sound4 = zstring.Intern(dialogueConfig.Sound4);
            }

            foreach (var dialogueKeyConfigItem in dialogueKeyConfigs)
            {
                DialogueKeyConfig dialogueKeyConfig = dialogueKeyConfigItem.Value;
                dialogueKeyConfig.Key = zstring.Intern(dialogueKeyConfig.Key);
            }

            foreach (var fxConfigItem in fxConfigs)
            {
                FXConfig fxConfig = fxConfigItem.Value;
                fxConfig.PrefabName = zstring.Intern(fxConfig.PrefabName);
                fxConfig.DummyNodeName = zstring.Intern(fxConfig.DummyNodeName);
            }

            foreach (var groundMoveFxsItem in groundMoveFxs)
            {
                foreach (var groundMoveFxItem in groundMoveFxsItem.Value)
                {
                    GroundMoveFx groundMoveFx = groundMoveFxItem.Value;
                    groundMoveFx.EventName = zstring.Intern(groundMoveFx.EventName);
                    groundMoveFx.SwitchState = zstring.Intern(groundMoveFx.SwitchState);
                }
            }

            foreach (var hurtMaterialConfigsItem in hurtMaterialConfigs)
            {
                foreach (var hurtMaterialConfigItem in hurtMaterialConfigsItem.Value)
                {
                    HurtMaterialConfig hurtMaterialConfig = hurtMaterialConfigItem.Value;
                    hurtMaterialConfig.HurtWeaponType = zstring.Intern(hurtMaterialConfig.HurtWeaponType);
                    hurtMaterialConfig.HurtSound = zstring.Intern(hurtMaterialConfig.HurtSound);
                }
            }

            foreach (var battleSceneCameraColliderItem in battleSceneCameraColliders)
            {
                BattleSceneCameraCollider battleSceneCameraCollider = battleSceneCameraColliderItem.Value;
                battleSceneCameraCollider.SceneCameraColliderName = zstring.Intern(battleSceneCameraCollider.SceneCameraColliderName);
            }

            foreach (var skillLevelCfgsItem in skillLevelCfgs)
            {
                foreach (var skillLevelCfgItem in skillLevelCfgsItem.Value)
                {
                    SkillLevelCfg skillLevelCfg = skillLevelCfgItem.Value;
                    if (skillLevelCfg.DetaulDescParam != null)
                    {
                        for (int i = 0; i < skillLevelCfg.DetaulDescParam.Length; i++)
                        {
                            skillLevelCfg.DetaulDescParam[i] = zstring.Intern(skillLevelCfg.DetaulDescParam[i]);
                        }
                    }

                    skillLevelCfg.SkillIcon = zstring.Intern(skillLevelCfg.SkillIcon);
                    skillLevelCfg.SkillPreview = zstring.Intern(skillLevelCfg.SkillPreview);
                    skillLevelCfg.SkillVideo = zstring.Intern(skillLevelCfg.SkillVideo);
                }
            }

            foreach (var stateToTimelineItem in stateToTimelines)
            {
                StateToTimeline stateToTimeline = stateToTimelineItem.Value;
                stateToTimeline.StateName = zstring.Intern(stateToTimeline.StateName);
            }
        }
    }
}