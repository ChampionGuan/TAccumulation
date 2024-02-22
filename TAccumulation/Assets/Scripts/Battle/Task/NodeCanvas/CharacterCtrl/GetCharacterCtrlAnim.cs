using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("Locomotion")]
    [Description("获取当前动画State")]
    public class GetCharacterCtrlAnim : CharacterAction
    {
        [RequiredField]
        public BBParameter<string> animStateName = new BBParameter<string>();
        protected override void OnExecute()
        {
            animStateName.SetValue(_context.locomotionCtrl.GetCurrentAnimStateName());
            EndAction();
        }
    }
}
