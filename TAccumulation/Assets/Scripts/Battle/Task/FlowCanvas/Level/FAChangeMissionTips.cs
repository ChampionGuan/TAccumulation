using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("修改战斗指引\nReviseBattleGuide")]
    public class FAChangeMissionTips : FlowAction
    {
        public BBParameter<int> id = new BBParameter<int>();
        public BBParameter<int> slot = new BBParameter<int>();
        public BBParameter<Arithmetic> operation = new BBParameter<Arithmetic>();
        private bool _isShowValue = true;
        [ShowIf(nameof(_isShowValue), 1)]
        public BBParameter<int> value = new BBParameter<int>(); 
        private ValueInput<int> _viModifyValue;
        
        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viModifyValue = AddValueInput<int>("modifyValue");
        }

        protected override void _Invoke()
        {
            int curValue = _viModifyValue.isConnected ? _viModifyValue.value : value.value;
            BattleUtil.SetMissionTipsVisible(ShowMissionTipsType.Change, id.value, slot.value,operation.value,curValue);
        }

#if UNITY_EDITOR
        protected override void OnNodeGUI()
        {
            base.OnNodeGUI();
            _isShowValue = !_viModifyValue.isConnected;
        }
#endif
    }
}
