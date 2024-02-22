using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace EasyCharacterMovement
{
    /// <summary>
    /// Character's current movement mode (walking, falling, etc):
    ///    - walking:  Walking on a surface, under the effects of friction, and able to "step up" barriers. Vertical velocity is zero.
    ///    - falling:  Falling under the effects of gravity, after jumping or walking off the edge of a surface.
    ///    - flying:   Flying, ignoring the effects of gravity.
    ///
    /// </summary>
    [Serializable]
    public class MovementModeCtrl
    {
        private MovementModeBase _curMode;
        // 事先创建的可用的移动模式，做到切换时无GC
        private Dictionary<MovementMode, MovementModeBase> _allMode;
        private CharacterMovement _character;
        public MovementModeBase curMode => _curMode;
        public event SwitchModeEvent OnEnterMode;
        public event SwitchModeEvent OnExitMode;

        public MovementModeCtrl(CharacterMovement character)
        {
            _character = character;
            _allMode = new Dictionary<MovementMode, MovementModeBase>();
            _allMode[MovementMode.walking] = new MMWalking(this, character);
            _allMode[MovementMode.Falling] = new MMFalling(this, character);
            _allMode[MovementMode.Flying] = new MMFlying(this, character);
            
            _curMode = _allMode[MovementMode.walking];
        }
        
        /// <summary>
        /// 移动模式的切换，必然能切换成功
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public void SwitchMode(MovementMode model)
        {
            if (model == _curMode.model)
                return;// 相同模式，不重复切换
            if (! _allMode.TryGetValue(model, out var targetMode))
                return;
            
            // Exit
            _curMode.Exit();
            OnExitMode?.Invoke(_curMode);
            
            // Enter
            _curMode = targetMode;
            _curMode.Enter();
            OnEnterMode?.Invoke(targetMode);
        }
        
        /// 注意：
        /// 1.只有进入新的模式时，才会退出旧模式，不主动退出模式
        /// 2.自动模式切换时，可能切换不成功，通过CanEnter,  CanExit判定。手动切换必然成功
        /// 3.模式之间理论上要求互斥
        public void Update(float deltaTime)
        {
            // 检测哪个状态可以进入, 只有进入新的模式时，才会退出旧模式，不主动退出模式
            foreach (var mode in _allMode)
            {
                var targetMode = mode.Value;
                // 相同模式，不重复切换
                if (targetMode.model == curMode.model)
                    continue;
                if (!targetMode.CanEnter(curMode))
                    continue;
                // 先退出
                if (!curMode.CanExit())
                    continue;
                SwitchMode(targetMode.model);
                break;
            }
        }

        public Vector3 Move(float deltaTime, Vector3 curVelocity)
        {
            return _curMode.Move(deltaTime, curVelocity);
        }
    }
}