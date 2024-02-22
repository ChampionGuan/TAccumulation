
using System;
using System.Collections.Generic;
using PapeGames;
using PapeGames.Rendering;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using X3;
using X3.Character;
using X3Battle.Timeline.Extension;
using ISubsystem = X3.Character.ISubsystem;

namespace X3Battle
{
    public class BSCTrackBind : BSCBase, IReset
    {
        private const string _cameraGroupName = "Camera Group";
        private const string _loopFxGroupName = "Loop Fx Group";
        private const string _runtimeCinemachineClipName = "BattleRuntime";
        private static TrackExtData _zeroExtData = new TrackExtData()
        {
            localScale = Vector3.one
        };
        
        // 预览loopFx的track
        private Dictionary<TrackAsset, bool> _loopFxTracks = new Dictionary<TrackAsset, bool>(10);

        // 只受时间关闭的track
        private Dictionary<TrackAsset, bool> _stopIndividualTracks = new Dictionary<TrackAsset, bool>(10);

        // animation轨道绑定的对象
        private Dictionary<string, GameObject> _animationBindObj = new Dictionary<string, GameObject>(10);

        // 所有加载出来的对象
        private List<GameObject> _subTranList = new List<GameObject>(15);

        private HashSet<GameObject> _hasAnimTrans = new HashSet<GameObject>();

        // 所有需要同步位置的对象 
        private Dictionary<Transform, TrackExtData> _isolateTransforms = new Dictionary<Transform, TrackExtData>(10);
        private PlayableDirector _director;
        private bool _isFollowCreator;
        private bool _needClearCameraEvent;
        private List<GhostObjectPool> _ghostPools = new List<GhostObjectPool>(5);
        private List<GameObject> _ghostHDList = new List<GameObject>();
        
        // PPV轨道bind的物体.
        private List<GameObject> _ppvBindGameObjects = new List<GameObject>(10);

        // 是否受到时间独立结束
        private bool _isStopIndividually;

        private ModelCfg _boyModelCfg;
        
        public Transform parentRoot { get; set; }
        
        public bool notBindCreator { get; set; }  // 是否不绑定creator，否则就从场上找单位
        public bool isPerformMode { get; set; }  // 是否表演模式
        public bool hasCreatureMaterialAnim { get; private set; } // 是否含有材质子轨道
        public GameObject womanModel { get; set; } // 表演模式女主Model
        public GameObject manModel { get; set; } // 表演模式男主model
        public GameObject monsterModel { get; set; } // 表演模式怪物model
        public GameObject monsterRoot { get; set; } // 表演模式怪物Root
        public bool usingMonster { get; private set; }  // 是否使用了monster轨道
        public bool usingGirl { get; private set; }  // 是否使用了女主轨道

        public void Reset()
        {
            _hasAnimTrans.Clear();
            _loopFxTracks.Clear();
            _stopIndividualTracks.Clear();
            _ghostHDList.Clear();
            _animationBindObj.Clear();
            _subTranList.Clear();
            _isolateTransforms.Clear();
            _ppvBindGameObjects.Clear();
            foreach (var item in _ghostPools)
            {
                item.Destroy();    
            }
            _ghostPools.Clear();
            _director = null;
            _isFollowCreator = false;
            _needClearCameraEvent = false;
            _isStopIndividually = false;
            parentRoot = null;
            notBindCreator = false;
            isPerformMode = false;
            hasCreatureMaterialAnim = false;
            womanModel = null;
            manModel = null;
            monsterModel = null;
            monsterRoot = null;
            usingMonster = false;
            usingGirl = false;
        }
        
        protected override bool _OnBuild()
        {
            var resCom = _battleSequencer.GetComponent<BSCRes>();
            if (parentRoot == null)
            {
                parentRoot = _context.GetRootTransform();
            }
            this._director = resCom.artDirector;
            if (resCom.artTimelineExtInfo != null)
            {
                _isFollowCreator = resCom.artTimelineExtInfo.isFollowActorForTimeline;
            }
            this._InitTracks();
            return true;
        }

        public GameObject CreateGhostHD(AvatarTrack track, out GameObject actor)
        {
            actor = null;
            var bindType = BSTypeUtil.GetBindRoleTypeByTrackExtData(track.extData);
            if (bindType == TrackBindRoleType.Male && isPerformMode)
            {
                // 目前只在爆发技中支持男主套装ID创建分身
                actor = manModel;
                var actorModel = Battle.Instance.modelMgr;
                _boyModelCfg = Battle.Instance.actorMgr.boy?.model.config;
                var avatar = actorModel.EnsureGhostHD(_boyModelCfg, track.material);
                if (avatar != null)
                {
                    avatar.SetVisible(false);
                    _ghostHDList.Add(avatar);
                    var model = avatar.transform.Find("Model");
                    if (model != null)
                    {
                        var x3Character = model.GetComponent<X3Character>();
                        if (x3Character != null)
                        {
                            // 关闭风场
                            var physicsWind = x3Character.GetSubsystem(ISubsystem.Type.PhysicsCloth);
                            if (physicsWind != null)
                            {
                                physicsWind.EnabledSelf = false;
                            }
                        }
                    }
                    return avatar;
                }
            }
            return null;
        }

