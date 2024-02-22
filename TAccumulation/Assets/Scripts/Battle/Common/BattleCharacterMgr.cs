using PapeGames.X3;
using System.Collections.Generic;
using UnityEngine;
using X3.Character;
using X3.Testbed;
using ISubsystem = X3.Character.ISubsystem;
using ISubsystemType = X3.Character.ISubsystem.Type;

namespace X3Battle
{
    public static class BattleCharacterMgr
    {
        //依赖LuaEnv, 必须先初始化（BattleLuaEnv.CallLua）
        private static IBattleLuaBridge _luaBridge => BattleEnv.LuaBridge;

        //战斗左右手固定骨骼
        private static List<string> _boneNames = new List<string> {"HPoint_hand_L", "HPoint_hand_R"};

        //当前设备等级
        private static int? _recommendGQLevel = null;

        //否为低端机
        public static bool IsBadQualityDevice => GetRecommendGQLevel() <= 2;

        //高模值（考虑机型，如果机型性能较低，此值依旧返回低模
        public static int LOD_HD => IsBadQualityDevice ? CharacterMgr.LOD_LD : CharacterMgr.LOD_HD;

        //低模值
        public static int LOD_LD => CharacterMgr.LOD_LD;

        /// <summary>
        /// 获取LOD
        /// </summary>
        public static float GetLOD(float lod)
        {
            if (!Application.isPlaying) return lod;
            return lod < 0.5f ? LOD_HD : LOD_LD;
        }

        /// <summary>
        /// 获取LOD
        /// </summary>
        /// <returns></returns>
        public static int GetGlobalLOD()
        {
            if (IsBadQualityDevice)
            {
                return LOD_LD;
            }

            return Mathf.RoundToInt(CharacterMgr.GetLOD());
        }

        /// <summary>
        /// 设置LOD
        /// </summary>
        /// <param name="lod">0(高模） or 1</param>
        public static void SetGlobalLOD(int lod)
        {
            //约束在高模与低模之间
            lod = lod > CharacterMgr.LOD_LD ? CharacterMgr.LOD_LD : lod < CharacterMgr.LOD_HD ? CharacterMgr.LOD_HD : lod;
            if (lod == CharacterMgr.LOD_HD && IsBadQualityDevice)
            {
                lod = CharacterMgr.LOD_LD;
            }

            CharacterMgr.SetLOD(lod);
            LogProxy.LogFormat("切换全局Lod：{0}, 当前设备等级：{1}", GetGlobalLOD(), GetRecommendGQLevel());
        }

        /// <summary>
        /// 当前设备等级(等级数字含义见：ICallLua.GetRecommendGQLevel())
        /// </summary>
        /// <returns></returns>
        public static int GetRecommendGQLevel()
        {
            if (null == _recommendGQLevel && null != _luaBridge)
            {
                _recommendGQLevel = _luaBridge.GetRecommendGQLevel();
            }

            return _recommendGQLevel ?? 1;
        }

        /// <summary>
        /// 获取模型实例，使用当前全局lod
        /// </summary>
        /// <param name="suitID">角色ID</param>
        /// <returns></returns>
        public static GameObject GetInsBySuitID(int suitID, bool brokenSuit = false)
        {
            return GetInsBySuitID(suitID, GetGlobalLOD(), brokenSuit);
        }

        /// <summary>
        /// 获取模型实例
        /// </summary>
        /// <param name="suitID"></param>
        /// <param name="lod"></param>
        /// <returns></returns>
        public static GameObject GetInsBySuitID(int suitID, int lod, bool brokenSuit = false)
        {
            GetBase2PartKeysBySuitID(suitID, out var parts, out var baseKey, brokenSuit);
            if (brokenSuit && (null == parts || parts.Length < 1))
            {
                LogProxy.LogError($"[BattleCharacterMgr] FormationSuit.xlsx:DirtFashionList/Fashion.xlsx 无此套装:{suitID}的爆衫部件数据，请相关配置策划检查！！");
                GetBase2PartKeysBySuitID(suitID, out parts, out baseKey, false);//即使没配 保底加载出来
            }
            var ins = X3AssetInsProvider.Instance.GetCharacterIns(baseKey, parts, lod, false);
            if (ins == null) return null;

            RemoveBattleEffect(ins);

            if (BattleUtil.IsGirlSuit(suitID))//策划:女主需要应用捏脸数据 一定应用
            {
                BattleEnv.LuaBridge.ApplyFaceData(suitID, ins);
            }
            return ins;
        }

