using System;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("激活NPC生成器Group\nSpawner:ActiveNPCGroup")]
    public class FASpawnGroupMonster : FlowAction
    {
        public BBParameter<int> groupId = new BBParameter<int>();
        [Name("IntervalTime(秒)")]
        public BBParameter<float> intervalTime = new BBParameter<float>();
        public CreateGroupMonsterMode activeMode;
        
        private Action _actionPerCreate;
        private Action _actionAllCreate;
        private FlowOutput _triggerFlowOutput;
        private FlowOutput _allTriggerFlowOutput;

        public FASpawnGroupMonster()
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
            float interval;
            if (intervalTime == null || intervalTime.value <= 0)
                interval = 0;
            else
                interval = intervalTime.value;
            _battle.actorMgr.CreateGroupMonstersAtIntervals(groupId.value, interval, activeMode,  _battle.actorMgr.GetSpawnPointConfigCount(groupId.value),false,_actionPerCreate, _actionAllCreate);
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
