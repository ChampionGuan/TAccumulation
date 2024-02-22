using System.Collections.Generic;
using NodeCanvas.BehaviourTrees;
using UnityEngine;

namespace X3Battle
{
    /// <summary>
    /// 战斗环境
    /// 1、它是一个静态类
    /// 2、可以用来暂存战前，战中，甚至战后的数据
    /// 3、...
    /// </summary>
    public static class BattleEnv
    {
        public static IBattleClientBridge ClientBridge { get; set; }
        public static IBattleLuaBridge LuaBridge => ClientBridge?.luaBridge;
        public static BattleArg StartupArg { get; set; }
        
        public static bool InDebugging { get; set; }
        public static bool DontEndBattleNonManual { get; set; }
        public static bool NoCdForPlayerSkills { get; set; }
        
        private static HashSet<int> _performIDs = new HashSet<int>();
        private static Dictionary<int, HashSet<string>> _heroExtWeaponParts = new Dictionary<int, HashSet<string>>();
        private static Dictionary<HeroType, LODUseType> _heroLodUseType = new Dictionary<HeroType, LODUseType>();

        //动态切换子树，预加载可能被切换的子树
        private static HashSet<BehaviourTree> _boySubTreeList;
        private static HashSet<BehaviourTree> _girlSubTreeList;
        public static HashSet<BehaviourTree> BoySubTreeList => _boySubTreeList ?? (_boySubTreeList = new HashSet<BehaviourTree>());
        public static HashSet<BehaviourTree> GirlSubTreeList => _girlSubTreeList ?? (_girlSubTreeList = new HashSet<BehaviourTree>());

        /// <summary> 内存大小等级 {0, 1, 2} </summary>
        private static int? _memorySizeLevel = null;
        public static int memorySizeLevel => _memorySizeLevel ?? (_memorySizeLevel = BattleUtil.GetMemorySizeLevel()).Value;

        /// <summary> 从lua端获取的无效文本 </summary>
        private static string _invalidText = null;
        public static string invalidText => _invalidText ?? (_invalidText = LuaBridge.GetInvalidText()); 

        /// <summary>
        /// 当战斗结束
        /// 在战斗结束后会调用此接口
        /// </summary>
        public static void OnBattleDestroy()
        {
            _performIDs.Clear();
            _heroExtWeaponParts.Clear();
            _heroLodUseType.Clear();
            BoySubTreeList.Clear();
            GirlSubTreeList.Clear();
            _boySubTreeList = null;
            _girlSubTreeList = null;
            StartupArg = null;
            InDebugging = false;
            NoCdForPlayerSkills = false;
            _memorySizeLevel = null;
            _invalidText = null;
        }

        /// <summary>
        /// 当游戏被重启
        /// 热更后，lua文件卸载后被重新载入
        /// </summary>
        public static void OnGameReboot()
        {
            // 配置卸载
            TbUtil.UnInit();
            // 桥数据清理
            ClientBridge.OnGameReboot();
            // 调用到lua端
            LuaBridge.OnGameReboot();
        }

        #region --战斗中所有的表演模型ID--

        public static HashSet<int> GetPerformIDs()
        {
            return _performIDs;
        }

        public static void AddPerformID(int id)
        {
            _performIDs.Add(id);
        }

        #endregion

        #region --战斗中表演角色的LOD值--

        public static void SetHeroLODUseType(HeroType heroType, LODUseType lodUseType)
        {
            if (!_heroLodUseType.TryGetValue(heroType, out var useType))
            {
                _heroLodUseType.Add(heroType, lodUseType);
                return;
            }

            if (useType != LODUseType.LDHD)
            {
                _heroLodUseType[heroType] = lodUseType;
            }
        }

        public static LODUseType GetHeroLODUseType(HeroType heroType)
        {
            return !_heroLodUseType.TryGetValue(heroType, out var useType) ? LODUseType.None : useType;
        }

        #endregion

        #region --额外添加的男女主武器部件--

        public static HashSet<string> GetHeroExtWeaponParts(HeroType type, bool isPerform)
        {
            var hashCode = _CalculateExtWeaponTypeHash(type, isPerform);
            _heroExtWeaponParts.TryGetValue(hashCode, out var parts);
            return parts;
        }
        
        private static int _CalculateExtWeaponTypeHash(HeroType type, bool isPerform)
        {
            var typeCode = (int)type * 1000;
            var boolCode = isPerform ? 1 : 0;
            var hash = typeCode + boolCode;
            return hash;
        }

        public static void AddHeroExtWeaponPart(HeroType type, bool isPerform, string newPart)
        {
            var hashCode = _CalculateExtWeaponTypeHash(type, isPerform);
            _heroExtWeaponParts.TryGetValue(hashCode, out var parts);
            if (parts == null)
            {
                parts = new HashSet<string>();
                _heroExtWeaponParts.Add(hashCode, parts);
            }

            parts.Add(newPart);
        }

        #endregion
    }
}