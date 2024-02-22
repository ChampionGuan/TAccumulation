using System;
using System.Collections.Generic;
using Framework;
using PapeGames.X3;
using UnityEngine;
using X3.PlayableAnimator;

namespace X3Battle
{
    public class BattleAnimator : PlayableAnimator
    {
        public struct RMMultiplier
        {
            public float xAxial;
            public float yAxial;
            public float zAxial;
            public bool living;
        }

        protected Dictionary<RMMultiplierType, RMMultiplier> _rmMultiplier;

        protected Actor actor;
        protected AnimCtrlPlayable _ctrlPlayable;
        protected AnimatorController _runtimeCtrl;
        protected Dictionary<string, string> _replacedState = new Dictionary<string, string>();
        protected int _frameCount;
        protected Action<EventAttrChange> _actionMoveSpeedChanged;
        protected Action<EventScalerChange> _actionScalerChange;
        protected BoneOverwrite _boneOverwrite = new BoneOverwrite();
        protected Vector3? _deltaPosition;
        protected Quaternion? _deltaRotation;
        protected List<Transform> _temptTransList = new List<Transform>();

        public StateNotifyEvent onStateNotify => stateNotify;
        public ActorAnimUpdateMode customUpdateMode { get; private set; }
        public DynamicAnimationGraph animationGraph => PlayableAnimationManager.Instance()?.FindPlayGraph(gameObject);
        public float rmMultiplierX { get; private set; }
        public float rmMultiplierY { get; private set; }
        public float rmMultiplierZ { get; private set; }
        public Vector3 velocity { get; private set; }

        #region Battle Event Function

        /// <summary>
        /// 初始化
        /// </summary>
        /// <param name="owner"></param>
        /// <param name="ctrlName"></param>
        public void OnStart(Actor owner, string ctrlName)
        {
            _actionMoveSpeedChanged = OnMoveSpeedAttrChanged;
            _actionScalerChange = OnScalerChange;
            actor = owner;
            avatar = animator.avatar;
            applyRootMotion = true;
            cullingMode = AnimatorCullingMode.AlwaysAnimate;
            updateMode = UpdateMode.Manual;
            customUpdateMode = ActorAnimUpdateMode.Auto;
            animator.runtimeAnimatorController = null;

            InitRmMultiplier();
            runtimeAnimatorController = _runtimeCtrl = BattleAnimatorCtrlContext.LoadAnimatorCtrl(ctrlName);
            actor.battle.onPostUpdate.Add(OnUpdate);
            actor.battle.onAnimationJobCompleted.AddListener(OnAnimationJobCompleted);
            actor.battle.eventMgr.AddListener<EventActorBase>(EventType.ActorBorn, OnActorBorn, "BattleAnimator.OnActorBorn");
            actor.battle.eventMgr.AddListener<EventActorStateChange>(EventType.ActorStateChange, OnMainStateChanged, "BattleAnimator.OnMainStateChanged");
            if (null == runtimeAnimatorController) enabled = false;
            SetConcurrentToMotions();
        }

        public void OnBorn()
        {
            enabled = true;
            actor?.eventMgr.AddListener<EventAttrChange>(EventType.MoveSpeedChange, _actionMoveSpeedChanged, "BattleAnimator.OnMoveSpeedAttrChanged");
            actor?.battle.eventMgr.AddListener(EventType.OnScalerChange, _actionScalerChange, "BattleAnimator.OnScalerChange");
        }

        public void OnRecycle()
        {
            enabled = false;
            _runtimeCtrl?.context?.Reset();
            actor?.eventMgr.RemoveListener<EventAttrChange>(EventType.MoveSpeedChange, _actionMoveSpeedChanged);
            actor?.battle.eventMgr.RemoveListener(EventType.OnScalerChange, _actionScalerChange);
        }

        #endregion

        #region Unity Event Function

        /// <summary>
        /// 继承父类Start
        /// </summary>
        protected override void Start()
        {
            Update(0);
            animationGraph?.Update();
        }

