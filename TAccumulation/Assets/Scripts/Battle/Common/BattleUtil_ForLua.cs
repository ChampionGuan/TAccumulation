using System;
using System.Collections.Generic;
using PapeGames.X3;
using PapeGames.X3UI;
using UnityEngine;

namespace X3Battle
{
    public static partial class BattleUtil
    {
        /// <summary>
        /// 预创建的UI筛选列表
        /// </summary>
        private static readonly List<string> _filterUINames = new List<string>() {"UIView_BattleTipsWnd", "UIView_BattleMainTips", "UIView_BattleInfoPopup", "UIView_BattleMonsterInf","UIView_BattleSoulTrialLayer"};
        /// <summary>
        /// 获取角色资源路径，供lua端使用
        /// </summary>
        /// <returns></returns>
        public static string[] GetCharacterAssetPaths(int suitID)
        {
            var assetPaths = new List<string>();
            BattleCharacterMgr.GetAssetPathsBySuitID(suitID, assetPaths, BattleCharacterMgr.LOD_LD, true);
            return assetPaths.ToArray();
        }

        /// <summary>
        /// 获取字典中的value，供lua端使用
        /// </summary>
        public static T GetDictValue<T>(Dictionary<int, T> dict, int id)
        {
            if (null == dict || !dict.TryGetValue(id, out var value))
            {
                return default;
            }

            return value;
        }

        /// <summary>
        /// 遍历字典，供lua端使用
        /// </summary>
        public static void ForeachDict<T>(Dictionary<int, T> dict, Action<T> call)
        {
            if (null == dict || null == call)
            {
                return;
            }

            foreach (var value in dict.Values)
            {
                call(value);
            }
        }

        /// <summary>
        /// 遍历资源分析的字典，供lua端使用
        /// </summary>
        public static void ForeachAnalyzeResult(Dictionary<BattleResType, Dictionary<string, ResDesc>> dict, Action<ResDesc> call)
        {
            if (null == dict || null == call)
            {
                return;
            }

            foreach (var item in dict)
            {
                foreach (var item2 in item.Value)
                {
                    call(item2.Value);
                }
            }
        }
        
        /// <summary>
        /// 遍历资源分析的字典获得分析的UI名字列表，供lua端使用
        /// </summary>
        public static void ForeachAnalyzeUINames(Dictionary<BattleResType, Dictionary<string, ResDesc>> dict, Action<string> call)
        {
            if (null == dict || null == call)
            {
                return;
            }

            foreach (var item in dict)
            {
                //动态icon引用预加载
                if (item.Key == BattleResType.Sprite)
                {
                    foreach (var icon in item.Value)
                    {
                        UISystem.LocaleDelegate?.OnGetSprite(icon.Value.fullPath,BattleClient.Instance.gameObject);
                    }
                    continue;
                }
                
                if (item.Key != BattleResType.UI)
                {
                    continue;
                }
                foreach (var item2 in item.Value)
                {
                    if (!Battle.Instance.arg.isShowTips && item2.Value.path == "UIView_BattleInfoPopup")
                    {
                        continue;
                    }
                    if (!item2.Value.path.StartsWith("UIView_") || !_filterUINames.Contains(item2.Value.path))
                    {
                        continue;
                    }
                    string UIName = item2.Value.path.Replace("UIView_", "");
                    call(UIName);
                }
            }
        }

        /// <summary>
        /// 获取关卡下所有怪配置IDs
        /// </summary>
        /// <param name="levelID"></param>
        /// <returns></returns>
        public static List<int> GetLevelAllMonsterCfgIDs(int levelID)
        {
            BattleLevelConfig levelConfig = TbUtil.GetCfg<BattleLevelConfig>(levelID);
            if (levelConfig == null)
            {
                return null;
            }

            var levelCfg = TbUtil.GetCfg<StageConfig>(levelConfig.StageID);
            if (null == levelCfg)
            {
                return null;
            }

            var ids = new List<int>();
            foreach (var point in levelCfg.SpawnPoints)
            {
                ids.Add(point.ConfigID);
            }

            return ids;
        }

        /// <summary>
        /// 开关蓝图cache机制（lua层在调用）
        /// </summary>
        /// <param name="enable"></param>
        public static void EnableNotionDataCache(bool enable)
        {
            ParadoxNotion.Serialization.JSONSerializer.FlushMem();
            ParadoxNotion.Serialization.JSONSerializer.EnableDataCache(enable);
        }
        
        /// <summary>
        /// 获取资源加载类型
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        public static BattleResLoadType GetResLoadType(BattleResType type)
        {
            var cfgItem = BattleResConfig.GetResConfig(type);
            if (cfgItem != null) return cfgItem.loadType;

            LogProxy.LogErrorFormat("资源类型：{0} 获取LoadType配置失败，默认返回BattleResLoadType.Prefab", type);
            return BattleResLoadType.Prefab;
        }

        public static float GetLongPressTime()
        {
            return TbUtil.battleConsts.LongPressTime;
        }
        
        public static float GetCountDownTime()
        {
            return TbUtil.battleConsts.LevelEndCountdown;
        }
        
        public static Dictionary<int, SkillSlotConfig> NewSkillSlotConfigDict()
        {
            return new Dictionary<int, SkillSlotConfig>();
        }
        
        public static bool IsEnemyOfPlayer(Actor actor)
        {
            return Battle.Instance.player.GetFactionRelationShip(actor) == FactionRelationship.Enemy;
        }

        public static int GetCurSlotIdByBtnType(SkillOwner skillOwner, PlayerBtnType btnType)
        {
            var slotIdVar = skillOwner?.TryGetCurSlotID(btnType, PlayerBtnStateType.Down);
            if (slotIdVar == null)
            {
                return -1;
            }
            return slotIdVar.Value;
        }

        public static bool CanCastSkillByBtnType(SkillOwner skillOwner, PlayerBtnType btnType)
        {
            int slotId = GetCurSlotIdByBtnType(skillOwner, btnType);
            if (slotId < 0)
            {
                return false;
            }
            return skillOwner.CanCastSkillBySlot(slotId);
        }
        
        /// <summary>
        /// 获取角色挂点
        /// </summary>
        public static Transform GetActorDummy(Actor actor, DummyType dummyType)
        {
            if (actor == null)
            {
                return null;
            }

            return ActorDummyType.dummyTypes.TryGetValue(dummyType, out var dummyName) ? actor.GetDummy(dummyName) : null;
        }
    }
}
