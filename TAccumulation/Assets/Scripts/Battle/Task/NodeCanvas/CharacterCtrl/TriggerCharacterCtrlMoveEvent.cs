using NodeCanvas.Framework;
using ParadoxNotion.Design;
using System;

namespace X3Battle
{
    [Category("Locomotion")]
    [Description("触发MoveType的Event")]
    public class TriggerCharacterCtrlMoveType : CharacterAction
    {
        [RequiredField]
        public BBParameter<string> moveType = new BBParameter<string>();
        protected override void OnExecute()
        {
            _fsm.TriggerEvent(moveType.value);
            EndAction(true);
        }
    }
}