        /// <summary>
        /// 继承父类Update，不走它的逻辑，避免出现不可控问题
        /// </summary>
        protected override void Update()
        {
        }

        /// <summary>
        /// 继承父类OnEnable
        /// </summary>
        protected override void OnEnable()
        {
            if (null != runtimeAnimatorController && null != animationGraph) animationGraph.Active = true;
            _deltaPosition = null;
            _deltaRotation = null;
        }

        /// <summary>
        /// 继承父类OnDisable
        /// </summary>
        protected override void OnDisable()
        {
            if (null != animationGraph) animationGraph.Active = false;
        }

        /// <summary>
        /// 继承父类OnDestroy
        /// </summary>
        protected override void OnDestroy()
        {
            if (null != actor?.battle)
            {
                actor.battle.onPostUpdate.Remove(OnUpdate);
                actor.battle.onAnimationJobCompleted.RemoveListener(OnAnimationJobCompleted);
                actor.battle.eventMgr.RemoveListener<EventActorBase>(EventType.ActorBorn, OnActorBorn);
                actor.battle.eventMgr.RemoveListener<EventActorStateChange>(EventType.ActorStateChange, OnMainStateChanged);
            }

            BattleAnimatorCtrlContext.UnloadAnimatorCtrl(_runtimeCtrl);
            _runtimeCtrl = null;
            _rmMultiplier = null;
            base.OnDestroy();
        }

        private void OnAnimatorMove()
        {
            if (!applyRootMotion)
            {
                return;
            }

            _deltaPosition = animator.deltaPosition;
            _deltaRotation = animator.deltaRotation;
        }

        #endregion

        public void InitRmMultiplier()
        {
            if (_rmMultiplier == null)
                _rmMultiplier = new Dictionary<RMMultiplierType, RMMultiplier>();
            _rmMultiplier[RMMultiplierType.Base] = new RMMultiplier { yAxial = 1, xAxial = 1, zAxial = 1, living = true };
            _rmMultiplier[RMMultiplierType.MoveSpeedAttr] = new RMMultiplier { yAxial = 1, xAxial = 1, zAxial = 1, living = false };
            _rmMultiplier[RMMultiplierType.AbnormalState] = new RMMultiplier { yAxial = 1, xAxial = 1, zAxial = 1, living = false };
            _rmMultiplier[RMMultiplierType.Dominate] = new RMMultiplier { yAxial = 1, xAxial = 1, zAxial = 1, living = false };
        }

        public void InitBoneOverwrite(Transform[] boneOverwrite, Transform[] newParent)
        {
            var playable = actor?.model?.playable;
            if (null == playable)
            {
                return;
            }

            if (_boneOverwrite.TrySetBoneTransform(boneOverwrite, newParent))
                _boneOverwrite.RebuildPlayable(animator, _ctrlPlayable.playable, playable.playable, runtimeAnimatorController, 0);
        }

        public void SetPrevBone(Transform root, int layer)
        {
            _temptTransList.Clear();
            for (int i = 0; i < root.childCount; i++)
            {
                var skinRender = root.GetChild(i).GetComponent<SkinnedMeshRenderer>();
                if(skinRender!= null)
                    CollectBone(skinRender.rootBone, _temptTransList);
            }
            
            SetPrevBone(layer, _temptTransList.ToArray());
        }

        private void CollectBone(Transform root, List<Transform> trans)
        {
            trans.Add(root);
            if (root.childCount == 0)
                return;
            for (int i = 0; i < root.childCount; i++)
            {
                CollectBone(root.GetChild(i), trans);
            }

        }

        /// <summary>
        /// 战斗角色动画默认不带有Evaluate
        /// 原则上不允许外部调用，目前存在两个特殊情况必须外部去调用Update 1.离线编辑器下 2.爆发技下驱动动画
        /// 
        /// </summary>
        /// <param name="deltaTime"></param>
        /// <param name="withEvaluate"></param>
        public override void Update(float deltaTime, bool withEvaluate = false)
        {
            if (actor.battle.frameCount != _frameCount)
            {
                _frameCount = actor.battle.frameCount;
                // 一帧里只会Update一次
                base.Update(deltaTime * speed, false);
            }
            else
            {
                base.Update(0, false);
            }

            if (withEvaluate)
            {
                _ctrlPlayable?.graph.Evaluate();
            }
        }

