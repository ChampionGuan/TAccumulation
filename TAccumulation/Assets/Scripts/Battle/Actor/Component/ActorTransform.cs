using System;
using System.Collections.Generic;
using EasyCharacterMovement;
using PapeGames.X3;
using Pathfinding;
using UnityEngine;
using Object = UnityEngine.Object;

namespace X3Battle
{
    public class ActorTransform : ActorComponent
    {
        public static readonly Vector3 RecycledPos = new Vector3(0f, -10000f, 0f);

        protected Transform _root;
        protected Transform _model;
        protected IRMAgent _rmAgent;
        protected Vector3? _prevPosition;
        protected Vector3? _prevForward;
        protected Dictionary<string, GameObject> _visibleGos;

        public CharacterMovement characterMove { get; private set; }
        public GraphUpdatePenalty updatePenalty { get; private set; }
        public Dummies dummies { get; private set; }

        public Vector3 prevPosition => _prevPosition ?? position;
        public Vector3 prevForward => _prevForward ?? forward;
        public Vector3 position => _root.position;
        public Vector3 eulerAngles => _root.eulerAngles;
        public Quaternion rotation => _root.rotation;
        public Vector3 forward => _root.forward;
        public Vector3 right => _root.right;
        public Vector3 up => _root.up;
        public bool isGrounded => characterMove && characterMove.isOnWalkableGround;
        public bool visibleSelf => _root.gameObject.visibleSelf;

        public ActorTransform() : base(ActorComponentType.Transform)
        {
            requiredAnimationJobRunning = true;
            requiredPhysicalJobRunning = true;
            requiredLateUpdate = true;
            _visibleGos = new Dictionary<string, GameObject>();
        }

        protected override void OnAwake()
        {
            _LoadModelIns();
            _LoadModelDummy();
        }

        protected override void OnStart()
        {
            _InitCharacterMovement();
            _InitRMAgent();
            _InitUpdatePenalty();
        }

        protected override void OnDestroy()
        {
            _UnloadCharacterMovement();
            _UnloadRMAgent();
            _UnloadModelIns();
            if (null != _root) Object.Destroy(_root.gameObject);
        }

        public override void OnBorn()
        {
            _root.name = actor.name;
            _root.SetParentInEditor(battle.root);

            if (characterMove != null)
            {
                characterMove.bePushedVelocity = Vector3.zero;
                characterMove.beResolveVec = Vector3.zero;
            }

            SetPosition(actor.bornCfg.Position, true);
            SetForward(actor.bornCfg.Forward);
            _root.gameObject.SetVisible(true);
            battle.gridPenaltyMgr.AddGraphUpdatePenalty(actor.insID, updatePenalty);
        }

        public override void OnRecycle()
        {
            _ClearAllVisible();
            _root.gameObject.SetVisible(false);
            _root.parent = battle.actorRootTrans;
            _root.position = RecycledPos;
            _prevPosition = null;
            _prevForward = null;
            battle.gridPenaltyMgr.RemoveGraphUpdatePenalty(actor.insID);
        }

        protected override void OnAnimationJobRunning()
        {
            _rmAgent?.OnUpdate(actor.deltaTime);
        }

        protected override void OnLateUpdate()
        {
            if (_IsCanMove())
            {
                characterMove?.OnLateUpdate(actor.deltaTime);
            }
        }

        protected override void OnPhysicalJobRunning()
        {
            dummies.Update();

            _prevPosition = position;
            _prevForward = forward;
        }

        /// <summary>
        /// 强制拉回到地面
        /// </summary>
        public void ForceFloor()
        {
            var pos = new Vector3(position.x, 0f, position.z);
            // ToDo 换成CC提供的ForceFloor
            SetPosition(pos, true);
        }

