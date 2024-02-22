using System;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Listener")]
    [Name("射击操作监听器\nOnFpsOperate")]
    public class OnFpsOperate : FlowListener
    {
        public BBParameter<FpsOperateType> fpsOperateType = new BBParameter<FpsOperateType>();
        public BBParameter<ECompareOperator> compareOperator = new BBParameter<ECompareOperator>();
        public BBParameter<int> ammunitionTimes = new BBParameter<int>();
        private Action<EventFpsOperateChange> _actionFpsOperateChange;

        public OnFpsOperate()
        {
            _actionFpsOperateChange = _OnFpsOperateChange;
        }
        
        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener(EventType.OnFpsOperateChange, _actionFpsOperateChange, "OnFpsOperate._OnFpsOperateChange");
        }

        protected override void _UnRegisterEvent()
        {
            Battle.Instance.eventMgr.RemoveListener(EventType.OnFpsOperateChange, _actionFpsOperateChange);
        }

        private void _OnFpsOperateChange(EventFpsOperateChange fpsOperateChange)
        {
            if (fpsOperateType.GetValue() != fpsOperateChange.fpsOperateType || !BattleUtil.IsCompareSize(ammunitionTimes.GetValue(), fpsOperateChange.times, compareOperator.GetValue()))
            {
                return;
            }
            _Trigger();
        }
    }
}