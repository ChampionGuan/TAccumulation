using System;
using System.Collections;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using X3Battle;

namespace EasyCharacterMovement
{
    [Serializable]
    public abstract class MovementModeBase
    {
        public MovementModeBase(MovementModeCtrl modeCtrl, CharacterMovement character)
        {
            _modeCtrl = modeCtrl;
            _character = character;
            _gravity = Physics.gravity;
        }
        
        protected Vector3 _gravity;
        protected float _maxSpeed;
        protected MovementModeCtrl _modeCtrl;
        protected CharacterMovement _character;

        public Vector3 gravity => _gravity;
        public float maxSpeed => _maxSpeed;

        public abstract MovementMode model { get; }

        // 是否可以上下移动
        public virtual bool canUpDown => false;
        // 设置位置时是否需要平滑
        public virtual bool needSmooth => false;
        
        public Vector3 Move(float deltaTime, Vector3 curVelocity)
        {
            return OnMove(deltaTime, curVelocity);
        }

        public void Enter()
        {
            LogProxy.LogFormat("移动模式Enter->{0}:{1}", model, _character.name);
            OnEnter();
        }

        public void Exit()
        {
            LogProxy.LogFormat("移动模式Exit->{0}:{1}", model, _character.name);
            OnExit();
        }

        /// <summary>
        /// 是否可以进入该模式， 默认不可以进入
        /// </summary>
        /// <param name="curMode">当前正在处于的模式</param>
        /// <returns></returns>
        public abstract bool CanEnter(MovementModeBase curMode);
        public abstract bool CanExit();
        
        protected virtual void OnEnter()
        {
            
        }
        protected virtual Vector3 OnMove(float deltaTime, Vector3 curVelocity)
        {
            return curVelocity;
        }
        protected virtual void OnExit()
        {
            
        }
    }
    
    /// <summary>
    /// 当有可行走地面时的，正常的地面移动模式
    /// RootMotion 控制移动，遥感控制旋转
    /// </summary>
    [Serializable]
    public class MMWalking : MovementModeBase
    {
        public override bool needSmooth => true;
        public override MovementMode model =>MovementMode.walking;
        
        public MMWalking(MovementModeCtrl modeCtrl, CharacterMovement character) : base(modeCtrl, character)
        {
        }
        public override bool CanEnter(MovementModeBase curMode)
        {
            if (_character.isOnGround)
                return true;
            return false;
        }
        
        public override bool CanExit()
        {
            if (!_character.isOnGround)
                return true;
            return false;
        }
    }
    
    /// <summary>
    /// 飞行模式，该模式步高为0，业务逻辑需要
    /// 1.该模式，允许业务逻辑控制y轴的值
    /// 2.退出时，保证必然在地面上，然后会触发OnFoundGround
    /// </summary>
    [Serializable]
    public class MMFlying : MovementModeBase
    {
        private float stepOffset;
        private float _enterTime;
        public override bool canUpDown => true;
        public override MovementMode model =>MovementMode.Flying;
        
        public MMFlying(MovementModeCtrl modeCtrl, CharacterMovement character) : base(modeCtrl, character)
        {
        }

        public override bool CanEnter(MovementModeBase curMode)
        {
            // 不可自动切换到该模式
            return false;
        }

        public override bool CanExit()
        {
            // 还原旧设计 0.1s 后可以退出
            if (Battle.Instance.time - _enterTime < 0.1f)
                return false;
            
            // 必须站到了地面上才可以退出
            if (_character.isOnGround)
                return true;
            return false;
        }

        protected override void OnEnter()
        {
            stepOffset = _character.stepOffset;
            _character.stepOffset = 0;
            _enterTime = Battle.Instance.time;
        }

        protected override void OnExit()
        {
            _character.stepOffset = stepOffset;
        }
    }

    /// <summary>
    /// 掉落模式，当没有检测到地面时，可以进入该模式
    /// 1.该模式角色移动时，原速度在重力方向(竖直向下)上，会叠加重力的影响。水平速度不受影响
    /// 2.退出时，保证必然在地面上，然后会触发OnFoundGround
    /// </summary>
    [Serializable]
    public class MMFalling : MovementModeBase
    {
        public override MovementMode model =>MovementMode.Falling;
        public MMFalling(MovementModeCtrl modeCtrl, CharacterMovement character) : base(modeCtrl, character)
        {
        }

        public float gravityScale;
        
        protected override void OnEnter()
        {
            _maxSpeed = 100;
            gravityScale = 10;
        }

        public override bool CanEnter(MovementModeBase curMode)
        {
            // 不在地面上就切换到falling
            if (!_character.isOnGround)
                return true;
            return false;
        }

        public override bool CanExit()
        {
            // 必须处于地面上才可以退出Falling
            if (_character.isOnGround)
                return true;
            return false;
        }
        
        protected override void OnExit()
        {

        }

        protected override Vector3 OnMove(float deltaTime, Vector3 curVelocity)
        {
            Vector3 gravityDir = gravity.normalized;
            // 纵向速度
            Vector3 verticalVelocity = Vector3.Project(curVelocity, gravityDir);
            // 横向速度
            Vector3 lateralVelocity = curVelocity - verticalVelocity;
            // 纵向速度叠加重力，合成新的速度
            var modifyVelocity = verticalVelocity + gravity * gravityScale * deltaTime + lateralVelocity;
            // 如果超过最大速度，横向速度不变，纵向速度就限制到最大速度
            if (modifyVelocity.sqrMagnitude > maxSpeed.square())
            {
                if (Vector3.Dot(modifyVelocity, gravityDir) > maxSpeed)
                    modifyVelocity = modifyVelocity.projectedOnPlane(gravityDir) + gravityDir * maxSpeed;
            }
            return modifyVelocity;
        }
    }
    
}