using System;
using PapeGames.X3;
using System.Collections.Generic;
using UnityEngine;
using X3.Character;
using Framework;

namespace X3Battle
{
    public class LookAt : ActorComponent
    {
        public bool enable = true;

        public LookAtBehaviour lookAtBehaviour;
        public bool isLookat => _isLookAt;
        public float rotateTime => _basicRotateTime;

        private X3LookAt _x3LookAt;

        private Vector3 _lookAtOffset;
        private bool _isLookAt;

        private float _basicRotateTime = 0.1f;
        private float _timeScale;
        
        private Action<EventActorStateChange> _actionActorStateChange;
        private Action<EventScalerChange> _actionScalerChange;
#if UNITY_EDITOR
        public Transform lookAtTarget;
#endif

        public LookAt() : base(ActorComponentType.LookAt)
        {
            requiredPhysicalJobRunning = true;
            _actionActorStateChange = _OnActorStateChange;
            _actionScalerChange = _OnScalerChange;
        }

        protected override void OnStart()
        {
            base.OnStart();
            _lookAtOffset = Vector3.zero;
            if (actor.IsBoy())
            {
                X3Character character = actor.EnsureComponent<X3Character>(actor.GetDummy(ActorDummyType.Model).gameObject);
                X3.Character.ISubsystem subsystem = character.GetSubsystem(X3.Character.ISubsystem.Type.LookAt);
                _x3LookAt = subsystem as X3LookAt;
                if(null == _x3LookAt) return;
                
                _x3LookAt.horizontalAngle = actor.roleCfg.LookAtHorizontalAngle;
                _x3LookAt.verticalAngle = actor.roleCfg.LookAtVerticalAngle;
                _x3LookAt.maxHoriArtAngle = actor.roleCfg.LookAtMaxHoriArtAngle;
                _x3LookAt.maxVertArtAngle = actor.roleCfg.LookAtMaxVertArtAngle;

                _x3LookAt.maxActualHoriAngle = actor.roleCfg.MaxActualHoriAngle;
                _x3LookAt.maxActualVertAngle = actor.roleCfg.MaxActualVertAngle;
                if (actor.boyCfg.LookAtOffset != null && actor.boyCfg.LookAtOffset.Length == 3)
                    _lookAtOffset = new Vector3(actor.boyCfg.LookAtOffset[0], actor.boyCfg.LookAtOffset[1], actor.boyCfg.LookAtOffset[2]);
            }
            else if (actor.type == ActorType.Monster)
            {
                lookAtBehaviour = actor.EnsureComponent<LookAtBehaviour>(actor.GetDummy(ActorDummyType.Model).gameObject);
                lookAtBehaviour.blendSpacePath = actor.monsterCfg.LookAtBlendSpaceConfig;
                lookAtBehaviour.Start();
                lookAtBehaviour.horizontalAngle = actor.roleCfg.LookAtHorizontalAngle;
                lookAtBehaviour.verticalAngle = actor.roleCfg.LookAtVerticalAngle;
                lookAtBehaviour.maxHoriArtAngle = actor.roleCfg.LookAtMaxHoriArtAngle;
                lookAtBehaviour.maxVertArtAngle = actor.roleCfg.LookAtMaxVertArtAngle;
                if (actor.monsterCfg.LookAtOffset != null && actor.monsterCfg.LookAtOffset.Length == 3)
                    _lookAtOffset = new Vector3(actor.monsterCfg.LookAtOffset[0], actor.monsterCfg.LookAtOffset[1], actor.monsterCfg.LookAtOffset[2]);
            }
        }

        protected override void OnDestroy()
        {
            base.OnDestroy();
            if (actor.type == ActorType.Monster)
            {
                lookAtBehaviour.OnDestroy();
            }
        }

        public override void OnBorn()
        {
            _isLookAt = false;
            _timeScale = 1;
            if (actor.IsBoy())
            {
                actor.eventMgr.AddListener<EventActorStateChange>(EventType.ActorStateChange, _actionActorStateChange, "LookAt._OnActorStateChange");
            }
            else if (actor.type == ActorType.Monster)
            {
                actor.eventMgr.AddListener<EventActorStateChange>(EventType.ActorStateChange, _actionActorStateChange, "LookAt._OnActorStateChange");
            }
            battle.eventMgr.AddListener<EventScalerChange>(EventType.OnScalerChange, _actionScalerChange, "LookAt._OnScalerChange");
        }

