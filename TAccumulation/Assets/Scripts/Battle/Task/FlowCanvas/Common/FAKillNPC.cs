using System;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("杀死NPC\nKillNPC")]
    [Description("适用于杀死指定NPC（带死亡表现，如果有的话）")]
    public class FAKillNPC : FlowAction
    {
        [Name("targetSpawnId")]
        public BBParameter<int> targetInsId = new BBParameter<int>();

        private FlowOutput _completedOutput;
        private Flow _flow;

        private Action<EventActorBase> _actionActorRecycle;

        public FAKillNPC()
        {
            _actionActorRecycle = OnKillCompleted;
        }

        protected override void _OnRegisterPorts()
        {
            var output = AddFlowOutput("Out");
            _completedOutput = AddFlowOutput("Completed");
            AddFlowInput("In", flow =>
            {
                _flow = flow;
                
                // DONE: 直接出.
                output.Call(flow);
                
                // DONE: 开始监听死亡表现完成.
                Battle.Instance.eventMgr.AddListener<EventActorBase>(EventType.ActorRecycle, _actionActorRecycle, "FAKillNPC.OnKillCompleted");

                // DONE: 击杀该Actor.
                var insId = targetInsId.GetValue();
                var actor = Battle.Instance.actorMgr.GetActor(insId);
                actor?.Dead();
            });
        }

        void OnKillCompleted(EventActorBase arg)
        {
            if (arg == null)
                return;
            if (arg.actor.spawnID != targetInsId.GetValue())
                return;
            _completedOutput.Call(_flow);
            Battle.Instance.eventMgr.RemoveListener<EventActorBase>(EventType.ActorRecycle, _actionActorRecycle);
        }
    }
}
