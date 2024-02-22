using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("杀死召唤物\nKillSummon")]
    public class FAKillSummon : FlowAction
    {
        private ValueInput<Actor> _viActor;

        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viActor = AddValueInput<Actor>(nameof(Actor));
        }

        protected override void _Invoke()
        {
            var actor = _viActor?.GetValue() ?? _actor;
            if (actor == null)
            {
                _LogError("请联系策划【蜗牛君】,【杀死召唤物 KillSummon】节点配置错误. 引脚【Actor】没有正确赋值 or 没有放在角色图里使用.");
                return;
            }

            var list = ObjectPoolUtility.CommonActorList.Get();
            actor.GetCreatures(null, list);

            // DONE: 杀死召唤物.
            for (int i = 0; i < list.Count; i++)
            {
                list[i].Dead();
            }
            
            ObjectPoolUtility.CommonActorList.Release(list);
        }
    }
}
