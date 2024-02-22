using NodeCanvas.Framework;
using PapeGames.X3;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    public enum SpotTurnAnim
    {
        TwoAnim = 2,
        FourAnim = 4,
    }
    public enum SpotTurnMode
    {
        None = -1,
        ConstTurn = 0,
        EnterRM = 1,
        //RealTimeRM = 2,
        RealTimeSpeed = 3,
        RealTimeDirSpeed = 4,
    }

    [Category("Locomotion")]
    [Description("【原地旋转】\n" +
        "动画方式 -- 1:FourAnim 2:TwoAnim,  \n" +
        "运动方式 -- 0:匀速 1.进入RM 2.---  3.程序自适应速度 4.程序自适应速度,不反向")]
    public class SetSpotTurnState : CharacterAction
    {
        public BBParameter<int> spotTurnAnim = (int)SpotTurnAnim.TwoAnim;

        private LocomotionCtrl _locomotionCtrl;

        protected override void OnExecute()
        {
            if ((_locomotionCtrl = _context.locomotionCtrl) == null)
                return;

            //转身默认不可打断
            _locomotionCtrl.SetMoveInterrupt(CtrlInterruptType.Locomotion, CanInterruptType.Cannot);
            _locomotionCtrl.SetSkillInterrupt(CtrlInterruptType.Locomotion, CanInterruptType.Cannot);

            _locomotionCtrl.GetMoveDeltaAngleY(out float angleY, out int sign);
            if (spotTurnAnim.value == (int)SpotTurnAnim.FourAnim)
            {
                PlayFourTurnAnim(angleY, sign);
            }
            else//就算策划填错也播双动画 if (spotTurnAnim.value == (int)SpotTurnAnim.TwoAnim)
            {
                PlayTwoTurnAnim(sign);
            }

            //匀速
            if (_locomotionCtrl.spotTurnMode == SpotTurnMode.ConstTurn)
            {
                _locomotionCtrl.SetPause(false);
                _locomotionCtrl.context.SetRootMotionMultiplier(null, 0);
                _locomotionCtrl.turnCurSpeed = _locomotionCtrl.spotTurnMaxSpeed;
                _locomotionCtrl.SetLocomotionMode(LocomotionMode.ConstTurnSpeed);
            }
            //程序旋转实时速度 速度由Clip设置
            else if (_locomotionCtrl.spotTurnMode == SpotTurnMode.RealTimeSpeed)
            {
                _locomotionCtrl.SetPause(false);
                _locomotionCtrl.context.SetRootMotionMultiplier(null, 0);
                _locomotionCtrl.isSpotTurnHasSign = false;
                _locomotionCtrl.SetLocomotionMode(LocomotionMode.SpotTurnLogicSpeed);
            }
            //程序旋转实时速度 速度由Clip设置 具有方向
            else if (_locomotionCtrl.spotTurnMode == SpotTurnMode.RealTimeDirSpeed)
            {
                _locomotionCtrl.SetPause(false);
                _locomotionCtrl.context.SetRootMotionMultiplier(null, 0);
                _locomotionCtrl.spotTurnEnterSelfDir = _locomotionCtrl.context.forward;
                _locomotionCtrl.isSpotTurnHasSign = true;
                _locomotionCtrl.setSpotTurnSign = sign;
                _locomotionCtrl.SetLocomotionMode(LocomotionMode.SpotTurnLogicSpeed);
            }
            //RM 根据角度设置一个RM比例
            else if (_locomotionCtrl.spotTurnMode == SpotTurnMode.EnterRM)
            {
                _locomotionCtrl.SetPause(true);
                _locomotionCtrl.SetEnterRMTurn(spotTurnAnim.value);
            }
            else
            {
                LogProxy.LogErrorFormat("原地旋转使用了非规定模式:{0}", (int)_locomotionCtrl.spotTurnMode);
            }

        }

        void PlayTwoTurnAnim(int sign)
        {
            if (sign > 0)
            {
                _actor.animator.PlayAnim(AnimStateName.TurnRight, false);
            }
            else
            {
                _actor.animator.PlayAnim(AnimStateName.TurnLeft, false);
            }
        }

        void PlayFourTurnAnim(float angleY, int sign)
        {
            string animName;
            if (sign > 0)
            {
                if (angleY < TbUtil.battleConsts.SpotTurnSelectAngle)
                {
                    animName = AnimStateName.TurnRight90;
                }
                else
                {
                    animName = AnimStateName.TurnRight180;
                }
            }
            else
            {
                if (angleY < TbUtil.battleConsts.SpotTurnSelectAngle)
                {
                    animName = AnimStateName.TurnLeft90;
                }
                else
                {
                    animName = AnimStateName.TurnLeft180;
                }
            }
            _actor.animator.PlayAnim(animName, false);
        }

        protected override void OnStop()
        {
            if (_locomotionCtrl == null)
                return;

            base.OnStop();
            _locomotionCtrl.context.SetRootMotionMultiplier(null, 1);
            _locomotionCtrl.isSpotTurnHasSign = false;
            _locomotionCtrl.SetMoveInterrupt(CtrlInterruptType.Locomotion, CanInterruptType.Can);
            _locomotionCtrl.SetSkillInterrupt(CtrlInterruptType.Locomotion, CanInterruptType.Can, (SkillTypeFlag)(-1));
        }
    }
}
