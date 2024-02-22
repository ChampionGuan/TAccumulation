using Framework;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Profiling;
using UnityEngine.Timeline;
using X3.Character;
using X3.PlayableAnimator;
using ISubsystem = X3.Character.ISubsystem;

namespace X3Battle
{
    public class BSCPerform : BSCBase, IReset
    {
        // TODO 做个临时开关，稳了彻底删掉PerformPlayableInstance
        public const bool usingPerformPlayable = false;
        
        private PerformConfig _performCfg;

        // 战斗中的男女主, 需要重置至Idel态.
        private Actor _girlActor;
        private Actor _boyActor;
        private Actor _monsterActor;
        
        private float? _oldLod;
        private PerformPlayableInstance _femalePlayableIns;
        private PerformPlayableInstance _malePlayableIns;
        
        // 表演场景的Root节点
        private GameObject _dynamicGirlModel;
        private GameObject _dynamicGirlRoot;
        private GameObject _dynamicBoyModel;
        private GameObject _dynamicBoyRoot;
        private GameObject _dynamicMonsterModel;
        private GameObject _dynamicMonsterRoot;
        private PlayableAnimator _dynamicMonsterAnimator;

        private PerformModel _performGirlModel;
        private PerformModel _performBoyModel;
        private PerformModel _performMonsterModel;

        private GameObject _dynamicBoyWeapon;
        private bool _oldBoyWeaponVisible;
        private bool _isTryIdle;

        public void Reset()
        {
            _girlActor = null;
            _boyActor = null;
            _monsterActor = null;
            
            _performCfg = null;
            
            _dynamicGirlModel = null;
            _dynamicGirlRoot = null;
            _dynamicBoyModel = null;
            _dynamicBoyRoot = null;
            _dynamicMonsterModel = null;
            _dynamicMonsterRoot = null;
            _dynamicMonsterAnimator = null;
            
            _dynamicBoyWeapon = null;
            _oldBoyWeaponVisible = false;
            
            _oldLod = null;
            _femalePlayableIns = null;
            _malePlayableIns = null;

            _isTryIdle = false;
        }
        
        public void StartStep1(bool isEvalBattleActor)
        {
            using (ProfilerDefine.BSCPerformStartPlay1Marker.Auto())
            {
                //此处优先调用暂停武器显隐 之后会延迟了一帧再切画面
                if (isEvalBattleActor)
                {
                    _girlActor?.weapon?.SetWeaponVisiblePause(true);
                    _boyActor?.weapon?.SetWeaponVisiblePause(true);    
                }
                // 新增逻辑打开表演人物Graph
                var bindCom = _battleSequencer.GetComponent<BSCTrackBind>();
                if (_performGirlModel != null && bindCom.usingGirl)
                {
                    _performGirlModel.SetVisible(true);
                }
            
                if (_performBoyModel != null)
                {
                    _performBoyModel.SetVisible(true);
                }
            }
        }

