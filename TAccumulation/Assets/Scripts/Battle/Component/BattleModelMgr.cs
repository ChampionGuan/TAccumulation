using System;
using System.Collections.Generic;
using Framework;
using PapeGames.X3;
using UnityEngine;
using X3.Character;
using X3.PlayableAnimator;

namespace X3Battle
{
    public class BattleModelMgr : BattleComponent
    {
        /// <summary>
        /// 表演用女主模型信息
        /// </summary>
        private ModelCfg _girlUltraCfg;

        /// <summary>
        /// 模型实例
        /// </summary>
        private Dictionary<ModelCfg, GameObject> _modelIns = new Dictionary<ModelCfg, GameObject>();

        /// <summary>
        /// 模型物理资产
        /// </summary>
        private Dictionary<ModelCfg, List<PhysicsClothAsset>> _physicsClothAssets = new Dictionary<ModelCfg, List<PhysicsClothAsset>>();

        /// <summary>
        /// 高品质残影实例
        /// </summary>
        private static Dictionary<ModelCfg, List<GameObject>> _ghostHDIns = new Dictionary<ModelCfg, List<GameObject>>();

        public BattleModelMgr() : base(BattleComponentType.ModelMgr)
        {
            requiredUpdate = false;
        }

        public override void OnActorBorn(Actor actor)
        {
            // note:预创建一个表演用实例
            if (battle.isBegin)
            {
                return;
            }

            // 女主、男主（备份模型实例，爆发技中会使用）
            if (actor.IsGirl() || actor.IsBoy())
            {
                _EnsureModel(actor);
            }

            /*// 女主、男主或者敌方阵营的怪
            if (actor.IsGirl() || actor.IsBoy() || (null != battle.actorMgr.player && actor.type == ActorType.Monster && battle.actorMgr.player.GetFactionRelationShip(actor) == FactionRelationship.Enemy))
            {
                _EnsureModel(actor);
            }*/
        }

        protected override void OnAwake()
        {
            battle.eventMgr.AddListener<EventActorChangeParts>(EventType.ActorChangeParts, _OnActorChangeParts, "BattleModelMgr._OnActorChangeParts");
        }

        protected override void OnDestroy()
        {
            DestroyAllModelIns();
            DestroyAllGhostHD();
            battle.eventMgr.RemoveListener<EventActorChangeParts>(EventType.ActorChangeParts, _OnActorChangeParts);
        }

        #region --角色模型相关--

        public GameObject GetModelIns(Actor actor)
        {
            return actor?.model == null ? null : _EnsureModel(actor);
        }

        public void RecycleModelIns(Actor actor, GameObject go)
        {
            if (null == go) return;
            go.SetVisible(false);
            go.transform.SetParent(battle.modelRootTrans);
            go.transform.position = new Vector3(0, -10000, 0);
        }

        public void DestroyAllModelIns()
        {
            foreach (var keyValue in _modelIns)
            {
                if (null == keyValue.Value)
                {
                    continue;
                }

                var root = keyValue.Value.transform;
                if (null == root)
                {
                    continue;
                }

                var go = root.Find("Model");
                go.parent = null;
                BattleResMgr.Instance.UnloadActorGO(go.gameObject, keyValue.Key);
                GameObject.Destroy(root.gameObject);
            }

            // DONE: 物理资产卸载.
            foreach (var physicsClothAsset in _physicsClothAssets)
            {
                if (physicsClothAsset.Value == null)
                    continue;
                var list = physicsClothAsset.Value;
                for (var i = physicsClothAsset.Value.Count - 1; i >= 0; i--)
                {
                    Res.Unload(list[i]);
                    list.RemoveAt(i);
                }

                list.Clear();
            }

            _physicsClothAssets.Clear();
            _modelIns.Clear();
        }

