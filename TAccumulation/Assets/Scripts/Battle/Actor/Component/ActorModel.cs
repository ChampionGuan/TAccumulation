using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using BattleCurveAnimator;
using UnityEngine.Rendering;
using PapeGames.Rendering;
using X3.Character;
using Object = UnityEngine.Object;

namespace X3Battle
{
    public class ActorModel : ActorComponent
    {
        protected GameObject _model;
        protected X3Character _character;
        protected RenderActor _renderActor;
        protected List<Renderer> _renderers;
        protected Material _material;
        protected Material _materialIns;
        protected Light _modelSceneLight;
        protected ApproachDissolveModifier _approachDissolveModifier;
        protected MonsterOcclusionDissolveModifier _occlusionDissolveModifier;
        protected MonsterOcclusionSourceModifier _occlusionSourceModifier;

        protected float _dissolveTime;
        protected float _dissolveFactor;
        protected float _dissolveBaseValue;
        protected Action<EventScalerChange> _actionScalerChange;

        public ModelCfg config => actor.createCfg.ModelCfg;
        public ModelInfo modelInfo => actor.modelInfo;
        public ActorPlayable playable { get; private set; }
        public BattleAnimator animator { get; private set; }
        public CurveAnimator curveAnimator { get; private set; }
        public bool isBrokenShirt { get; private set; }
        public bool physicsClothPaused { get; private set; }

        public float dissolveAlpha
        {
            get
            {
                var alpha = 1f;
                if (null != _approachDissolveModifier)
                {
                    // XTBUG-34478 如果近距离虚化被禁用，强制虚化的值也会生效
                    alpha = _approachDissolveModifier.dissolveEnable ? Mathf.Min(_approachDissolveModifier.currentAlpha, _approachDissolveModifier.forceDissolve) : _approachDissolveModifier.forceDissolve;
                }

                if (null != _occlusionDissolveModifier)
                {
                    alpha = Mathf.Min(_occlusionDissolveModifier.currentAlpha, alpha);
                }

                return alpha;
            }
        }

        public ActorModel() : base(ActorComponentType.Model)
        {
            requiredAnimationJobRunning = true;
            requiredPhysicalJobRunning = true;
            _actionScalerChange = _OnScalerChange;
        }

        protected override void OnAwake()
        {
            _model = actor.GetDummy(ActorDummyType.Model).gameObject;
            _character = _model.GetComponent<X3Character>();
            _LoadAnimator();
            _LoadMaterial();
        }

        protected override void OnStart()
        {
            _InitAnimator();
            _InitRenderer();
            _InitOcclusion();
            _InitCurveAnimator();
            _InitModelSceneLight();
        }

        protected override void OnDestroy()
        {
            _UnloadMaterial();
            _UnloadAnimator();
            _UnloadModelSceneLight();
            _UnloadCurveAnimator();
            _UnloadOcclusion();
        }

        public override void OnBorn()
        {
            if (null != animator)
            {
                animator.OnBorn();
            }

            _dissolveFactor = 0;
            _SwitchShadow(true);
            battle.eventMgr.AddListener(EventType.OnScalerChange, _actionScalerChange, "ActorModel._OnScalerChange()");
        }

        public override void OnRecycle()
        {
            if (null != curveAnimator)
            {
                curveAnimator.ResetAnimator();
            }

            if (null != animator)
            {
                animator.OnRecycle();
            }

            if (null != _approachDissolveModifier)
            {
                _approachDissolveModifier.forceDissolve = 1f;
            }

            battle.eventMgr.RemoveListener(EventType.OnScalerChange, _actionScalerChange);
        }

        protected override void OnAnimationJobRunning()
        {
            playable?.OnUpdate(battle.deltaTime);
            curveAnimator?.Update(actor.deltaTime);
        }

        protected override void OnPhysicalJobRunning()
        {
            curveAnimator?.OnLateUpdate();
            if (_dissolveFactor != 0 && null != _approachDissolveModifier)
            {
                _dissolveTime += actor.deltaTime;
                var dissolveValue = _dissolveBaseValue + _dissolveTime * _dissolveFactor;
                if (dissolveValue > 1 || dissolveValue < 0) _dissolveFactor = 0;
                _approachDissolveModifier.forceDissolve = Mathf.Clamp01(dissolveValue);
            }
        }