        public void StartStep3(bool isEvalBattleActor)
        {
            using (ProfilerDefine.BSCPerformStartPlay3Marker.Auto())
            {
                // 是否处理battleActor重置
                if (isEvalBattleActor)
                {
                    _isTryIdle = true;
                    // 男女主停止技能
                    if (_girlActor != null)
                    {
                        //恢复武器显隐 因为要求要播对应idle和武器状态了
                        _girlActor.weapon?.SetWeaponVisiblePause(false);
                        _girlActor.skillOwner?.ClearSkillRemainFX();
                        _girlActor.aiOwner?.ClearCombatAIGoal();
                        _girlActor.input?.ClearCache();
                        _girlActor.commander?.ClearCmd();
                
                        // DONE: 加的特殊规则, 处理女主一开始动画RootMotion跳了起来, 导致爆发技女主一直在空中.
                        _girlActor.transform.ForceFloor();

                        // 女主武器设置：由于游戏暂停了 没更新武器显隐 所以设置一下武器显示并Update
                        //_girlActor.weapon.SetWeaponVisible(true);
                        //_girlActor.weapon.LateUpdate();
						//TODO 整理此处接口到统一_ForceIdle changkong
                        _girlActor.animator.Play(AnimStateName.WeaponIdle, 0, 0f);//需要播放一下 防止看到一帧的动画切换
                        _girlActor.battle.SetIdleParam(_girlActor, true);

                        // 表演女主看向目标
                        if (_girlActor != null)
                        {
                            var castSkillForward = _girlActor.skillOwner.curCastForward;
                            _girlActor.transform.SetForward(castSkillForward);
                        }
                    }

                    if (_boyActor != null)
                    {
                        //恢复武器显隐 因为要求要播对应idle和武器状态了
                        _boyActor.weapon?.SetWeaponVisiblePause(false);
                        _ForceIdle(_boyActor, false, false);
                        // DONE: 加的特殊规则, 处理男主一开始动画RootMotion跳了起来, 爆发技之后会看到男主没落在地上.
                        _boyActor.transform.ForceFloor();
                    }
                }
            }
        }

        // 特殊规则 timeline表演完后可以选择不同的Idle 选择是否播淡出特效
        private void _ForceIdle(Actor actor, bool isBattleIdle, bool weaponEffect)
        {
            actor.animator.Play(isBattleIdle ? AnimStateName.WeaponIdle : AnimStateName.Idle, 0, 0f);//需要播放一下 防止看到一帧的动画切换
            actor.battle.SetIdleParam(_boyActor, isBattleIdle, weaponEffect);
            actor.ForceIdle();
        }
        
        // 处理表演人物
        public void StartStep2()
        {
            using (ProfilerDefine.BSCPerformStartPlay2Marker.Auto())
            {
                // 表演女主位置
                if (_dynamicGirlRoot != null)
                {
                    _dynamicGirlRoot.transform.localPosition = Vector3.zero;
                }
            
                // 表演男主位置设置
                if (_dynamicBoyRoot != null)
                {
                    _dynamicBoyRoot.transform.localPosition = Vector3.zero;
                    _dynamicBoyRoot.transform.forward = Vector3.forward;
                
                    // 表演男主武器强制显示.
                    if (_dynamicBoyWeapon != null)
                    {
                        _oldBoyWeaponVisible = _dynamicBoyWeapon.activeSelf;
                        _dynamicBoyWeapon.SetActive(true);   
                    }
                }
            
                // 怪物处理
                _FindMonster();
                if (_performMonsterModel != null)
                {
                    _performMonsterModel.SetVisible(true);
                }
            
                // 表演怪物位置设置
                if (_dynamicMonsterRoot != null)
                {
                    var performRoot = Battle.Instance.performRootTrans;
                    _dynamicMonsterRoot.transform.SetParent(performRoot);
                    _dynamicMonsterRoot.transform.localPosition = Vector3.zero;
                    _dynamicMonsterRoot.transform.forward = Vector3.forward;
                    _dynamicMonsterAnimator = _performMonsterModel?.animator;
                    // DONE: 怪物默认播放受击动画.
                    _dynamicMonsterAnimator?.Play("Idle", 0, 0f);
                }
            }
        }

        // 播放结束2：恢复男主武器显示、关闭表演人物Graph
        public void StopStep1()
        {
            using (ProfilerDefine.BSCPerformStopPlay1Marker.Auto())
            {
                if (_performMonsterModel != null && _monsterActor != null)
                {
                    _RecyclePerformModel(_monsterActor, _performMonsterModel);
                    _monsterActor = null;
                    _performMonsterModel = null;
                    _dynamicMonsterRoot = null;
                    _dynamicMonsterModel = null;
                    _dynamicMonsterAnimator = null;
                }
            
                // 恢复男主武器显示
                if (_dynamicBoyWeapon != null)
                {
                    _dynamicBoyWeapon.SetActive(_oldBoyWeaponVisible);
                }
            
                // 关闭表演人物Graph
                if (_performGirlModel != null)
                {
                    _performGirlModel.SetVisible(false);
                }
            
                if (_performBoyModel != null)
                {
                    _performBoyModel.SetVisible(false);
                }
            
                if (_performMonsterModel != null)
                {
                    _performMonsterModel.SetVisible(false);
                }
            }
        }