        public void RegisterControlCreator()
        {
            ControlPlayableAsset.SetMountPlayableCreator(_MountPlayableCreator);
        }

        public void UnRegisterControlCreator()
        {
            ControlPlayableAsset.SetMountPlayableCreator(null);
        }

        // 同步一下特效位置和旋转
        public void SyncPosAndRotation()
        {
            var resCom = _battleSequencer.GetComponent<BSCRes>();
            if (resCom.artObject != null)
            {
                // 同步timeline节点
                var timelineTrans = resCom.artObject.transform;
                SetTimelineParent(_battleSequencer.bsCreateData.creatorModel ?? parentRoot?.gameObject, _isFollowCreator, timelineTrans, _zeroExtData, false);

                // 同步 IsolateEffect
                var parentObj = _battleSequencer.bsCreateData.creatorModel?.transform;
                foreach (var iter in _isolateTransforms)
                {
                    SetTimelineParent(parentObj?.gameObject, false, iter.Key, iter.Value, false);   
                }    
            }
        }

        //  绑定轨道
        private void _InitTracks()
        {
            // build逻辑资源
            var resCom = _battleSequencer.GetComponent<BSCRes>();
            if (resCom.logicAsset != null)
            {
                var logicTracks = resCom.logicAsset.GetOutputTracks();
                for (int i = 0; i < logicTracks.Length; i++)
                {
                    if (logicTracks[i] is ActionTrack actionTrack)
                    {
                        _EvalActionTrack(actionTrack);
                    }
                }
            }
            
            // build美术资源
            if (resCom.artAsset != null && resCom.artDirector != null)
            {
                var allTracks = resCom.artAsset.GetOutputTracks();
                TrackAsset lastTrack = null; // 上个被处理的轨道
                GameObject lastIsHookEffectTrackAndObj = null; // 上个轨道是hookEffect轨并且获取到的绑定Obj
                // TODO 改成Switch整洁一点
                for (int i = 0; i < allTracks.Length; i++)
                {
                    var baseTrack = allTracks[i];
                    //  处理预览group，by雨天
                    if (!this.EvalLoopFXGropup(baseTrack))
                    {
                        if (baseTrack.muted)
                        {
                            // muted的轨道不处理
                            continue;
                        }

                        var clipArray = baseTrack.GetClipsArray();
                        if (clipArray == null || clipArray.Length == 0)
                        {
                            if (baseTrack is AnimationTrack animationTrack)
                            {
                                if (animationTrack.infiniteClip == null)
                                {
                                    // AnimationTrack比较特殊，infiniteClip和clipArray都为空才算真的空
                                    continue;
                                }   
                            }
                            else
                            {
                                // 空轨道不处理
                                continue;   
                            }
                        }
                        
                        if (baseTrack is AnimationTrack)
                        {
                            this.EvalAnimationTrack(baseTrack, lastIsHookEffectTrackAndObj);
                        }
                        else if (baseTrack is ControlTrack)
                        {
                            lastIsHookEffectTrackAndObj = this.EvalControlTrack(baseTrack);
                        }
                        else if (baseTrack is PhysicsWindTrack physicsWindTrack)
                        {
                            this.BindRoleObjGeneral(_director, physicsWindTrack, physicsWindTrack.extData);
                        }
                        else if (baseTrack is ActorOperationTrack actorOperationTrack)
                        {
                            this.BindRoleObjGeneral(_director, actorOperationTrack, actorOperationTrack.extData);
                        }
                        else if (baseTrack is LODTrack lodTrack)
                        {
                            this.BindRoleObjGeneral(_director, lodTrack, lodTrack.extData);
                        }
                        else if (baseTrack is VisibilityTrack visibilityTrack)
                        {
                            this.BindRoleObjGeneral(_director, visibilityTrack, visibilityTrack.extData);
                        }
                        else if (baseTrack is ChangeWeaponTrack wTrack)
                        {
                            this.BindRoleObjGeneral(_director, wTrack, wTrack.extData);
                        }
                        else if (baseTrack is ChangeSuitTrack suitTrack)
                        {
                            var bindObject = this.BindRoleObjGeneral(_director, suitTrack, suitTrack.extData);
                            if (bindObject != null)
                            {
                                ChangeSuitUtil.PreloadChangeSuit(bindObject, suitTrack);
                            }
                        }
                        else if (baseTrack is CameraImpulseTrack ciTrack)
                        {
                            this._EvalTrackStopIndividually(ciTrack);
                            this.BindRoleObjGeneral(_director, ciTrack, ciTrack.extData);
                        }
                        else if (baseTrack is TransformOperationTrack operationTrack)
                        {
                            this.BindTransformOperationTrack(_director, operationTrack, operationTrack.extData);
                        }
                        else if (baseTrack is CurveAnimTrack curveAnimTrack)
                        {
                            this._EvalTrackStopIndividually(curveAnimTrack);
                            this.BindRoleObjGeneral(_director, curveAnimTrack, curveAnimTrack.extData);
                            var bindObj = _director.GetGenericBinding(baseTrack);
                            if (bindObj != null && bindObj is GameObject)
                            {
                                var clips = curveAnimTrack.GetClipsArray();
                                for (int k = 0; k < clips.Length; k++)
                                {
                                    var timelineClip = clips[k];
                                    if (timelineClip.asset is CurveAnimPlayableAsset actionClip)
                                    {
                                        var bingdGO = bindObj as GameObject;
                                        if (bingdGO != null)
                                        {
                                            actionClip.multiAnimData.name = actionClip.GetHashCode().ToString();//TODO 仅在CreateClip做这个 但要刷资源
#if UNITY_EDITOR
                                            actionClip.multiAnimData.name = _director.name + actionClip.GetHashCode();
#endif
                                            var curveAnim = bingdGO.GetComponent<BattleCurveAnimator.CurveAnimator>();
                                            if (curveAnim != null)
                                                curveAnim.PreAddAnimation(actionClip.multiAnimData);
                                        }
                                    }
                                }
                            }
                        }
                        else if (baseTrack is SubSystemControlTrack subSystemControlTrack)
                        {
                            this.BindRoleObjGeneral(this._director, subSystemControlTrack,
                                subSystemControlTrack.extData);
                        }
                        else if (baseTrack is GhostTrack)
                        {
                            this._EvalTrackStopIndividually(baseTrack);
                            this.BindGhostTrack(lastTrack, baseTrack);
                        }
                        else if (baseTrack is CameraMixingTrack)
                        {
                            this.EvalCinemachineTrack(baseTrack);
                        }
                        else if (baseTrack is SimpleAudioTrack simpleAudioTrack)
                        {
                            this._EvalTrackStopIndividually(simpleAudioTrack);
                            this.BindRoleObjGeneral(this._director, simpleAudioTrack, simpleAudioTrack.extData);
                        }
                        else if (baseTrack is AvatarTrack avatarTrack)
                        {
                            //todo 长空 临时改法
                            // var timelineClips = avatarTrack.GetClipsArray();
                            // if (timelineClips.Length > 0)
                            // {
                            //     // 不是空轨道才创建Avatar
                            //     var avatar = _CreateGhostHD(avatarTrack, out var actor);
                            //     // avatar创建成功再创建逻辑
                            //     if (avatar != null && actor != null)
                            //     {
                            //         _AddArtSequencerTrack<BSAPlayAvatar, AvatarClip>(avatarTrack,
                            //             (action, _) =>
                            //             {
                            //                 action.SetData(actor, avatar);
                            //             });
                            //     }
                            // }
                        }
                    }
                    lastTrack = baseTrack;
                }
                var timelineTrans = resCom.artObject.transform;
                this.SetTimelineParent(_battleSequencer.bsCreateData.creatorModel ?? parentRoot?.gameObject, this._isFollowCreator, timelineTrans, _zeroExtData, false);
            }
            _ClearUnusedAnimator();
        }