        /// <summary>
        /// 设置动画更新模式，更新方可以为多处
        /// </summary>
        /// <param name="mode"></param>
        public void SetUpdateMode(ActorAnimUpdateMode mode)
        {
            if (customUpdateMode == mode)
            {
                return;
            }

            customUpdateMode = mode;
        }

        /// <summary>
        /// RebuildPlayable，由上层发起
        /// </summary>
        protected override void RebuildPlayable()
        {
            var playable = actor?.model?.playable;
            if (null == playable)
            {
                return;
            }

            playable.RemoveChild(_ctrlPlayable);
            if (null == runtimeAnimatorController)
            {
                return;
            }

            _ctrlPlayable = _ctrlPlayable ?? new AnimCtrlPlayable(this);
            playable.AddChild(_ctrlPlayable);

            _boneOverwrite.RebuildPlayable(animator, _ctrlPlayable.playable, playable.playable, runtimeAnimatorController, 0);
        }

        public void AddOverwriteClip(AnimationClip clip)
        {
            _boneOverwrite.AddOverwriteClip(clip);
        }

        public void EnableOverwrite(string clipName, bool enable)
        {
            _boneOverwrite.EnableOverwrite(clipName, enable);
        }

        public void EnableTransformToNewParent(bool enable)
        {
            _boneOverwrite.EnableTransformToNewParent(enable);
        }

        public BattleAnimatorCtrlContext CreateContext()
        {
            var transforms = new List<Transform>();
            var parents = new List<Transform>();
            foreach (var layerOverwriteBone in actor.modelInfo.layerOverwriteBones)
            {
                var trans = actor.GetDummy(ActorDummyType.Model).Find(layerOverwriteBone.bonePath);
                var parent = actor.GetDummy(ActorDummyType.Model).Find(layerOverwriteBone.newParentBonePaths);
                if (trans != null && parent != null)
                {
                    transforms.Add(trans);
                    parents.Add(parent);
                }
            }
            return new BattleAnimatorCtrlContext(transforms.ToArray(), parents.ToArray());
        }
        
        /// <summary>
        /// 播放动画
        /// </summary>
        /// <param name="stateName">状态名称</param>
        /// <param name="skipSameState">跳过相同动画</param>
        /// <param name="fadeTime">过渡时间</param>
        /// <param name="layerIndex">所在层Index</param>
        /// <param name="stateSpeed">播放速度</param>
        public void PlayAnim(string stateName, bool skipSameState = true, float fadeTime = 0, int layerIndex = 0, float? stateSpeed = null)
        {
            if (string.IsNullOrEmpty(stateName))
            {
                return;
            }

            var name = GetReplaceStateName(stateName);
            if (null != stateSpeed)
            {
                SetStateSpeed(name, stateSpeed.Value, layerIndex);
            }

            if (fadeTime > 0)
                CrossFadeInFixedTime(name, fadeTime, layerIndex, skipSameState ? float.NegativeInfinity : 0);
            else
                CrossFadeInFixedTime(name, layerIndex, skipSameState ? float.NegativeInfinity : 0);
        }

        /// <summary>
        /// 播放动画
        /// </summary>
        /// <param name="stateName"></param>
        /// <param name="offsetTime"></param>
        /// <param name="fadeTime"></param>
        /// <param name="layerIndex"></param>
        public void PlayAnim(string stateName, float offsetTime, float fadeTime, int layerIndex = 0, float? stateSpeed = null)
        {
            if (string.IsNullOrEmpty(stateName))
            {
                return;
            }

            var name = GetReplaceStateName(stateName);
            if (null != stateSpeed)
            {
                SetStateSpeed(name, stateSpeed.Value, layerIndex);
            }

            if (fadeTime > 0)
                CrossFadeInFixedTime(name, fadeTime, layerIndex, offsetTime);
            else
                CrossFadeInFixedTime(name, layerIndex, offsetTime);
        }