        public override void OnDead()
        {
            _SwitchShadow(false);
            curveAnimator?.RemoveAll(); //死亡清除所有效果 防止死亡效果被覆盖
        }

        /// <summary>
        /// 虚化效果（模型下的特效不影响）
        /// </summary>
        /// <param name="fadingTime"></param>
        /// <param name="isFadein"></param>
        public void DissolveFade(float fadingTime, bool isFadein)
        {
            if (null == _approachDissolveModifier) return;
            var tgtValue = isFadein ? 1 : 0;
            if (fadingTime == 0)
            {
                _approachDissolveModifier.forceDissolve = tgtValue;
                return;
            }

            _dissolveBaseValue = Mathf.Clamp01(_approachDissolveModifier.forceDissolve);
            _dissolveFactor = (tgtValue - _dissolveBaseValue) / fadingTime;
            _dissolveTime = 0;
        }

        /// <summary>
        /// 禁用镜头靠近虚化效果
        /// </summary>
        /// <param name="enable"></param>
        public void SetApproachDissolveEnable(bool enable)
        {
            if (null != _approachDissolveModifier)
                _approachDissolveModifier.dissolveEnable = enable;
        }

        public void BrokenShirt()
        {
            //只有Hero类型的模型才会有爆衫
            if (isBrokenShirt || config.Type != ActorType.Hero)
            {
                return;
            }

            isBrokenShirt = true;
            _ChangeShirt(config.SuitID, isBrokenShirt);
        }

        public void RestoreShirt()
        {
            //只有Hero类型的模型才会有爆衫
            if (!isBrokenShirt || config.Type != ActorType.Hero)
            {
                return;
            }

            isBrokenShirt = false;
            _ChangeShirt(config.SuitID, isBrokenShirt);
        }

        public void SwitchSceneLight(bool v)
        {
            if (_modelSceneLight == null)
                return;
            _modelSceneLight.enabled = v;
        }

        public void SetPhysicsClothPaused(bool isPause)
        {
            physicsClothPaused = isPause;
            _SetPhysicsClothScale(actor.timeScale * (physicsClothPaused ? 0f : 1));
        }

        public void OcclusionSourceModifierEnable(bool enable)
        {
            if (_occlusionSourceModifier == null)
            {
                _occlusionSourceModifier = _model.GetOrAddComponent<MonsterOcclusionSourceModifier>();
                _renderActor.__AddContainingModifier(_occlusionSourceModifier);
                if (!string.IsNullOrEmpty(modelInfo.occlusionCfg.bonePath))
                    _occlusionSourceModifier.pivot = _model.transform.Find(modelInfo.occlusionCfg.bonePath);
            }

            _occlusionSourceModifier.enabled = enable;
        }

        private void _InitOcclusion()
        {
            _renderActor = _model.GetComponent<RenderActor>();
            if (_renderActor == null)
                return;

            if (actor.modelInfo.approachDissolveCfg.isUse)
            {
                _approachDissolveModifier = _renderActor.GetOrAddComponent<ApproachDissolveModifier>();
                _approachDissolveModifier.dissolveEnable = true;

                if (_approachDissolveModifier.approachCapsuleList == null)
                    _approachDissolveModifier.approachCapsuleList = new List<ApproachDissolveModifier.CapsuleItem>();
                else
                    _approachDissolveModifier.approachCapsuleList.Clear();
                for (int i = 0; i < actor.modelInfo.approachDissolveCfg.capsules.Length; i++)
                {
                    var capsule = new ApproachDissolveModifier.CapsuleItem();
                    capsule.radius = actor.modelInfo.approachDissolveCfg.capsules[i].radius;
                    capsule.rotate = actor.modelInfo.approachDissolveCfg.capsules[i].rotate;
                    capsule.offset = actor.modelInfo.approachDissolveCfg.capsules[i].offset;
                    capsule.halfHeight = actor.modelInfo.approachDissolveCfg.capsules[i].halfHeight;
                    capsule.pivot = _model.transform.Find(actor.modelInfo.approachDissolveCfg.capsules[i].path);
                    if (capsule.pivot == null)
                        capsule.pivot = _model.transform;
                    _approachDissolveModifier.approachCapsuleList.Add(capsule);
                }

                if (battle.misc.modelInfoCommon != null)
                    _approachDissolveModifier.dissolveCurve = battle.misc.modelInfoCommon.approachDissolveCurve;
            }

            if (actor.IsGirl())
            {
                OcclusionSourceModifierEnable(true);
            }
            else if (actor.IsBoy())
            {
                OcclusionSourceModifierEnable(false);
            }
            else if (config.Type == ActorType.Monster)
            {
                _occlusionDissolveModifier = _model.GetOrAddComponent<MonsterOcclusionDissolveModifier>();
                _renderActor.__AddContainingModifier(_occlusionDissolveModifier);
                if (!string.IsNullOrEmpty(modelInfo.occlusionCfg.bonePath))
                    _occlusionDissolveModifier.pivot = _model.transform.Find(modelInfo.occlusionCfg.bonePath);
                _occlusionDissolveModifier.MinAlpha = modelInfo.occlusionCfg.minAlpha;
                _occlusionDissolveModifier.DelayTime = modelInfo.occlusionCfg.delayTime;
                _occlusionDissolveModifier.inRadius = modelInfo.occlusionCfg.inRadius;
                _occlusionDissolveModifier.outRadius = modelInfo.occlusionCfg.outRadius;
            }
        }

