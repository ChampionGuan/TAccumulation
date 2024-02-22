using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("获取破盾虚弱状态剩余时间\nGetWeakLeftTime")]
    public class FAGetWeakLeftTime : FlowAction
    {
        public ValueInput<Actor> _viSourceActor;
        private float _leftTime;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viSourceActor = AddValueInput<Actor>("actor");
            AddValueOutput("剩余时间", () => _leftTime);
        }

        protected override void _Invoke()
        {
            var actor = _viSourceActor.GetValue();
            if (actor == null)
            {
                _LogError("请联系策划【路浩】,【获取破盾状态剩余时间】节点配置错误. 引脚【actor】没有正确赋值.");
                return;
            }
            if (actor.actorWeak == null)
            {
                _LogError($"请联系策划【路浩】,【获取破盾状态剩余时间】节点配置错误. 引脚【actor】{actor.name}没有虚弱组件.");
                return;
            }

            _leftTime = actor.actorWeak.recoverTime;
        }
    }
}