        /// <summary>
        /// 设置RootMotion缩放系数
        /// </summary>
        /// <param name="x">xz轴缩放系数，空则保持</param>
        /// <param name="y">y轴缩放系数，空则保持</param>
        /// <param name="live">是否禁用，空则保持</param>
        /// <param name="type">作用类型</param>
        public void SetRootMotionMultiplier(float? x = null, float? y = null, float? z = null, bool? live = null, RMMultiplierType type = RMMultiplierType.Base)
        {
            if (null == _rmMultiplier) return;

            var multiplier = _rmMultiplier[type];
            if (null != y) multiplier.yAxial = y.Value;
            if (null != x) multiplier.xAxial = x.Value;
            if (null != z) multiplier.zAxial = z.Value;
            if (null != live) multiplier.living = live.Value;
            _rmMultiplier[type] = multiplier;

            rmMultiplierY = 1f;
            rmMultiplierX = 1f;
            rmMultiplierZ = 1f;
            foreach (var keyValue in _rmMultiplier)
            {
                if (!keyValue.Value.living) continue;
                rmMultiplierX *= keyValue.Value.xAxial;
                rmMultiplierY *= keyValue.Value.yAxial;
                rmMultiplierZ *= keyValue.Value.zAxial;
                if (keyValue.Key != RMMultiplierType.Dominate) continue;
                rmMultiplierX = keyValue.Value.xAxial;
                rmMultiplierY = keyValue.Value.yAxial;
                rmMultiplierZ = keyValue.Value.zAxial;
                break;
            }
        }

        /// <summary>
        /// 替换状态名称
        /// </summary>
        /// <param name="nameOriginal"></param>
        /// <param name="nameReplaced"></param>
        public void ReplaceStateName(string nameOriginal, string nameReplaced)
        {
            if (_replacedState.ContainsKey(nameOriginal))
            {
                _replacedState[nameOriginal] = nameReplaced;
            }
            else
            {
                _replacedState.Add(nameOriginal, nameReplaced);
            }
        }

        /// <summary>
        /// 获取替换的状态名称
        /// </summary>
        /// <param name="name"></param>
        /// <returns></returns>
        public string GetReplaceStateName(string name)
        {
            return _replacedState.TryGetValue(name, out var replaced) ? replaced : name;
        }

        /// <summary>
        /// 获取当前动画状态信息
        /// </summary>
        /// <param name="layerIndex"></param>
        /// <returns></returns>
        public string GetCurrentAnimatorStateName(int layerIndex = 0)
        {
            return GetCurrentAnimatorStateInfo(layerIndex).name;
        }

        /// <summary>
        /// 获取动画状态长度
        /// </summary>
        /// <param name="stateName"></param>
        /// <param name="layerIndex"></param>
        /// <returns></returns>
        public new float GetAnimatorStateLength(string stateName, int layerIndex = 0)
        {
            var length = base.GetAnimatorStateLength(stateName, layerIndex);
            return length ?? 0;
        }

        public AnimationClip GetAnimatorStateClip(string stateName, int layerIndex = 0)
        {
            return null != runtimeAnimatorController ? runtimeAnimatorController.GetAnimatorStateClip(stateName, layerIndex) : null;
        }


        /// <summary>
        /// 计算BlendTree绑定的parameter值，blendTree输出为期望值
        /// </summary>
        /// <param name="stateName"></param> 状态名
        /// <param name="inValue"></param> 输入值
        /// <param name="layerIndex"></param> layer
        /// <returns></returns>
        public bool TryCalBlendTreeParamValue(string blendTreeName, float inValue, out float value, int layerIndex = 0, ComputeThresholdsType type = ComputeThresholdsType.Speed)
        {
            value = 0;
            return runtimeAnimatorController && runtimeAnimatorController.TryCalParameterValue(blendTreeName, inValue, layerIndex, out value);
        }

