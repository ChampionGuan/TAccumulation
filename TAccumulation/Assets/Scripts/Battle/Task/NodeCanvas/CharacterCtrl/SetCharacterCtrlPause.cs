using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("Locomotion")]
    [Description("是否暂停程序的旋转和移动")]
    public class SetCharacterCtrlPause : CharacterAction
    {
        [RequiredField]
        public bool value;

        protected override string info
        {
            get { return "程序旋转:" + (value ? "暂停" : "开启"); }
        }

        protected override void OnExecute()
        {
            _context.locomotionCtrl.SetPause(value);
            EndAction(true);
        }
    }
}