        private void _UnloadOcclusion()
        {
            // 已和空气确认，虚化组件不需要移除，参数重置即可
            if (null != _approachDissolveModifier)
            {
                _approachDissolveModifier.dissolveEnable = false;
                _approachDissolveModifier.approachCapsuleList.Clear();
                ApproachDissolveModifier.CapsuleItem item = ApproachDissolveModifier.CapsuleItem.defaultValue;
                _approachDissolveModifier.approachCapsuleList.Add(item);
            }

            if (null != _occlusionDissolveModifier)
            {
                _occlusionDissolveModifier.pivot = null;
                _occlusionDissolveModifier.MinAlpha = 0.2f;
                _occlusionDissolveModifier.DelayTime = 0.3f;
                _occlusionDissolveModifier.inRadius = 0.5f;
                _occlusionDissolveModifier.outRadius = 1f;
            }

            if (null != _occlusionSourceModifier)
            {
                _occlusionSourceModifier.pivot = null;
            }

            _approachDissolveModifier = null;
            _occlusionDissolveModifier = null;
            _occlusionSourceModifier = null;
        }

        private void _InitCurveAnimator()
        {
            if (null == actor.roleCfg)
            {
                return;
            }

            curveAnimator = BattleUtil.EnsureComponent<CurveAnimator>(_model);
            curveAnimator.Init(2, true, true);
            curveAnimator.updateMode = CurveAnimator.UpdateMode.Manual;

            //TODO 临时代码 迟早会干掉BattleEffect 现在代码删除防止影响CurveAnimator
            var bes = _model.GetComponentsInChildren<BattleBaseEffect>(true);
            for (var i = 0; i < bes.Length; i++)
            {
                Object.Destroy(bes[i]);
            }
        }

        private void _UnloadCurveAnimator()
        {
            if (curveAnimator)
            {
                curveAnimator.ResetAnimator();
                Object.DestroyImmediate(curveAnimator);
            }
        }

        private void _InitRenderer()
        {
            if (_renderers == null)
                _renderers = new List<Renderer>();
            else
                _renderers.Clear();

            _GetNodeRender("Body", _renderers);
            _GetNodeRender("Weapon", _renderers);
        }

        private void _GetNodeRender(string nodeName, List<Renderer> list)
        {
            var nodeGO = _model.transform.Find(nodeName);
            if (nodeGO == null) return;

            var renderers = nodeGO.GetComponentsInChildren<Renderer>(true);
            foreach (var renderer in renderers)
            {
                var material = renderer.sharedMaterial;
                if (material == null)
                    continue;

                var shaderName = material.shader.name;
                foreach (var s in TbUtil.battleConsts.TargetShaderName)
                {
                    if (shaderName.Contains(s))
                        list.Add(renderer);
                }
            }
        }

        private void _SwitchShadow(bool isOn)
        {
            foreach (var r in _renderers)
            {
                r.shadowCastingMode = isOn ? ShadowCastingMode.On : ShadowCastingMode.Off;
            }
        }

