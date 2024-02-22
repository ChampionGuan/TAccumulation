using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [HasRefreshButtonAttribute]
    [Category("X3Battle/通用/Action")]
    [Name("销毁道具\nDestroyItem")]
    public class FADestroyItem : FlowAction
    {
        private ValueInput<int> _itemId;
        
        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _itemId = AddValueInput<int>("itemId");
        }

        protected override void _Invoke()
        {
            int itemId = _itemId.value;
            if (itemId <= 0)
            {
                return;
            }
            _battle.DestroyItemByCfgID(itemId);
        }
    }
}
