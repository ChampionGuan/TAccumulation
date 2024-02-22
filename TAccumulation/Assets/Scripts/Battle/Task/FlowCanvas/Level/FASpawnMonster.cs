using System;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("激活NPC生成器\nSpawner:ActiveNPC")]
    public class FASpawnMonster : FlowAction
    {
        [Name("SpawnID")]
        public BBParameter<int> pointId = new BBParameter<int>();

        private Action<int> _actionWaitComplete;
        private FlowOutput _triggerFlowOutput;

        public FASpawnMonster()
        {
            _actionWaitComplete = _WaitComplete;
        }

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _triggerFlowOutput = AddFlowOutput("Trigger");
        }

        protected override void _Invoke()
        {
            _battle.battleTimer.AddTimer(null, 0.01f, 0f, funcComplete: _actionWaitComplete);
        }

        private void _WaitComplete(int id)
        {
            _battle.actorMgr.CreateMonster(pointId.value);
            _triggerFlowOutput.Call(Flow.New);
        }
    }
}
