using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Condition")]
    [Name("比较Buff层数\nCompareBuffLayer(Actor)")]
    public class FCCompareBuffLayer_Actor : FlowCondition
    {
        public BBParameter<ECompareOperator> CompareOperator = new BBParameter<ECompareOperator>();
        public BBParameter<int> StackCount = new BBParameter<int>();

        private ValueInput<Actor> _viBuffOwner;
        private ValueInput<int> _viBuffID;

        protected override void _OnAddPorts()
        {
            _viBuffOwner = AddValueInput<Actor>("BuffOwner");
            _viBuffID = AddValueInput<int>("BuffID");
        }

        protected override bool _IsMeetCondition()
        {
            var actor = _viBuffOwner.GetValue();
            if (actor == null || actor.buffOwner == null)
                return false;
            var layer = actor.buffOwner.GetLayerByID(_viBuffID.value);

            if (layer == null || !BattleUtil.IsCompareSize(layer.Value, StackCount.GetValue(), CompareOperator.GetValue()))
                return false;
            return true;
        }
    }
}
