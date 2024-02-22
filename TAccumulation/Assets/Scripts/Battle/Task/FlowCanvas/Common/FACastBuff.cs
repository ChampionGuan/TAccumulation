using System.Collections.Generic;
using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("添加Buff\nCastBuff")]
    public class FACastBuff : FlowAction
    {
        // public List<BuffAddParam> BuffAddParams = new List<BuffAddParam>();
        public List<NewBuffAddParam> NewBuffAddParam = new List<NewBuffAddParam>();
        
        private ValueInput<Actor> _viTarget;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viTarget = AddValueInput<Actor>("Target");
        }

        protected override void _Invoke()
        {
            var target = _viTarget.GetValue();
            int level = _level;
            target?.buffOwner?.CreateBuffs(level, NewBuffAddParam, _actor);
        }
    }
}