        public override void OnDead()
        {
            if (actor.IsBoy())
            {
                actor.eventMgr.RemoveListener<EventActorStateChange>(EventType.ActorStateChange, _actionActorStateChange);
            }
            else if (actor.type == ActorType.Monster)
            {
                actor.eventMgr.RemoveListener<EventActorStateChange>(EventType.ActorStateChange, _actionActorStateChange);                
            }
            battle.eventMgr.RemoveListener<EventScalerChange>(EventType.OnScalerChange, _actionScalerChange);
        }

        protected override void OnPhysicalJobRunning()//先确定动画
        {
            //UpdateWeight();
        }

        /// <summary>
        /// 使用看向策略看向目标
        /// </summary>
        /// <param name="isLookAt"></param>
        /// <param name="isSkill"></param>
        /// <param name="rotateTime"></param>
        public void UseLookAtStrategy(bool isLookAt, float rotateTime = 0f)
        {
            //策划需求：
            //0 = 非战斗不看向girl，战斗不看向和怪物一致策略的目标
            //1 = 非战斗看向girl，战斗不看向和怪物一致策略的目标
            //2 = 非战斗不看向girl，战斗看向和怪物一致策略的目标
            //3 = 非战斗看向girl，战斗看向和怪物一致策略的目标
            if (actor.IsBoy())
            {
                bool isBattleState = actor.aiOwner != null && actor.aiOwner.enabled && actor.aiOwner.isBattleState;
                if (actor.boyCfg.LookAtStrategy == 0)
                {
                    if (isBattleState)
                    {
                        _LookAtStrategy(false, rotateTime, _lookAtOffset);
                    }
                    else
                    {
                        LookAtLogic(false, actor, null, TargetType.Girl, rotateTime);
                    }
                }
                else if (actor.boyCfg.LookAtStrategy == 1)
                {
                    // 非战斗状态看向女主
                    if (!isBattleState)
                    {
                        LookAtLogic(isLookAt, actor, null, TargetType.Girl, rotateTime, _lookAtOffset);
                    }
                    else
                    {
                        _LookAtStrategy(false, rotateTime, _lookAtOffset);
                    }
                }
                else if (actor.boyCfg.LookAtStrategy == 2)
                {
                    // 战斗看向和怪物一致策略的目标
                    if (isBattleState)
                    {
                        _LookAtStrategy(isLookAt, rotateTime, _lookAtOffset);
                    }
                    else
                    {
                        LookAtLogic(false, actor, null, TargetType.Girl, rotateTime);
                    }
                }
                else
                {
                    if (isBattleState)
                    {
                        _LookAtStrategy(isLookAt, rotateTime, _lookAtOffset);
                    }
                    else
                    {
                        LookAtLogic(isLookAt, actor, null, TargetType.Girl, rotateTime);
                    }
                }
            }
            else if (actor.type == ActorType.Monster)
            {
                _LookAtStrategy(isLookAt, rotateTime, _lookAtOffset);
            }
        }

        /// <summary>
        /// 怪物看向策略，技能状态下看向技能目标，Idle状态下看向移动目标，Move状态下看向移动目标
        /// </summary>
        /// <param name="isSkill"></param>
        /// <param name="rotateTime"></param>
        /// <param name="offset"></param>
        private void _LookAtStrategy(bool isLookAt, float rotateTime, Vector3 offset)
        {
            if (actor.mainState.mainStateType == ActorMainStateType.Skill)
            {
                LookAtLogic(isLookAt, actor, null, TargetType.Skill, rotateTime, offset);
            }
            else if (actor.mainState.mainStateType == ActorMainStateType.Move)
            {
                LookAtLogic(isLookAt, actor, null, TargetType.Move, rotateTime, offset);
            }
            else if (actor.mainState.mainStateType == ActorMainStateType.Idle)
            {
                LookAtLogic(isLookAt, actor, null, TargetType.Lock, rotateTime, offset);
            }
            else//不看向
            {
                LookAtLogic(isLookAt, actor, null, null, rotateTime, offset);
            }
        }