        // 通用的创建美术Sequencer方法
        private void _AddArtSequencerTrack<T, V>(TrackAsset track, Action<T, V> onCreate) where T: X3Sequence.Action, new() where V: PlayableAsset
        {
            if (track == null)
            {
                return;
            }
            var timelineClips = track.GetClipsArray();
            if (timelineClips.Length > 0)
            {
                var sequenceTrack = new X3Sequence.Track(_battleSequencer.artSequencer, weakInterrupt:track.IsIgnoreInterrupt(), specialEnd: track.IsSpecialEnd(), name: track.name);
                for (int i = 0; i < timelineClips.Length; i++)
                {
                    var timelineClip = timelineClips[i];
                    if (timelineClip.asset != null && timelineClip.asset is V assetClip)
                    {
                        if (assetClip != null)
                        {
                            var action = new T();
                            onCreate?.Invoke(action, assetClip);
                            action.Init(sequenceTrack, (float)timelineClip.start, (float)timelineClip.duration, timelineClip.displayName);
                            sequenceTrack.AddAction(action);
                        }
                    }
                }
                _battleSequencer.artSequencer.AddTrack(sequenceTrack);
            }
        }
        
        // 清除不适用的Animator子节点
        private void _ClearUnusedAnimator()
        {
            for (int i = 0; i < _subTranList.Count; i++)
            {
                var effectObj = _subTranList[i];
                if (!_hasAnimTrans.Contains(effectObj))
                {
                    var t = effectObj.GetComponent<Animator>();
                    if (t != null)
                    {
                        UnityEngine.Object.Destroy(t);
                    }
                }
            }
        }

