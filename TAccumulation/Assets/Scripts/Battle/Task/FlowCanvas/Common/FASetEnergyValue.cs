using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("设置能量值\nSetEnergyValue")]
    public class FASetEnergyValue : FlowAction
    {
        public BBParameter<EnergyType> EnergyType = new BBParameter<EnergyType>(X3Battle.EnergyType.Male);
        public BBParameter<float> EnergyValue = new BBParameter<float>();

        private ValueInput<Actor> _viActor;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viActor = AddValueInput<Actor>(nameof(Actor));
        }

        protected override void _Invoke()
        {
            var target = _viActor?.GetValue();
            if (target == null)
            {
                _LogError($"节点【设置能量值 SetEnergyValue】引脚参数错误, 引脚【Actor】没有正确配置.");
                return;
            }

            if (target.attributeOwner == null)
            {
                _LogError($"节点【设置能量值 SetEnergyValue】引脚参数错误, 引脚【Actor】没有AttributeOwner组件.");
                return;
            }

            var energyType = EnergyType.GetValue();
            var energyValue = EnergyValue.GetValue();
            var attrType = AttrUtil.ConvertEnergyToAttr(energyType);
            target.attributeOwner.SetAttrValue(attrType, energyValue);
        }
    }
}