        /// <summary>
        /// 直接设置看向目标
        /// </summary>
        /// <param name="isLookAt"></param>
        /// <param name="self"></param>
        /// <param name="target"></param>
        /// <param name="targetType"></param>
        /// <param name="rotateTime"></param>
        /// <param name="offset"></param>
        public void LookAtLogic(bool isLookAt, Actor self, Actor target, TargetType? targetType, float rotateTime, Vector3 offset = new Vector3())
        {
            if (_isLookAt != isLookAt)
                _isLookAt = isLookAt;

            if (lookAtBehaviour == null && _x3LookAt == null)
                return;

            if (_isLookAt)
            {
                if (target == null && targetType.HasValue)
                {
                    target = self.GetTarget(targetType.Value);
                }

                if (target != null)
                {
                    Transform lookAtPoint = target.GetDummy(ActorDummyType.Point_HeadLookAt);
                    if (lookAtPoint != null)
                    {
                        _LookAtTarget(self, rotateTime, lookAtPoint, offset);
                    }
                }
                else
                {
                    LogProxy.Log($"【看向】 Actor Ins:{self.insID}没有找到目标");
                    return;
                }
            }
            else
            {
                _LookAtTarget(self, rotateTime, null, offset);
            }
        }

        public void Pause(bool isPause)
        {
            if(isPause)
            {
                // 
                enable = false;
                if (actor.IsBoy())
                {
                    _x3LookAt.headRotateTime = float.MaxValue;
                }
                else if (actor.type == ActorType.Monster)
                {
                    lookAtBehaviour.headRotateTime = float.MaxValue;
                }
            }
            else
            {
                enable = true;
                if (actor.IsBoy())
                {
                    _x3LookAt.headRotateTime = _basicRotateTime / _timeScale;
                }
                else if (actor.type == ActorType.Monster)
                {
                    lookAtBehaviour.headRotateTime = _basicRotateTime / _timeScale;
                }
            }
        }

        public void ResetLookAtStrategy()
        {
            if (!actor.IsBoy())
            {
                return;
            }
            UseLookAtStrategy(_isLookAt, _basicRotateTime);
        }
		
	    public void UpdateWeight()
        {
            if (!enable)
                return;
            if (actor.IsBoy() || actor.type == ActorType.Monster)
            {
                var state = actor.animator.GetCurrentAnimatorStateInfo(0);
                var weight = isLookat ? state.weight : (1 - state.weight);
                if (actor.IsBoy())
                    _x3LookAt.Weight = weight;
                else if (actor.type == ActorType.Monster)
                    lookAtBehaviour.Weight = weight;
            }           
        }

        private void _OnActorStateChange(EventActorStateChange evt)
        {
            if (evt.toStateName == ActorMainStateType.Dead) return;
            UseLookAtStrategy(_isLookAt, _basicRotateTime);
        }

        private void _LookAtTarget(Actor actor, float rotateTime, Transform lookAtPoint, Vector3 offset)
        {
            if (!enable)
                return;
            _basicRotateTime = rotateTime;

#if UNITY_EDITOR
            lookAtTarget = lookAtPoint;
#endif
            if (actor.IsBoy())
            {
                if(_timeScale > 0)
                    _x3LookAt.headRotateTime = _basicRotateTime / _timeScale;
                _x3LookAt.LookAtTarget(lookAtPoint, true, offset);
            }
            else if (actor.type == ActorType.Monster)
            {
                if (_timeScale > 0)
                    lookAtBehaviour.headRotateTime = _basicRotateTime / _timeScale;
                lookAtBehaviour.LookAtTarget(lookAtPoint, offset);
            }
        }

        private void _OnScalerChange(EventScalerChange arg)
        {
            if (!(arg.timeScalerOwner is Actor actor) || actor != this.actor)
                return;

            _timeScale = arg.timeScale;
            if (_timeScale <= 0)
                return;

            if (actor.IsBoy())
            {
                _x3LookAt.headRotateTime = _basicRotateTime / _timeScale;
            }
            else if(actor.type == ActorType.Monster)
            {
                lookAtBehaviour.headRotateTime = _basicRotateTime / _timeScale;
            }
        }
    }
}