        private void _EvalActionTrack(ActionTrack actionTrack)
        {
            // var context = _timeline.actionContext;
            // actionTrack.SetContext(context);
            // actionTrack.SetLogicTimeline(_timeline);
            if (actionTrack.muted)
            {
                return;
            }
            var sequenceTrack = new BattleActionTrack( _battleSequencer.logicSequencer, specialEnd:true, name:actionTrack.name, tags: actionTrack.tags);
            var clips = actionTrack.GetClipsArray();
            for (int i = 0; i < clips.Length; i++)
            {
                var timelineClip = clips[i];
                if (timelineClip.asset is BSActionAsset actionClip)
                {
                    var playable = actionClip.CreatePlayable();
                    playable.SetBattleData(actionClip, _battleSequencer.bsCreateData.bsActionContext, _battleSequencer);
                    playable.Init(sequenceTrack, (float)timelineClip.start, (float)timelineClip.duration, timelineClip.displayName);
                    sequenceTrack.AddAction(playable);
                }   
            }
            _battleSequencer.logicSequencer.AddTrack(sequenceTrack);
        }
        
        // return boolean 是否走了预览处理逻辑
        private bool EvalLoopFXGropup(TrackAsset baseTrack)
        {
            //  预览Group处理
            var baseTrackParent = baseTrack.parent;
            if (baseTrackParent && baseTrackParent.name == _loopFxGroupName)
            {
                baseTrack.muted = true;
                this._loopFxTracks[baseTrack] = true;
                return true;
            }

            return false;
        }

        // ---------------------------- CinemachineTrack的处理 ------------------------------
        private void EvalCinemachineTrack(TrackAsset track)
        {
            //  绑定track
            var cameraBrain = Battle.Instance.cameraTrace.GetCameraBrain();
            this._director.SetGenericBinding(track, cameraBrain);
            //  绑定clip
            var clips = track.GetClipsArray();
            for (int i = 0; i < clips.Length; i++)
            {
                var timelineClip = clips[i];
                if (timelineClip.displayName == _runtimeCinemachineClipName)
                {
                    var ctrlClip = timelineClip.asset as CinemachineShot;
                    var vartualCamera = Battle.Instance.cameraTrace.GetVirtualCamera();
                    X3TimelineUtility.BindCinemachineClip(this._director, ctrlClip, vartualCamera);
                }
            }
        }

        // ---------------------------  ControlTrack 的处理 -----------------------------------
        private GameObject EvalControlTrack(TrackAsset baseTrack)
        {
            if (baseTrack.muted)
            {
                return null;
            }
            var controlTrack = baseTrack as ControlTrack;
            var extData = controlTrack.extData;
            var trackType = extData.trackType;
            GameObject curHookEffectGameObj = null;
            if (trackType == TrackExtType.HookEffect)
            {
                this._EvalTrackStopIndividually(controlTrack);
                Transform hookTran = null; // 取到人物身上的挂载点
                
                if (!string.IsNullOrEmpty(extData.topParentRecorderKey))
                {
                    // 优先从recorder身上拿
                    var rootTran = _battleSequencer.GetRecordObject(extData.topParentRecorderKey)?.transform;
                    if (rootTran != null)
                    {
                        hookTran = rootTran.Find(extData.HookName);
                    }
                }
                else
                {
                    if (isPerformMode || notBindCreator)
                    {
                        hookTran = this.GetHookTransformByTrackExtData(extData);
                    }
                    else
                    {
                        hookTran = this.GetHookTransformByCreator(_battleSequencer.bsCreateData.creatorModel, extData.HookName);
                    } 
                }
                curHookEffectGameObj = this.SetTrackEffect(this._director, controlTrack, extData, hookTran,
                    extData.isFollowActor, false);
            }
            else if (trackType == TrackExtType.ChildHookEffect)
            {
                var hookTran = this._director.gameObject.transform;
                hookTran = hookTran.Find(extData.HookName);
                curHookEffectGameObj = this.SetTrackEffect(this._director, controlTrack, extData, hookTran, true, true);
            }
            else if (trackType == TrackExtType.IsolateEffect)
            {
                _EvalTrackStopIndividually(controlTrack);
                // isolate是独立特效，不会被设置到父节点上
                var parentObj = _battleSequencer.bsCreateData.creatorModel?.transform;
                SetTrackEffect(this._director, controlTrack, extData, parentObj, false,
                    false);
            }
            else if (trackType == TrackExtType.ChildAnim || trackType == TrackExtType.ChildEffect)
            {
                this._EvalTrackStopIndividually(controlTrack);
            }

            return curHookEffectGameObj;
        }