        // 播放结束步骤2：播放结束特效
        public void StopStep2()
        {
            using (ProfilerDefine.BSCPerformStopPlay2Marker.Auto())
            {
                //  如果有配结束时特效就播出来
                var endTimelineEffectPath = _performCfg.EndEffectPath;
                if (!string.IsNullOrEmpty(endTimelineEffectPath))
                {
                    Battle.Instance.sequencePlayer.PlaySceneEffect(endTimelineEffectPath);
                }
            }
        }
        
        protected override void _OnInit()
        {
            this._performCfg = _battleSequencer.bsCreateData.performCfg;
            this._oldBoyWeaponVisible = false;
            this._femalePlayableIns = null;
            this._malePlayableIns = null;
            var bindCom = _battleSequencer.GetComponent<BSCTrackBind>();
            bindCom.isPerformMode = true;

            _FindWoman();
            _DisableGirlDB();
            _FindMan();
        }

        protected override bool _OnBuild()
        {
            // 获取Root
            var performRoot = Battle.Instance.performRootTrans;
            var trackBindCom = _battleSequencer.GetComponent<BSCTrackBind>();
            trackBindCom.parentRoot = performRoot.transform;

                // 表演女主位置
            if (_dynamicGirlRoot != null)
            {
                _dynamicGirlRoot.transform.SetParent(performRoot);
                _dynamicGirlRoot.transform.localPosition = Vector3.zero;
            }
            
            // 表演男主位置设置
            if (_dynamicBoyRoot != null)
            {
                _dynamicBoyRoot.transform.SetParent(performRoot);
                _dynamicBoyRoot.transform.localPosition = Vector3.zero;
            }

            this._InitActorAnim();
            _EvalMonsterHurtAnim();
            
            return true;
        }

        //  播放角色表演动画
        public void _InitActorAnim()
        {
            var resCom = _battleSequencer.GetComponent<BSCRes>();
            var director = resCom.artDirector;
            var timelineObj = resCom.artObject;
            if (director != null && timelineObj != null)
            {
                var groupType = _context.GetEStaticSlot();
                //  女主表演动画
                if (usingPerformPlayable && _dynamicGirlModel != null)
                {
                    this._femalePlayableIns = ObjectPoolUtility.PerformPlayableInstance.Get();
                    this._femalePlayableIns.SetAnimatorByGameObject(this._dynamicGirlModel);
                    this._femalePlayableIns.SetOnlyFemale();
                    this._femalePlayableIns.SetAnimationGroupType((int) groupType);
                    this._femalePlayableIns.BuildTimelinePerformPlayable(director);
                    _battleSequencer.AddPlayableIns(this._femalePlayableIns);
                }
                
                //  男主表演动画
                if (usingPerformPlayable && _dynamicBoyModel != null)
                {
                    this._malePlayableIns = ObjectPoolUtility.PerformPlayableInstance.Get();
                    this._malePlayableIns.SetAnimatorByGameObject(this._dynamicBoyModel);
                    this._malePlayableIns.SetOnlyMale();
                    this._malePlayableIns.SetAnimationGroupType((int) groupType);
                    this._malePlayableIns.BuildTimelinePerformPlayable(director);
                    _battleSequencer.AddPlayableIns(this._malePlayableIns); 
                }
            }
        }

