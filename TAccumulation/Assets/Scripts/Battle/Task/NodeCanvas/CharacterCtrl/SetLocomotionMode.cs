using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    //运动策略
    public enum LocomotionMode
    {
        Null = 0,
        ConstTurnSpeed = 1,//移动.徘徊.原地转身 匀速旋转 
        MoveDeltaTurnSpeedAndRM = 2,//移动 角度差值移速和RM
        SpotTurnRealTimeRM = 3,//原地转身 - 实时RM
        SpotTurnLogicSpeed = 4,
    }

    [Category("Locomotion")]
    [Description("【设置运动策略】\n" +
        "1:移动 - 匀速旋转\n" +
        "2:移动 - 角度斜率转速和RM\n" +
        "3:原地转身 - 实时RM\n" +
        "4:原地转身 - Clip程序速度")]
    public class SetLocomotionMode : CharacterAction
    {
        public LocomotionMode locomotionMode = LocomotionMode.ConstTurnSpeed;

        [TagField, ShowIf("locomotionMode", (int)LocomotionMode.ConstTurnSpeed)]
        public BBParameter<float> turnSpeed = 300;

        [TagField, ShowIf("locomotionMode", (int)LocomotionMode.MoveDeltaTurnSpeedAndRM)]
        public BBParameter<float> turnMinSpeed = 300;
        [TagField, ShowIf("locomotionMode", (int)LocomotionMode.MoveDeltaTurnSpeedAndRM)]
        public BBParameter<float> turnMaxSpeed = 600;
        [TagField, ShowIf("locomotionMode", (int)LocomotionMode.MoveDeltaTurnSpeedAndRM)]
        public BBParameter<float> turnMinSpeedAngle = 60;
        [TagField, ShowIf("locomotionMode", (int)LocomotionMode.MoveDeltaTurnSpeedAndRM)]
        public BBParameter<float> turnMaxSpeedAngle = 180;
        //TODO设置RM

        //[TagField, ShowIf("locomotionMode", (int)LocomotionMode.SpotTurn)]
        //public BBParameter<int> spotTurnAnim = (int)SpotTurnAnim.TwoAnim;//选择播放几个动作
        //[TagField, ShowIf("locomotionMode", (int)LocomotionMode.SpotTurn)]
        //public BBParameter<int> spotTurnMode = (int)SpotTurnMode.CtrlTurn;//选择旋转策略
        
        //[TagField, ShowIf("locomotionMode", (int)LocomotionMode.SpotTurn)]
        //public BBParameter<int> spotTurnAnim = (int)SetSpotTurnState.SpotTurnAnim.TwoAnim;
        //public BBParameter<int> spotTurnMode = (int)SetSpotTurnState.SpotTurnMode.CtrlTurn;


        protected override void OnExecute()
        {
            var ctrl = _context.locomotionCtrl;
            if (ctrl == null)
                return;

            ctrl.SetLocomotionMode(locomotionMode);

            if (locomotionMode == LocomotionMode.ConstTurnSpeed)
            {
                ctrl.SetTurnSpeed(turnSpeed.value, null, null, null, null);
            }
            else if (locomotionMode == LocomotionMode.MoveDeltaTurnSpeedAndRM)
            {
                ctrl.SetTurnSpeed(0, turnMinSpeed.value, turnMaxSpeed.value, turnMinSpeedAngle.value, turnMaxSpeedAngle.value);
            }
            //else if (locomotionMode == LocomotionMode.MoveDeltaTurnSpeed)
            //{
            //    ctrl.SetTurnSpeed(0, turnMinSpeed2.value, turnMaxSpeed2.value, null, null);
            //}
            //else if (locomotionMode == LocomotionMode.SpotTurn)
            //{
            //    ctrl.SetPause(true);
            //    ctrl.SetEnterRMTurn(spotTurnAnim.value);
            //}
            //else if (locomotionMode == LocomotionMode.DeltaRealTimeRM)
            //{
            //    ctrl.SetPause(true);
            //    //ctrl.SetRealTimeRMTurn(spotTurnAnim2.value);
            //}
            EndAction(true);
        }
    }
}
