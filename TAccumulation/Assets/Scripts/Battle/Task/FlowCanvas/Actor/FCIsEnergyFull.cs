using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Condition")]
    [Name("判断Actor能量是否充满\nIsEnergyFull")]
    public class FCIsEnergyFull : FlowCondition
    {
        public BBParameter<EnergyType> energyType = new BBParameter<EnergyType>(EnergyType.Ultra);
        
        private ValueInput<Actor> _viSourceActor;

        protected override void _OnAddPorts()
        {
            _viSourceActor = this.AddValueInput<Actor>("SourceActor");
        }

        protected override bool _IsMeetCondition()
        {
            var type = energyType.GetValue();
            var sourceActor = _viSourceActor.GetValue();
            if (sourceActor == null)
            {
                _LogError($"请联系策划【卡宝】, 蓝图{this._graphOwner.name}中节点【判断Actor能量是否充满 IsEnergyFull】参数配置错误, SourceActor==null, 条件永远返回false");
                return false;
            }

            if (sourceActor.energyOwner == null)
            {
                _LogError($"请联系策划【卡宝】, 蓝图{this._graphOwner.name}中节点【判断Actor能量是否充满 IsEnergyFull】参数配置错误, SourceActor没有能量组件EnergyOwner, 条件永远返回false");
                return false;
            }

            return AttrUtil.IsEnergyFull(sourceActor, type);
        }
    }
}
