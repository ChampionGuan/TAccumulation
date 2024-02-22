using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("Locomotion")]
    [Description("处理角色Run状态的RootMotion比例")]
    public class UpdateRoleRun : CharacterAction
    {
        public bool isCheckTurnBack = true;
        [TagField, ShowIf("isCheckTurnBack", 1)]
        public BBParameter<string> turnBackEvent = "";
        [TagField, ShowIf("isCheckTurnBack", 1)]
        public BBParameter<int> minTurnBackAngle = new BBParameter<int>();
        [TagField, ShowIf("isCheckTurnBack", 1)]
        public BBParameter<float> minTurnBackRmMultiplier = 0.9f;
        [TagField, ShowIf("isCheckTurnBack", 1)]
        public BBParameter<string> turnBackParam = new BBParameter<string>();

        public bool isUpdateRmMultiplier = true;

        protected override string info
        {
            get { return (isCheckTurnBack ? "折返:检测\n" : "") + (isUpdateRmMultiplier ? "Rm比例:更新" : ""); }
        }

        protected override void OnExecute()
        {
            base.OnExecute();
            if (isUpdateRmMultiplier)
            {
                _context.locomotionCtrl.isUpdateRmMultiplier = true;
                _context.locomotionCtrl.moveCtrlSpeedMultiplier = 1;
            }
        }

        protected override void OnUpdate()
        {
            base.OnUpdate();
            _context.locomotionCtrl.GetMoveDeltaAngleY(out var includeAngleY, out var sign);
            _context.locomotionCtrl.context.SetFloat(AnimParams.MoveDirection, includeAngleY * sign);
            if (isCheckTurnBack && includeAngleY >= minTurnBackAngle.value &&
                _context.locomotionCtrl.moveCtrlSpeedMultiplier >= minTurnBackRmMultiplier.value)
            {
                _actor.animator.SetBool(turnBackParam.value, true);
                _context.locomotionCtrl.TriggerFSMEvent(turnBackEvent.value);
            }
            else if (isUpdateRmMultiplier)
            {
                _context.locomotionCtrl.UpdateDeltaRM();
            }
        }
        protected override void OnStop()
        {
            base.OnStop();
            if (isUpdateRmMultiplier)
            {
                _context.locomotionCtrl.isUpdateRmMultiplier = false;
                _context.locomotionCtrl.moveCtrlSpeedMultiplier = 1;
            }
        }
    }
}
