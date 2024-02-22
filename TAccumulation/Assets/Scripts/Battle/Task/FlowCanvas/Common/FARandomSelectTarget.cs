using System;
using System.Collections.Generic;
using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Function")]
    [Name("随机选取目标\nRandomSelectTarget")]
    public class FARandomSelectTarget : FlowAction
    {
        public BBParameter<float> radius = new BBParameter<float>(1f);
        public BBParameter<int> maxNum = new BBParameter<int>(1);
        public BBParameter<FactionFlag> factionFlag = new BBParameter<FactionFlag>(FactionFlag.Hero);
        public BBParameter<IncludeSummonType> includeSummonType = new BBParameter<IncludeSummonType>(IncludeSummonType.AnyType);

        private ValueInput<Actor> _viRefActor;
        private Random _random = new Random();

        protected override void _OnRegisterPorts()
        {
            _viRefActor = AddValueInput<Actor>("RefActor");
            AddValueOutput<List<Actor>>(nameof(Actor), () =>
            {
                var refActor = _viRefActor.GetValue();
                if (refActor == null)
                {
                    _LogError($"请联系策划【蜗牛君】,【随机选取目标 FARandomSelectTarget】节点的参数[RefActor]引脚没有正确配置, 目前为null");
                    return new List<Actor>();
                }

                var rad = radius.GetValue();
                if (rad <= 0f)
                {
                    _LogError($"请联系策划【蜗牛君】,【随机选取目标 FARandomSelectTarget】节点的参数[radius]没有正确配置, 目前为{rad}");
                    return new List<Actor>();
                }
                
                var max = maxNum.GetValue();
                if (max <= 0f)
                {
                    _LogError($"请联系策划【蜗牛君】,【随机选取目标 FARandomSelectTarget】节点的参数[max]没有正确配置, 目前为{max}");
                    return new List<Actor>();
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

                // DONE: 打乱列表里的数据.
                BattleUtil.ShuffleList(list2);

                // DONE: 选取关注数量的Actor.
                var results = new List<Actor>();
                for (int i = 0; i < list2.Count; i++)
                {
                    if (i >= max)
                    {
                        break;
                    }
                    results.Add(list2[i]);
                }

                ObjectPoolUtility.CommonActorList.Release(list1);
                ObjectPoolUtility.CommonActorList.Release(list2);
                
                return results;
            });
        }
    }
}
