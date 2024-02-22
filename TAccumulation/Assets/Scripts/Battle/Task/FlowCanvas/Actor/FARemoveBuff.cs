using System.Collections.Generic;
using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("移除Buff\nRemoveBuff")]
    public class FARemoveBuff : FlowAction
    {
        // public List<BuffRemoveParam> BuffRemoveParams = new List<BuffRemoveParam>();
        public List<NewBuffRemoveParam> newBuffRemoveParams = new List<NewBuffRemoveParam>();

        private ValueInput<Actor> _viTarget;
        
        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viTarget = AddValueInput<Actor>("SourceActor"); 
        }
        
        protected override void _Invoke()
        {
            var target = _viTarget.GetValue();
            if (target == null)
                return;
            target.buffOwner?.RemoveBuffs(newBuffRemoveParams);
        }
    }
}
