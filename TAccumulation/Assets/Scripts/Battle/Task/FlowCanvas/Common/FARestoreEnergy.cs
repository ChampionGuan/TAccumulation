using System.Collections.Generic;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("能量回复\nRestoreEnergy")]
    public class FARestoreEnergy : FlowAction
    {
        public enum RestoreType
        {
            RealValue = 1,
            Percent = 2
        }
        
        public BBParameter<EnergyType> energyType = new BBParameter<EnergyType>(EnergyType.Skill);
        
        private ValueInput<List<float>> _viMathParam;
        private ValueInput<Actor> _viTarget;
        public RestoreType restoreType = RestoreType.RealValue;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viMathParam = AddValueInput<List<float>>("MathParam");
            _viTarget = AddValueInput<Actor>("Target");
        }

        protected override void _Invoke()
        {
            var target = _viTarget.GetValue();
            if (target == null)
            {
                _LogError("请联系策划【蜗牛君】,【能量回复 RestoreEnergy】Target的引脚没有配置, 目前为null");
                return;
            }

            if (target.energyOwner == null)
            {
                _LogError($"请联系策划【蜗牛君】,【能量回复 RestoreEnergy】Target的引脚没有正确配置, {target.name}没有EnergyOwner组件.");
                return;
            }
            
            var mathParam = _viMathParam.GetValue();
            if (mathParam == null)
            {
                _LogError("请联系策划【蜗牛君】,【能量回复 RestoreEnergy】mathParam的参数没有配置为null");
                return;
            }
            
            // DONE: 策划要该数组长度必须为1
            if (mathParam.Count != 1)
            {
                _LogError($"请联系策划【蜗牛君】,【能量回复 RestoreEnergy】mathParam的参数长度不为1, 目前长度为:{mathParam.Count}");
                return;
            }

            var value = mathParam[0];
            if (restoreType == RestoreType.Percent)
            {
                var energyAttr = target.attributeOwner.GetAttr(AttrUtil.ConvertEnergyToAttr(energyType.GetValue())) as InstantAttr;
                if (energyAttr == null)
                {
                    _LogError($"【能量回复 RestoreEnergy】能量类型是常规属性{energyType.GetValue()}，没有最大值！");
                }
                value = value * energyAttr.GetMaxValue();
            }
            if (value > 0)
            {
                target.energyOwner.GatherEnergy(energyType.GetValue(), value);
            }
            else if (value < 0)
            {
                target.energyOwner.ConsumeEnergy(energyType.GetValue(), -value);
            }
        }
    }
}
