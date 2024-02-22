using System;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;
using UnityEngine.Events;

namespace X3Battle
{
    public class PlayerSelectFx : BattleComponent
    {
        private Actor _selectedActor;
        private int _fxId;
        private bool _isActive = true;

        private string _dummyName;
        private float _minCameraDistance;
        private float _maxCameraDistance;
        private float _minScale;
        private float _maxScale;
        
        private Transform _cameraTransform;
        
        private FxPlayer _fxPlayer;
        private Transform _dummyTrans;

        private UnityAction<CinemachineBrain> _updateFxPlayer;

        private Action<FxPlayer> _actionFxPlayerDestroy;

        private bool _markNeedPlay;
        
        
        public PlayerSelectFx() : base(BattleComponentType.PlayerSelectFx)
        {
            requiredUpdate = false;
            requiredPhysicalJobRunning = true;
        }

        protected override void OnAwake()
        {
            _dummyName = TbUtil.battleConsts.SelectedDummyName;
            _minCameraDistance = TbUtil.battleConsts.SelectedMinCameraDistance;
            _maxCameraDistance = TbUtil.battleConsts.SelectedMaxCameraDistance;
            _minScale = TbUtil.battleConsts.SelectedMinScale;
            _maxScale = TbUtil.battleConsts.SelectedMaxScale;
            _fxId = TbUtil.battleConsts.SelectedMonsterFXID;
            
            _cameraTransform = BattleUtil.MainCamera.transform;

            _markNeedPlay = false;
            
            battle.eventMgr.AddListener<EventChangeLockTarget>(EventType.ChangeLockTarget, _OnChangeLockTarget, "PlayerSelectFx._OnChangeLockTarget");
            battle.eventMgr.AddListener<EventCastSkill>(EventType.CastSkill, _OnPlayerCastSkill, "PlayerSelectFx._OnPlayerCastSkill()");
            battle.eventMgr.AddListener<EventChangeLockTargetMode>(EventType.ChangeLockTargetMode, _OnChangeLockTargetMode, "PlayerSelectFx._OnChangeLockTarget");
            _updateFxPlayer = _UpdateFxPlayer;
            CinemachineCore.CameraUpdatedEvent?.AddListener(_updateFxPlayer);
            _actionFxPlayerDestroy = _FxPlayerOnDestroy;
            
            //处理boss出生时立刻锁定，BOSS出生技能又有无敌，立刻清除锁定的问题。
            //正常情况下锁定特效有ending阶段，不能立刻消除，会闪一下。
            //临时处理，Todo，最好是特效那边支持
        }
        
        public override void OnActorBorn(Actor actor)
        {
            if (actor.IsPlayer())
            {
                actor.eventMgr.AddListener<EventActorStateChange>(EventType.ActorStateChange, _OnPlayerMove, "PlayerSelectFx._OnActorEnterDeadState");
            }
        }

        public override void OnActorRecycle(Actor actor)
        {
            if (actor.IsPlayer())
            {
                actor.eventMgr.RemoveListener<EventActorStateChange>(EventType.ActorStateChange, _OnPlayerMove);
            }
        }

        
        //计算当前帧最终是否播放特效。目前onPreLateUpdate只有表现，不会发出ChangeLockTarget事件
        protected override void OnPhysicalJobRunning()
        {
            _PlayFx();
        }

        private void _UpdateFxPlayer(CinemachineBrain cinemachineBrain)
        {
            if (battle.isEnd)
            {
                _ClearFx();
                return;
            }
            _UpdateFxPlayer();
        }

        private void _FxPlayerOnDestroy(FxPlayer fxPlayer)
        {
            if(_fxPlayer != fxPlayer)
                return;
            _ClearFx();
        }

        private void _UpdateFxPlayer()
        {
            if (_fxPlayer == null || _dummyTrans == null || _cameraTransform == null)
            {
                return;
            }
            Vector3 startPosition = _cameraTransform.position;
            Vector3 endPosition = _dummyTrans.position;
            
            // 计算大小
            float distance = (endPosition - startPosition).magnitude;
            float currentScale;
            if (distance <= _minCameraDistance)
            {
                currentScale = _maxScale;
            }
            else if (distance >= _maxCameraDistance)
            {
                currentScale = _minScale;
            }
            else
            {
                currentScale = Mathf.Lerp(_maxScale, _minScale, (distance - _minCameraDistance) / (_maxCameraDistance - _minCameraDistance));
            }
            BattleUtil.SetScale(_fxPlayer.transform, currentScale);
            
            //计算位置
            Vector3 normalized = (endPosition - startPosition).normalized;
            Vector3 fxPosition = startPosition + normalized * _minCameraDistance;
            _fxPlayer.transform.position = fxPosition;
        }