        //  停止播放角色材质动画
        private void _DestroyActorAnim()
        {
            if (this._femalePlayableIns != null)
            {
                this._femalePlayableIns.Destroy();
                this._femalePlayableIns = null;
            }

            if (this._malePlayableIns != null)
            {
                this._malePlayableIns.Destroy();
                this._malePlayableIns = null;
            }
        }

        private void _EvalMonsterHurtAnim()
        {
            var resCom = _battleSequencer.GetComponent<BSCRes>();
            var director = resCom.artDirector;
            if (director.playableAsset is TimelineAsset timelineAsset)
            {
                var allTracks = timelineAsset.GetOutputTracks();
                foreach (var trackAsset in allTracks)
                {
                    // DONE: 怪物受击动画绑定规则.
                    if (trackAsset.name == "DynamicAnimator")
                    {
                        if (trackAsset is AnimationTrack animationTrack)
                        {
                            var roleType = BSTypeUtil.GetBindRoleTypeByTrackExtData(animationTrack.extData);
                            if (roleType == TrackBindRoleType.Monster)
                            {
                                _BindMonsterAnimTrack(director, animationTrack, animationTrack.extData);
                            }
                        }
                    }
                }
            }
        }

        protected override void _OnDestroy()
        {
            if (_performGirlModel != null)
            {
                _RecyclePerformModel(_girlActor, _performGirlModel);
            }
            
            if (_performBoyModel != null)
            {
                _RecyclePerformModel(_boyActor, _performBoyModel);
            }
            
            this._DestroyActorAnim();
        }

        protected override void _OnTick(float deltaTime)
        {
            if (_dynamicMonsterAnimator != null)
            {
                _dynamicMonsterAnimator.Update(deltaTime);
            }
            
            if (_isTryIdle)
            {
                if (_girlActor?.animator != null)
                {
                    _girlActor.animator.Update(deltaTime);
                }
                _girlActor.weapon.PostUpdateVisible();

                if (_boyActor?.animator != null)
                {
                    _boyActor.animator.Update(deltaTime);
                }
                _boyActor.weapon.PostUpdateVisible();

                _isTryIdle = false;
            }
        }

        // param timelineObj BattleTimeline timeline对象
        // return GameObject 获取女主模型
        private void _FindWoman()
        {
            var bindCom = _battleSequencer.GetComponent<BSCTrackBind>();
            var actor = Battle.Instance.actorMgr.girl;
            if (actor != null)
            {
                _girlActor = actor;
                var girlModel = _GetPerformModel(actor);
                if (girlModel != null)
                {
                    _performGirlModel = girlModel;
                    _dynamicGirlRoot = girlModel.root;
                    _dynamicGirlModel = girlModel.model;
                    bindCom.womanModel = _dynamicGirlModel;
                }
            }
        }

        // 根据配置禁用女主身上的某些部件 (目前场上只有一个爆发技，只需要在Init时调用一次即可)
        private void _DisableGirlDB()
        {
            if (_performGirlModel != null && _performCfg.DisableDBList != null && _performCfg.DisableDBList.Length > 0)
            {
                var x3character = _performGirlModel.x3Character;
                var x3PhysicsCloth = x3character.GetSubsystem(ISubsystem.Type.PhysicsCloth) as X3PhysicsCloth;
                var parts = ObjectPoolUtility.CommonStringList.Get();
                
                for (int i = 0; i < _performCfg.DisableDBList.Length; i++)
                {
                    parts.Clear();
                    var intType = _performCfg.DisableDBList[i];  // PartType类型
                    CharacterMgr.GetPartNamesWithPartType(_dynamicGirlModel, intType, parts);
                    foreach (var partName in parts)
                    {
                        x3PhysicsCloth.SetSimulateState(partName, false);
                    }
                }
                
                ObjectPoolUtility.CommonStringList.Release(parts);
            }   
        }