        // 处理需要根据时间结束的track（目前只有HookEffect和IsolateEffect会调到这个）
        private void _EvalTrackStopIndividually(TrackAsset baseTrack)
        {
            // 若存在一个Track忽略打断独立播放，则整个timeline独立播放
            if (baseTrack.IsIgnoreInterrupt())
            {
                this._stopIndividualTracks[baseTrack] = true;
                this._isStopIndividually = true;
                _battleSequencer.isPlayIndividually = true;
            }

            // 若存在一个Track忽略逻辑独立播放，则整个timeline独立播放
            if (!baseTrack.IsSpecialEnd())
            {
                this._stopIndividualTracks[baseTrack] = true;
                this._isStopIndividually = true;
                _battleSequencer.isPlayIndividually = true;
            }
        }

        private Transform GetHookTransformByTrackExtData(TrackExtData auxData)
        {
            var roleType = BSTypeUtil.GetBindRoleTypeByTrackExtData(auxData);
            var role = this.GetRoleModelByRoleType(roleType);
            if (role != null)
            {
                var hookTrans = role.transform.Find(auxData.HookName);
                return hookTrans ?? role.transform;
            }
            else
            {
                LogProxy.LogWarning(
                    $"警告！角色查找失败，没有找到hook绑定角色。timeline={_battleSequencer.name}, 请在编辑器Alt+Q打开Timeline修复问题！");
                return null;
            }
        }

        private Transform GetHookTransformByCreator(GameObject creator, string HookName)
        {
            return creator == null ? null : creator.transform.Find(HookName) ?? creator.transform;
        }

        private GameObject SetTrackEffect(PlayableDirector director, TrackAsset track, TrackExtData VARIABLE,
            Transform parentObj, bool followRoot, bool followScale)
        {
            // 不是animation类型的可以重复创建
            GameObject obj = null;
            if (!string.IsNullOrEmpty(VARIABLE.bindRecorderKey))
            {
                obj = _battleSequencer.GetRecordObject(VARIABLE.bindRecorderKey); 
                this._animationBindObj[VARIABLE.bindRecorderKey] = obj;
            }
            else if(!string.IsNullOrEmpty(VARIABLE.bindPath))
            {
                obj = this.InitOtherEffect(VARIABLE.bindPath);
                this._animationBindObj[VARIABLE.bindPath] = obj;
            }
            
            if (obj)
            {
                this.SetTimelineParent(parentObj?.gameObject, followRoot, obj.transform, VARIABLE, followScale);
                if (VARIABLE.trackType == TrackExtType.HookEffect)
                {
                    // hookEffect需要特殊处理，释放的那一刻取挂点信息，此刻父节点需要重设回去
                    obj.transform.parent = parentObj;
                }
                else if (VARIABLE.trackType == TrackExtType.IsolateEffect)
                {
                    _isolateTransforms.Add(obj.transform, VARIABLE);   
                }
                this.BindControlTrack(director, track, obj, VARIABLE, parentObj);
            }

            // 编辑器下不设置轨道muted
            if (!Application.isEditor)
            {
                track.muted = !obj;
            }

            return obj;
        }

        private void BindControlTrack(PlayableDirector director, TrackAsset track, GameObject bindObj,
            TrackExtData trackExtData, Transform creatureTran)
        {
            var clips = track.GetClipsArray();
            for (int i = 0; i < clips.Length; i++)
            {
                var ctrlClip = clips[i].asset as ControlPlayableAsset;
                X3TimelineUtility.BindControlClip(this._director, ctrlClip, bindObj);
            }
        }

        // 挂载playable生成器
        private MountPlayableBehaviourBase _MountPlayableCreator(ControlPlayableAsset clipAsset, GameObject obj, float clipIn)
        {
            var trackExtData = clipAsset.trackExtData;
            if (trackExtData == null || obj == null)
            {
                return null;
            }
            
            var multiplePlayable = new MultipleMountPlayableBehaviour();
            if (trackExtData.trackType == TrackExtType.HookEffect)
            {
                // var hookDetachPlayable = new HookPositionRotation(trackExtData, obj);
                // multiplePlayable.AddPlayableBehaviour(hookDetachPlayable);
            }
            else if (trackExtData.trackType == TrackExtType.IsolateEffect && trackExtData.isFollowReferencePos && _battleSequencer.bsCreateData.creatorModel != null)
            {
                // TODO 稳了删
                // var effectFollowPos = new EffectFollowPosPlayable();
                // effectFollowPos.SetReferent(_timeline.createData.creatorModel.transform);
                // multiplePlayable.AddPlayableBehaviour(effectFollowPos);
            }
            return multiplePlayable;
        }