        /// <summary>
        /// 为StateMotion设置动作模组
        /// </summary>
        private void SetConcurrentToMotions()
        {
            if (runtimeAnimatorController == null)
                return;

            AnimatorControllerLayer layer = runtimeAnimatorController.GetLayer(0);
            Dictionary<string, StateToTimeline> animDict = new Dictionary<string, StateToTimeline>(); // 存stateName对应的timeline名

            // 找到state对应的timeline以及concurrent
            foreach (var config in TbUtil.stateToTimelines.Values)
            {
                //女主
                if (actor.IsGirl())
                {
                    var weaponSkinId = actor.battle.arg.girlWeaponID;
                    if (weaponSkinId <= 0)
                    {
                        LogProxy.LogError("女主武器皮肤配置无法读取到，请检查配置");
                        continue;
                    }
                    var weaponSkinConfig = TbUtil.GetCfg<WeaponSkinConfig>(weaponSkinId);
                    if (weaponSkinConfig == null)
                    {
                        LogProxy.LogError("女主武器皮肤配置无法读取到，请检查配置");
                        continue;
                    }

                    if (config.GroupID != 0 && weaponSkinConfig.BSTTGroupID != config.GroupID)
                    {
                        continue;
                    }
                }
                else if (actor.IsBoy())
                {
                    if (actor.boyCfg.BSTTGroupID != config.GroupID)
                    {
                        continue;
                    }
                }
                else if (actor.IsMonster())
                {
                    if (actor.monsterCfg.BSTTGroupID != config.GroupID)
                    {
                        continue;
                    }
                }

                if (animDict.ContainsKey(config.StateName) && animDict[config.StateName].Priority > config.Priority)
                {
                    // 如果state已有优先级，且优先级高于当前遍历到的config的优先级
                    continue;
                }

                animDict[config.StateName] = config;
            }

            for (int i = 0; i < layer.statesCount; i++)
            {
                var state = layer.GetState<StateMotion>(i);
                if (state != null)
                {
                    if (state.isBlendTree)
                    {
                        var blendTreeChildren = (state.motion as BlendTree).childMotions;
                        var childTimelineMotions = new List<TimelineMotion>();
                        foreach (var blendTreeChild in blendTreeChildren)
                        {
                            var clipName = blendTreeChild.clip.name;
                            if (animDict.ContainsKey(clipName))
                            {
                                var timelineMotion = new TimelineMotion(animDict[clipName].ActionModeID, actor, blendTreeChild.clip.isLooping);
                                LogProxy.Log("动作模组： actor.name = " + actor.name + " clipName = " + clipName + " 绑定了动作模组：" + animDict[clipName].ActionModeID);
                                childTimelineMotions.Add(timelineMotion);
                            }
                            else
                            {
                                // 没有配置的话创一个空的TimelineMotion占位置
                                childTimelineMotions.Add(new TimelineMotion(0, actor, blendTreeChild.clip.isLooping, null));
                                // LogProxy.Log("动作模组： actor.name = " + actor.name + " clipName = " + clipName +"创建空动作模组占位");
                            }
                        }

                        state.motion.SetConcurrent(new BlendTreeMotion(childTimelineMotions));
                    }
                    else
                    {
                        if (animDict.ContainsKey(state.name))
                        {
                            LogProxy.Log("动作模组： actor.name = " + actor.name + " state.name = " + state.name + " 绑定了动作模组：" + animDict[state.name].ActionModeID);
                            state.motion.SetConcurrent(new TimelineMotion(animDict[state.name].ActionModeID, actor, state.isLooping));
                        }
                    }
                }
            }
        }

        private void OnUpdate()
        {
            if (!isRunning || customUpdateMode != ActorAnimUpdateMode.Auto) return;
            using (ProfilerDefine.AnimatorUpdatePMarker.Auto())
            {
                Update(actor.battle.unscaledDeltaTime);
                _boneOverwrite?.Update();
            }
        }

