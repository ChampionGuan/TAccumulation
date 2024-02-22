using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("Locomotion")]
    [Description("设置旋转速度,支持为null时会不设置")]
    public class SetCharacterCtrlTurnSpeed : CharacterAction
    {
        [RequiredField]
        //public BBParameter<float> turnInitSpeed = 0;
        public BBParameter<float> turnMinSpeed = 600;
        public BBParameter<float> turnMaxSpeed = 1350;
        public BBParameter<float> turnMinSpeedAngle = 0;
        public BBParameter<float> turnMaxSpeedAngle = 0;
        //public BBParameter<float> turnAccelSpeed = 0;

        protected override string info
        {
            get { return "旋转速度:设置"; }
        }
        protected override void OnExecute()
        {
            _context.locomotionCtrl.SetTurnSpeed(
                0,
                turnMinSpeed.value,
                turnMaxSpeed.value,
                turnMinSpeedAngle.value,
                turnMaxSpeedAngle.value,
                0);
            EndAction();
        }
    }
}
