using NodeCanvas.Framework;
using ParadoxNotion.Design;
using System;

namespace X3Battle
{
    [Category("Locomotion")]
    [Description("获取移动使用的移动类型和移动动画")]
    public class GetCharacterCtrlMoveType : CharacterAction
    {
        [RequiredField]
        public BBParameter<string> moveType = new BBParameter<string>();
        public BBParameter<string> moveAnim = new BBParameter<string>();
        protected override void OnExecute()
        {
            if((int)_context.locomotionCtrl.moveType < (int)MoveType.Num)
            {
                moveType.SetValue(LocomotionName.MoveTypeName[(int)_context.locomotionCtrl.moveType]);
                moveAnim.SetValue(_context.locomotionCtrl.moveAnim);
            }
            EndAction(true);
        }
    }
}
