using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action/ActorList")]
    [Name("ActorList操作-增加\nFAAddToActorList")]
    public class FAAddToActorList : FlowAction
    {
        private ValueInput<ActorList> _viActorList;
        private ValueInput<Actor> _viActor;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();

            _viActorList = AddValueInput<ActorList>("List");
            _viActor = AddValueInput<Actor>("Actor");
            AddValueOutput("ActorList", () => _viActorList?.GetValue());
        }

        protected override void _Invoke()
        {
            var list = _viActorList?.GetValue();
            if (list == null)
            {
                _LogError($"请联系策划【路浩/大头】, 节点【ActorList操作-增加 FAAddToActorList】引脚参数配置错误, 【ActorList】引脚为null!");
                return;
            }

            var actor = _viActor?.GetValue();
            if (actor == null)
            {
                _LogError($"请联系策划【路浩/大头】, 节点【ActorList操作-增加 FAAddToActorList】引脚参数配置错误, 【Actor】引脚为null!");
                return;
            }

            if (actor.isDead)
            {
                _LogError($"请联系策划【路浩/大头】, 节点【ActorList操作-增加 FAAddToActorList】引脚参数配置错误, 【Actor】引脚为已死亡的角色:{actor.name}");
                return;
            }

            if (list.Contains(actor))
            {
                return;
            }
            
            list.Add(actor);
        }
    }
}