        /// <summary>
        /// 卸载模型实例
        /// </summary>
        /// <param name="ins"></param>
        /// <param name="restoreTFInfos"></param>
        /// <returns></returns>
        public static bool ReleaseIns(GameObject ins, bool restoreTFInfos = false)
        {
            return X3AssetInsProvider.Instance.ReleaseIns(ins, restoreTFInfos);
        }

        /// <summary>
        /// 获取裸模和部件信息
        /// </summary>
        /// <param name="suitID">角色套装ID</param>
        /// <param name="partKeys">部件列表</param>
        /// <param name="baseKey">裸模Key</param>
        public static void GetBase2PartKeysBySuitID(int suitID, out string[] partKeys, out string baseKey, bool brokenSuit = false)
        {
            partKeys = null;
            baseKey = null;
            if (TbUtil.TryGetCfg(suitID, out ActorSuitCfg suitCfg))
            {
                GetBase2PartKeys(suitCfg.SuitID, suitCfg.ScoreID, out partKeys, out baseKey, brokenSuit);
            }
        }

        /// <summary>
        /// 获取裸模和部件信息
        /// </summary>
        /// <param name="suitID">套装(皮肤)id， 角色配置(ActorCfg)ID与套装ID值一致</param>
        /// <param name="scoreID">score(逻辑)id，女主默认为0, 男主存在boyCfg中</param>
        /// <param name="partKeys">部件列表</param>
        /// <param name="baseKey">裸模Key</param>
        /// <param name="brokenSuit">是否为爆衫(破烂的套装）</param>
        public static void GetBase2PartKeys(int suitID, int scoreID, out string[] partKeys, out string baseKey, bool brokenSuit = false)
        {
            partKeys = null;
            baseKey = null;

            //note:角色配置ID与套装ID值一致
            _luaBridge?.GetCharacterBaseKey2PartKeys(scoreID, suitID, brokenSuit, out baseKey, out partKeys);
        }

        /// <summary>
        /// 获取角色对应的资源路径列表
        /// </summary>
        /// <param name="suitID"></param>
        /// <param name="assetPaths"></param>
        /// <param name="lod">高or低模</param>
        /// <param name="includeBaseKey">是否忽略baseKey的资源路径</param>
        public static void GetAssetPathsBySuitID(int suitID, List<string> assetPaths, int lod = CharacterMgr.LOD_LD, bool includeBaseKey = true)
        {
            if (null == assetPaths)
            {
                return;
            }

            assetPaths.Clear();
            GetBase2PartKeysBySuitID(suitID, out var partKeys, out var baseKey);

            if (!includeBaseKey && !string.IsNullOrEmpty(baseKey))
            {
                assetPaths.Add(_luaBridge?.GetCharacterBaseAssetPath(baseKey));
            }

            if (partKeys == null) return;
            foreach (var part in partKeys)
            {
                assetPaths.Add(GetPartAssetPath(part, lod));
            }
        }

        /// <summary>
        /// 添加部件
        /// </summary>
        /// <param name="ins"></param>
        /// <param name="partKey"></param>
        /// <param name="autoReplacePartWithSameType"></param>
        /// <returns></returns>
        public static bool AddPart(GameObject ins, string partKey, bool autoReplacePartWithSameType = true, bool autoSyncLod = true)
        {
            if (ins == null) return false;

            var result = CharacterMgr.AddPart(ins, partKey, autoReplacePartWithSameType, autoSyncLod);

            var cfg = TryGetPartCfg(partKey);
            if (cfg == null || cfg.Type != (int) AssetType.WEAPON) return result;

            var subComp = (X3SkinnedMesh) CharacterMgr.GetSubsystem(ins, ISubsystemType.SkinnedMesh);
            if (subComp == null) return result;

            var smr = subComp.GetBodyPartByName(partKey);
            if (smr == null || smr.gameObject.transform.parent == null) return result;

            RemoveBattleEffect(ins);
            return result;
        }

