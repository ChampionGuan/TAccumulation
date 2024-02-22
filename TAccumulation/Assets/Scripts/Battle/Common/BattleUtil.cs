using System;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEngine;
using System.IO;
using System.Text;
using CollisionQuery;
using EasyCharacterMovement;
using PapeGames.X3;
using ParadoxNotion.Services;
using UnityEngine.Profiling;
using Debug = UnityEngine.Debug;
using Logger = ParadoxNotion.Services.Logger;
using Path = System.IO.Path;
using System.Linq;
using System.Security.Cryptography;
using NodeCanvas.Framework;

namespace X3Battle
{
    public static partial class BattleUtil
    {
        private static StringBuilder _tempSB = new StringBuilder();
        private static List<Vector3> _cachePoints = new List<Vector3>(10);

        static BattleUtil()
        {
#if UNITY_EDITOR
            Logger.logLevel = LogLevel.All;
            Logger.LogFunc = null;
#else
            Logger.logLevel = LogLevel.Error;
            Logger.LogFunc = ParadoxNotionLog;
#endif
            //BattleUtil中的寻路都使用Nevmesh
            _nnTriangleInfo.graphMask = 1 << 1;
        }

        /// <summary>
        /// 用于调试的字符串Format
        /// </summary>
        [System.Diagnostics.Conditional(LogProxy.DEBUG_LOG)]
        public static void DebugFormat(ref string originStr, string str, params object[] args)
        {
            originStr = string.Format(str, args);
        }

        /// <summary>
        /// 获得怪物评级
        /// </summary>
        /// <param name="configId"></param>
        /// <returns></returns>
        public static int GetMonsterRate(int configId)
        {
            TbUtil.TryGetCfg(configId, out MonsterCfg monsterCfg);
            if (monsterCfg == null)
            {
                return 0;
            }

            return monsterCfg.Rate;
        }

        public static float GetAggressiveCDR(bool isStageStrategy = true)
        {
            if (!isStageStrategy || Battle.Instance == null)
            {
                return 1;
            }
            return Battle.Instance.levelFlow.aggressiveStrategyCDR;
        }

        public static int GetAggressiveToken()
        {
            if (Battle.Instance == null)
            {
                return 0;
            }
            return Battle.Instance.levelFlow.aggressiveStrategyExtraToken;
        }
        
        public static float GetAggressiveTokenExitSpeedup()
        {
            if (Battle.Instance == null)
            {
                return 1;
            }
            return Battle.Instance.levelFlow.aggressiveStrategyTokenExitSpeedup;
        }