        //------------------------------------- AnimationTrack的处理 -------------------------------
        // 处理Animation轨
        private void EvalAnimationTrack(TrackAsset baseTrack, GameObject lastIsHookEffectTrackAndObj)
        {
            var animTrack = baseTrack as AnimationTrack;
            var extData = animTrack.extData;
            var trackType = extData.trackType;
            if (trackType == TrackExtType.CreatureAnim || trackType == TrackExtType.CameraAnim)
            {
                this.BindActorAnim(this._director, animTrack, extData);
                animTrack.UpdateHasMaterialSubTrack();
                if ((animTrack.HasMaterialSubTrack))
                {
                    hasCreatureMaterialAnim = true;
                }
            }
            else if(trackType == TrackExtType.Creature_Parent_Anim)
            {
                BindActorParentAnim(_director, animTrack, extData);
            }
            else if (trackType == TrackExtType.HookEffectAnim || trackType == TrackExtType.ChildHookEffectAnim)
            {
                if (lastIsHookEffectTrackAndObj != null)
                {
                    var targetObj = lastIsHookEffectTrackAndObj;
                    if (!string.IsNullOrEmpty(extData.HookName))
                    {
                        targetObj = lastIsHookEffectTrackAndObj.transform.Find(extData.HookName)?.gameObject;    
                    }
                    if (targetObj != null)
                    {
                        _hasAnimTrans.Add(targetObj);
                        BattleUtil.EnsureComponent<Animator>(targetObj);
                        this._director.SetGenericBinding(animTrack, targetObj);   
                    }
                }
            }
            else if (trackType == TrackExtType.IsolateEffectAnim)
            {
                this.SetTrackAnim(this._director, animTrack, extData, this._battleSequencer.bsCreateData.creatorModel, this._isFollowCreator, false);
            }
            else if (trackType == TrackExtType.ChildAnim)
            {
                this._EvalTrackStopIndividually(animTrack);

                var bindObj = _director.GetGenericBinding(baseTrack);
                if (bindObj is Animator anim)
                {
                    var ppv = anim.GetComponent<PostProcessVolume>();
                    if (ppv != null && extData.isStopByLogic)
                    {
                        _ppvBindGameObjects.Add(anim.gameObject);
                    }
                }

                if (baseTrack.parent != null && baseTrack.parent.name == _cameraGroupName)
                {
                     // 非表演模式发个事件给相机， 三夕要求的
                    if (!isPerformMode)
                    {
                        var obj = _director.GetGenericBinding(baseTrack);
                        GameObject cameraObj = null;
                        if (obj is GameObject tempCameraObj)
                        {
                            cameraObj = tempCameraObj;
                        }
                        else if (obj is Animator animator)
                        {
                            cameraObj = animator.gameObject;
                        }

                        if (obj != null)
                        {
                            _needClearCameraEvent = true;
                            var eventData = Battle.Instance.eventMgr.GetEvent<EventTimeLineWithVirCam>();
                            eventData.Init(GetHashCode(), _battleSequencer.bsCreateData.creatorActor, cameraObj, true);
                            Battle.Instance.eventMgr.Dispatch(EventType.TimelineWithVirCam, eventData);
                        }
                    }
                }
            }
        }

        // 绑定TransformOperation的轨道
        private void BindTransformOperationTrack(PlayableDirector director, TrackAsset track, TrackExtData extData)
        {
            if (isPerformMode)
            {
                // 表演模式，特殊处理
                usingMonster = true;
                Func<GameObject> getter = () => {
                   return  monsterRoot;
                };
                // 表演模式
                var roleType = BSTypeUtil.GetBindRoleTypeByTrackExtData(extData);
                if (roleType == TrackBindRoleType.Monster)
                {
                    var timelineClips = track.GetClipsArray();
                    foreach (var timelineClip in timelineClips)
                    {
                        if (timelineClip.asset is TransformOperationClip operationClip)
                        {
                            operationClip.dynamicGetter = getter;
                        }   
                    }
                }
            }   
        }

        
        private void BindActorParentAnim(PlayableDirector director, AnimationTrack track, TrackExtData trackExtData)
        {
            GameObject bindGameObject = null;
            if (isPerformMode || notBindCreator)
            {
                var roleType = BSTypeUtil.GetBindRoleTypeByTrackExtData(trackExtData);
                bindGameObject = this.GetRoleModelByRoleType(roleType);
            }
            else
            {
                bindGameObject = _battleSequencer.bsCreateData.creatorModel;
            }
            if (bindGameObject != null)
            {
                var parent = bindGameObject.transform.parent;
                BattleUtil.EnsureComponent<Animator>(parent.gameObject);
                director.SetGenericBinding(track, parent.gameObject);   
            }
        }
        