        private void _LoadAnimator()
        {
            if (string.IsNullOrEmpty(config.AnimatorCtrlName)) return;
            if (null == playable) playable = new ActorPlayable(actor.EnsureComponent<Animator>(_model));
            if (null == animator) animator = actor.EnsureComponent<BattleAnimator>(_model);
        }

        private void _InitAnimator()
        {
            animator?.OnStart(actor, config.AnimatorCtrlName);
        }

        private void _UnloadAnimator()
        {
            if (null != animator)
            {
                Object.DestroyImmediate(animator);
                animator = null;
            }

            if (null != playable)
            {
                playable.OnDestroy();
                playable = null;
            }
        }

        private void _InitModelSceneLight()
        {
            if (battle.player != actor)
                return;
            if (_modelSceneLight != null)
                return;
            if (BattleCharacterMgr.IsBadQualityDevice) //低配不加载
                return;

            var path = battle.config.PlayerSceneLightPath ?? battle.config.SceneName + "_Light";
            if (!BattleResMgr.Instance.IsExists(path, BattleResType.ActorSceneLight))
                return;
            var lightGo = BattleResMgr.Instance.Load<GameObject>(path, BattleResType.ActorSceneLight);
            lightGo.transform.SetParent(_model.transform, false); //保持位置
            _modelSceneLight = lightGo.GetComponent<Light>();
            //Debug.LogError(BattleCharacterMgr.GetRecommendGQLevel() + "我是主角灯:" + path);
        }

        private void _UnloadModelSceneLight()
        {
            if (_modelSceneLight == null)
                return;

            BattleResMgr.Instance.Unload(_modelSceneLight);
        }

        private void _LoadMaterial()
        {
            if (null == _character)
            {
                return;
            }

            var materialName = actor.createCfg.Material;
            if (string.IsNullOrEmpty(materialName))
            {
                return;
            }

            var material = BattleResMgr.Instance.Load<Material>(materialName, BattleResType.Material);
            if (material == null)
            {
                return;
            }

            _material = material;
            var materialClone = Object.Instantiate(material);
            _materialIns = materialClone;
            _character.SetToClone(materialClone);
        }

        private void _UnloadMaterial()
        {
            if (_materialIns != null) Object.Destroy(_materialIns);
            if (_material == null) return;
            BattleResMgr.Instance.Unload(_material);
            _material = null;
        }

        private void _ChangeShirt(int suitID, bool brokenSuit)
        {
            BattleCharacterMgr.GetBase2PartKeysBySuitID(suitID, out var parts, out _, brokenSuit);
            if (null == parts || parts.Length < 1)
            {
                LogProxy.LogError($"[ActorModel._ChangeShirt()] errorMsg:无此套装:{suitID}的{(brokenSuit ? "爆衫" : "")}部件数据，请检查！！");
                return;
            }

            var addParts = ObjectPoolUtility.CommonStringList.Get();
            CharacterMgr.GetPartNamesWithPartType(_model, (int)PartType.Weapon, addParts);
            addParts.AddRange(parts);

            //爆衣时的部件动态加载符合预期，不打印error
            bool preValue = BattleResMgr.isDynamicBottomLoadErring;
            BattleResMgr.isDynamicBottomLoadErring = false;
            BattleCharacterMgr.ChangeParts(_model, addParts);
            // 换衫后，重新获取渲染组件！
            _InitRenderer();
            curveAnimator.InitRender(true, true);

            // 抛出事件
            var data = actor.eventMgr.GetEvent<EventActorChangeParts>();
            data.Init(actor, parts, brokenSuit);
            actor.eventMgr.Dispatch(EventType.ActorChangeParts, data);
            BattleResMgr.isDynamicBottomLoadErring = preValue;
            ObjectPoolUtility.CommonStringList.Release(addParts);
        }

        private void _SetPhysicsClothScale(float scale)
        {
            if (_character == null)
                return;

            if (_character.GetSubsystem(X3.Character.ISubsystem.Type.PhysicsCloth) is X3PhysicsCloth physicsCloth)
            {
                if (scale > 1) scale = 1; // scale大于1会寄掉

                physicsCloth.SetTimeScale(scale);
            }
        }

        private void _OnScalerChange(EventScalerChange arg)
        {
            if (arg.timeScalerOwner is Actor actor && actor != this.actor)
                return;

            _SetPhysicsClothScale(this.actor.timeScale * battle.timeScale * (physicsClothPaused ? 0f : 1));
        }
    }
}