        /// <summary>
        /// 依据部件类型获取部件列表
        /// </summary>
        /// <param name="suitID"></param>
        /// <param name="scoreID"></param>
        /// <param name="type"></param>
        /// <returns></returns>
        public static List<string> GetPartKeysByTypeID(int suitID, int scoreID, PartType type)
        {
            var typePartKeys = new List<string>();
            GetBase2PartKeys(suitID, scoreID, out var partKeys, out _);
            if (partKeys == null)
            {
                return null;
            }

            foreach (var part in partKeys)
            {
                var cfg = TryGetPartCfg(part);
                if (null == cfg)
                {
                    continue;
                }

                if (cfg.Type == (int) type)
                {
                    typePartKeys.Add(part);
                }
            }

            return typePartKeys;
        }

        /// <summary>
        /// 角色换部件
        /// </summary>
        /// <param name="character"></param>
        /// <param name="addParts"></param>
        public static void ChangeParts(GameObject character, List<string> addParts)
        {
            if (null == character || null == addParts)
            {
                return;
            }

            var toRemoveParts = ListPool<string>.Get();
            CharacterMgr.GetAllParts(character, toRemoveParts);
            for (var index = toRemoveParts.Count - 1; index >= 0; index--)
            {
                if (addParts.Contains(toRemoveParts[index]))
                {
                    toRemoveParts.RemoveAt(index);
                }
            }

            if (toRemoveParts.Count > 0) CharacterMgr.RemoveParts(character, toRemoveParts);
            CharacterMgr.ChangeParts(character, addParts, false);
            ListPool<string>.Release(toRemoveParts);
        }

        /// <summary>
        /// 获取部件配置
        /// </summary>
        /// <param name="partName"></param>
        /// <returns></returns>
        private static PartData TryGetPartCfg(string partName)
        {
            if (string.IsNullOrEmpty(partName))
                return null;
            var cfg = TablePartConfig.Instance.GetPartData(partName);
            return cfg;
        }

        /// <summary>
        /// 隐藏部件
        /// </summary>
        /// <param name="ins"></param>
        /// <param name="partName"></param>
        /// <param name="hide"></param>
        /// <returns></returns>
        public static bool HidePart(GameObject ins, string partName, bool hide)
        {
            return CharacterMgr.HidePart(ins, partName, hide);
        }

        /// <summary>
        /// 移除部件
        /// </summary>
        /// <param name="ins"></param>
        /// <param name="partKey"></param>
        /// <returns></returns>
        public static bool RemovePart(GameObject ins, string partKey)
        {
            return CharacterMgr.RemovePart(ins, partKey);
        }

        /// <summary>
        /// 获取部件父骨骼
        /// </summary>
        /// <param name="ins"></param>
        /// <param name="partKey"></param>
        /// <returns></returns>
        public static Transform GetPartParentBone(GameObject ins, string partKey)
        {
            return CharacterMgr.GetPartParentBone(ins, partKey);
        }

        /// <summary>
        /// 获取部件对应的AssetPath,根据lod和PartKey
        /// </summary>
        /// <param name="partKey"></param>
        /// <param name="lod"></param>
        /// <returns></returns>
        public static string GetPartAssetPath(string partKey, int lod)
        {
            if (string.IsNullOrEmpty(partKey))
                return null;
            return _luaBridge?.GetCharacterPartAssetPath(partKey, lod);
        }

        /// <summary>
        /// 获取武器骨骼
        /// </summary>
        /// <param name="ins"></param>
        /// <param name="dst"></param>
        /// <returns></returns>
        public static bool GetWeaponBones(GameObject ins, List<Transform> dst)
        {
            return CharacterMgr.GetChildBones(ins, _boneNames, dst);
        }

        /// <summary>
        /// 添加子系统
        /// </summary>
        /// <param name="ins"></param>
        /// <param name="type"></param>
        /// <returns></returns>
        public static ISubsystem EnsureSubsystem(GameObject ins, ISubsystemType type)
        {
            return CharacterMgr.EnsureSubsytem(ins, type);
        }

        private static void RemoveBattleEffect(GameObject ins)
        {
            //默认角色流程中添加BattleEffect 战斗已经启用 删除一下
            var bes = ins.GetComponentsInChildren<BattleBaseEffect>();
            if (bes.Length > 0)
            {
                LogProxy.Log("[BattleCharacterMgr]检测到BattleEffect，已移除");
                foreach (var be in bes)
                    GameObject.DestroyImmediate(be);
            }
        }
    }
}