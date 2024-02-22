using NodeCanvas.Framework;
using ParadoxNotion.Design;
using PapeGames.X3;
using X3.PlayableAnimator;

namespace X3Battle
{
    [Category("Locomotion")]
    [Description("设置Animator参数")]
    public class SetCharacterCtrlAnimFloat : CharacterAction
    {
        [RequiredField]
        public BBParameter<string> animName = new BBParameter<string>();
        public AnimatorControllerParameterType parameterType = AnimatorControllerParameterType.Float;

        [TagField, ShowIf("parameterType", (int)AnimatorControllerParameterType.Float)]
        public BBParameter<float> value = new BBParameter<float>();
        [TagField, ShowIf("parameterType", (int)AnimatorControllerParameterType.Int)]
        public BBParameter<int> intValue = new BBParameter<int>();
        [TagField, ShowIf("parameterType", (int)AnimatorControllerParameterType.Bool)]
        public BBParameter<bool> boolValue = new BBParameter<bool>();
        [TagField, ShowIf("parameterType", (int)AnimatorControllerParameterType.Trigger)]
        public BBParameter<bool> triggerValue = new BBParameter<bool>();

        //Float = 1,
        //Int = 3,
        //Bool = 4,
        //Trigger = 9

        protected override string info
        {
            get {
                string str;
                if (parameterType == AnimatorControllerParameterType.Float)
                    str = value.value.ToString();
                else if (parameterType == AnimatorControllerParameterType.Int)
                    str = intValue.value.ToString();
                else if (parameterType == AnimatorControllerParameterType.Bool)
                    str = boolValue.value.ToString();
                else if (parameterType == AnimatorControllerParameterType.Trigger)
                    str = triggerValue.value.ToString();
                else
                    str = "不支持的类型";
                return $"设置Anim参数:{animName} = {str}"; 
            }
        }

        protected override void OnExecute()
        {
            if (_context == null || _context.locomotionCtrl == null || _context.locomotionCtrl.context == null)
                return; 
            if (parameterType == AnimatorControllerParameterType.Float)
                _context.locomotionCtrl.context.SetFloat(animName.value, value.value);
            else if (parameterType == AnimatorControllerParameterType.Int)
                _context.locomotionCtrl.context.SetInteger(animName.value, intValue.value);
            else if (parameterType == AnimatorControllerParameterType.Bool)
                _context.locomotionCtrl.context.SetBool(animName.value, boolValue.value);
            else if (parameterType == AnimatorControllerParameterType.Trigger)
                _context.locomotionCtrl.context.SetBool(animName.value, triggerValue.value);
            else
                LogProxy.LogError("不支持的类型");
            EndAction(true);
        }
    }
}