        // 动态绑定actor的动画
        private void BindActorAnim(PlayableDirector director, AnimationTrack track, TrackExtData trackExtData)
        {
            // 有recordObj就走独立逻辑
            if (!string.IsNullOrEmpty(trackExtData.bindRecorderKey))
            {
                var recordObj = _battleSequencer.GetRecordObject(trackExtData.bindRecorderKey);
                var _creatorTrans = _battleSequencer.bsCreateData.creatorModel?.transform;
                X3TimelineUtility.SetTransPositionByExtData(recordObj.transform, trackExtData, _creatorTrans);
                X3TimelineUtility.SetTransRotationByExtData(recordObj.transform, trackExtData, _creatorTrans);
                X3TimelineUtility.SetTransLocalScaleByExtData(recordObj.transform, trackExtData);
                director.SetGenericBinding(track, recordObj);
                return;
            }
            
            if (isPerformMode)
            {
                // 表演模式根据绑定信息设置
                track.muted = false;
                var roleType = BSTypeUtil.GetBindRoleTypeByTrackExtData(trackExtData);
                var bindGameObject = this.GetRoleModelByRoleType(roleType);
                if (bindGameObject)
                {
                    var trans = bindGameObject.transform;
                    X3TimelineUtility.SetTransLocalPositionByExtData(trans, trackExtData);
                    X3TimelineUtility.SetTransLocalRotationByExtData(trans, trackExtData);
                    X3TimelineUtility.SetTransLocalScaleByExtData(trans, trackExtData);
                    // TODO 稳了删
                    if (BSCPerform.usingPerformPlayable)
                    {
                        if (roleType == TrackBindRoleType.Male || roleType == TrackBindRoleType.Female ||
                            roleType == TrackBindRoleType.Monster)
                        {
                            // 男女主怪物现在不走timeline播表演了，而是生成playable，此处直接muted即可
                            track.muted = true;
                        }
                        else
                        {
                            director.SetGenericBinding(track, bindGameObject);
                        }
                    }
                    else
                    {
                        director.SetGenericBinding(track, bindGameObject);
                    }
                }
            }
            else
            {
                // 技能模式直接设置mute
                track.muted = true;
            }
        }

        private GameObject GetRoleModelByRoleType(TrackBindRoleType roleType)
        {
            if (roleType == TrackBindRoleType.Female)
            {
                usingGirl = true;
                return womanModel;
            }
            else if (roleType == TrackBindRoleType.Male)
            {
                return manModel;
            }
            else if (roleType == TrackBindRoleType.Monster)
            {
                usingMonster = true;  // 标记一下用到了monster
                return monsterModel;
            }

            return null;
        }

        // 设置轨道特效
        private void SetTrackAnim(PlayableDirector director, AnimationTrack track, TrackExtData VARIABLE,
            GameObject parentObj, bool followRoot, bool followScale)
        {
            var bindPath = VARIABLE.bindPath;
            if (string.IsNullOrEmpty(bindPath))
            {
                return;
            }

            // animation类型的唯一
            _animationBindObj.TryGetValue(bindPath, out var tempObj);
            if (tempObj == null)
            {
                if (!string.IsNullOrEmpty(VARIABLE.bindRecorderKey))
                {
                    tempObj = _battleSequencer.GetRecordObject(VARIABLE.bindRecorderKey);
                    this._animationBindObj[VARIABLE.bindRecorderKey] = tempObj;
                }
                else if(!string.IsNullOrEmpty(bindPath))
                {
                    tempObj = this.InitOtherEffect(bindPath);
                    this._animationBindObj[bindPath] = tempObj;
                }
            }
            
            if (tempObj != null)
            {
                this.SetTimelineParent(parentObj, followRoot, tempObj.transform, VARIABLE, followScale);
                // tempObj.SetActive(true);
                _hasAnimTrans.Add(tempObj);
                BattleUtil.EnsureComponent<Animator>(tempObj);
                director.SetGenericBinding(track, tempObj);
            }
        }

        // 加载一个特效对象
        private GameObject InitOtherEffect(string bindPath)
        {
            if (string.IsNullOrEmpty(bindPath))
            {
                return null;
            }
            
            var obj = _context.LoadTimelineFxObject(bindPath);
            if (obj != null)
            {
                _subTranList.Add(obj);
                // obj.SetActive(false);
            }
            else
            {
                LogProxy.LogError($"timeline特效加载失败，如果GM中关闭了timeline特效，忽略这条报错！特效路径：{bindPath}");
            }

            return obj;
        }

        // 设置节点的Parent
        private void SetTimelineParent(GameObject parentObj, bool followRoot, Transform childTran,
            TrackExtData extData, bool followScale)
        {
            {
                if (parentObj)
                {
                    var parentTran = parentObj.transform;
                    if (followRoot)
                    {
                        childTran.parent = parentTran;
                        if (extData != null)
                        {
                            X3TimelineUtility.SetTransLocalPositionByExtData(childTran, extData);
                            X3TimelineUtility.SetTransLocalRotationByExtData(childTran, extData);
                        }
                    }
                    else
                    {
                        childTran.parent = parentRoot;
                        if (extData != null)
                        {
                            X3TimelineUtility.SetTransPositionByExtData(childTran, extData, parentTran);
                            X3TimelineUtility.SetTransRotationByExtData(childTran, extData, parentTran);
                        }
                    }

                    if (extData != null)
                    {
                        X3TimelineUtility.SetTransLocalScaleByExtData(childTran, extData);
                    }
                }
                else
                {
                    childTran.parent = parentRoot;
                    if (extData != null)
                    {
                        X3TimelineUtility.SetTransLocalPositionByExtData(childTran, extData);
                        X3TimelineUtility.SetTransLocalRotationByExtData(childTran, extData);
                        X3TimelineUtility.SetTransLocalScaleByExtData(childTran, extData);
                    }
                }
            }
        }

