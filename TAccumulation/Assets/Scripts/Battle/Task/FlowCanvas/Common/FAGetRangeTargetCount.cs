using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Function")]
    [Name("获取目标附近的单位数量\nFAGetRangeTargetCount")]
    public class FAGetRangeTargetCount : FlowAction
    {
        public BBParameter<float> radius = new BBParameter<float>(1f);
        public BBParameter<FactionFlag> factionFlag = new BBParameter<FactionFlag>(FactionFlag.Hero);
        public BBParameter<IncludeSummonType> includeSummonType = new BBParameter<IncludeSummonType>(IncludeSummonType.AnyType);

        protected override void _OnRegisterPorts()
        {
            var viRefActor = AddValueInput<Actor>("RefActor");
            AddValueOutput<int>("Count", () =>
            {
                var refActor = viRefActor.GetValue();
                if (refActor == null)
                {
                    _LogError($"请联系策划【蜗牛君】,【随机选取目标 FARandomSelectTarget】节点的参数[RefActor]引脚没有正确配置, 目前为null");
                    return 0;
                }

                var rad = radius.GetValue();
                if (rad <= 0f)
                {
                    _LogError($"请联系策划【蜗牛君】,【随机选取目标 FARandomSelectTarget】节点的参数[radius]没有正确配置, 目前为{rad}");
                    return 0;
                }
                
                var list1 = ObjectPoolUtility.CommonActorList.Get();
                var list2 = ObjectPoolUtility.CommonActorList.Get();
                
                // DONE: 只筛选 角色和怪物
                BattleUtil.FilterActors(Battle.Instance.actorMgr.actors, list1, ActorFlag.Hero | ActorFlag.Monster);
                // DONE: 默认剔除自己.
                list1.Remove(refActor);
                // DONE: 阵营筛选
                BattleUtil.FilterActors(list1, list2, factionFlag.GetValue());
                // DONE: 范围筛选
                BattleUtil.FilterActors(list2, list1, refActor.transform.position, rad);
                // DONE: 是否包含召唤物类型.
                var isIncludeSummonType = includeSummonType.GetValue();
                BattleUtil.FilterActors(list1, list2, isIncludeSummonType);

                int result = list2.Count;
                ObjectPoolUtility.CommonActorList.Release(list1);
                ObjectPoolUtility.CommonActorList.Release(list2);
                return result;
            });
        }
    }
}