        private GameObject _EnsureModel(Actor actor)
        {
            if (null == actor?.model)
            {
                return null;
            }

            var modelCfg = actor.model.config;
            var actorIsBoy = actor.IsBoy();
            var actorIsGirl = actor.IsGirl();
            if (actorIsGirl)
            {
                if (!TbUtil.TryGetCfg(battle.arg.boySuitID, out MaleSuitConfig boySuitCfg))
                {
                    LogProxy.LogErrorFormat("【ActorMgr.EnsureActorModelIns】 加载Girl爆发技模型失败, 没有Boy套装配置. Boy套装ID:{0}", battle.arg.boySuitID);
                    return null;
                }

                var targetSuitID = BattleEnv.LuaBridge.GetFemaleUltraSuitID(battle.arg.girlSuitID, battle.arg.boySuitID, boySuitCfg.ScoreID);
                if (!TbUtil.TryGetCfg(targetSuitID, out FemaleSuitConfig girlSuitCfg))
                {
                    LogProxy.LogErrorFormat("【ActorMgr.EnsureActorModelIns】 加载Girl爆发技模型失败, 没有Girl套装配置. Girl套装ID:{0}", targetSuitID);
                    return null;
                }

                if (null == _girlUltraCfg)
                {
                    _girlUltraCfg = new ModelCfg
                    {
                        SuitID = girlSuitCfg.SuitID,
                        Type = ActorType.Hero,
                        SubType = (int)HeroType.Girl,
                        Name = girlSuitCfg.Name,
                    };
                }

                modelCfg = _girlUltraCfg;
            }

            //从缓存中获取
            if (_TryGetValue(_modelIns, modelCfg, out var key, out var value))
            {
                if (value != null)
                {
                    return value;
                }

                _modelIns.Remove(key);
            }

            // DONE: 爆发技用模型加载LOD处理.
            var lod = actorIsGirl || actorIsBoy ? BattleUtil.GetHeroLOD(actorIsGirl ? HeroType.Girl : HeroType.Boy) : BattleCharacterMgr.LOD_HD;
            var model = BattleResMgr.Instance.LoadActorGO(modelCfg, lod);
            var root = new GameObject(modelCfg.Name + "(Model)");
            root.transform.SetParent(battle.modelRootTrans);
            root.transform.position = new Vector3(0, -10000, 0);
            model.transform.SetParent(root.transform);
            model.transform.name = "Model";
            model.transform.localPosition = Vector3.zero;

            // 将graph置为非活跃状态
            var modelGraph = PlayableAnimationManager.Instance()?.FindPlayGraph(model);
            if (null != modelGraph) modelGraph.Active = false;

            // 目前仅处理女主的武器与创建.
            var weaponSkinID = actorIsGirl ? actor.battle.arg.girlWeaponID : actorIsBoy ? (actor.suitCfg as MaleSuitConfig)?.WeaponID : 0;
            if (null != weaponSkinID && weaponSkinID != 0 && TbUtil.TryGetCfg<WeaponSkinConfig>(weaponSkinID.Value, out var weaponSkinConfig))
            {
                var partNames = BattleUtil.GetWeaponParts(weaponSkinConfig.ID);
                if (partNames != null)
                {
                    foreach (var partName in partNames)
                    {
                        BattleCharacterMgr.AddPart(model, partName, autoSyncLod: false);
                        BattleCharacterMgr.GetPartParentBone(model, partName);
                    }
                }

                // DONE: 查询额外武器部件， 第二个参数True表示表演Action的部件
                var extParts = BattleEnv.GetHeroExtWeaponParts(actorIsGirl ? HeroType.Girl : HeroType.Boy, true);
                if (extParts != null)
                {
                    foreach (var extPart in extParts)
                    {
                        var isInclude = false;
                        if (partNames != null)
                        {
                            foreach (var partName in partNames)
                            {
                                if (!partName.Equals(extPart)) continue;
                                isInclude = true;
                                break;
                            }

                            if (isInclude)
                            {
                                continue;
                            }
                        }

                        // 表演女主添加全部部件并隐藏
                        BattleCharacterMgr.AddPart(model, extPart, false, autoSyncLod: false);
                        BattleCharacterMgr.HidePart(model, extPart, true);
                    }
                }
            }

            if (actorIsGirl || actorIsBoy)
            {
                //男女主高低模都需要的情况处理
                var x3Character = model.GetComponent<X3Character>();

                // DONE: 默认禁用IK
                X3.Character.ISubsystem subsystem = x3Character.GetSubsystem(X3.Character.ISubsystem.Type.FootIK);
                if (subsystem is X3FootIK x3FootIK)
                {
                    x3FootIK.enabled = false;
                }

                if (x3Character != null && BattleEnv.GetHeroLODUseType(actorIsGirl ? HeroType.Girl : HeroType.Boy) == LODUseType.LDHD && lod != BattleCharacterMgr.LOD_HD)
                {
                    // NOTE: 只有当加载角色的lod 不等于 游戏真正用到的LOD时, 才存在切换LOD的可能.
                    x3Character.LOD = BattleCharacterMgr.LOD_HD;
                    var x3PhysicsCloth = x3Character.GetSubsystem(X3.Character.ISubsystem.Type.PhysicsCloth) as X3PhysicsCloth;
                    var currentPartNames = x3PhysicsCloth?.GetCurrentPartNames();
                    if (currentPartNames != null)
                    {
                        foreach (string partName in currentPartNames)
                        {
                            _CachePhysicsClothAsset(modelCfg, partName, BattleCharacterMgr.LOD_HD);
                            _CachePhysicsClothAsset(modelCfg, partName, BattleCharacterMgr.LOD_LD);
                        }
                    }
                }
            }
            else
            {
                //动画控制器(只有怪需要，男女主的动画通过timeline控制）
                var animator = BattleUtil.EnsureComponent<PlayableAnimator>(model);
                animator.updateMode = PlayableAnimator.UpdateMode.Manual;
                animator.applyRootMotion = false;
                animator.runtimeAnimatorController = BattleAnimatorCtrlContext.LoadAnimatorCtrl(modelCfg.AnimatorCtrlName);
                animator.SetCtrlWeight(1);
            }

            root.SetVisible(false);
            _modelIns.Add(modelCfg, root);
            return root;
        }

