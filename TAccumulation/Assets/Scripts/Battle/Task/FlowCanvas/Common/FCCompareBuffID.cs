using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name("判断BuffID\nCompareBuffID")]
    public class FCCompareBuffID : FlowCondition
    {
        public BBParameter<int> buffID = new BBParameter<int>();
        private ValueInput<IBuff> _viSourceBuff;

        protected override void _OnAddPorts()
        {
            _viSourceBuff = AddValueInput<IBuff>("SourceBuff");
        }

        protected override bool _IsMeetCondition()
        {
            var sourceBuff = _viSourceBuff.GetValue();
            if (sourceBuff == null)
                return false;
            var id = buffID.GetValue();
            if (sourceBuff.ID != id)
                return false;
            return true;
        }
        
    }
}
