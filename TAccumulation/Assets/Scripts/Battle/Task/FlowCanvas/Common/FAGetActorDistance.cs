using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Function/GetActorDistance")]
    [Name("获得距离\nGetActorDistance")]
    public class FAGetActorDistance : FlowAction
    {
        private ValueInput<Actor> _viActor1;
        private ValueInput<Actor> _viActor2;

        protected override void _OnRegisterPorts()
        {
            _viActor1 = AddValueInput<Actor>("Actor1");
            _viActor2 = AddValueInput<Actor>("Actor2");
            AddValueOutput("Distance", () =>
            {
                var actor1 = _viActor1?.GetValue();
                if (actor1 == null)
                {
                    _LogError("请联系策划【路浩】,【获得距离 GetActorDistance】节点配置错误. 引脚【Actor1】没有正确赋值.");
                    return -1f;
                }
                
                var actor2 = _viActor2?.GetValue();
                if (actor2 == null)
                {
                    _LogError("请联系策划【路浩】,【获得距离 GetActorDistance】节点配置错误. 引脚【Actor2】没有正确赋值.");
                    return -1f;
                }

                return BattleUtil.GetActorDistance(actor1, actor2);
            });
        }
    }
}