        private void _CachePhysicsClothAsset(ModelCfg modelCfg, string partName, int lod)
        {
            var physicsAssetPath = X3PhysicsCloth.GetClothPhysicsAssetPath(partName, lod);
            if (string.IsNullOrEmpty(physicsAssetPath))
            {
                return;
            }

            var physicsClothAsset = Res.Load<PhysicsClothAsset>(physicsAssetPath, Res.AutoReleaseMode.Scene);
            if (physicsClothAsset == null)
            {
                return;
            }

            if (!_TryGetValue(_physicsClothAssets, modelCfg, out var key, out var list))
            {
                list = new List<PhysicsClothAsset> { physicsClothAsset };
                _physicsClothAssets.Add(modelCfg, list);
            }
            else
            {
                list.Add(physicsClothAsset);
            }
        }

        #endregion

        #region --高品质残影相关--

        /// <summary>
        /// 返回一个GhostHD形象
        /// </summary>
        /// <param name="modelCfg">角色形象</param>
        /// <param name="material">材质参数，有可能为空</param>
        /// <returns></returns>
        public GameObject EnsureGhostHD(ModelCfg modelCfg, Material material = null)
        {
            if (modelCfg == null)
            {
                throw new ArgumentException("ModelCfg 不能为 null");
            }

            // DONE: 有缓存, 先用缓存里的.
            if (_TryGetValue(_ghostHDIns, modelCfg, out _, out var list))
            {
                if (list != null && list.Count > 0)
                {
                    int lastIndex = list.Count - 1;
                    var avatar = list[lastIndex];
                    list.RemoveAt(lastIndex);
                    // DONE: 从池子里取得统一打开显示隐藏.
                    avatar.SetVisible(true);
                    return avatar;
                }
            }

            // DONE: 没缓存现场加载.
            // 暂不考虑部件问题.
            var lod = BattleCharacterMgr.LOD_LD;
            var model = BattleResMgr.Instance.LoadActorGO(modelCfg, lod);
            var root = new GameObject(modelCfg.Name + "(Avatar)");
            root.transform.SetParent(battle.modelRootTrans);
            root.transform.position = new Vector3(0, -10000, 0);
            model.transform.SetParent(root.transform);
            model.transform.name = "Model";
            model.transform.localPosition = Vector3.zero;

            var modelGraph = PlayableAnimationManager.Instance()?.FindPlayGraph(model);
            if (null != modelGraph) modelGraph.Active = false;

            var x3Character = model.GetComponent<X3Character>();
            // 设置材质
            if (x3Character != null && material != null)
            {
                x3Character.SetToClone(material);
            }

            return root;
        }

        public void RecycleGhostHD(ModelCfg modelCfg, GameObject ghostHD)
        {
            if (null == modelCfg) return;
            if (null == ghostHD) return;
            ghostHD.SetVisible(false);
            ghostHD.transform.SetParent(battle.modelRootTrans);
            ghostHD.transform.position = new Vector3(0, -10000, 0);

            // DONE: 回池操作.
            if (!_TryGetValue(_ghostHDIns, modelCfg, out _, out var list))
            {
                list = new List<GameObject>();
                _ghostHDIns.Add(modelCfg, list);
            }

            list.Add(ghostHD);
        }

        public void DestroyAllGhostHD()
        {
            foreach (var keyValuePair in _ghostHDIns)
            {
                var list = keyValuePair.Value;
                for (var i = list.Count - 1; i >= 0; i--)
                {
                    var root = list[i];
                    var model = root.transform.Find("Model");
                    model.parent = null;
                    BattleResMgr.Instance.UnloadActorGO(model.gameObject, keyValuePair.Key);
                    GameObject.Destroy(root.gameObject);
                }
            }

            _ghostHDIns.Clear();
        }

        #endregion

        #region --模型爆衫相关--

        /// <summary>
        /// 当角色换部件
        /// </summary>
        /// <param name="arg"></param>
        private void _OnActorChangeParts(EventActorChangeParts arg)
        {
            if (!_TryGetValue(_modelIns, arg.actor.model.config, out _, out var outIns)) return;
            
            var model = outIns?.transform.Find("Model")?.gameObject;
            if (null == model) return;

            var addParts = ObjectPoolUtility.CommonStringList.Get();
            CharacterMgr.GetPartNamesWithPartType(model, (int)PartType.Weapon, addParts);
            addParts.AddRange(arg.parts);

            BattleCharacterMgr.ChangeParts(model, addParts);
            ObjectPoolUtility.CommonStringList.Release(addParts);
        }

        #endregion

        #region --通用方法--

        private static bool _TryGetValue<T>(Dictionary<ModelCfg, T> dict, ModelCfg key, out ModelCfg outKey, out T outValue)
        {
            outKey = null;
            outValue = default;
            if (null == dict)
            {
                return false;
            }

            foreach (var keyValue in dict)
            {
                if (!_EqualsModelCfg(keyValue.Key, key)) continue;
                outKey = keyValue.Key;
                outValue = keyValue.Value;
                return true;
            }

            return false;
        }

        private static bool _EqualsModelCfg(ModelCfg objA, ModelCfg objB)
        {
            if (objA is null)
            {
                return objB is null;
            }

            if (objB is null)
            {
                return false;
            }

            return objA == objB;
        }

        #endregion
    }
}