        private void _OnPlayerCastSkill(EventCastSkill arg)
        {
            if (battle.player.targetSelector.GetModeType() != TargetLockModeType.AI)
            {
                return;
            }

            if (arg.skill.actor != battle.player)
            {
                return;
            }
            Actor targetActor = battle.player.targetSelector.GetTarget();
            _UpdateTarget(targetActor);
        }
        
        private void _OnPlayerMove(EventActorStateChange eventActorMove)
        {
            if (battle.player.targetSelector.GetModeType() != TargetLockModeType.AI)
            {
                return;
            }

            if (eventActorMove.toStateName != ActorMainStateType.Move)
            {
                return;
            }
            Actor targetActor = battle.player.targetSelector.GetTarget();
            _UpdateTarget(targetActor);
        }

        private void _OnChangeLockTarget(EventChangeLockTarget changeLockTarget)
        {
            if (battle.player == null || battle.player != changeLockTarget.actor)
                return;
            //AI模式下切换目标不立刻切换特效
            if (battle.player.targetSelector.GetModeType() == TargetLockModeType.AI && changeLockTarget.target != null)
            {
                //AI模式下目标死亡时如果有其他可选择单位会直接选择其他单位，但是策划需要此时立刻停掉死亡目标的锁定特效
                if (_selectedActor != null && _selectedActor.isDead)
                {
                    _UpdateTarget(null);
                }
                return;
            }
            Actor targetActor = changeLockTarget.target;
            _UpdateTarget(targetActor);
        }
        
        private void _OnChangeLockTargetMode(EventChangeLockTargetMode changeLockTargetMode)
        {
            if (battle.player == null || battle.player != changeLockTargetMode.actor)
                return;
            //退出AI模式时
            if (changeLockTargetMode.preLockMode == TargetLockModeType.AI &&
                changeLockTargetMode.targetLockMode != TargetLockModeType.AI)
            {
                _UpdateTarget(null);
            }
        }

        private void _UpdateTarget(Actor targetActor)
        {
            if (targetActor == null)
            {
                _ClearFx();
                return;
            }
            if (!targetActor.IsMonster() || targetActor == _selectedActor)
                return;
            _ClearFx();
            _selectedActor = targetActor;
            _markNeedPlay = true;
        }

        private void _ClearFx()
        {
            _StopFx();
            _selectedActor = null;
            if (_fxPlayer != null)
            {
                _fxPlayer.destroyFx = null;
            }
            _fxPlayer = null;
            _dummyTrans = null;
        }

        private void _PlayFx()
        {
            if (!_markNeedPlay)
            {
                return;
            }
            _markNeedPlay = false;
            if (!_isActive)
            {
                return;
            }
            if (_selectedActor == null)
            {
                return;
            }
            FxPlayer fxPlayer = battle.fxMgr.PlayBattleFx(_fxId, _selectedActor.insID, targetType: TargetType.Skill, resType: BattleResType.FX, isOnly: true, timeScaleType: FxPlayer.TimeScaleType.Battle);
            if (fxPlayer == null)
            {
                return;
            }
            _fxPlayer = fxPlayer;
            _fxPlayer.destroyFx = _actionFxPlayerDestroy;
            _dummyTrans = _selectedActor.GetDummy(_dummyName);
            _UpdateFxPlayer();
        }

        private void _StopFx()
        {
            if (_selectedActor == null)
            {
                return;
            }
            battle.fxMgr.StopFx(_fxId, _selectedActor.insID);
        }

        public void SetFxActive(bool active)
        {
            if (_isActive == active)
            {
                return;
            }
            _isActive = active;
            if (_selectedActor == null)
            {
                return;
            }
            if (_isActive)
            {
                _markNeedPlay = true;
            }
            else
            {
                _StopFx();
                _markNeedPlay = false;
            }
        }

        protected override void OnDestroy()
        {
            CinemachineCore.CameraUpdatedEvent?.RemoveListener(_updateFxPlayer);
            battle.eventMgr.RemoveListener<EventChangeLockTarget>(EventType.ChangeLockTarget, _OnChangeLockTarget);
            battle.eventMgr.RemoveListener<EventCastSkill>(EventType.CastSkill,_OnPlayerCastSkill);
            battle.eventMgr.RemoveListener<EventChangeLockTargetMode>(EventType.ChangeLockTargetMode, _OnChangeLockTargetMode);
            _ClearFx();
            _cameraTransform = null;
        }
    }
}