        private GameObject _TryGetBindModelByExtDat(TrackExtData extData)
        {
            if (!string.IsNullOrEmpty(extData.bindRecorderKey))
            {
                var obj = _battleSequencer.GetRecordObject(extData.bindRecorderKey);
                return obj;
            } 
            else if (isPerformMode || notBindCreator)
            {
                var roleType = BSTypeUtil.GetBindRoleTypeByTrackExtData(extData);
                var bindGameObject = this.GetRoleModelByRoleType(roleType);
                return bindGameObject;
            }
            else
            {
                return _battleSequencer.bsCreateData.creatorModel;
            }
        }

        // --------------------------------- 绑定主体，通用代码 ----------------------------
        private GameObject BindRoleObjGeneral(PlayableDirector director, TrackAsset track, TrackExtData extData)
        {
            var bindGameObject = this._TryGetBindModelByExtDat(extData);
            if (bindGameObject)
            {
                director.SetGenericBinding(track, bindGameObject);
            }
            return bindGameObject;
        }

        //-------------------------------------- 设置特效动画相关--------------------------------------/-
        // private void BindFxPlayerTrack(PlayableDirector director, FxPlayerTrack track)
        // {
        //     GameObject obj = null;
        //     if (!string.IsNullOrEmpty(track.extData.bindRecorderKey))
        //     {
        //         obj = _timeline.GetRecordObject(track.extData.bindRecorderKey);
        //     }
        //     else
        //     {
        //         this.InitOtherEffect(track.extData.bindPath);
        //     }
        //     if (obj != null)
        //     {
        //         this.SetTimelineParent(null, false, obj.transform, null, false);
        //         // obj.SetActive(true);
        //         director.SetGenericBinding(track, obj);
        //     }
        // }

        //-------------------------------------- 设置残影相关 -----------------------------------------
        private void BindGhostTrack(TrackAsset lastTrack, TrackAsset track)
        {
            var ghostTrack = track as GhostTrack;
            if (ghostTrack != null)
            {
                ghostTrack.ghostObjPool = null;
            }
            if (isPerformMode || notBindCreator)
            {
                // 表演模式或者非强绑定模式使用相邻轨道的
                if (lastTrack is AnimationTrack)
                {
                    ghostTrack.referTarget = this._director.GetGenericBinding(lastTrack) as GameObject;
                }
                else if (lastTrack is GhostTrack)
                {
                    ghostTrack.referTarget = (lastTrack as GhostTrack).referTarget;
                }
            }
            else
            {
                // 技能模式使用主体的
                ghostTrack.referTarget = this._battleSequencer.bsCreateData.creatorModel;
            }

            // 提前创建好池
            var bindObj = _director.GetGenericBinding(ghostTrack) as GameObject;
            var pool = new GhostObjectPool(bindObj);
            ghostTrack.ghostObjPool = pool;
            
            _ghostPools.Add(pool);
            ghostTrack.RefreshClipInfo(this._director);
        }

        //---------------------------------------------- 销毁逻辑 ----------------------------------------------
        protected override void _OnDestroy()
        {
            if (_needClearCameraEvent)
            {
                _needClearCameraEvent = false;
                var eventData = Battle.Instance.eventMgr.GetEvent<EventTimeLineWithVirCam>();
                eventData.Init(GetHashCode(), null, null, false);
                Battle.Instance.eventMgr.Dispatch(EventType.TimelineWithVirCam, eventData);  
            }
            
            if (this._loopFxTracks.Count > 0)
            {
                foreach (var iter in _loopFxTracks)
                {
                    iter.Key.muted = false;
                }
            }

            if (_subTranList.Count > 0)
            {
                for (int i = 0; i < _subTranList.Count; i++)
                {
                    _context.UnloadGameObject(_subTranList[i]);
                }
            }

            if (_ghostHDList.Count > 0)
            {
                var actorModel = Battle.Instance.modelMgr;
                for (int i = 0; i < _ghostHDList.Count; i++)
                {
                    if (_boyModelCfg != null)
                    {
                        actorModel.RecycleGhostHD(_boyModelCfg, _ghostHDList[i]);   
                    }
                }
                _ghostHDList.Clear();
            }

            _boyModelCfg = null;
        }

        public void SetPPVVisible(bool visible)
        {
            if (_ppvBindGameObjects == null || _ppvBindGameObjects.Count <= 0)
            {
                return;
            }

            foreach (GameObject go in _ppvBindGameObjects)
            {
                go.SetVisible(visible);
            }
        }
    }
}