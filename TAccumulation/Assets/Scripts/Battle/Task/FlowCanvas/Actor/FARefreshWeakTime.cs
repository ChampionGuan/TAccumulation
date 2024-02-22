using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("刷新破盾虚弱时间\nResetBreakRecoveryTime")]
    public class FARefreshWeakTime : FlowAction
    {
        private ValueInput<Actor> _viSourceActor;
        private ValueInput<float> _viTime;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viSourceActor = AddValueInput<Actor>("actor");
            _viTime = AddValueInput<float>("时长");
        }

        protected override void _Invoke()
        {
            var actor = _viSourceActor.GetValue();
            if (actor == null)
            {
                _LogError("请联系策划【路浩】,【刷新破盾虚弱时间 RefreshWeakTime】节点配置错误. 引脚【actor】没有正确赋值.");
                return;
            }

            if (actor.actorWeak == null)
            {
                _LogError($"请联系策划【路浩】,【刷新破盾虚弱时间 RefreshWeakTime】节点配置错误. 引脚【actor】{actor.name}没有虚弱组件.");
                return;
            }

            actor.actorWeak.RefreshWeakTime(_viTime.GetValue());
        }
    }
}