        // return GameObject 获取男主模型
        private void _FindMan()
        {
            var actor = Battle.Instance.actorMgr.boy;
            if (actor != null)
            {
                _boyActor = actor;
                var boyModel = _GetPerformModel(actor);
                if (boyModel != null)
                {
                    _performBoyModel = boyModel;
                    _dynamicBoyRoot = boyModel.root;
                    _dynamicBoyModel = boyModel.model;
                    _dynamicBoyWeapon = boyModel.weapon;
                    var bindCom = _battleSequencer.GetComponent<BSCTrackBind>();
                    bindCom.manModel = _dynamicBoyModel;
                }
            }
        }

        // param timelineObj BattleTimeline timeline对象
        // return GameObject 获取Boos模型
        private void _FindMonster()
        {
            using (ProfilerDefine.BSCPerformFindMonsterMarker.Auto())
            {
                _performMonsterModel = null;
                _dynamicMonsterRoot = null;
                _dynamicMonsterModel = null;

                var bindCom = _battleSequencer.GetComponent<BSCTrackBind>();
                bindCom.monsterRoot = null;
                bindCom.monsterModel = null;
                if (bindCom.usingMonster)
                {
                    var girl = Battle.Instance.actorMgr.girl;
                    var actor = girl?.GetTarget(TargetType.Skill); 
                    if (actor != null)
                    {
                        _monsterActor = actor;
                        var monsterModel = _GetPerformModel(_monsterActor);
                        _performMonsterModel = monsterModel;
                        _dynamicMonsterRoot = monsterModel.root;
                        _dynamicMonsterModel = monsterModel.model;
                        bindCom.monsterRoot = _dynamicMonsterRoot;
                        bindCom.monsterModel = _dynamicMonsterModel;
                    }     
                }
            }
        }

        private void _BindMonsterAnimTrack(PlayableDirector director, AnimationTrack track, TrackExtData trackExtData)
        {
            var sequenceTrack = new X3Sequence.Track(_battleSequencer.artSequencer, name: track.name);
            var roleType = BSTypeUtil.GetBindRoleTypeByTrackExtData(trackExtData);
            if (roleType == TrackBindRoleType.Monster)
            {
                var clips = track.GetClips();
                foreach (var timelineClip in clips)
                {
                    // DONE: 绑定规则.
                    var animClipName = timelineClip.displayName;
                    var action = new BSADynamicActorAnim();
                    action.SetData(animClipName, _GetMonsterPlayableAnimatorFunc, _GetMonsterAnimationNameFunc);
                    action.Init(sequenceTrack, (float)timelineClip.start, (float)timelineClip.duration, timelineClip.displayName);
                    sequenceTrack.AddAction(action);
                }
            }
            
            _battleSequencer.artSequencer.AddTrack(sequenceTrack);
        }

        private PlayableAnimator _GetMonsterPlayableAnimatorFunc(string clipName)
        {
            return _dynamicMonsterAnimator;
        }

        private string _GetMonsterAnimationNameFunc(string clipName)
        {
            // DONE: 受击动作需要查怪物表, 其余的不用查表.
            if (clipName == "Hurt" && _monsterActor != null)
            {
                if (TbUtil.TryGetCfg(_monsterActor.config.ID, out MonsterCfg monsterCfg))
                {
                    clipName = monsterCfg.UltraSkillHurtAnim;
                }
            }

            return clipName;
        }

        private PerformModel _GetPerformModel(Actor actor)
        {
            var go = actor?.battle.modelMgr.GetModelIns(actor);
            if (null == go)
            {
                return null;
            }

            var model = go.transform.Find("Model").gameObject;

            // TODO for 老艾, performModel 池子优化.
            return new PerformModel(model, actor.model.config);
        }

        private void _RecyclePerformModel(Actor actor, PerformModel performModel)
        {
            if (null == performModel)
            {
                return;
            }

            actor?.battle?.modelMgr?.RecycleModelIns(actor, performModel.root);
        }
    }
}