        /// <summary>
        /// 设置位置
        /// </summary>
        /// <param name="position"> 要设置到的目标点位置 </param>
        /// <param name="isForce"> 无视物理强制设置到目标位置 </param>
        /// <param name="isResolveOverlap"> 在isForce==true时生效, 先无视物理强制设置到目标位置, 再根据当前位置通过物理解决重叠问题. </param>
        /// <param name="checkAirWall"></param> isForce==true是生效, 强制设置到目标位置时不能穿空气墙
        public void SetPosition(Vector3 position, bool isForce = false, bool isResolveOverlap = false, bool checkAirWall = false)
        {
            if (null == _root)
            {
                return;
            }

            if (isForce)
            {
                if (characterMove)
                {
                    if (checkAirWall)
                    {
                        if (characterMove.CapsuleCast(position, ColliderTag.AirWall, out Vector3 pos))
                        {
                            position = pos;
                        }
                    }
                    characterMove.SetPosition(position, true);
                }
                else
                {
                    if (null != _rmAgent)
                    {
                        position = BattleUtil.GetNavMeshNearestPoint(position);
                    }

                    if (position.IsNaN())
                    {
                        LogProxy.LogError($"[ActorTransform.SetPosition()]{actor.name}：设置位置异常，位置信息非法，请留意检查！！");
                        return;
                    }

                    _root.position = position;
                }

                if (!isResolveOverlap)
                {
                    return;
                }
            }

            SetDeltaPosition(position - _root.position);
        }
        
        public void SetDeltaPosition(Vector3 deltaPos)
        {
            if (!_IsCanMove())
            {
                // LYDJS-40810 在不允许移动的情况下，如果y轴有位移，可以进入移动逻辑，但不允许xz平面有位移
                // 目前只有受击时，击飞浮空时会用到y轴向的位移
                if (Mathf.Abs(deltaPos.y) < float.Epsilon)
                {
                    return;
                }

                deltaPos.x = 0;
                deltaPos.z = 0;
            }

            if (null == characterMove)
            {
                if (null != _rmAgent)
                {
                    var point = BattleUtil.GetNavMeshNearestPoint(position + deltaPos);
                    deltaPos = point - position;
                }

                if (position.IsNaN())
                {
                    LogProxy.LogError($"[ActorTransform.SetDeltaPosition()]{actor.name}：设置位置异常，位置信息非法，请留意检查！！");
                }
                else
                {
                    _root.position += deltaPos;
                }

                return;
            }

            // TODO: obt目前临时处理，后续要考虑一下deltaTime为0怎么处理
            if(actor.deltaTime != 0)
                characterMove.Move(deltaPos / actor.deltaTime, actor.deltaTime);
        }

        public void TowardTarget()
        {
            var target = actor.targetSelector?.GetTarget();
            if (target != null)
            {
                _root.LookAt(target.transform.position);
            }
        }

        public void SetEulerAngles(Vector3 eulerAngles)
        {
            if (null == _root)
            {
                return;
            }

            _root.eulerAngles = eulerAngles;
        }

        public void SetDeltaEulerAngles(Vector3 deltaEulerAngles)
        {
            if (null == _root)
            {
                return;
            }

            _root.eulerAngles += deltaEulerAngles;
        }

        /// <summary>
        /// 绕Y轴旋转deltaEulerAnglesY角度
        /// </summary>
        /// <param name="deltaEulerAnglesY"></param>
        public void TranslateEulerAnglesY(float deltaEulerAnglesY)
        {
            if (null == _root)
            {
                return;
            }

            var eulerAngles = _root.eulerAngles;
            eulerAngles.y += deltaEulerAnglesY;
            _root.eulerAngles = eulerAngles;
        }

        public void SetEulerAnglesY(float eulerAnglesY)
        {
            if (null == _root)
            {
                return;
            }

            var eulerAngles = _root.eulerAngles;
            eulerAngles.y = eulerAnglesY;
            _root.eulerAngles = eulerAngles;
        }

        public void SetRotation(Quaternion rotation)
        {
            if (null == _root)
            {
                return;
            }

            _root.rotation = rotation;
        }

        public void SetForward(Vector3 forward, bool ignoreY = true)
        {
            if (null == _root)
            {
                return;
            }

            if (ignoreY)
            {
                forward.y = 0;
            }

            _root.forward = forward;
        }

