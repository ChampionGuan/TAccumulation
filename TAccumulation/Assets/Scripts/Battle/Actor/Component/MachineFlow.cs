using FlowCanvas;

namespace X3Battle
{
    public class MachineFlow : ActorComponent
    {
        private NotionGraph<FlowScriptController> _flow;

        public MachineFlow() : base(ActorComponentType.MachineFlow)
        {
        }

        protected override void OnAwake()
        {
            var flowName = actor.createCfg.FlowName;
            if (string.IsNullOrEmpty(flowName))
            {
                return;
            }

            var context = new ActorContext(actor);
            _flow = new NotionGraph<FlowScriptController>();
            _flow.Init(context, flowName, BattleResType.Flow, actor.GetDummy(), false);
        }

        protected override void OnStart()
        {
            actor.transform.AddChild(_flow.trans);
        }

        public override void OnBorn()
        {
            if (null != _flow)
            {
                _flow.SetVariableValue("State", (actor.bornCfg as MachineBornCfg).State);
                _flow.Restart();
            }
        }

        protected override void OnUpdate()
        {
            _flow?.Update(battle.deltaTime);
        }

        protected override void OnDestroy()
        {
            _flow?.OnDestroy();
            _flow = null;
        }
    }
}
