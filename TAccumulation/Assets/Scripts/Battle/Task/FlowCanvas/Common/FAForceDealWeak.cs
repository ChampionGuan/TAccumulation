using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("强制使单位虚弱\nForceDealWeak")]
    public class FAForceDealWeak : FlowAction
    {
        private ValueInput<Actor> _viSourceActor;
        
        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viSourceActor = AddValueInput<Actor>("SourceActor");
        }

        protected override void _Invoke()
        {
            if (_viSourceActor == null)
            {
                _LogError("请联系策划【卡宝】,【强制使单位虚弱 ForceDealWeak】节点配置错误. 引脚【SourceActor】没有正确赋值.");
                return;
            }

            var actor = _viSourceActor.GetValue();
            if (actor == null)
            {
                _LogError("请联系策划【卡宝】,【强制使单位虚弱 ForceDealWeak】节点配置错误. 引脚【SourceActor】没有正确赋值.");
                return;
            }
            
            if (actor.actorWeak == null)
            {
                _LogError($"请联系策划【卡宝】,【强制使单位虚弱 ForceDealWeak】节点配置错误. 引脚【SourceActor】{actor.name}没有虚弱组件.");
                return;
            }
            
            // DONE: 强制该角色直接虚弱.
            actor.actorWeak.ForceEnterWeak();
        }
    }
}