        private void OnAnimationJobCompleted()
        {
            if (!isRunning) return;

            using (ProfilerDefine.AnimatorSetDeltaTimePMarker.Auto())
            {
                if (null == _deltaPosition && null == _deltaRotation)
                {
                    return;
                }

                if (null != _deltaPosition && _deltaPosition != Vector3.zero)
                {
                    var deltaPos = _deltaPosition.Value;
                    velocity = deltaPos / actor.deltaTime;

                    var deltaModelUp = Vector3.Dot(deltaPos, actor.transform.up) * actor.transform.up * rmMultiplierY;
                    var deltaModelRight = Vector3.Dot(deltaPos, actor.transform.right) * actor.transform.right * rmMultiplierX;
                    var deltaModelForward = Vector3.Dot(deltaPos, actor.transform.forward) * actor.transform.forward * rmMultiplierZ;

                    deltaPos = deltaModelUp + deltaModelRight + deltaModelForward;
                    actor.transform.SetDeltaPosition(deltaPos);
                }

                if (null != _deltaRotation && _deltaRotation != Quaternion.identity)
                {
                    var deltaAngles = _deltaRotation.Value.eulerAngles;
                    // todo:XTBUG-15266 临时处理方式，前后帧为负值的情况
                    deltaAngles.x = deltaAngles.x > 180 ? deltaAngles.x - 360 : deltaAngles.x;
                    deltaAngles.y = deltaAngles.y > 180 ? deltaAngles.y - 360 : deltaAngles.y;
                    deltaAngles.z = deltaAngles.z > 180 ? deltaAngles.z - 360 : deltaAngles.z;
                    deltaAngles.x *= rmMultiplierX;
                    deltaAngles.y *= rmMultiplierY;
                    deltaAngles.z *= rmMultiplierZ;
                    actor.transform.SetDeltaEulerAngles(deltaAngles);
                }

                transform.localPosition = Vector3.zero;
                transform.localEulerAngles = Vector3.zero;
                _deltaPosition = null;
                _deltaRotation = null;
            }
        }

        private void OnActorBorn(EventActorBase data)
        {
            if (data.actor != actor || null == actor.attributeOwner || !actor.attributeOwner.ContainAttr(AttrType.MoveSpeed))
            {
                return;
            }

            var value = actor.attributeOwner.GetPerthAttrValue(AttrType.MoveSpeed);
            SetRootMotionMultiplier(value, value, value, null, RMMultiplierType.MoveSpeedAttr);
        }

        private void OnMoveSpeedAttrChanged(EventAttrChange data)
        {
            //移动属性有变化
            var value = actor.attributeOwner.GetPerthAttrValue(AttrType.MoveSpeed);
            SetRootMotionMultiplier(value, value, value, null, RMMultiplierType.MoveSpeedAttr);
        }

        private void OnScalerChange(EventScalerChange arg)
        {
            if (runtimeAnimatorController == null)
                return;

            if (arg.timeScalerOwner is Actor scalerActor && scalerActor != this.actor)
                return;
            
            for (int i = 0; i < runtimeAnimatorController.layersCount; i++)
            {
                var layer = runtimeAnimatorController.GetLayer(i);
                switch (layer.timeScaleType)
                {
                    case (int)AnimatorLayerTimeScalerType.Default:
                        layer.SetSpeed(actor.timeScale * actor.battle.timeScale);
                        break;
                    case (int)AnimatorLayerTimeScalerType.BattleTimeScale:
                        layer.SetSpeed(actor.battle.timeScale);
                        break;
                    default:
                        return;
                }
            }
        }

        private void OnMainStateChanged(EventActorStateChange data)
        {
            if (data.actor != actor)
            {
                return;
            }

            //Move态才会启用移动属性对应的RootMotion缩放值
            SetRootMotionMultiplier(null, null, null, data.toStateName == ActorMainStateType.Move, RMMultiplierType.MoveSpeedAttr);
        }
    }
}