        /// <summary>
        /// 判断是否是新手引导
        /// </summary>
        /// <returns></returns>
        public static bool IsGuideLevel(int targetLevelId)
        {
            if (TbUtil.battleConsts.GuideLevelIds == null)
            {
                return false;
            }

            foreach (int levelId in TbUtil.battleConsts.GuideLevelIds)
            {
                if (levelId == targetLevelId)
                {
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// Graph中的日志打印
        /// </summary>
        private static void ParadoxNotionLog(LogType type, object tag, string message, object context)
        {
            switch (type)
            {
                case LogType.Error:
                    LogProxy.LogErrorFormat(message, tag);
                    break;
                case LogType.Assert:
                    LogProxy.LogFormat(message, tag);
                    break;
                case LogType.Warning:
                    LogProxy.LogWarningFormat(message, tag);
                    break;
                case LogType.Log:
                    LogProxy.LogFormat(message, tag);
                    break;
                case LogType.Exception:
                    LogProxy.LogFatalFormat(message, tag);
                    break;
                default:
                    throw new ArgumentOutOfRangeException(nameof(type), type, null);
            }
        }

        public static string GetModelInfoFilePath(string fileName)
        {
            return $"{BattleConst.ModelInfosCfgFile}/{fileName}";
        }

        public static List<string> GetFiles(string rootPath, string extension)
        {
            var filesName = new List<string>();
            DirectoryInfo folder = new DirectoryInfo(rootPath);
            FileSystemInfo[] files = folder.GetFileSystemInfos();
            for (int i = 0; i < files.Length; i++)
            {
                if (files[i] is DirectoryInfo)
                {
                    GetFiles(files[i].FullName, extension);
                }
                else
                {
                    if (files[i].Name.EndsWith(extension))
                    {
                        filesName.Add(files[i].Name.Replace(".bytes", ""));
                    }
                }
            }

            return filesName;
        }

        /// <summary>
        /// 通过Shape检测角色
        /// </summary>
        /// <param name="shapeBoxInfo"></param>
        /// <param name="actor"></param>
        /// <param name="lastHitGround"></param>
        /// <param name="lastHitAirWall"></param>
        /// <returns></returns>
        public static List<Actor> ShapeDetect(ShapeBoxInfo shapeBoxInfo, Actor actor, out bool lastHitGround, out bool lastHitAirWall)
        {
            var shapeBox = ObjectPoolUtility.ShapeBoxPool.Get();
            shapeBox.Init(shapeBoxInfo, new VirtualTrans(actor.GetDummy()));
            shapeBox.Update();

            var targetPosition = shapeBox.GetCurWorldPos();
            var prevPosition = shapeBox.GetPrevWorldPos();
            var angleY = shapeBox.GetCurWorldEuler().y;
            var bundingShape = shapeBox.GetBoundingShape();

            ObjectPoolUtility.ShapeBoxPool.Release(shapeBox);
            var relationShips = new List<FactionRelationship>();
            relationShips.Add(FactionRelationship.Friend);
            relationShips.Add(FactionRelationship.Enemy);
            relationShips.Add(FactionRelationship.Neutral);
            List<Actor> results = new List<Actor>();
            List<CollisionDetectionInfo> actorCollisionInfos = new List<CollisionDetectionInfo>();
            PickAOETargets(Battle.Instance, ref results, targetPosition, prevPosition, new Vector3(0f, angleY, 0f), bundingShape, actor, false, null, false, actorCollisionInfos, relationShips, false, X3LayerMask.MissileTest);
            lastHitGround = false;
            lastHitAirWall = false;
            foreach (CollisionDetectionInfo actorCollisionInfo in actorCollisionInfos)
            {
                if (actorCollisionInfo.tag == ColliderTag.Ground)
                {
                    lastHitGround = true;
                    break;
                }
            }

            foreach (CollisionDetectionInfo actorCollisionInfo in actorCollisionInfos)
            {
                if (actorCollisionInfo.tag == ColliderTag.AirWall)
                {
                    lastHitAirWall = true;
                    break;
                }
            }

            return results;
        }
        
        /// <summary>
        /// 射线地面检测
        /// 算法思想：
        /// 线段1：起点到终点， 线段2：起点，终点在地面上的投影出的线段
        /// 一：先认定地面是个平面， 则可以计算出两个线段的交点
        /// 二：对交点重新去一次地面高度。 
        /// </summary>
        /// <param name="startPos">射线起点</param>
        /// <param name="endPos">射线终点</param>
        /// <param name="hitPoint">与地面的碰撞点</param>
        /// <returns>是否碰到地面</returns>
        public static bool RayCastGround(Vector3 startPos, Vector3 endPos, out Vector3 hitPoint)
        {
            hitPoint = default(Vector3);
            if (startPos == endPos)
            {
                return false;
            }
            float startH = BattleUtil.GetGroundHeight(startPos);
            float endH = BattleUtil.GetGroundHeight(endPos);
            
            if (startPos.y > startH && endPos.y > endH)
            {
                // 起点和终点都在地面上，则认定与地面无碰撞
                return false;
            }
            Vector3 groundStartPos = new Vector3(startPos.x, startH, startPos.z);
            Vector3 groundEndPos = new Vector3(endPos.x, endH, endPos.z);
            bool isHit = X3Physics.SegmentSegmentPoint2D(startPos, endPos, groundStartPos, groundEndPos, out hitPoint);
            hitPoint.y = BattleUtil.GetGroundHeight(hitPoint);
            return isHit;
        }
        
        /// <summary>
        /// 构建IDLevel[]
        /// </summary>
        /// <param name="ids"></param>
        /// <returns></returns>
        public static IDLevel[] CreateIdLevels(int[] ids)
        {
            if (ids == null)
            {
                return null;
            }

            IDLevel[] idLevels = new IDLevel[ids.Length];
            for (int i = 0; i < ids.Length; i++)
            {
                IDLevel idLevel = new IDLevel()
                {
                    ID = ids[i],
                    Level = 1,
                };
                idLevels[i] = idLevel;
            }

            return idLevels;
        }

        /// <summary>
        /// 销毁对象
        /// </summary>
        /// <param name="obj"></param>
        public static void DestroyObj(GameObject obj)
        {
            if (obj == null)
            {
                return;
            }

            if (Application.isPlaying)
            {
                GameObject.Destroy(obj);
            }
            else
            {
                GameObject.DestroyImmediate(obj);
            }
        }

        /// <summary>
        /// 设置父对象在Editor环境下
        /// </summary>
        /// <param name="go"> 不能为null </param>
        /// <param name="parent"> 可以为null </param>
        [Conditional("UNITY_EDITOR")]
        public static void SetParentInEditor(this Transform go, Transform parent)
        {
            if (go == null)
            {
                return;
            }

            go.transform.SetParent(parent);
        }

        /// <summary>
        /// 获取战斗回放路径
        /// </summary>
        /// <returns></returns>
        public static string ForceGetReplayLogPath()
        {
            string dirName = "Replays";
            string fullPath = "";
#if UNITY_EDITOR
            fullPath = Path.Combine(Application.dataPath, $"../../Tools/verifybattle/{dirName}/");
#else
            fullPath = Application.persistentDataPath + $"/{dirName}/";
#endif
            if (!Directory.Exists(fullPath))
            {
                Directory.CreateDirectory(fullPath);
            }

            return fullPath;
        }

        /// <summary>
        /// 获取资源路径
        /// </summary>
        /// <param name="relativePath"></param>
        /// <param name="type"></param>
        /// <returns></returns>
        public static string GetResPath(string relativePath, BattleResType type)
        {
            if (string.IsNullOrEmpty(relativePath))
                return relativePath;

            // 场景的全路径在系统表中配置
            if (type == BattleResType.Scene)
            {
                var sceneFullPath = BattleEnv.LuaBridge?.GetScenePath(relativePath);
                if (!string.IsNullOrEmpty(sceneFullPath))
                    return sceneFullPath;
                return relativePath;
            }
            // 非Playing模式必须保证取到的路径不会是，中低档次的特效
            if (Application.isPlaying)
                relativePath = GetResPathByLodType(relativePath, type, FxSetting.GetEffectQuality());
            var config = BattleResConfig.GetResConfig(type);
            return null == config ? relativePath : StrConcat(config.dir, relativePath, config.ext);
        }

        /// <summary>
        /// 根据等级获取对应特效路径
        /// </summary>
        /// <param name="relativePath"></param>
        /// <param name="type"></param>
        /// <returns></returns>
        public static string GetResPathByLodType(string relativePath, BattleResType type, FxSetting.LodType lodType)
        {
            switch (type)
            {
                case BattleResType.FX:
                case BattleResType.TimelineFx:
                case BattleResType.HurtFX:
                case BattleResType.AllFX:
                    return GetFxPathByLodType(relativePath, type, lodType);
                default:
                    return relativePath;
            }
        }

        /// <summary>
        /// 是否是特效类型
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        public static bool IsFxResType(BattleResType type)
        {
            switch (type)
            {
                case BattleResType.FX:
                case BattleResType.TimelineFx:
                case BattleResType.HurtFX:
                case BattleResType.AllFX:
                    return true;
                default:
                    return false;
            }
        }
        
        public static bool IsUIResType(BattleResType type)
        {
            switch (type)
            {
                case BattleResType.UI:
                case BattleResType.DynamicUI:
                case BattleResType.SystemDynamicUI:
                    return true;
                default:
                    return false;
            }
        }

        /// <summary>
        /// 根据等级获取特效路径
        /// 这里只处理battle文件夹下的
        /// </summary>
        /// <param name="relativePath"></param>
        /// <returns></returns>
        public static string GetFxPathByLodType(string relativePath, BattleResType type, FxSetting.LodType lodType)
        {
            var returnPath = relativePath;

            //已经加上的不用再加
            if (relativePath.Contains(BattleConst.LOD_LOW) || relativePath.Contains(BattleConst.LOD_MID))
            {
                return returnPath;
            }

            BattleResConfigItem config = BattleResConfig.GetResConfig(type);
            if (config == null)
                return returnPath;

            bool isHaveExt = false;
            if (returnPath.Contains(".prefab"))
            {
                isHaveExt = true;
                returnPath = returnPath.Replace(".prefab", "");
            }

            switch (lodType)
            {
                case FxSetting.LodType.high:
                    break;
                case FxSetting.LodType.low:
                    returnPath = StrConcat(returnPath, BattleConst.LOD_LOW);
                    break;
                case FxSetting.LodType.mid:
                    returnPath = StrConcat(returnPath, BattleConst.LOD_MID);
                    break;
            }

            if (isHaveExt)
            {
                returnPath = StrConcat(returnPath, ".prefab");
            }

            string fullPath = string.Empty;
            if (config != null)
            {
                if (!isHaveExt)
                    fullPath = StrConcat(config.dir, returnPath, config.ext);
                else
                    fullPath = StrConcat(config.dir, returnPath);
            }

            // res 的接口非playing模式下发现有GC，且较慢。  runtime没有测试
            bool isFileExist = Application.isPlaying ? Res.IsAssetFileExist(fullPath) : File.Exists(fullPath);
            if (!isFileExist)
            {
                LogProxy.LogError("特效路径错误:" + fullPath);
                returnPath = relativePath;
            }
            return returnPath;
        }

        /// <summary>
        /// 获取皮肤配置文件里替换过的资源路径
        /// </summary>
        /// <param name="skinID"> 策划配置的皮肤ID(SkinCfg.ID), 又称皮肤替换ID </param>
        /// <param name="battleResType"> 战斗资源类型 </param>
        /// <param name="resPath"> 需要替换的路径 </param>
        /// <returns> 返回替换后的路径（没有配置的话, 直接返回原路径） </returns>
        public static string GetPathBySkinID(int skinID, BattleResType battleResType, string resPath)
        {
            // DONE: 默认皮肤的有效配置ID从1开始.
            if (skinID <= 0)
            {
                return resPath;
            }

            if (string.IsNullOrEmpty(resPath))
            {
                return resPath;
            }

            var skinCfg = TbUtil.GetCfg<SkinCfg>(skinID);
            if (skinCfg == null)
            {
                return resPath;
            }

            switch (battleResType)
            {
                case BattleResType.Timeline:
                    // DONE: 处理目录拼接.
                    // Roles/PL/Weapons/Pistol_RY_2503/Timeline_PL_Pistol__WeaponIdle_RY_2503
                    string timelinePath = resPath;
                    int index = timelinePath.LastIndexOf('/');
                    if (index >= 1)
                    {
                        timelinePath = timelinePath.Insert(index, skinCfg.DiffName);
                    }

                    // DONE: 去包里查找有没有这个资产, 如果有就返回拼接过后的字段.
                    timelinePath += skinCfg.DiffName;
                    if (BattleResMgr.Instance.IsExists(timelinePath, BattleResType.Timeline))
                    {
                        LogProxy.LogFormat("【战斗】【皮肤】Timeline原资源{0}, 替换成了{1}", resPath, timelinePath);
                        return timelinePath;
                    }

                    break;
                case BattleResType.FX:
                case BattleResType.AllFX:
                case BattleResType.HurtFX:
                    break;
                case BattleResType.ActorAudio:
                case BattleResType.BulletAudio:
                    if (skinCfg.AudioDict.TryGetValue(resPath, out string audioPath))
                    {
                        LogProxy.LogFormat("【战斗】【皮肤】Audio原资源{0}, 替换成了{1}", resPath, audioPath);
                        return audioPath;
                    }

                    break;
            }

            return resPath;
        }

        /// <summary>
        /// 获取皮肤特效ID
        /// </summary>
        /// <param name="skinID"> 策划配置的皮肤ID(SkinCfg.ID), 又称皮肤替换ID </param>
        /// <param name="fxID"> 需要替换的特效ID </param>
        /// <returns> 返回替换后的特效ID </returns>
        public static int GetFxIDBySkinID(int skinID, int fxID)
        {
            int result = fxID;
            
            // DONE: 默认皮肤的有效配置ID从1开始.
            if (skinID <= 0)
            {
                return result;
            }

            var skinCfg = TbUtil.GetCfg<SkinCfg>(skinID);
            if (skinCfg == null)
            {
                return result;
            }

            if (skinCfg.FxIDTable == null)
            {
                return result;
            }

            if (!skinCfg.FxIDTable.TryGetValue(fxID, out int value))
            {
                return result;
            }

            LogProxy.LogFormat("【战斗】【皮肤】Fx原资源:{0}, 替换成了:{1}", fxID, value);
            result = value;
            return result;
        }

        /// <summary>
        /// 根据SlotID获取皮肤替换ID （如果该技能是否配置在其他人身上，返回目标的皮肤替换ID）
        /// </summary>
        /// <param name="actor"> 目标角色 </param>
        /// <param name="slotID"> slotID </param>
        /// <returns> 返回皮肤替换ID </returns>
        public static int GetSkinIDBySlotID(Actor actor, int slotID)
        {
            var battle = actor.battle;
            if (!battle.arg.cacheBornCfgs.TryGetValue(actor.cfgID, out var actorCacheBornCfg))
            {
                return actor.bornCfg.SkinID;
            }

            if (!actorCacheBornCfg.SkillSourceTable.TryGetValue(slotID, out int otherSourceCfgID))
            {
                return actor.bornCfg.SkinID;
            }

            var result = _GetSkinIDByCfgID(otherSourceCfgID);
            return result;
        }

        private static int _GetSkinIDByCfgID(int cfgID)
        {
            int result = 0;
            if (!TbUtil.TryGetCfg(cfgID, out ActorCfg actorCfg))
            {
                return result;
            }

            if (actorCfg.Type == ActorType.Hero)
            {
                if (actorCfg.SubType == (int) HeroType.Girl)
                {
                    // DONE: 查女主武器皮肤表 TODO: 目前不存在女主给男主这样的技能配置.
                    var weaponSkinConfig = TbUtil.GetCfg<WeaponSkinConfig>(Battle.Instance.arg.girlWeaponID);
                    if (weaponSkinConfig != null)
                    {
                        result = weaponSkinConfig.WeaponSkinCfgID;
                    }
                }
                else if (actorCfg.SubType == (int)HeroType.Boy)
                {
                    // DONE: 查男主皮肤表
                    if (TbUtil.TryGetCfg(actorCfg.ModelData.SuitID, out MaleSuitConfig suitCfg))
                    {
                        result = suitCfg.SkinEditorID;
                    }
                }
            }
            
            return result;
        }

        /// <summary>
        /// 是否是音频
        /// </summary>
        /// <param name="???"></param>
        /// <returns></returns>
        public static bool IsBattleResAudio(BattleResType type)
        {
            switch (type)
            {
                case BattleResType.ActorAudio:
                case BattleResType.BulletAudio:
                case BattleResType.TimelineAudio:
                case BattleResType.UIAudio:
                case BattleResType.BGM:
                case BattleResType.FxAudio:
                    return true;
            }
            return false;
        }

        /// <summary>
        /// 通过指定资源类型判断是否需要皮肤替换
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        public static bool IsSkinReplaceType(BattleResType type)
        {
            switch (type)
            {
                case BattleResType.Timeline:
                case BattleResType.FX:
                case BattleResType.AllFX:
                case BattleResType.HurtFX:
                case BattleResType.ActorAudio:
                case BattleResType.BulletAudio:
                    return true;
            }

            return false;
        }

        /// <summary>
        /// 女主动画控制器名称
        /// boyKey:
        /// </summary>
        /// <param name="girlWeaponID"></param>
        /// <param name="boyCfgID"></param>
        /// <returns></returns>
        public static string GenGirlAnimatorCtrlName(int girlWeaponID, int boyCfgID)
        {
            var boyCfg = TbUtil.GetCfg<BoyCfg>(boyCfgID);
            if (boyCfg == null)
            {
                LogProxy.LogError($"BattleUtil.GenGirlAnimatorCtrlName(), 获取男主配置失败，请检查ID:{boyCfgID}");
                return null;
            }
            
            var weaponSkinCfg = TbUtil.GetCfg<WeaponSkinConfig>(girlWeaponID);
            if (weaponSkinCfg == null)
            {
                LogProxy.LogError($"BattleUtil.GenGirlAnimatorCtrlName(), 获取WeaponSkinConfig失败，请检查ID:{girlWeaponID}");
                return null;
            }
            
            var weaponLogicCfg = TbUtil.GetCfg<WeaponLogicConfig>(weaponSkinCfg.WeaponLogicID);
            if (weaponLogicCfg == null)
            {
                LogProxy.LogError($"BattleUtil.GenGirlAnimatorCtrlName(), 获取WeaponLogicConfig失败，请检查ID:{weaponSkinCfg.WeaponLogicID}");
                return null;
            }

            return StrConcat("PL_", boyCfg.GirlAnimCtrlKey, "_", weaponLogicCfg.GirlAnimCtrlKey);
        }

        /// <summary>
        /// 获取场景名称
        /// </summary>
        /// <param name="levelID"></param>
        /// <returns></returns>
        public static string GetSceneName(int levelID = 0)
        {
            // 场景名字优先从启动参数中获取
            if (BattleEnv.StartupArg != null)
            {
                string sceneName = BattleEnv.StartupArg.sceneName;
                if (!string.IsNullOrEmpty(sceneName))
                {
                    return sceneName;
                }

                levelID = BattleEnv.StartupArg.levelID;
            }

            // 从关卡配置表中取
            BattleLevelConfig levelConfig = TbUtil.GetCfg<BattleLevelConfig>(levelID);
            if (levelConfig != null)
            {
                return levelConfig.SceneName;
            }

            LogProxy.LogErrorFormat("未找到正确的场景名字，levelID:{0}", levelID);
            return "battle_forest_001";
        }

        /// <summary>
        /// 获取场景_Mask文件路径 (mask文件：角色表现，角色音效和步尘)
        /// </summary>
        /// <param name="levelID"></param>
        /// <returns></returns>
        public static string GetSceneMapRelativePath(int levelID)
        {
            //地图信息:场景预制路径下的mask文件夹内的地图名_mask文件
            var path = "";
            var sceneName = GetSceneName(levelID);
            path = GetSceneMapRelativePath(sceneName);
            return path;
        }

        // 通过SceneName获取相对路径
        public static string GetSceneMapRelativePath(string sceneName)
        {
            if (string.IsNullOrEmpty(sceneName))
            {
                return string.Empty;
            }
            var scenePath = BattleEnv.LuaBridge?.GetScenePath(sceneName);
            if (string.IsNullOrEmpty(scenePath))
            {
                return string.Empty;
            }
            var sceneFile = scenePath.Substring(0, scenePath.LastIndexOf("/"));
            var path = StrConcat(sceneFile, "/mask/", sceneName, "_Mask");
            return path;
        }

        /// <summary>
        /// 获取角色资源描述信息
        /// </summary>
        /// <param name="modelCfg"></param>
        /// <returns></returns>
        public static ResDesc GetActorResDesc(ModelCfg modelCfg)
        {
            ResDesc desc = new ResDesc();
            desc.name = modelCfg.Name;
            desc.path = modelCfg.PrefabName;
            switch (modelCfg.Type)
            {
                case ActorType.SkillAgent:
                case ActorType.BattleElement:
                    desc.type = BattleResType.FX;
                    break;
                case ActorType.Hero:
                    desc.type = BattleResType.Hero;
                    desc.suitID = modelCfg.SuitID;
                    break;
                case ActorType.Monster:
                    desc.type = BattleResType.Monster;
                    break;
                case ActorType.Machine:
                    desc.type = BattleResType.Machine;
                    break;
                case ActorType.Item:
                    desc.type = BattleResType.Item;
                    break;
                case ActorType.InterActor:
                    if (modelCfg.SubType == (int)InterActorType.Art)
                        desc.type = BattleResType.InterActor;
                    else if (modelCfg.SubType == (int)InterActorType.Design)
                        desc.type = BattleResType.DesignModel;
                    else
                        LogProxy.LogErrorFormat("ActorType{0}, SubType:{1}设定之外的类型", modelCfg.Type);
                    break;
                default:
                    LogProxy.LogErrorFormat("ActorType{0}, 未指定BattleResType", modelCfg.Type);
                    break;
            }

            return desc;
        }

        /// <summary>
        /// 获取组件，如果没有则创建
        /// </summary>
        /// <param name="go"></param>
        /// <typeparam name="T"></typeparam>
        /// <returns></returns>
        public static T EnsureComponent<T>(GameObject go) where T : Component
        {
            if (null == go)
            {
                return null;
            }

            var component = go.GetComponent<T>();
            if (null == component)
            {
                component = go.AddComponent<T>();
            }

            return component;
        }

        /// <summary>
        /// 获取角色调试信息
        /// </summary>
        /// <param name="cfg"></param>
        /// <returns></returns>
        public static string GetActorDebugInfo(ActorCfg cfg)
        {
            if (null == cfg)
            {
                return "Actor(id=0)";
            }

            switch (cfg.Type)
            {
                case ActorType.Hero:
                    return $"英雄(id={cfg.ID})";
                case ActorType.Monster:
                    return $"怪物(id={cfg.ID})";
                case ActorType.SkillAgent:
                    switch ((SkillAgentType) cfg.SubType)
                    {
                        case SkillAgentType.Missile:
                            return $"子弹(id={cfg.ID})";
                        case SkillAgentType.Dynamic:
                            return $"动态技能代理(id={cfg.ID})";
                    }

                    return $"技能召唤物(id={cfg.ID})";
                case ActorType.BattleElement:
                    return $"战场元素(id={cfg.ID})";
                case ActorType.TriggerArea:
                    return $"区域触发(id={cfg.ID})";
                case ActorType.Obstacle:
                    return $"阻挡体(id={cfg.ID})";
                case ActorType.Machine:
                    return $"机关(id={cfg.ID})";
                default:
                    return $"未知元素(id={cfg.ID})";
            }
        }
        
        // 获取受击音效
        public static string GetHurtSound(DamageBoxCfg damageBoxCfg, HurtMaterialType hurtMaterialType)
        {
            if ((string)damageBoxCfg.hurtWeaponType == null)
                return null;
            TbUtil.TryGetCfg((string)damageBoxCfg.hurtWeaponType, out Dictionary<int, HurtMaterialConfig> weaponHurtCfg);
            if (weaponHurtCfg != null)
            {
                weaponHurtCfg.TryGetValue((int)hurtMaterialType, out var materialHurtCfg);
                if (materialHurtCfg != null && !string.IsNullOrEmpty(materialHurtCfg.HurtSound))
                {
                    return materialHurtCfg.HurtSound;
                }
            }
            return null;
        }
        
        /// <summary>
        /// 通过槽位ID计算槽位类型和索引
        /// </summary>
        /// <param name="slotID"></param>
        /// <param name="index"></param>
        /// <returns></returns>
        public static SkillSlotType GetSlotTypeAndIndex(int slotID, out int index)
        {
            var intType = slotID / BattleConst.SkillSlotSpace;
            index = slotID % BattleConst.SkillSlotSpace;
            var type = (SkillSlotType) intType;
            return type;
        }

        /// <summary>
        /// 通过type和index获取slotID
        /// </summary>
        /// <param name="slotType"></param>
        /// <param name="slotIndex"></param>
        /// <returns></returns>
        public static int GetSlotID(SkillSlotType slotType, int slotIndex)
        {
            var result = (int) slotType * BattleConst.SkillSlotSpace + slotIndex;
            return result;
        }

        /// <summary>
        ///  向skillSlotConfigs中添加一个技能
        /// demo：添加一个肉鸽被动，BattleUtil.AddSkillCfg(slotCfgs, 12001, SkillSlotType.Passive, SkillSourceType.Rogue)
        /// </summary>
        /// <param name="skillSlotConfigs">人物bornCfgs.skillSlots</param>
        /// <param name="skillID">技能ID</param>
        /// <param name="slotType">槽位类型</param>
        /// <param name="sourceType">来源</param>
        /// <param name="skillLevel">等级，默认1级</param>
        public static void AddSkillCfg(Dictionary<int, SkillSlotConfig> skillSlotConfigs, int skillID, SkillSlotType slotType, SkillSourceType sourceType, int skillLevel = 1)
        {
            if (skillSlotConfigs == null)
            {
                return;
            }
            // 优先尾部添加
            var maxIndex = GetSlotMaxIndex(skillSlotConfigs, slotType);
            var slotID = GetSlotID(slotType, maxIndex + 1);
            skillSlotConfigs.Add(slotID, new SkillSlotConfig()
            {
                ID = slotID,
                SlotType = slotType,
                SkillLevel = skillLevel,
                SkillID = skillID,
                SourceType = sourceType,
            });
        }

        /// <summary>
        /// 移除skillSlotConfigs中的一个技能
        /// demo：移除一个被动，BattleUtil.RemoveSkillCfg(slotCfgs, 12001, SkillSlotType.Passive)
        /// </summary>
        /// <param name="skillSlotConfigs">人物bornCfgs.skillSlots</param>
        /// <param name="skillID">技能ID</param>
        /// <param name="slotType">槽位类型</param>
        public static void RemoveSkillCfg(Dictionary<int, SkillSlotConfig> skillSlotConfigs, int skillID, SkillSlotType slotType)
        {
            if (skillSlotConfigs == null)
            {
                return;
            }
            
            int? slotID = null;
            foreach (var iter in skillSlotConfigs)
            {
                var slotCfg = iter.Value;
                if (slotCfg.SlotType == slotType && slotCfg.SkillID == skillID)
                {
                    // 优先尾部删除
                    if (slotID == null || slotCfg.ID > slotID.Value)
                    {
                        slotID = slotCfg.ID;
                    }
                }
            }

            if (slotID != null)
            {
                skillSlotConfigs.Remove(slotID.Value);
            }
        }
        
        /// <summary>
        /// 获取当前某种类型的Slot的最大索引
        /// </summary>
        /// <param name="skillSlotConfigs"></param>
        /// <param name="slotType"></param>
        /// <returns></returns>
        public static int GetSlotMaxIndex(Dictionary<int, SkillSlotConfig> skillSlotConfigs, SkillSlotType slotType)
        {
            if (slotType < 0)
            {
                LogProxy.LogError("BattleUtil.GetSlotMaxIndex 参数slotType不允许小于0");
                return 0;
            }
            
            if (skillSlotConfigs == null || skillSlotConfigs.Count <= 0)
            {
                return 0;
            }

            int index = 0;
            foreach (var kSkillSlotConfig in skillSlotConfigs)
            {
                var skillSlotConfig = kSkillSlotConfig.Value;
                if (skillSlotConfig.SlotType == slotType)
                {
                    GetSlotTypeAndIndex(skillSlotConfig.ID, out int slotIndex);
                    if (slotIndex > index)
                    {
                        index = slotIndex;
                    }
                }
            }

            return index;
        }
        
        /// <summary>
        /// 获取槽位调试信息
        /// </summary>
        /// <param name="slotID"></param>
        /// <returns></returns>
        public static string GetSlotDebugInfo(int slotID)
        {
            var type = GetSlotTypeAndIndex(slotID, out var index);
            return $"类型={type}, 索引={index}";
        }

        /// <summary>
        /// 获取两阵营间的关系
        /// </summary>
        /// <param name="typeA"></param>
        /// <param name="typeB"></param>
        /// <returns></returns>
        public static FactionRelationship GetFactionRelationShipByType(FactionType typeA, FactionType typeB)
        {
            if (TbUtil.TryGetCfg(typeA, out BattleFactionConfig configTypeA))
            {
                if (null != configTypeA.EnemyFaction)
                {
                    foreach (var factionType in configTypeA.EnemyFaction)
                    {
                        if (factionType == typeB)
                        {
                            return FactionRelationship.Enemy;
                        }
                    }
                }

                if (null != configTypeA.FriendlyFaction)
                {
                    foreach (var factionType in configTypeA.FriendlyFaction)
                    {
                        if (factionType == typeB)
                        {
                            return FactionRelationship.Friend;
                        }
                    }
                }
            }

            return FactionRelationship.Neutral;
        }

        /// <summary>
        ///  计算Tween值
        /// </summary>
        /// <param name="progress">一个从0到1的数字 ，不在这个区间强行截取</param>
        /// <param name="tweenEaseType">Tween类型</param>
        /// <returns></returns>
        public static float CalculateTweenValue(float progress, TweenEaseType tweenEaseType)
        {
            if (progress < 0)
            {
                return 0;
            }

            if (progress > 1)
            {
                return 1;
            }

            var result = progress;
            if (tweenEaseType == TweenEaseType.Liner)
            {
                result = progress;
            }
            else if (tweenEaseType == TweenEaseType.EaseInQuad)
            {
                result = (float) Math.Pow(progress, 0.5f);
            }
            else if (tweenEaseType == TweenEaseType.EaseOutQuad)
            {
                result = progress * progress;
            }
            else
            {
                LogProxy.LogErrorFormat("CalculateTweenValue不支持的枚举类型{0}", tweenEaseType);
            }

            return result;
        }

        /// <summary>
        /// 获得扇形范围内的Actor列表
        /// </summary>
        /// <param name="source">原Actor</param>
        /// <param name="rotateAngle">Actor的朝向与扇形朝向的夹角</param>
        /// <param name="fanColumnAngle">扇形夹角</param>
        /// <param name="radius">半径</param>
        /// <returns></returns>
        public static List<Actor> GetActorsInFanColumn(Actor source, float rotateAngle, float fanColumnAngle, float radius)
        {
            Vector3 eulerAngles = source.transform.eulerAngles;
            BoundingShape shape = new BoundingShape();
            shape.ShapeType = ShapeType.FanColumn;
            shape.Height = 0.1f;
            shape.Angle = fanColumnAngle;
            shape.Radius = radius;
            Vector3 rot = new Vector3(0, eulerAngles.y + rotateAngle, 0);
            X3Physics.CollisionTestNoGC(source.transform.position, Vector3.zero, rot, shape, false, X3LayerMask.ColliderTest, out var actors);
            return actors;
        }

        /// <summary>
        /// 目标Actor是否在扇形范围内
        /// </summary>
        /// <param name="source">原Actor</param>
        /// <param name="target">目标Actor</param>
        /// <param name="rotateAngle">Actor的朝向与扇形朝向的夹角</param>
        /// <param name="fanColumnAngle">扇形夹角</param>
        /// <param name="radius">半径</param>
        /// <returns></returns>
        public static bool IsTargetInFanColumn(Actor source, Actor target, float rotateAngle, float fanColumnAngle, float radius)
        {
            List<Actor> actors = GetActorsInFanColumn(source, rotateAngle, fanColumnAngle, radius);
            return actors.Contains(target);
        }

        /// <summary>
        /// 扇形范围内是否存在阻挡体
        /// </summary>
        /// <param name="source">原Actor</param>
        /// <param name="rotateAngle">Actor的朝向与扇形朝向的夹角</param>
        /// <param name="fanColumnAngle">扇形夹角</param>
        /// <param name="radius">半径</param>
        /// <returns></returns>
        public static bool IsObstacleInFanColumn(Actor source, float rotateAngle, float fanColumnAngle, float radius)
        {
            List<Actor> actors = GetActorsInFanColumn(source, rotateAngle, fanColumnAngle, radius);
            foreach (Actor actor in actors)
            {
                if (actor.config.Type == ActorType.Obstacle)
                {
                    return true;
                }
            }
            var actorDir = source.transform?.forward;
            var actorPos = source.transform?.position;
            if (actorDir == null || actorPos == null)
            {
                return false;
            }
            //求扇形的中线
            actorDir.Value.Normalize();
            var fanColumnDir = Quaternion.AngleAxis(rotateAngle, Vector3.up) * actorDir.Value;
            //求扇形的边线
            var fanColumnLine1 = Quaternion.AngleAxis(rotateAngle - fanColumnAngle, Vector3.up) * actorDir.Value;
            var fanColumnLine2 = Quaternion.AngleAxis(rotateAngle + fanColumnAngle, Vector3.up) * actorDir.Value;
            
            _cachePoints.Clear();
            _cachePoints.Add(actorPos.Value);
            _cachePoints.Add(fanColumnDir * radius + actorPos.Value);
            
            _cachePoints.Add(fanColumnLine1 * (radius / 2.0f) + actorPos.Value);
            _cachePoints.Add(fanColumnLine1 * radius  + actorPos.Value);
            
            _cachePoints.Add(fanColumnLine2 * (radius / 2.0f) + actorPos.Value);
            _cachePoints.Add(fanColumnLine2 * radius  + actorPos.Value);
            
#if UNITY_EDITOR
            Debug.DrawLine(actorPos.Value, _cachePoints[1], Color.red);
            Debug.DrawLine(actorPos.Value, _cachePoints[3], Color.red);
            Debug.DrawLine(actorPos.Value, _cachePoints[5], Color.red);
#endif
            
            foreach (var point in _cachePoints)
            {
                if (!IsInNavMesh(point))
                {
                    LogProxy.Log("扇形范围内是否存在阻挡体 point = " + point + " 在navmesh之外");
                    return true;
                }
            }
            return false;
        }

        /// <summary>
        /// 物理检测接口
        /// </summary>
        /// <param name="battle"></param>
        /// <param name="pos"></param>
        /// <param name="prevPos"></param>
        /// <param name="angleY">与z轴的夹角</param>
        /// <param name="shapeType">前临时保留仅仅为了支持 等于3的情况 todo后期干掉</param>
        /// <param name="shapeArg1"></param>
        /// <param name="shape">形状</param>
        /// <param name="factionType">阵营类型</param>
        /// <param name="sameFaction">是否取相同阵营，还是不同阵营</param>
        /// <param name="excludeSet">排除列表</param>
        /// <param name="isContinuousMode">是否连续</param>
        /// <param name="factionRelationShip">阵营关系，当此参数不为nil时，阵营判断不走老的sameFaction，走这个字段</param>
        /// <param name="bIncludeSelf">是自己的时候, 包括进来</param>
        /// <returns></returns>
        public static void PickAOETargets(Battle battle, ref List<Actor> targets, Vector3 pos, Vector3 prevPos, Vector3 euler, BoundingShape shape, Actor refSelf, bool sameFaction, List<Actor> excludeSet, bool isContinuousMode, List<CollisionDetectionInfo> actorCollisionInfos, List<FactionRelationship> factionRelationShips = null, bool bIncludeSelf = false, int? layerMask = null, FactionType? coverFactionType = null)
        {
            using (ProfilerDefine.UtilPickAOETargetPMarker.Auto())
            {
                targets.Clear();
                int mask = layerMask ?? X3LayerMask.HurtTest;
                var collisionNum = X3Physics.CollisionTestNoGC(pos, prevPos, euler, shape, isContinuousMode, out var readOnlyCollisionInfo, mask);
                if (collisionNum <= 0)
                {
                    return;
                }

                bool needCollisionInfo = actorCollisionInfos != null;
                if (needCollisionInfo)
                    actorCollisionInfos.Clear();
                bool needExclude = excludeSet != null;
                var actors = targets;
                for (int i = 0; i < collisionNum; i++)
                {
                    if (needCollisionInfo)
                        actorCollisionInfos.Add(readOnlyCollisionInfo[i]);
                    var actor = readOnlyCollisionInfo[i].hitActor;
                    if (actor == null) // actor可能为空，例如地面
                        continue;
                    if (needExclude && excludeSet.Contains(actor))
                        continue;
                    if (actors.Contains(actor))
                        continue;
                    actors.Add(actor);
                }

                // 阵营立场
                var factionType = coverFactionType ?? refSelf.factionType;
                
                // 阵营筛选
                for (var i = actors.Count - 1; i >= 0; i--)
                {
                    var actor = actors[i];
                    if (null != factionRelationShips)
                    {
                        bool b = false;
                        foreach (var factionRelationship in factionRelationShips)
                        {
                            // DONE: 该actor是自己 && 筛选阵营里含友方 则是否包含自己 听配置bIncludeSelf
                            if (refSelf == actor && factionRelationship == FactionRelationship.Friend)
                            {
                                b = bIncludeSelf;
                                break;
                            }

                            // 相同阵营则包括.
                            if (GetFactionRelationShipByType(factionType, actor.factionType) == factionRelationship)
                            {
                                b = true;
                                break;
                            }
                        }

                        if (!b)
                        {
                            actors.Remove(actor);
                        }
                    }
                    else if (sameFaction)
                    {
                        if (actor.factionType != factionType)
                        {
                            actors.Remove(actor);
                        }
                    }
                    else
                    {
                        if (actor.factionType == factionType)
                        {
                            actors.Remove(actor);
                        }
                    }
                }
            }
        }

        /// <summary>
        /// 获取角色
        /// </summary>
        /// <param name="type"></param>
        /// <param name="selfActor"></param>
        /// <returns></returns>
        public static Actor GetActor(ChooseActorType type, Actor selfActor = null)
        {
            switch (type)
            {
                case ChooseActorType.Self:
                    return selfActor;
                case ChooseActorType.Girl:
                    return Battle.Instance.actorMgr.girl;
                case ChooseActorType.Boy:
                    return Battle.Instance.actorMgr.boy;
                case ChooseActorType.GirlLockTarget:
                    var girl = Battle.Instance.actorMgr.girl;
                    return girl?.targetSelector.GetTarget();
                case ChooseActorType.BoyLockTarget:
                    var boy = Battle.Instance.actorMgr.boy;
                    return boy?.targetSelector.GetTarget();
                default:
                    return null;
            }
        }

        /// <summary>
        /// 获取离自己最近的敌方单位
        /// </summary>
        /// <param name="oneself"></param>
        /// <param name="maxDistance">最大距离</param>
        /// <param name="considerLockIgnore">是否考虑不可锁定标签</param>
        /// <returns></returns>
        public static Actor GetNearestEnemy(Actor oneself, float maxDistance = -1, bool considerLockIgnore = false)
        {
            if (null == oneself)
            {
                return null;
            }

            var sqrMaxDistance = -1.0f;
            if (maxDistance >= 0)
            {
                sqrMaxDistance = maxDistance * maxDistance;
            }

            float disSqrMag = 0;
            Actor nearestActor = null;
            foreach (var item in Battle.Instance.actorMgr.actors)
            {
                if (item.isDead || oneself == item || item.type != ActorType.Hero && item.type != ActorType.Monster && item.type != ActorType.Machine || //XTBUG-22232 临时：策划确认，暂时只有Hero、Monster和Machine类型参与筛选，后续待整理
                    oneself.GetFactionRelationShip(item) != FactionRelationship.Enemy) continue;

                if (considerLockIgnore)
                {
                    var ignoreSelect = item.stateTag.IsActive(ActorStateTagType.LockIgnore);
                    if (ignoreSelect)
                    {
                        continue;
                    }
                }

                var sqrMag = (oneself.transform.position - item.transform.position).sqrMagnitude;

                if (sqrMaxDistance > 0 && sqrMag > sqrMaxDistance)
                {
                    continue;
                }

                if (null != nearestActor && !(sqrMag < disSqrMag)) continue;

                disSqrMag = sqrMag;
                nearestActor = item;
            }

            return nearestActor;
        }

        /// <summary>
        /// 获取Actor, 便捷策划配置的获取Actor的接口.
        /// </summary>
        /// <param name="idType"> 当id==-1时为女主, 当id==-2时为男主. </param>
        /// <returns> Actor </returns>
        public static Actor GetActorByIDType(int idType)
        {
            if (idType == 0 || idType < (int) ActorIDType.Boy)
                return null;

            switch (idType)
            {
                case (int) ActorIDType.Girl:
                    return Battle.Instance.actorMgr.girl;
                case (int) ActorIDType.Boy:
                    return Battle.Instance.actorMgr.boy;
                default:
                    return Battle.Instance.actorMgr.GetActor(idType);
            }
        }

        /// <summary>
        /// 获取Hero类型资源的LOD值
        /// </summary>
        /// <param name="heroType"></param>
        /// <returns></returns>
        public static int GetHeroLOD(HeroType heroType)
        {
            var lodUseType = BattleEnv.GetHeroLODUseType(heroType);
            switch (lodUseType)
            {
                case LODUseType.LD:
                case LODUseType.LDHD:
                    return BattleCharacterMgr.LOD_LD;
                default: return BattleCharacterMgr.LOD_HD;
            }
        }

        /// <summary>
        /// 获取描述信息
        /// </summary>
        /// <param name="stateTypes"></param>
        /// <typeparam name="T"></typeparam>
        /// <returns></returns>
        public static string GetArrayDesc<T>(T[] stateTypes)
        {
            if (stateTypes == null)
            {
                return null;
            }

            _tempSB.Clear();
            for (int i = 0; i < stateTypes.Length; i++)
            {
                if (stateTypes[i] == null)
                    continue;
                if (i != 0)
                {
                    _tempSB.Append(",");
                }

                _tempSB.Append(stateTypes[i].ToString());
            }

            return _tempSB.ToString();
        }

        /// <summary>
        /// 比较大小
        /// </summary>
        /// <param name="value">值</param>
        /// <param name="refValue">参考值</param>
        /// <param name="compareOperator">比较操作符</param>
        /// <returns>返回比较结果</returns>
        public static bool IsCompareSize(float value, float refValue, ECompareOperator compareOperator)
        {
            switch (compareOperator)
            {
                case ECompareOperator.EqualTo:
                    return value == refValue;
                case ECompareOperator.NotEqual:
                    return value != refValue;
                case ECompareOperator.GreaterThan:
                    return value > refValue;
                case ECompareOperator.LessThan:
                    return value < refValue;
                case ECompareOperator.GreaterOrEqualTo:
                    return value >= refValue;
                case ECompareOperator.LessOrEqualTo:
                    return value <= refValue;
                default: return false;
            }
        }
        
        public static bool IsCompareSize(int sourceValue, int targetValue, ECompareOperator compareOperator)
        {
            switch (compareOperator)
            {
                case ECompareOperator.EqualTo:
                    return sourceValue == targetValue;
                case ECompareOperator.NotEqual:
                    return sourceValue != targetValue;
                case ECompareOperator.GreaterThan:
                    return sourceValue > targetValue;
                case ECompareOperator.LessThan:
                    return sourceValue < targetValue;
                case ECompareOperator.GreaterOrEqualTo:
                    return sourceValue >= targetValue;
                case ECompareOperator.LessOrEqualTo:
                    return sourceValue <= targetValue;
                default: return false;
            }
        }

        /// <summary>
        /// 比较大小
        /// </summary>
        /// <param name="value">值</param>
        /// <param name="refValue">参考值</param>
        /// <param name="compareOperator">比较操作符</param>
        /// <returns>返回比较结果</returns>
        public static bool IsCompareSize(float value, float refValue, ECoreCompareOperator compareOperator)
        {
            switch (compareOperator)
            {
                case ECoreCompareOperator.MaxEqualTo:
                case ECoreCompareOperator.EqualTo:
                    return value == refValue;
                case ECoreCompareOperator.NotEqual:
                    return value != refValue;
                case ECoreCompareOperator.GreaterThan:
                    return value > refValue;
                case ECoreCompareOperator.LessThan:
                    return value < refValue;
                case ECoreCompareOperator.GreaterOrEqualTo:
                    return value >= refValue;
                case ECoreCompareOperator.LessOrEqualTo:
                    return value <= refValue;
                default: return false;
            }
        }

        /// <summary>
        /// 计算点
        /// </summary>
        /// <param name="point">点</param>
        /// <param name="forward">朝向</param>
        /// <param name="offsetPos">位置偏移</param>
        /// <param name="offsetEulerAnglesY">Y朝向偏移</param>
        /// <returns></returns>
        public static Vector3 CalcPosition(Vector3 point, Vector3 forward, Vector3 offsetPos, float offsetEulerAnglesY)
        {
            if (offsetPos == Vector3.zero) return point;

            var offset = Vector3.zero;
            var rotation = Quaternion.LookRotation(forward);
            var up = rotation * Vector3.up;
            if (offsetEulerAnglesY != 0) rotation = Quaternion.LookRotation(Quaternion.AngleAxis(offsetEulerAnglesY, up) * forward);
            var right = rotation * Vector3.right;

            offset += forward * offsetPos.z;
            offset += right * offsetPos.x;
            offset += up * offsetPos.y;
            return point + offset;
        }

        /// <summary>
        /// 获取武器部件列表
        /// </summary>
        /// <param name="weaponSkinID"></param>
        /// <returns></returns>
        public static string[] GetWeaponParts(int weaponSkinID)
        {
            return BattleEnv.LuaBridge.GetWeaponPartIDs(weaponSkinID);
        }

        /// <summary>
        /// 获取SkillLevelCfg中的配置项
        /// </summary>
        /// <param name="skillLevelCfg"></param>
        /// <param name="mathParamType"></param>
        /// <returns></returns>
        public static float[] GetSkillMathParam(SkillLevelCfg skillLevelCfg, MathParamType mathParamType)
        {
            if (skillLevelCfg == null)
                return null;
            switch (mathParamType)
            {
                case MathParamType.MathParam1: return skillLevelCfg.MathParam1;
                case MathParamType.MathParam2: return skillLevelCfg.MathParam2;
                case MathParamType.MathParam3: return skillLevelCfg.MathParam3;
                case MathParamType.MathParam4: return skillLevelCfg.MathParam4;
                case MathParamType.MathParam5: return skillLevelCfg.MathParam5;
                case MathParamType.MathParam6: return skillLevelCfg.MathParam6;
                case MathParamType.MathParam7: return skillLevelCfg.MathParam7;
                case MathParamType.MathParam8: return skillLevelCfg.MathParam8;
                case MathParamType.MathParam9: return skillLevelCfg.MathParam9;
                case MathParamType.MathParam10: return skillLevelCfg.MathParam10;
                default: return null;
            }
        }

        /// <summary>
        /// 获取BuffLevelConfig中的配置项
        /// </summary>
        /// <param name="buffLevelConfig"></param>
        /// <param name="mathParamType"></param>
        /// <returns></returns>
        public static float[] GetBuffMathParam(BuffLevelConfig buffLevelConfig, MathParamType mathParamType)
        {
            if (buffLevelConfig == null)
                return null;
            switch (mathParamType)
            {
                case MathParamType.MathParam1: return buffLevelConfig.MathParam1;
                case MathParamType.MathParam2: return buffLevelConfig.MathParam2;
                case MathParamType.MathParam3: return buffLevelConfig.MathParam3;
                case MathParamType.MathParam4: return buffLevelConfig.MathParam4;
                case MathParamType.MathParam5: return buffLevelConfig.MathParam5;
                case MathParamType.MathParam6: return buffLevelConfig.MathParam6;
                case MathParamType.MathParam7: return buffLevelConfig.MathParam7;
                case MathParamType.MathParam8: return buffLevelConfig.MathParam8;
                case MathParamType.MathParam9: return buffLevelConfig.MathParam9;
                case MathParamType.MathParam10: return buffLevelConfig.MathParam10;
                case MathParamType.MathParam11: return buffLevelConfig.MathParam11;
                case MathParamType.MathParam12: return buffLevelConfig.MathParam12;
                case MathParamType.MathParam13: return buffLevelConfig.MathParam13;
                case MathParamType.MathParam14: return buffLevelConfig.MathParam14;
                case MathParamType.MathParam15: return buffLevelConfig.MathParam15;
                case MathParamType.MathParam16: return buffLevelConfig.MathParam16;
                case MathParamType.MathParam17: return buffLevelConfig.MathParam17;
                case MathParamType.MathParam18: return buffLevelConfig.MathParam18;
                case MathParamType.MathParam19: return buffLevelConfig.MathParam19;
                case MathParamType.MathParam20: return buffLevelConfig.MathParam20;
                default:
                    LogProxy.LogError($"GetMathParam：配置错误，{mathParamType}");
                    return Array.Empty<float>();
            }
        }
        
        /// <summary>
        /// 计算消耗能量
        /// </summary>
        public static float GetSlotUltraEnergyValue(SkillSlot skillSlot)
        {
            SlotEnergyCoster slotEnergyCoster = null;
            if (skillSlot.energyCoster1.energyType == AttrType.UltraEnergy)
            {
                slotEnergyCoster = skillSlot.energyCoster1;
            }
            else if(skillSlot.energyCoster2.energyType == AttrType.UltraEnergy)
            {
                slotEnergyCoster = skillSlot.energyCoster2;
            }
            else if(skillSlot.energyCoster3.energyType == AttrType.UltraEnergy)
            {
                slotEnergyCoster = skillSlot.energyCoster3;
            }

            if (slotEnergyCoster == null)
            {
                return 0;
            }
            float attrValue = skillSlot.skill.actor.attributeOwner.GetAttrValue(slotEnergyCoster.energyType);
            float totalValue = attrValue * slotEnergyCoster.energyRatio * 0.001f + slotEnergyCoster.energyValue;
            if (totalValue <= 0)
            {
                return 0;
            }
            return attrValue / totalValue;
        }

        /// <summary>
        /// 计算消耗能量
        /// </summary>
        public static float CalCostEnergy(SkillSlot slot)
        {
            Actor actor = slot.skill.actor;
            if (actor.attributeOwner == null)
            {
                return 0f;
            }

            SlotEnergyCoster slotEnergyCoster = null;
            if (slot.energyCoster1.energyType == AttrType.SkillEnergy)
            {
                slotEnergyCoster = slot.energyCoster1;
            }
            else if (slot.energyCoster2.energyType == AttrType.SkillEnergy)
            {
                slotEnergyCoster = slot.energyCoster2;
            }
            else if (slot.energyCoster3.energyType == AttrType.SkillEnergy)
            {
                slotEnergyCoster = slot.energyCoster3;
            }

            if (slotEnergyCoster == null)
            {
                return 0;
            }

            var attrValue = actor.attributeOwner.GetAttrValue(slotEnergyCoster.energyType);
            return (attrValue * slotEnergyCoster.energyRatio * 0.001f + slotEnergyCoster.energyValue) * 0.01f;
        }

        /// <summary>
        /// 计算动态属性变化值
        /// </summary>
        /// <returns></returns>
        public static float CalDynamicAttr(float curVal, float basicCur, float basicInit, float basicFinal, float effectInit, float effectFinal)
        {
            var ratio = (curVal - basicCur * basicInit) / (basicCur * basicFinal - basicCur * basicInit);
            return (effectFinal - effectInit) * ratio + effectInit;
        }

        /// <summary>
        /// 是否含有某种伤害盒类型
        /// </summary>
        /// <param name="flag"></param>
        /// <param name="type"></param>
        /// <returns></returns>
        public static bool ContainDamageBoxType(DamageBoxTypeFlag flag, DamageBoxType type)
        {
            var result = (int) flag & (1 << (int) type);
            return result > 0;
        }

        /// <summary>
        /// 是否含有某种技能类型
        /// </summary>
        /// <param name="flag"></param>
        /// <param name="type"></param>
        /// <returns></returns>
        public static bool ContainSkillType(SkillTypeFlag flag, SkillType type)
        {
            var result = (int) flag & (1 << (int) type);
            return result > 0;
        }
        
        // 是否含有某种方向类型
        public static bool ContainQTEDirection(QTEDirectionFlag flag, QTEDirection type)
        {
            var result = (int) flag & (1 << (int) type);
            return result > 0;
        }

        /// <summary>
        /// 是否含有某种playerBtnType
        /// </summary>
        /// <param name="flag"></param>
        /// <param name="type"></param>
        /// <returns></returns>
        public static bool ContainPlayerBtnType(PlayerBtnTypeFlag flag, PlayerBtnType type)
        {
            var result = (int) flag & (1 << ((int) type + 1));
            return result > 0;
        }

        /// <summary>
        /// 是否含有PlayerBtnStateType
        /// </summary>
        /// <param name="flag"></param>
        /// <param name="type"></param>
        /// <returns></returns>
        public static bool ContainBtnStateType(BtnStateInputFlag flag, PlayerBtnStateType type)
        {
            var result = (int) flag & (1 << (int) type);
            return result > 0;
        }

        /// <summary>
        /// 是否是套装Id
        /// </summary>
        /// <param name="id"> 被检测Id </param>
        /// <returns>  </returns>
        public static bool IsSuit(int id)
        {
            return IsGirlSuit(id) || IsBoySuit(id);
        }

        /// <summary>
        /// 是否是女主套装Id
        /// </summary>
        /// <param name="suitId"> 被检测的套装Id </param>
        /// <returns>  </returns>
        public static bool IsGirlSuit(int suitId)
        {
            return TbUtil.HasCfg<FemaleSuitConfig>(suitId);
        }

        /// <summary>
        /// 是否是男主套装Id
        /// </summary>
        /// <param name="suitId"> 被检测的套装Id </param>
        /// <returns></returns>
        public static bool IsBoySuit(int suitId)
        {
            return TbUtil.HasCfg<MaleSuitConfig>(suitId);
        }

        /// <summary>
        /// 获取子对象，如果没有则创建
        /// </summary>
        /// <param name="target"></param>
        /// <param name="childName"></param>
        /// <returns></returns>
        public static Transform EnsureChild(Transform target, string childName, Vector3? localPos = null)
        {
            if (null == target)
            {
                return new GameObject(childName).transform;
            }

            var child = target.Find(childName);
            if (null != child)
            {
                return child;
            }

            child = new GameObject(childName).transform;
            child.parent = target;
            child.localPosition = localPos ?? Vector3.zero;
            child.localEulerAngles = Vector3.zero;
            child.localScale = Vector3.one;
            return child;
        }

        /// <summary>
        /// 读取HitParamConfig中的数据
        /// </summary>
        /// <param name="hitParamConfig"></param>
        /// <param name="hitParamRatioType"></param>
        /// <returns></returns>
        /// <exception cref="ArgumentOutOfRangeException"></exception>
        public static float GetHitParamRatio(HitParamConfig hitParamConfig, HitParamRatioType hitParamRatioType)
        {
            float result = 0f;
            if (hitParamConfig == null)
            {
                return result;
            }

            switch (hitParamRatioType)
            {
                case HitParamRatioType.AttackRatio:
                    result = hitParamConfig.TargetDamageAtkRatio;
                    break;
                default:
                    throw new ArgumentOutOfRangeException(nameof(hitParamRatioType), hitParamRatioType, null);
            }

            return result;
        }

        /// <summary>
        /// 两点连线的碰撞点
        /// </summary>
        /// <param name="startPos"></param>
        /// <param name="targetPos"></param>
        /// <returns></returns>
        public static Vector3 RayCastByColliderTest(Vector3 startPos, Vector3 targetPos)
        {
            Vector3? result = null;
            var offsetPos = targetPos - startPos;
            int collisionCount = X3Physics.RayCast(startPos, offsetPos, out var collisionInfos, X3LayerMask.ColliderTest, offsetPos.magnitude);
            if (collisionInfos != null)
            {
                for (int i = 0; i < collisionCount; i++)
                {
                    if (collisionInfos[i].tag != ColliderTag.AirWall) continue;
                    if (!(collisionInfos[i] is CollisionDetectionHitInfo collisionDetectionHitInfo)) continue;
                    if (result == null || ((Vector3)collisionDetectionHitInfo.hitInfo.point - startPos).sqrMagnitude < (result.Value - startPos).sqrMagnitude)
                    {
                        result = collisionDetectionHitInfo.hitInfo.point;
                    }
                }
            }

            if (result == null)
            {
                result = targetPos;
            }

            return result.Value;
        }

        public static bool IsFindAirWall(Vector3 startPos, Vector3 dir, float distance)
        {
            int collisionCount = X3Physics.RayCast(startPos, dir, out var collisionInfos, 1 << X3Layer.ActorCollider, distance);
            if (collisionInfos != null)
            {
                for (int i = 0; i < collisionCount; i++)
                {
                    if (collisionInfos[i].tag == ColliderTag.AirWall)
                    {
                        return true;
                    }
                }
            }

            return false;
        }

        public static GlobalBlackboard GetBattleGlobalBlackboard()
        {
            if (!Application.isPlaying)
            {
                return GlobalBlackboard.Find("Battle");
            }

            return Battle.Instance.globalBlackboard.GetGlobalBlackboard();
        }

        /// <summary>
        /// 过渡方法
        /// </summary>
        /// <param name="operation"></param>
        /// <returns></returns>
        public static ECompareOperator OperatorToCompareOperator(Operation operation)
        {
            ECompareOperator compareOperation = ECompareOperator.EqualTo;
            switch (operation)
            {
                case Operation.EqualTo:
                    compareOperation = ECompareOperator.EqualTo;
                    break;
                case Operation.NotEqualTo:
                    compareOperation = ECompareOperator.NotEqual;
                    break;
                case Operation.GreaterThan:
                    compareOperation = ECompareOperator.GreaterThan;
                    break;
                case Operation.LessThan:
                    compareOperation = ECompareOperator.LessThan;
                    break;
                case Operation.GreaterThanOrEqualTo:
                    compareOperation = ECompareOperator.GreaterOrEqualTo;
                    break;
                case Operation.LessThanOrEqualTo:
                    compareOperation = ECompareOperator.LessOrEqualTo;
                    break;
            }
            return compareOperation;
        }

        /// <summary>
        /// 比较两角色的距离
        /// </summary>
        /// <param name="distance"></param>
        /// <param name="actor1"></param>
        /// <param name="actor2"></param>
        /// <param name="calcActor1Radius"></param>
        /// <param name="calcActor2Radius"></param>
        /// <param name="operation"></param>
        /// <returns></returns>
        public static bool CompareActorDistance(float distance, Actor actor1, Actor actor2, bool calcActor1Radius, bool calcActor2Radius, ECompareOperator operation)
        {
            if (actor1 == null || actor2 == null)
            {
                return false;
            }
            CalculateActorsRadius(actor1, actor2, out float radius1, out float radius2);
            var dis = distance;
            if (calcActor1Radius)
            {
                dis += radius1;
            }

            if (calcActor2Radius)
            {
                dis += radius2;
            }

            dis *= dis;
            var sqrDis = (actor2.transform.position - actor1.transform.position).sqrMagnitude;
            switch (operation)
            {
                case ECompareOperator.EqualTo:
                    return sqrDis == dis;
                case ECompareOperator.LessThan:
                    return sqrDis < dis;
                case ECompareOperator.LessOrEqualTo:
                    return sqrDis <= dis;
                case ECompareOperator.NotEqual:
                    return sqrDis != dis;
                case ECompareOperator.GreaterOrEqualTo:
                    return sqrDis >= dis;
                case ECompareOperator.GreaterThan:
                    return sqrDis > dis;
            }

            return true;
        }

        /// <summary>
        /// 预警特效数据转换
        /// </summary>
        public static WarnFxCfg ConvertWarnFxCfg(WarnEffectData warnEffectData)
        {
            var warnFxCfg = new WarnFxCfg();
            warnFxCfg.fxID = warnEffectData.fxID; //固定ID
            warnFxCfg.isFollow = warnEffectData.ifFollow;

            switch (warnEffectData.warnEffectType)
            {
                case WarnEffectType.Shine:
                    warnFxCfg.type = WarnType.Shine;
                    break;
                case WarnEffectType.Lock:
                    warnFxCfg.type = WarnType.Lock;
                    warnFxCfg.targetType = warnEffectData.targetType;
                    break;
                case WarnEffectType.Ray:
                    warnFxCfg.type = WarnType.Ray;
                    warnFxCfg.targetType = warnEffectData.targetType;
                    warnFxCfg.duration = warnEffectData.rayWarnData.duration;
                    warnFxCfg.pos = warnEffectData.rayWarnData.offsetPos;
                    warnFxCfg.angle = warnEffectData.rayWarnData.angle;
                    break;
                case WarnEffectType.Circle:
                    warnFxCfg.type = WarnType.Circle;
                    warnFxCfg.targetType = warnEffectData.targetType;
                    warnFxCfg.duration = warnEffectData.circleWarnData.duration;
                    warnFxCfg.radius = warnEffectData.circleWarnData.radius;
                    warnFxCfg.pos = warnEffectData.circleWarnData.offsetPos;
                    break;
                case WarnEffectType.Sector:
                    warnFxCfg.type = WarnType.Sector;
                    warnFxCfg.targetType = warnEffectData.targetType;
                    warnFxCfg.duration = warnEffectData.sectorWarnData.duration;
                    warnFxCfg.radius = warnEffectData.sectorWarnData.radius;
                    warnFxCfg.pos = warnEffectData.sectorWarnData.offsetPos;
                    warnFxCfg.angle = new Vector3(0, warnEffectData.sectorWarnData.eulerAngleY, 0);
                    warnFxCfg.centralAngle = warnEffectData.sectorWarnData.centralAngle;
                    break;
                case WarnEffectType.Rectangle:
                    warnFxCfg.type = WarnType.Rectangle;
                    warnFxCfg.targetType = warnEffectData.targetType;
                    warnFxCfg.duration = warnEffectData.rectangleWarnData.duration;
                    warnFxCfg.length = warnEffectData.rectangleWarnData.length;
                    warnFxCfg.width = warnEffectData.rectangleWarnData.width;
                    warnFxCfg.pos = warnEffectData.rectangleWarnData.offsetPos;
                    warnFxCfg.angle = new Vector3(0, warnEffectData.rectangleWarnData.eulerAngleY, 0);
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }

            return warnFxCfg;
        }

        /// <summary>
        /// 获取talkAI的路径
        /// </summary>
        /// <param name="isMonster"></param>
        /// <param name="talkFlowName"></param>
        /// <returns></returns>
        public static List<string> GetTalkFlowPaths(int levelID, bool isMonster, string talkFlowName)
        {
            List<string> talkFlowPaths = new List<string>();

            if (!TbUtil.battleLevelConfigs.TryGetValue(levelID, out var levelConfig))
            {
                LogProxy.LogErrorFormat("关卡 levelID：{0} 不存在", levelID);
                return talkFlowPaths;
            }

            BattleResMgr.Instance.TryInit();
            var stageConfig = TbUtil.GetCfg<StageConfig>(levelConfig.StageID);

            if (stageConfig == null)
            {
                LogProxy.LogErrorFormat("关卡 StageID：{0} 不存在", levelConfig.StageID);
                return talkFlowPaths;
            }

            if (isMonster)
            {
                talkFlowPaths.Add(talkFlowName);
            }
            else
            {
                talkFlowPaths.Add($"{talkFlowName}/Level_{stageConfig.ID}");
                SpawnPointConfig[] spawnPointConfigs = stageConfig.SpawnPoints;
                MonsterCfg curMonsterCfg = null;
                foreach (SpawnPointConfig spawnPointConfig in spawnPointConfigs)
                {
                    TbUtil.TryGetCfg(spawnPointConfig.ConfigID, out MonsterCfg monsterCfg);
                    if (monsterCfg == null)
                    {
                        continue;
                    }

                    if (curMonsterCfg == null)
                    {
                        curMonsterCfg = monsterCfg;
                    }
                    else
                    {
                        if (curMonsterCfg.SubType < monsterCfg.SubType)
                        {
                            curMonsterCfg = monsterCfg;
                        }
                    }
                }

                if (curMonsterCfg != null)
                {
                    talkFlowPaths.Add($"{talkFlowName}/Monster_{curMonsterCfg.ID}");
                }
            }

            return talkFlowPaths;
        }

        /// <summary>
        /// 左右互换
        /// </summary>
        public static void Swap<T>(ref T a, ref T b)
        {
            T tmp = a;
            a = b;
            b = tmp;
        }

        /// <summary>
        /// 获取系统内存大小类型
        /// </summary>
        public static int GetMemorySizeLevel()
        {
            var level = PlayerPrefs.GetInt("SettingMemorySizeLevel", 0);
            return level;
        }

        /// <summary>
        /// string拼接，外部长期持有，使用此接口
        /// </summary>
        /// <returns></returns>
        public static string StrConcat(string str0, string str1)
        {
            string result;
            if (null == str0) str0 = string.Empty;
            if (null == str1) str1 = string.Empty;

            if (zstring.isInit)
            {
                using (zstring.Block())
                {
                    var temp = (zstring) str0 + str1;
                    result = temp.Intern();
                }  
            }
            else
            {
                result = string.Concat(str0, str1);
            }
            return result;
        }

        /// <summary>
        /// string拼接，外部长期持有，使用此接口
        /// </summary>
        /// <returns></returns>
        public static string StrConcat(string str0, string str1, string str2)
        {
            string result;
            if (null == str0) str0 = string.Empty;
            if (null == str1) str1 = string.Empty;
            if (null == str2) str2 = string.Empty;
            
            if (zstring.isInit)
            {
                using (zstring.Block())
                {
                    var temp = (zstring) str0 + str1 + str2;
                    result = temp.Intern();
                }
            }
            else
            {
                result = string.Concat(str0, str1, str2);
            }

            return result;
        }

        /// <summary>
        /// string拼接，外部长期持有，使用此接口
        /// </summary>
        /// <returns></returns>
        public static string StrConcat(string str0, string str1, string str2, string str3)
        {
            string result;
            if (null == str0) str0 = string.Empty;
            if (null == str1) str1 = string.Empty;
            if (null == str2) str2 = string.Empty;
            if (null == str3) str3 = string.Empty;
            
            if (zstring.isInit)
            {
                using (zstring.Block())
                {
                    var temp = (zstring) str0 + str1 + str2 + str3;
                    result = temp.Intern();
                }
            }
            else
            {
                result = string.Concat(str0, str1, str2, str3);
            }
            
            return result;
        }

        /// <summary>
        /// 临时string拼接，用完就丢，使用此接口
        /// </summary>
        /// <returns></returns>
        public static string StrConcatVolatile(string str0, string str1)
        {
            string result;
            if (null == str0) str0 = string.Empty;
            if (null == str1) str1 = string.Empty;
            
            if (zstring.isInit)
            {
                using (zstring.Block())
                {
                    result = (zstring) str0 + str1;
                }
            }
            else
            {
                result = string.Concat(str0, str1);
            }

            return result;
        }

        /// <summary>
        /// 临时string拼接，用完就丢，使用此接口
        /// </summary>
        /// <returns></returns>
        public static string StrConcatVolatile(string str0, string str1, string str2)
        {
            string result;
            if (null == str0) str0 = string.Empty;
            if (null == str1) str1 = string.Empty;
            if (null == str2) str2 = string.Empty;
            
            if (zstring.isInit)
            {
                using (zstring.Block())
                {
                    result = (zstring) str0 + str1 + str2;
                }
            }
            else
            {
                result = string.Concat(str0, str1, str2);
            }

            return result;
        }

        /// <summary>
        /// 临时string拼接，用完就丢，使用此接口
        /// </summary>
        /// <returns></returns>
        public static string StrConcatVolatile(string str0, string str1, string str2, string str3)
        {
            string result;
            if (null == str0) str0 = string.Empty;
            if (null == str1) str1 = string.Empty;
            if (null == str2) str2 = string.Empty;
            if (null == str3) str3 = string.Empty;
            
            if (zstring.isInit)
            {
                using (zstring.Block())
                {
                    result = (zstring) str0 + str1 + str2 + str3;
                } 
            }
            else
            {
                result = string.Concat(str0, str1, str2, str3);
            }
            
            return result;
        }

        /// <summary>
        /// 尝试调用，非阻断
        /// </summary>
        /// <param name="action"></param>
        public static void TryInvoke(Action action)
        {
            try
            {
                action?.Invoke();
            }
            catch (Exception e)
            {
                LogProxy.LogError(e);
            }
        }

        /// <summary>
        /// 尝试调用，非阻断
        /// </summary>
        /// <param name="action"></param>
        public static void TryInvoke<T>(Action<T> action, T arg)
        {
            try
            {
                action?.Invoke(arg);
            }
            catch (Exception e)
            {
                LogProxy.LogError(e);
            }
        }

        /// <summary>
        /// 获取当前武器逻辑配置
        /// </summary>
        /// <returns></returns>
        public static WeaponLogicConfig GetCurrentWeaponLogicConfig()
        {
            if (Battle.Instance == null)
            {
                return null;
            }

            var weaponSkinConfig = TbUtil.GetWeaponSkinConfig(Battle.Instance.arg.girlWeaponID);
            return weaponSkinConfig != null ? TbUtil.GetWeaponLogicConfig(weaponSkinConfig.WeaponLogicID) : null;
        }

        /// <summary>
        /// 卸载 峻峻 预缓存时持有的引用
        /// </summary>
        /// <param name="relativePath"></param>
        /// <param name="type"></param>
        public static void ReleasePreloadRef(string relativePath, BattleResType type)
        {
            if (BattleEnv.StartupArg == null || !Application.isPlaying)
                return;
			if(type == BattleResType.Hero)
				return;
            if (string.IsNullOrEmpty(relativePath))
            {
                LogProxy.LogErrorFormat("资源相对路径为空，无法unloadAsset，类型：{0}", type);
                return;
            }
            var fullPath = GetResPath(relativePath, type);
            BattleEnv.LuaBridge.UnloadAsset(BattleEnv.StartupArg.levelID.ToString(), fullPath);
        }

        /// <summary>
        /// 获取两单位的距离,（坐标距离减两单位半径）
        /// </summary>
        /// <param name="distance"></param>
        /// <param name="actor1"></param>
        /// <param name="actor2"></param>
        /// <param name="calcActor1Radius"></param>
        /// <param name="calcActor2Radius"></param>
        /// <param name="operation"></param>
        /// <returns></returns>
        public static float GetActorDistance(Actor actor1, Actor actor2)
        {
            if (actor1 == null || actor2 == null)
            {
                LogProxy.LogError($"GetActorDistance! actor is null!");
                return 0;
            }
            CalculateActorsRadius(actor1, actor2, out float radius1, out float radius2);
            float dis = (actor2.transform.position - actor1.transform.position).magnitude - radius1 - radius2;
            return dis;
        }

        public static void CalculateActorsRadius(Actor actor1, Actor actor2, out float radius1, out float radius2)
        {
            if (actor1.model.modelInfo.isSpecialBody && !actor2.model.modelInfo.isSpecialBody)
            {
                radius2 = actor2.radius;
                radius1 = _CalculateActorsRadius(actor2.collider.characterMovement, Vector3.zero, actor2.transform.position, actor1);
                if (radius1 < 0)
                {
                    radius1 = actor1.radius;
                }
            }
            else if (!actor1.model.modelInfo.isSpecialBody && actor2.model.modelInfo.isSpecialBody)
            {
                radius1 = actor1.radius;
                radius2 = _CalculateActorsRadius(actor1.collider.characterMovement, Vector3.zero, actor1.transform.position, actor2);
                if (radius2 < 0)
                {
                    radius2 = actor2.radius;
                }
            }
            else
            {
                radius1 = actor1.radius;
                radius2 = actor2.radius;
            }
        }

        public static float GetMonsterRadius(Actor role, Vector3 rolePoint, Actor monster)
        {
            if (!role.IsRole() || !monster.IsMonster() || !monster.model.modelInfo.isSpecialBody)
            {
                return monster.radius;
            }
            Vector3 movementOffset = rolePoint - role.transform.position;
            movementOffset.y = 0;
            float alienRadius =  _CalculateActorsRadius(role.collider.characterMovement, movementOffset, rolePoint, monster);
            if (alienRadius < 0)
            {
                alienRadius = monster.radius;
            }
            return alienRadius;
        }

        private static float _CalculateActorsRadius(CharacterMovement roleMovement, Vector3 movementOffset, Vector3 rolePosition, Actor target)
        {
            if (roleMovement == null)
            {
                return -1;
            }
            float alienRadius;
            _cachePoints.Clear();
            Vector3 targetPoint = target.transform.position;
            Vector3 direction = targetPoint - rolePosition;
            direction.y = 0;
            Vector3 up = (roleMovement.updatedRotation * Vector3.up).normalized;
            X3Physics.CapsuleTestPoints(roleMovement.worldCenter + movementOffset, up,  roleMovement.height, roleMovement.radius, direction.normalized, direction.magnitude, _cachePoints, target, X3LayerMask.ColliderTest);
            if (_cachePoints.Count == 0)
            {
                alienRadius = -1;
            }
            else
            {
                Vector3 nearestPoint = _cachePoints[0];
                float nearestDistance = (nearestPoint - rolePosition).sqrMagnitude;
                for (int i = 1; i < _cachePoints.Count; i++)
                {
                    Vector3 point = _cachePoints[i];
                    float distance = (point - rolePosition).sqrMagnitude;
                    if (distance < nearestDistance)
                    {
                        nearestPoint = point;
                        nearestDistance = distance;
                    }
                }
                Vector3 hitPointToTarget = targetPoint - nearestPoint;
                hitPointToTarget.y = 0;
                alienRadius = hitPointToTarget.magnitude;
            }
            return alienRadius;
        }

        /// <summary>
        /// 字典合并,将dict合并到outDict中
        /// </summary>
        /// <param name="outDict"></param>
        /// <param name="dict"></param>
        /// <typeparam name="T1"></typeparam>
        /// <typeparam name="T2"></typeparam>
        public static void CombineDict<T1, T2>(Dictionary<int, T1> outDict, Dictionary<int, T2> dict) where T2 : T1
        {
            if (null == outDict || null == dict)
            {
                return;
            }

            foreach (var cfg in dict)
            {
                if (outDict.ContainsKey(cfg.Key))
                {
                    LogProxy.LogError($"BattleUtil.CombineDict() errorMsg:字典合并异常，存在相同ID:({cfg.Key})的数据，请检查!!");
                    continue;
                }

                outDict.Add(cfg.Key, cfg.Value);
            }
        }

        /// <summary>
        ///  通过type获取actor
        /// </summary>
        /// <param name="type"></param>1 = girl 2 = boy 其余是怪物的ID
        public static Actor GeDialogueActor(int type)
        {
            if (type == 1)
            {
                var actor = Battle.Instance.actorMgr.girl;
                return actor;
            }

            if (type == 2)
            {
                var actor = Battle.Instance.actorMgr.boy;
                return actor;
            }

            var monster = Battle.Instance.actorMgr.GetActor(type);
            return monster;
        }

        /// <summary>
        /// 根据阵营复合枚举过滤Actors
        /// </summary>
        /// <param name="filters"> 待筛列表 </param>
        /// <param name="outActors"> 接收返回结果的列表 </param>
        /// <param name="factionFlag"> 阵营筛选条件 </param>
        public static void FilterActors(List<Actor> filters, List<Actor> outActors, FactionFlag factionFlag)
        {
            if (filters == null || outActors == null)
            {
                return;
            }
            
            outActors.Clear();
            for (var i = 0; i < filters.Count; i++)
            {
                var filterActor = filters[i];
                if (!ContainFactionType(factionFlag, filterActor.factionType))
                {
                    continue;
                }

                outActors.Add(filterActor);
            }
        }

        /// <summary>
        /// 根据角色类型复合枚举过滤Actors
        /// </summary>
        /// <param name="filters"> 待筛列表 </param>
        /// <param name="outActors"> 接收返回结果的列表 </param>
        /// <param name="actorFlag"> 角色复合枚举 </param>
        public static void FilterActors(List<Actor> filters, List<Actor> outActors, ActorFlag actorFlag)
        {
            if (filters == null || outActors == null)
            {
                return;
            }
            
            outActors.Clear();
            for (var i = 0; i < filters.Count; i++)
            {
                var filterActor = filters[i];
                if (!ContainActorType(actorFlag, filterActor.type))
                {
                    continue;
                }

                outActors.Add(filterActor);
            }
        }

        /// <summary>
        /// 根据圆形{center, radius}, 筛选角色是否在圆形范围内.
        /// </summary>
        /// <param name="filters"> 待筛列表 </param>
        /// <param name="outActors"> 接收返回结果的列表 </param>
        /// <param name="center"> 圆心位置 </param>
        /// <param name="radius"> 半径 </param>
        public static void FilterActors(List<Actor> filters, List<Actor> outActors, Vector3 center, float radius)
        {
            if (filters == null || outActors == null)
            {
                return;
            }
            
            outActors.Clear();
            float sqrRadius = radius * radius;
            for (var i = 0; i < filters.Count; i++)
            {
                var filterActor = filters[i];
                if ((filterActor.transform.position - center).sqrMagnitude > sqrRadius)
                {
                    continue;
                }

                outActors.Add(filterActor);
            }
        }

        /// <summary>
        /// 根据 是否包含召唤物的枚举过滤条件 对待筛列表进行过筛
        /// </summary>
        /// <param name="filters"> 待筛列表 </param>
        /// <param name="outActors"> 接收返回结果的列表 </param>
        /// <param name="includeSummonType"> 是否包含召唤物的枚举过滤条件 </param>
        public static void FilterActors(List<Actor> filters, List<Actor> outActors, IncludeSummonType includeSummonType)
        {
            if (filters == null || outActors == null)
            {
                return;
            }
            
            outActors.Clear();
            for (var i = 0; i < filters.Count; i++)
            {
                var filterActor = filters[i];
                if (!IsEligibleActor(filterActor, includeSummonType))
                {
                    continue;
                }

                outActors.Add(filterActor);
            }
        }

        /// <summary>
        /// 是否是符合资格的Actor, 条件是IncludeSummonType
        /// </summary>
        /// <param name="includeSummonType"></param>
        /// <param name="actor"></param>
        /// <returns></returns>
        public static bool IsEligibleActor(Actor actor, IncludeSummonType includeSummonType)
        {
            if (actor == null)
            {
                return false;
            }
            
            var isCreature = actor.IsCreature();
            // DONE: 只关注召唤物的, 将不是召唤物的剔除掉.
            if (!isCreature && includeSummonType == IncludeSummonType.OnlySummon)
            {
                return false;
            }
            // DONE: 不关注召唤物的, 将是召唤物的剔除掉.
            if (isCreature && includeSummonType == IncludeSummonType.NoSummon)
            {
                return false;
            }

            return true;
        }

        public static bool ContainFactionType(FactionFlag flag, FactionType type)
        {
            var result = (int) flag & (1 << (int) type);
            return result > 0;
        }

        public static bool ContainActorType(ActorFlag flag, ActorType type)
        {
            var result = (int) flag & (1 << (int) type);
            return result > 0;
        }

        public static bool ContainFactionRelationShip(FactionRelationshipFlag flag, FactionRelationship type)
        {
            var result = (int) flag & (1 << (int) type);
            return result > 0;
        }
        
        //求两圆交点
        public static int FindCircleCircleIntersections(Vector2 c0, float r0, Vector2 c1, float r1, out Vector2 intersection1, out Vector2 intersection2)
        {
            // Find the distance between the centers.
            double dx = c0.x - c1.x;
            double dy = c0.y - c1.y;
            double dist = Math.Sqrt(dx * dx + dy * dy);

            if (Math.Abs(dist - (r0 + r1)) < 0.00001f)
            {
                intersection1 = Vector2.Lerp(c0, c1, r0 / (r0 + r1));
                intersection2 = intersection1;
                return 1;
            }

            // See how many solutions there are.
            if (dist > r0 + r1)
            {
                // No solutions, the circles are too far apart.
                intersection1 = new Vector2(float.NaN, float.NaN);
                intersection2 = new Vector2(float.NaN, float.NaN);
                return 0;
            }
            else if (dist < Math.Abs(r0 - r1))
            {
                // No solutions, one circle contains the other.
                intersection1 = new Vector2(float.NaN, float.NaN);
                intersection2 = new Vector2(float.NaN, float.NaN);
                return 0;
            }
            else if ((dist == 0) && (Math.Abs(r0 - r1) < Mathf.Epsilon))
            {
                // No solutions, the circles coincide.
                intersection1 = new Vector2(float.NaN, float.NaN);
                intersection2 = new Vector2(float.NaN, float.NaN);
                return 0;
            }
            else
            {
                // Find a and h.
                double a = (r0 * r0 -
                    r1 * r1 + dist * dist) / (2 * dist);
                double h = Math.Sqrt(r0 * r0 - a * a);

                // Find P2.
                double cx2 = c0.x + a * (c1.x - c0.x) / dist;
                double cy2 = c0.y + a * (c1.y - c0.y) / dist;

                // Get the points P3.
                intersection1 = new Vector2(
                    (float)(cx2 + h * (c1.y - c0.y) / dist),
                    (float)(cy2 - h * (c1.x - c0.x) / dist));
                intersection2 = new Vector2(
                    (float)(cx2 - h * (c1.y - c0.y) / dist),
                    (float)(cy2 + h * (c1.x - c0.x) / dist));

                return 2;
            }
        }

        /// <summary>
        /// 打乱列表
        /// </summary>
        /// <param name="list"> 待打乱的列表 </param>
        /// <param name="startIndex"> 待打乱列表的起始索引, 无效的startIndex会默认重置为0 </param>
        /// <param name="endIndex"> 待打乱列表的末尾索引, 无效的endIndex会默认重置为list.Count - 1 </param>
        /// <typeparam name="T"> </typeparam>
        public static void ShuffleList<T>(List<T> list, int startIndex = 0, int endIndex = -1)
        {
            if (list == null || list.Count <= 1)
            {
                return;
            }

			if (startIndex >= list.Count){
				return;
			}

            if (startIndex < 0)
            {
                startIndex = 0;
            }

            if (endIndex < 0 || endIndex >= list.Count)
            {
                endIndex = list.Count - 1;
            }

            if (startIndex >= endIndex)
            {
                return;
            }
            
            for (var i = 0; i < list.Count; i++)
            {
                var index = UnityEngine.Random.Range(i, list.Count);
                var temp = list[i];
                list[i] = list[index];
                list[index] = temp;
            }
        }

        /// <summary>
        /// 去重列表 (从后往前剔除列表内重复的元素)
        /// </summary>
        /// <param name="list"> 待去重列表 </param>
        /// <typeparam name="T"></typeparam>
        public static void DistinctList<T>(List<T> list) where T : class
        {
            if (list == null || list.Count <= 1)
            {
                return;
            }
            
            for (int i = list.Count - 1; i >= 0; i--)
            {
                bool isRepeated = false;
                for (int j = 0; j < i; j++)
                {
                    if (list[i].Equals(list[j]))
                    {
                        isRepeated = true;
                        break;
                    }
                }

                if (isRepeated)
                {
                    list.RemoveAt(i);
                }
            }
        }

        /// <summary>
        /// 根据技能ID查技能的槽位ID
        /// </summary>
        /// <param name="actor"> 有SkillOwner的Actor </param>
        /// <param name="skillID"> 技能ID </param>
        /// <returns>  </returns>
        public static int? GetSlotIDBySkillID(Actor actor, int skillID)
        {
            if (actor?.skillOwner == null)
            {
                LogProxy.LogError($"【程序错误】，请联系战斗程序排查逻辑, BattleUtil.GetSlotIDBySkillID actor参数需要有[SkillOwner]组件.");
                return null;
            }
            
            int? result = null;
            var allSlotConfigs = actor.skillOwner.GetAllSlotConfigs();
            if (allSlotConfigs != null)
            {
                foreach (var keyValuePair in allSlotConfigs)
                {
                    var skillSlotConfig = keyValuePair.Value;
                    if (skillSlotConfig.SkillID == skillID)
                    {
                        result = skillSlotConfig.ID;
                    }
                }
            }

            return result;
        }
        
        /// <summary>
        /// 通过configID 获取男角名字 名字返回类似 role1
        /// </summary>
        /// <param name="configID"></param>
        /// <returns></returns>
        public static int GetActorName(int configID)
        {
            foreach (var configItem in TbUtil.dialogueNameConfigs.Values)
            {
                if (configItem.ScoreID == configID)
                {
                    return configItem.MaleName;
                }
            }

            return 0;
        }

        /// <summary>
        /// 获取该点的高度
        /// </summary>
        /// <returns></returns>
        public static float GetPosY()
        {
            //目前没有高度设置 临时为0
            return 0;
        }

        public static void SetHurtVibrateEnable(bool enable)
        {
            if (enable)
            {
                PlayerPrefs.SetInt("hurtVibrate", 1);
            }
            else
            {
                PlayerPrefs.SetInt("hurtVibrate", 0);
            }
        }

        public static bool GetHurtVibrate()
        {
            if(!PlayerPrefs.HasKey("hurtVibrate"))
            {
                return true;
            }
            else
            {
                if (PlayerPrefs.GetInt("hurtVibrate") == 1)
                    return true;
                else
                    return false;
            }
        }

        /// <summary>
        /// 获取一个形状沿着移动方向，碰到空气墙时的，不会发生任何穿透和接触的点.
        /// 注意：
        /// 1.该形状起始点不可与空气墙穿透
        /// 2.仅仅支持 box，sphere，capsule形状
        /// </summary>
        /// <param name="noPenetrationPos">该形状在该点，不会与空气墙发生穿透</param>
        /// <param name="hitNormal">与空气墙发生碰撞时的，碰撞点法线</param>
        /// <returns>是否碰到空气墙</returns>
        public static bool GetNoPenetrationPos(Vector3 startPos, Vector3 moveDir, float moveDis, Vector3 rot, 
            BoundingShape shape, LayerMask layerMask, out Vector3 noPenetrationPos, out Vector3 hitNormal, ref List<X3Collider> resultCollides)
        {
            noPenetrationPos = default(Vector3);
            hitNormal = default(Vector3);
            
            moveDis = Mathf.Max(0.01f, moveDis);
            Vector3 endPos = startPos + moveDir * moveDis;
            Quaternion quaternion = new Quaternion();
            quaternion.eulerAngles = rot;
            int hitNum = X3Physics.CollisionTestWithCollisionInfo(startPos, endPos, quaternion, shape, out var results, layerMask);
            if (hitNum <= 0)
                return false;

            for (int i = 0; i < hitNum; i++)
            {
                var hitInfo = results[i];
                var x3Collider = X3Physics.GetX3Collider(hitInfo.Collider);
                if (x3Collider == null)
                    continue;
                if (x3Collider.tag == ColliderTag.AirWall)
                {
                    hitNormal = hitInfo.normal;
                    if (hitInfo.distance > 0)
                    {
                        noPenetrationPos = startPos + moveDir * hitInfo.distance * 0.9f;
                    }
                    else
                    {
                        float len = shape.GetShapeMaxHalfValue();
                        noPenetrationPos = startPos - moveDir * len * 1.1f;
                    }
                    resultCollides?.Add(x3Collider);
                    return true;
                }
            }
            return false;
        }

        /// <summary>
        /// 添加角色隐身状态
        /// </summary>
        /// <param name="layer"></param>
        /// <param name="go"></param>
        /// <param name="visible"></param>
        /// <param name="rootBoneVisible"></param>
        /// <param name="debugTag">调试信息</param>
        public static void AddCharacterVisibleClip(int layer, GameObject go, bool visible, bool rootBoneVisible, string debugTag = null)
        {
            if (go == null)
            {
                return;
            }

            var goTrans = go.transform;
            var rootBone = goTrans.Find("Roots")?.gameObject;
            if (!rootBone)
            {
                go.AddVisibleWithLayer(visible, layer, true, debugTag);
                return;
            }

            var childCount = goTrans.childCount;
            for (var i = 0; i < childCount; i++)
            {
                var child = goTrans.GetChild(i).gameObject;
                child.AddVisibleWithLayer(child != rootBone ? visible : rootBoneVisible, layer, true, debugTag);
            }
        }

        /// <summary>
        /// 移除角色隐身状态
        /// </summary>
        /// <param name="layer"></param>
        /// <param name="go"></param>
        public static void RemoveCharacterVisibleClip(int layer, GameObject go)
        {
            if (go == null)
            {
                return;
            }

            var goTrans = go.transform;
            var rootBone = goTrans.Find("Roots")?.gameObject;
            if (!rootBone)
            {
                go.RemoveVisibleWithLayer(layer);
                return;
            }

            var childCount = goTrans.childCount;
            for (var i = 0; i < childCount; i++)
            {
                var child = goTrans.GetChild(i).gameObject;
                child.RemoveVisibleWithLayer(layer);
            }
        }

        /// <summary>
        /// 清除角色隐身状态
        /// </summary>
        /// <param name="go"></param>
        public static void ClearCharacterVisibleClips(GameObject go)
        {
            if (go == null)
            {
                return;
            }

            var goTrans = go.transform;
            var rootBone = goTrans.Find("Roots")?.gameObject;
            if (!rootBone)
            {
                go.ClearVisible();
                return;
            }

            var childCount = goTrans.childCount;
            for (var i = 0; i < childCount; i++)
            {
                var child = goTrans.GetChild(i).gameObject;
                child.ClearVisible();
            }
        }
		
        /// <summary>
        /// Interpolate float from Current to Target. Scaled by distance to Target, so it has a strong start speed and ease out. 
        /// </summary>
        /// <param name="current"></param>
        /// <param name="target"></param>
        /// <param name="deltaTime"></param>
        /// <param name="interpSpeed"></param>
        /// <returns></returns>
        public static float FInterpTo(float current, float target, float deltaTime, float interpSpeed)
        {
            if (interpSpeed <= 0)
                return target; 

            var dist = target - current;

            if (Mathf.Abs(dist) < Mathf.Epsilon)
            {
                return target;
            }

            float deltaMove = dist * Mathf.Clamp01(deltaTime * interpSpeed);
            return current + deltaMove;
        }

        // 当前关卡是否通关, 默认return true
        public static bool IsLevelUnLock()
        {
            bool stageIsUnLock = true;
# if UNITY_EDITOR
            if (BattleEnv.StartupArg != null && BattleEnv.StartupArg.startupType != BattleStartupType.Online)
            {
                // Editor 下的离线战斗， 是否通关通过启动器设置
                stageIsUnLock = PlayerPrefs.GetInt("keyStageIsUnLock", 1) == 1;
                return stageIsUnLock;
            }
# endif
            if (BattleEnv.LuaBridge != null && BattleEnv.StartupArg != null)
            {
                return BattleEnv.LuaBridge.StageIsUnLockById(BattleEnv.StartupArg.levelID);
            }
            return stageIsUnLock;
        }
		
		/// <summary>
        /// Dauglas-Peucker算法，将由多点组成的曲线（折线）降采样为点数较小的类似曲线（折线）
        /// </summary>
        /// <param name="originPoints"></param>
        /// <param name="tolerance"></param>
        /// <returns></returns>
        public static List<Vector3> DauglasPeucker(List<Vector3> originPoints, float tolerance)
        {

            int count = originPoints.Count;
            if(count <= 2)
            {
                return originPoints;
            }

            var result = new List<Vector3>();
            float dMax = 0;
            int index = 0;
            for (int i = 1; i < count - 1; i ++)
            {
                var d = PerpendicularDistance(originPoints[i], originPoints[0], originPoints[count - 1]);
                if (d > dMax)
                {
                    dMax = d;
                    index = i;
                }
            }

            if(dMax > tolerance)
            {
                List<Vector3> origin1 = originPoints.Take(index + 1).ToList();
                List<Vector3> origin2 = originPoints.Skip(index).ToList();

                List<Vector3> result1 = DauglasPeucker(origin1, tolerance);
                List<Vector3> result2 = DauglasPeucker(origin2, tolerance);

                result1.RemoveAt(result1.Count - 1);

                result = result1.Concat(result2).ToList();
            }
            else
            {
                result.Add(originPoints[0]);
                result.Add(originPoints[count - 1]);
            }

            return result;
        }

        /// <summary>
        /// 目标点到直线的距离
        /// </summary>
        /// <param name="targetPoint"></param> 目标点
        /// <param name="startPoint"></param> 直线起始点
        /// <param name="endPoint"></param> 直线终点
        /// <returns></returns>
        public static float PerpendicularDistance(Vector3 targetPoint, Vector3 startPoint, Vector3 endPoint)
        {
            var vecT_S = startPoint - targetPoint;
            var vecS_E = endPoint - startPoint;

            float d = Vector3.Cross(vecT_S, vecS_E).magnitude / vecS_E.magnitude;
            return d;
        }
		
        public static float GetGroundHeight(Vector3 posWS, out Vector3 normalWS)
        {
            using (ProfilerDefine.UtilGetGroundHeightPMarker.Auto())
            {
                var result = X3.SceneInfomation.HeightInquirer.GetGroundHeight(posWS, out normalWS, out bool success);
                return result;
            }
        }
        
        public static float GetGroundHeight(Vector3 posWS)
        {
            using (ProfilerDefine.UtilGetGroundHeightPMarker.Auto())
            {
                var result = X3.SceneInfomation.HeightInquirer.GetGroundHeight(posWS, out bool success); 
                return result;
            }
        }

        /// <summary>
        /// 是否包含目标角色
        /// </summary>
        /// <param name="actor"></param>
        /// <param name="info"></param>
        /// <returns></returns>
        public static bool IsIncludeActor(Actor actor, WitchTimeIncludeData info)
        {
            var result = false;
            if (info.isIncludeBullets && actor.type == ActorType.SkillAgent && actor.subType == (int)SkillAgentType.Missile)
            {
                result = true;
            }
            else if (info.isIncludeMagicFields && actor.type == ActorType.SkillAgent && actor.subType == (int)SkillAgentType.MagicField)
            {
                result = true;
            }
            else if (info.isIncludeItems && actor.type == ActorType.Item)
            {
                result = true;
            }
            else if (info.isIncludeSummoned && actor.IsCreature())
            {
                result = true;
            }

            return result;
        }
        
        // 清除Player和Boy的CD
        public static void ClearFriendSkillsCdForEditor()
        {
            Battle.Instance.ClearSkillsCd(Battle.Instance.player.insID);
            Battle.Instance.ClearSkillsCd(Battle.Instance.actorMgr.boy.insID);
        }

        /// <summary>
        /// 判断射线与圆是否相交 2D
        /// </summary>
        /// <param name="rayPos"></param>
        /// <param name="rayDir"></param>
        /// <param name="circlePos"></param>
        /// <param name="circleRadius"></param>
        /// <returns></returns>
        public static bool IsCircleRayIntersect(Vector2 rayPos, Vector2 rayDir, Vector2 circlePos, float circleRadius)
        {
            Vector2 m = circlePos - rayPos; // 计算圆心到射线原点的向量
            float b = Vector2.Dot(m, rayDir.normalized);
            Vector2 point = rayPos + rayDir.normalized * b;
            var dis = Vector2.Distance(circlePos, point); //求垂线的长度
            if (dis <= circleRadius)
            {
                return true;
            }

            return false;
        }

        /// <summary>
        /// 求射线与圆的垂线长度
        /// </summary>
        /// <param name="rayPos"></param>
        /// <param name="rayDir"></param>
        /// <param name="circlePos"></param>
        /// <param name="circleRadius"></param>
        /// <returns></returns>
        public static float GetCircleRayPerpendicular(Vector2 rayPos, Vector2 rayDir, Vector2 circlePos)
        {
            Vector2 m = circlePos - rayPos; // 计算圆心到射线原点的向量
            float b = Vector2.Dot(m, rayDir.normalized);
            Vector2 point = rayPos + rayDir.normalized * b;
            return Vector2.Distance(circlePos, point);
        }
        
        /// <summary>
        /// 求 过一点与圆的切线与点到圆心的连线的夹角 要求点不能在圆内
        /// </summary>
        /// <param name="rayPos"></param>
        /// <param name="rayDir"></param>
        /// <param name="circlePos"></param>
        /// <param name="circleRadius"></param>
        /// <returns></returns>
        public static float GetCirclePointLineAngle(Vector2 rayPos, Vector2 circlePos, float circleRadius)
        {
            var distance = Vector2.Distance(rayPos, circlePos);
            var ratio = circleRadius / distance;
            var angle = Mathf.Asin(ratio) * Mathf.Rad2Deg;
            return angle;
        }
        
        /// <summary>
        /// 用AES加密字符串
        /// </summary>
        /// <param name="text"></param>
        /// <param name="key"></param>
        /// <returns></returns>
        public static string EncryptString(string text, byte[] key)
        {
            byte[] iv = new byte[16];
            byte[] array;

            using (Aes aes = Aes.Create())
            {
                aes.Key = key;
                aes.IV = iv;

                ICryptoTransform encryptor = aes.CreateEncryptor(aes.Key, aes.IV);

                using (MemoryStream memoryStream = new MemoryStream())
                {
                    using (CryptoStream cryptoStream = new CryptoStream(memoryStream, encryptor, CryptoStreamMode.Write))
                    {
                        using (StreamWriter streamWriter = new StreamWriter(cryptoStream))
                        {
                            streamWriter.Write(text);
                        }

                        array = memoryStream.ToArray();
                    }
                }
            }

            return Convert.ToBase64String(array);
        }

        /// <summary>
        /// 用AES解密字符串
        /// </summary>
        /// <param name="text"></param>
        /// <param name="key"></param>
        /// <returns></returns>
        public static string DecryptString(string text, byte[] key)
        {
            byte[] iv = new byte[16];
            byte[] buffer = Convert.FromBase64String(text);

            using (Aes aes = Aes.Create())
            {
                aes.Key = key;
                aes.IV = iv;

                ICryptoTransform decryptor = aes.CreateDecryptor(aes.Key, aes.IV);

                using (MemoryStream memoryStream = new MemoryStream(buffer))
                {
                    using (CryptoStream cryptoStream = new CryptoStream(memoryStream, decryptor, CryptoStreamMode.Read))
                    {
                        using (StreamReader streamReader = new StreamReader(cryptoStream))
                        {
                            return streamReader.ReadToEnd();
                        }
                    }
                }
            }
		}
		
        public static bool IsNaN(this Vector3 v3)
        {
            return float.IsNaN(v3.x)
                   || float.IsNaN(v3.y)
                   || float.IsNaN(v3.z);
        }

        public static Transform GetLockPoint(Actor actor, MissileLockPointType type)
        {
            switch (type)
            {
                case MissileLockPointType.Defualt:
                case MissileLockPointType.Render_Point_Pivot:
                {
                    return actor?.GetDummy(ActorDummyType.RenderPointPivot);
                }
                case MissileLockPointType.Render_Point_Root:
                {
                    return actor?.GetDummy(ActorDummyType.PointRoot);
                }
                case MissileLockPointType.Render_Point_Top:
                {
                    return actor?.GetDummy(ActorDummyType.PointTop);
                }
            }

            return null;
        }

        /// <summary>
        /// 根据BattleSummon表中的配置对指定属性进行缩放
        /// 目前策划要所有常规属性都继承
        /// </summary>
        public static void SetDictAttrBySummonScale(Dictionary<AttrType, float> dictAttribute,S2Int[] scaleList)
        {
            foreach (var scaleData in scaleList)
            {
                if (dictAttribute.TryGetValue((AttrType)scaleData.ID,out var attrValue))
                {
                    if (scaleData.ID > 1000)
                    {
                        LogProxy.LogError($"修改了1000以上临时属性 {scaleData.ID} 的 缩放值");
                    }
                    dictAttribute[(AttrType)scaleData.ID] = Mathf.Round(attrValue * scaleData.Num * 0.001f);
                }
            }
        }
    }
}