        public Vector3 GetPosition(Vector3 offsetPos, float offsetAngleY, string dummyName = ActorDummyType.Root)
        {
            var dummy = dummies.GetDummy(dummyName);
            if (null != dummy)
                return BattleUtil.CalcPosition(dummy.GetDummy().position, dummy.GetDummy().forward, offsetPos, offsetAngleY);

            LogProxy.LogErrorFormat("【ActorModel.GetPosition()】获取挂点失败，请检查挂点名字：{0}的配置是否存在！！", dummyName);
            return position;
        }

        public void ApplyPrevFrameTransform(Action onApplied, bool restoreImmediately = true)
        {
            if (null == onApplied && restoreImmediately)
            {
                return;
            }

            var position = this.position;
            var forward = this.forward;
            _root.position = prevPosition;
            _root.forward = prevForward;
            onApplied?.Invoke();

            if (!restoreImmediately) return;
            _root.position = position;
            _root.forward = forward;
        }

        public void AddChild(Transform child, bool worldPositionStays = false)
        {
            if (null == child)
            {
                return;
            }

            child.SetParent(_root, worldPositionStays);
        }

        public Transform GetDummy(string dummyName)
        {
            if (string.IsNullOrEmpty(dummyName))
            {
                dummyName = ActorDummyType.Root;
            }

            var dummy = dummies?.GetDummyTrans(dummyName);
            return null != dummy ? dummy : _root;
        }

        /// <summary>
        /// 根对象的隐藏设置
        /// </summary>
        /// <param name="visible"></param>
        public void SetVisible(bool visible)
        {
            if (null == _root) return;
            _root.gameObject.SetVisible(visible);

            var eventData = actor.eventMgr.GetEvent<EventActorVisible>();
            eventData.Init(actor, visible);
            actor.eventMgr.Dispatch(EventType.ActorVisible, eventData);
        }

        /// <summary>
        /// 添加Model对象的隐藏设置
        /// </summary>
        /// <param name="layer"></param>
        /// <param name="visible"></param>
        /// <param name="rootBoneVisible"></param>
        public void AddModelVisible(int layer, bool visible, bool rootBoneVisible)
        {
            BattleUtil.AddCharacterVisibleClip(layer, _model.gameObject, visible, rootBoneVisible);
        }

        /// <summary>
        /// 移除Model对象的隐藏设置
        /// </summary>
        /// <param name="layer"></param>
        public void RemoveModelVisible(int layer)
        {
            BattleUtil.RemoveCharacterVisibleClip(layer, _model.gameObject);
        }

        /// <summary>
        /// 添加Model的孩子对象的隐藏设置
        /// </summary>
        public void AddModelChildVisible(int layer, string path, bool visible)
        {
            if (string.IsNullOrEmpty(path)) return;
            if (!_visibleGos.TryGetValue(path, out var go))
            {
                go = _model.Find(path)?.gameObject;
                _visibleGos.Add(path, go);
            }

            go?.AddVisibleWithLayer(visible, layer);
        }

        /// <summary>
        /// 移除Model的孩子对象的隐藏设置
        /// </summary>
        public void RemoveModelChildVisible(int layer, string path)
        {
            if (string.IsNullOrEmpty(path)) return;
            if (!_visibleGos.TryGetValue(path, out var go) || null == go) return;
            go.RemoveVisibleWithLayer(layer);
        }

        public T EnsureComponent<T>(GameObject tgt = null) where T : Component
        {
            if (null == tgt)
            {
                tgt = _root?.gameObject;
            }

            return null == tgt ? null : tgt.GetOrAddComponent<T>();
        }

        public bool HasComponent<T>(GameObject tgt = null) where T : Component
        {
            if (null == tgt)
            {
                tgt = _root?.gameObject;
            }

            return null != tgt && tgt.GetComponent<T>() != null;
        }

        public void RemoveComponent<T>(GameObject tgt = null) where T : Component
        {
            if (null == tgt)
            {
                tgt = _root?.gameObject;
            }

            tgt?.RemoveComponent<T>();
        }

        public static void SetBodyNode(Transform parent)
        {
            var body = new GameObject("Body");
            body.transform.SetParent(parent);
            for (var i = parent.childCount - 1; i >= 0; i--)
            {
                var r = parent.GetChild(i).GetComponent<Renderer>();
                if (r != null)
                {
                    r.transform.SetParent(body.transform);
                }
            }
        }

