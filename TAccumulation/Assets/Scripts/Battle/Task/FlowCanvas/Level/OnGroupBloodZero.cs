using System;
using System.Collections.Generic;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Listener")]
    [Name("Npc Group血量监听器\nOnGroupBloodZero")]
    public class OnGroupBloodZero : FlowListener
    {
        public BBParameter<int> groupId = new BBParameter<int>();
        public BBParameter<ECompareOperator> eCompareOperator = new BBParameter<ECompareOperator>();
        public BBParameter<float> hpPercent = new BBParameter<float>(); // HpPercent.

        [Name("GroupTotalHp")] 
        public bool useGroupTotalHP = false; // 是否使用这一刻所有角色血量上限和作为分母.
        
        private HpRateMode _hpRateMode;
        private GroupActorHpInfo _groupActorHpInfo; // 当_hpRateMode为总体时需要依赖该数据.
        private Action<EventActorHealthChangeForUI> _actionOnActorHealthChange;

        /// <summary> 血量比值模式 </summary>
        enum HpRateMode
        {
            /// <summary> 个体当前血量/个体最大血量 </summary>
            Single,
            /// <summary> 总体当前血量/总体最大血量 </summary>
            Total,
        }

        struct GroupActorHpInfo
        {
            public Dictionary<int, float> actorCurHpMap; // 记录总体每个Actor的当前血量.
            public float totalCurHp; // 总体当前血量.
            public float totalMaxHp; // 总体最大血量.
            public float totalInvMaxHp; // 总体最大血量的倒数. 1/总体最大血量
            public int totalCount; // 总体个数.
            public HashSet<int> meetActorInsIds; // 达成条件的ID个数.

            public void Reset()
            {
                actorCurHpMap?.Clear();
                meetActorInsIds?.Clear();
                totalCurHp = 0f;
                totalMaxHp = 0f;
                totalInvMaxHp = 0f;
                totalCount = 0;
            }
        }

        public OnGroupBloodZero()
        {
            _actionOnActorHealthChange = _OnActorHealthChange;
            _groupActorHpInfo.actorCurHpMap = new Dictionary<int, float>();
            _groupActorHpInfo.meetActorInsIds = new HashSet<int> { -1, -2, -3, -4, -5, -6, -7, -8, -9, -10 };
        }

        protected override void _RegisterEvent()
        {
            Battle.Instance.eventMgr.AddListener<EventActorHealthChangeForUI>(EventType.ActorHealthChangeForUI, _actionOnActorHealthChange, "OnGroupBloodZero._OnActorHealthChange");
            _hpRateMode = useGroupTotalHP ? HpRateMode.Total : HpRateMode.Single;
            _groupActorHpInfo.Reset();

            var actorGroup = Battle.Instance.actorMgr.GetActorGroup(groupId.GetValue());
            var actorIds = actorGroup?.actorIds;
            if (actorIds != null && actorIds.Count > 0)
            {
                // DONE: 先统计当前组内成员总的当前血量和总的最大血量, 并且记录当前这一刻每个成员的当前血量(用于优化).
                foreach (var actorId in actorIds)
                {
                    var actor = Battle.Instance.actorMgr.GetActor(actorId);
                    if (!actor.IsMonster())
                    {
                        continue;
                    }
                    var curHp = _GetActorAttrValue(actor, AttrType.HP);
                    var maxHp = _GetActorAttrValue(actor, AttrType.MaxHP);
                    _groupActorHpInfo.totalCurHp += curHp;
                    _groupActorHpInfo.totalMaxHp += maxHp;
                    _groupActorHpInfo.totalCount += 1;
                    _groupActorHpInfo.actorCurHpMap.Add(actor.insID, curHp);
                }

                // DONE: 保护判断, 防止比值的分母为0;
                if (_groupActorHpInfo.totalMaxHp > 0f)
                {
                    _groupActorHpInfo.totalInvMaxHp = 1 / _groupActorHpInfo.totalMaxHp;    
                }
                else
                {
                    _LogError("请联系策划【五当/禔安】【Npc Group血量监听器OnGroupBloodZero】监听这一刻的组内成员的最大血量和<=0");
                }

                // DONE: 再比较每个角色是否达成条件.
                foreach (var actorId in actorIds)
                {
                    var actor = Battle.Instance.actorMgr.GetActor(actorId);
                    if (_CheckAndUpdateHpPercentCondition(actor))
                    {
                        _groupActorHpInfo.meetActorInsIds.Add(actor.insID);
                    }
                }
            }

            _CheckCondition();
        }

        protected override void _UnRegisterEvent()
        {
            _groupActorHpInfo.Reset();
            Battle.Instance.eventMgr.RemoveListener<EventActorHealthChangeForUI>(EventType.ActorHealthChangeForUI, _actionOnActorHealthChange);
        }
        
        private void _OnActorHealthChange(EventActorHealthChangeForUI args)
        {
            if (args.actor.groupId != groupId.GetValue())
            {
                return;
            }
            
            // DONE: 判断当前这个Actor血量变化的百分比是否符合策划配置.
            if (!_CheckAndUpdateHpPercentCondition(args.actor))
            {
                return;
            }

            // DONE: 并且只能符合一次条件, 所以是HashSet.
            if (!_groupActorHpInfo.meetActorInsIds.Add(args.actor.insID))
            {
                return;
            }

            _CheckCondition();
        }

        private bool _CheckCondition()
        {
            if (_groupActorHpInfo.totalCount <= 0 || _groupActorHpInfo.meetActorInsIds.Count != _groupActorHpInfo.totalCount)
            {
                return false;
            }

            _Trigger();
            return true;
        }

        /// <summary>
        /// 比较角色的
        /// </summary>
        /// <param name="actor"></param>
        /// <returns></returns>
        private bool _CheckAndUpdateHpPercentCondition(Actor actor)
        {
            if (actor?.attributeOwner == null)
            {
                return false;
            }

            // DONE: 不是监听注册时组内的角色, 不予处理, 即不曾达成过条件.
            if (!_groupActorHpInfo.actorCurHpMap.TryGetValue(actor.insID, out float lastCurHp))
            {
                return false;
            }
            
            float curHp = actor.attributeOwner.GetAttrValue(AttrType.HP);
            if (_hpRateMode == HpRateMode.Single)
            {
                float maxHp = actor.attributeOwner.GetAttrValue(AttrType.MaxHP);
                if (maxHp <= 0f)
                {
                    _LogError($"请联系【程序】, Actor的最大血量<=0, name={actor.name}, insId={actor.insID}, actorId={actor.cfgID}");
                    return false;
                }

                // DONE: 判断当前这个Actor血量变化的百分比是否符合策划配置.
                float curHpPercent = curHp / maxHp;
                if (!BattleUtil.IsCompareSize(curHpPercent, hpPercent.GetValue(), eCompareOperator.GetValue()))
                {
                    return false;
                }
            }
            else
            {
                // DONE: 更新组内的总血量信息.
                if (curHp != lastCurHp)
                {
                    _groupActorHpInfo.actorCurHpMap[actor.insID] = curHp;
                    _groupActorHpInfo.totalCurHp = _groupActorHpInfo.totalCurHp - lastCurHp + curHp;
                }

                // DONE: 判断当前总的血量变化的百分比是否符合策划配置.
                float curHpPercent = _groupActorHpInfo.totalCurHp * _groupActorHpInfo.totalInvMaxHp;
                if (!BattleUtil.IsCompareSize(curHpPercent, hpPercent.GetValue(), eCompareOperator.GetValue()))
                {
                    return false;
                }
            }
            return true;
        }

        private float _GetActorAttrValue(Actor actor, AttrType attrType)
        {
            if (actor == null)
            {
                return 0f;
            }

            if (actor.attributeOwner == null)
            {
                return 0f;
            }

            float attrValue = actor.attributeOwner.GetAttrValue(attrType);
            return attrValue;
        }
    }
}
