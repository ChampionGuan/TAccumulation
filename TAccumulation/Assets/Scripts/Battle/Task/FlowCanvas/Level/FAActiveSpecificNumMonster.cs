using System;
using FlowCanvas;
using NodeCanvas.Framework;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("特殊激活NPC_A型（同组内指定数量激活）\nActiveSpecificNumMonster")]
    public class FAActiveSpecificNumMonster : FlowAction
    {
        public BBParameter<int> groupId = new BBParameter<int>();
        public BBParameter<int> activeCount = new BBParameter<int>();
        [Name("IntervalTime(秒)")]
        public BBParameter<float> intervalTime = new BBParameter<float>();
        public BBParameter<CreateGroupMonsterMode> mode = new BBParameter<CreateGroupMonsterMode>();
        public BBParameter<bool> ignoreDead = new BBParameter<bool>();
        
        private Action _actionPerCreate;
        private Action _actionAllCreate;
        private FlowOutput _triggerFlowOutput;
        private FlowOutput _allTriggerFlowOutput;

        public FAActiveSpecificNumMonster()
        {
            _actionPerCreate = _PerCreate;
            _actionAllCreate = _AllCreate;
        }
        
        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _triggerFlowOutput = AddFlowOutput("Trigger");
            _allTriggerFlowOutput = AddFlowOutput("AllTrigger");
        }
        
        protected override void _Invoke()
        {
            if (groupId.value <= 0)
            {
                LogProxy.LogError("【关卡】节点FAActiveSpecificNumMonster配置错误， groupId <= 0");
            }

            Battle.Instance.actorMgr.CreateGroupMonstersAtIntervals(groupId.value, intervalTime.value, mode.value, activeCount.value, ignoreDead.value, _actionPerCreate, _actionAllCreate);
        }
        
        private void _PerCreate()
        {
            _triggerFlowOutput.Call(Flow.New);
        }

        private void _AllCreate()
        {
            _allTriggerFlowOutput.Call(Flow.New);
        }
    }
}
