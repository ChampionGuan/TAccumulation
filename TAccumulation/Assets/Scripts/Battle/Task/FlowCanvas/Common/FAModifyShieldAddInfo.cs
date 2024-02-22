using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("添加护盾量修饰\nFAModifyShieldAddInfo")]
    public class FAModifyShieldAddInfo : FlowAction
    {
        [Name("修改值")]
        public BBParameter<float> addValue = new BBParameter<float>();
        private ValueInput<ShieldAddInfo> _shieldAddInfoInput;
        
        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _shieldAddInfoInput = AddValueInput<ShieldAddInfo>("护盾Info");
        }

        protected override void _Invoke()
        {
            var addInfo = _shieldAddInfoInput.GetValue();
            if (addInfo != null)
            {
                addInfo.addEfficiency += addValue.value;
            }
        }
    }
}