        public static void ResetBodyNode(Transform parent)
        {
            var body = parent.Find("Body");
            if (body == null)
                return;
            for (var i = body.childCount - 1; i >= 0; i--)
            {
                var child = body.GetChild(i);
                child.transform.SetParent(parent);
            }

            Object.Destroy(body.gameObject);
        }

        private void _LoadModelIns()
        {
            _root = _root ? _root : new GameObject().transform;
            _root.parent = battle.actorRootTrans;

            var cfg = actor.createCfg.ModelCfg;
            _model = BattleResMgr.Instance.LoadActorGO(cfg, BattleCharacterMgr.GetGlobalLOD()).transform; // 低模
            _model.parent = _root;
            _model.name = "Model";
            _model.localPosition = Vector3.zero;
            _model.localEulerAngles = Vector3.zero;

            //角色渲染层级 - 把主角除武器的Renderer放到Body下,使K材质身体和武器互不影响
            //(怪物因为目前没法判断是否Weapon先不做)
            if (cfg.Type == ActorType.Hero)
            {
                SetBodyNode(_model);
            }
        }

        private void _UnloadModelIns()
        {
            if (null == _model) return;
            var cfg = actor.createCfg.ModelCfg;
            if (cfg.Type == ActorType.Hero)
            {
                ResetBodyNode(_model);
            }

            _model.parent = null;
            BattleResMgr.Instance.UnloadActorGO(_model.gameObject, cfg);
        }

        private void _LoadModelDummy()
        {
            // 挂点            
            var dummyInfo = actor.modelInfo.dummys;
            dummies = new Dummies();
            dummies.Init(dummyInfo, _model);
            dummies.TryAddDummy(ActorDummyType.Root, _root, _root);
            dummies.TryAddDummy(ActorDummyType.Model, _model, _model);
        }

        private void _InitCharacterMovement()
        {
            characterMove = _root.GetComponent<CharacterMovement>();
            if (null == characterMove)
            {
                return;
            }

            characterMove.allowPushCharacters = actor.modelInfo.characterMoveCfg.AllowPushCharacters;
            characterMove.rigidActor.mass = actor.createCfg.ModelCfg.Weight;
            characterMove.FoundGround += _OnFoundGround;
            characterMove.ModeCtrl.OnEnterMode += _OnEnterMoveMode;
            characterMove.ModeCtrl.OnExitMode += _OnExitMoveMode;
            characterMove.OnSetWorldPos += _OnCharacterMoveSetPos;
            characterMove.pushForceScale = TbUtil.battleConsts.GlobalPushScale;
            characterMove.yLerpTime = TbUtil.battleConsts.CharacterMovement_YLerpTime;
            characterMove.InitCollisionMask();
        }

        private void _UnloadCharacterMovement()
        {
            if (!characterMove) return;
            characterMove.FoundGround -= _OnFoundGround;
            characterMove.ModeCtrl.OnEnterMode -= _OnEnterMoveMode;
            characterMove.ModeCtrl.OnExitMode -= _OnExitMoveMode;
            characterMove.OnSetWorldPos -= _OnCharacterMoveSetPos;
        }

        private void _InitRMAgent()
        {
            _rmAgent = _root.GetComponent<IRMAgent>();
            if (null == _rmAgent || characterMove == null) return;
            
            _rmAgent.height = characterMove.height;
            _rmAgent.DeleSeachPathBefore += _OnSearchPathBefore;
            //todo 寻路找拐点的距离值 后期放在配置表
            _rmAgent.pickNextWaypointDist = actor.type == ActorType.Hero ? 1.0f : 1.4f;
        }

        private void _UnloadRMAgent()
        {
            if (_rmAgent != null)
            {
                _rmAgent.DeleSeachPathBefore -= _OnSearchPathBefore;
                _rmAgent.UnLoadDestroy();
                _rmAgent = null;
            }

            if (updatePenalty != null)
            {
                updatePenalty.OnDestroy();
                updatePenalty = null;
            }
        }

