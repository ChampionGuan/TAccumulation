using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("关闭|开启AI\nDisableAI")]
    [Description("关闭|开启AI")]
    public class FADisableAI: FlowAction
    {
        [Name("是否关闭AI")] 
        public bool disable;
        private ValueInput<Actor> actor;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            actor = AddValueInput<Actor>("Actor");
        }

        protected override void _Invoke()
        {
            var selectActor = actor.GetValue();
            if (selectActor == null)
                return;
            selectActor.aiOwner?.DisableAI(disable,AISwitchType.Player);
        }
    }
}
