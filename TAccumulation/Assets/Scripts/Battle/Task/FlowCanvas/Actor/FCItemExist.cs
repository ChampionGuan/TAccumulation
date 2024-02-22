using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name(("判断道具\nItemExist"))]
    public class FCItemExist: FlowCondition
    {
        private ValueInput<Actor> _viItem;
        public BBParameter<int> itemId = new BBParameter<int>();
        protected override void _OnAddPorts()
        {
            base._OnAddPorts();
            _viItem = AddValueInput<Actor>("item");
        }

        protected override bool _IsMeetCondition()
        {
            if (itemId.isNoneOrNull)
            {
                return false;
            }
            int itemIdValue = itemId.value;
            if (itemIdValue <= 0)
            {
                return false;
            }

            Actor item = _viItem.value;
            if (item == null)
            {
                return false;
            }
            
            return item.cfgID == itemIdValue;
        }
    }
}