        /// <summary>
        /// 初始化寻路惩罚模块
        /// </summary>
        private void _InitUpdatePenalty()
        {
            if (!BattleUtil.AStarIsActive || !BattleUtil.AStarIsGrid)
            {
                return;
            }

            if (actor.config.Type != ActorType.Hero
                && actor.config.Type != ActorType.Monster
                && actor.config.SubType != (int)SkillAgentType.MagicField)
            {
                return;
            }

            updatePenalty = _root.GetOrAddComponent<GraphUpdatePenalty>();

            //怪物走配置半径，其它走characterMove的半径
            var radius = characterMove == null ? 0 : characterMove.radius;
            var pCfg = actor.modelInfo.pathFindCfg;
            if (!pCfg.useCharacterRadius)
            {
                radius = pCfg.radius;
            }
            if (pCfg.shape == PathFindShapeType.Circle)
            {
                updatePenalty.InitCircle(new Vector2(pCfg.offset.x,pCfg.offset.z), radius);
            }
            else if (pCfg.shape == PathFindShapeType.Rectangle)
            {
                updatePenalty.InitRectangle(new Vector2(pCfg.offset.x,pCfg.offset.z), pCfg.width, pCfg.length);
                //矩形时，寻路半径取长宽中短的那个
                radius = Math.Min(pCfg.width, pCfg.length) * 0.5f;
            }
            
            if (characterMove == null) return;

            //只有人和怪物才会有自己的寻路标记
            if (actor.config.Type == ActorType.Hero
                || actor.config.Type == ActorType.Monster)
            {
                updatePenalty.pathTag = battle.gridPenaltyMgr.GetCurrentTag();
            }

            if (_rmAgent != null)
            {
                _rmAgent.pathTag = updatePenalty.pathTag;
                _rmAgent.radius = radius;
            }
        }

        /// <summary>
        /// 清除隐身设置
        /// </summary>
        private void _ClearAllVisible()
        {
            BattleUtil.ClearCharacterVisibleClips(_model.gameObject);

            foreach (var go in _visibleGos.Values)
            {
                go.ClearVisible();
            }

            _visibleGos.Clear();
        }

        // 寻路之前的回调
        private void _OnSearchPathBefore()
        {
            if (actor != null && _rmAgent != null)
            {
                var eventData = Battle.Instance.eventMgr.GetEvent<EventUpdatePenalty>();
                eventData.Init(actor.insID, _rmAgent.radius);
                Battle.Instance.eventMgr.Dispatch(EventType.OnUpdatePently, eventData);
            }
        }

        // 物理模拟完成后，应用到Transform上之前调用
        private void _OnCharacterMoveSetPos(Vector3 originalPos, ref Vector3 desirePos)
        {
            var point = BattleUtil.GetNavMeshNearestPoint(desirePos);
            desirePos = point;
        }

        private void _OnFoundGround(ref FindGroundResult groundResult)
        {
            using (ProfilerDefine.HurtOnFoundGroundPMarker.Auto())
            {
                var eventData = actor.eventMgr.GetEvent<EventOnFoundGround>();
                eventData.Init(actor, groundResult);
                actor.eventMgr.Dispatch(EventType.OnFoundGround, eventData);
            }
        }
        
        private void _OnEnterMoveMode(MovementModeBase mode)
        {
            using (ProfilerDefine.HurtOnFoundGroundPMarker.Auto())
            {
                var eventData = actor.eventMgr.GetEvent<EventOnSwitchMoveMode>();
                eventData.Init(actor, mode, true);
                actor.eventMgr.Dispatch(EventType.OnEnterMoveMode, eventData);
            }
        }
        
        private void _OnExitMoveMode(MovementModeBase mode)
        {
            using (ProfilerDefine.HurtOnFoundGroundPMarker.Auto())
            {
                var eventData = actor.eventMgr.GetEvent<EventOnSwitchMoveMode>();
                eventData.Init(actor, mode, false);
                actor.eventMgr.Dispatch(EventType.OnExitMoveMode, eventData);
            }
        }

        private bool _IsCanMove()
        {
            return null == actor.stateTag || !actor.stateTag.IsActive(ActorStateTagType.CannotMove);
        }
    }
}