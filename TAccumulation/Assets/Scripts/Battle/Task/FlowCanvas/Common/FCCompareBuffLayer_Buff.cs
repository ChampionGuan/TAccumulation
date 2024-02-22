using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Condition")]
    [Name("比较Buff层数\nCompareBuffLayer(Buff)")]
    public class FCCompareBuffLayer_Buff : FlowCondition
    {
        public BBParameter<ECompareOperator> CompareOperator = new BBParameter<ECompareOperator>();
        public BBParameter<int> StackCount = new BBParameter<int>();

        private ValueInput<IBuff> _viBuff;

        protected override void _OnAddPorts()
        {
            _viBuff = AddValueInput<IBuff>("Buff");
        }

        protected override bool _IsMeetCondition()
        {
            var buff = _viBuff.GetValue();
            if (buff == null)
                return false;
            if (!BattleUtil.IsCompareSize(buff.layer, StackCount.GetValue(), CompareOperator.GetValue()))
                return false;
            return true;
        }
    }
}
