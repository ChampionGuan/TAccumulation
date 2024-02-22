using System;
using System.Collections.Generic;
using PapeGames.X3;

namespace X3Battle
{
    /// <summary>
    /// 被嘲讽组件
    /// </summary>
    public class ActorTaunt : ActorComponent
    {
        /// <summary>
        /// 抗嘲讽值
        /// </summary>
        private int _antiTauntStrength;
        /// <summary>
        /// 嘲讽列表
        /// </summary>
        private SortedSet<TauntData> _taunts = new SortedSet<TauntData>();
        private Dictionary<Actor, TauntData> _searchData = new Dictionary<Actor, TauntData>();
        /// <summary>
        /// 当前嘲讽
        /// </summary>
        private TauntData _taunt;
        /// <summary>
        /// 当前嘲讽目标
        /// </summary>
        public Actor tauntTarget => _taunt?.sourceActor;

        private int _addOperationIndex;  // 添加索引
        private Action<EventStateTagChangeBase> _actionStateTagChange;
        private Action<EventActorBase> _actionActorDead;

        private float _attenuatePeriod;  // 嘲讽衰减时长, 30， 此事件内反复嘲讽，需要进行衰减，时间结束后恢复效果
        private int[] _tauntTimes;  // 次数数组, 3|4|5, 在时间内的被嘲讽次数数组，本例中，需要在3、4、5次时根据下方2个字段进行逻辑处理
        private float[] _attenuateRatio; // 嘲讽值衰减, 0.6|0.6|0.1, 匹配上一字段次数时，嘲讽强度的系数，本例中：第3次开始，嘲讽强度*0.6；第5次后，嘲讽强度*0.5

        private int _curTauntTimes;  // 当前周期内累计的嘲讽次数
        private float _curAttenuatePeriod;  // 当前周期剩余时间
        private float _curAttenuateRatio = 1;  // 当前的嘲讽值衰减比例, 默认1
        
        public ActorTaunt() : base(ActorComponentType.Taunt)
        {
            requiredAnimationJobRunning = true;
            
            _actionStateTagChange = _OnStateTagChange;
            _actionActorDead = _OnActorDead;

            _attenuatePeriod = TbUtil.battleConsts.TauntDeclinePeriod;
            _tauntTimes = TbUtil.battleConsts.TauntedTimes;
            _attenuateRatio = TbUtil.battleConsts.TauntStrengthDecline;
        }

        protected override void OnAwake()
        {
            if (actor.IsGirl())
            {
                var weaponSkinConfig = TbUtil.GetCfg<WeaponSkinConfig>(Battle.Instance.arg.girlWeaponID);
                if (weaponSkinConfig != null)
                {
                    _antiTauntStrength = weaponSkinConfig.AntiTauntStrength;
                }
                else
                {
                    _antiTauntStrength = 0;
                }
            }
            else
            {
                _antiTauntStrength = actor.roleCfg.AntiTauntStrength;
            }
            _addOperationIndex = 0;
        }
        
        public override void OnBorn()
        {
            _ResetAttenuateData();
            actor.eventMgr.AddListener(EventType.LockIgnoreStateTagChange, _actionStateTagChange, "ActorTaunt._OnStateTagChange");
            battle.eventMgr.AddListener(EventType.ActorRecycle, _actionActorDead, "ActorTaunt._OnActorRecycle");
        }

        protected override void OnAnimationJobRunning()
        {
            if (_curAttenuatePeriod > 0)
            {
                _curAttenuatePeriod -= actor.deltaTime;
                if (_curAttenuatePeriod <= 0)
                {
                    LogProxy.LogFormat("【目标】{0}嘲讽衰减周期结束", actor.name);
                    _ResetAttenuateData();
                }
            }
        }
        
        // 重置衰减数据
        private void _ResetAttenuateData()
        {
            _curTauntTimes = 0;
            _curAttenuatePeriod = 0;
            _curAttenuateRatio = 1f;
        }

        // 计算衰减后的嘲讽值
        private float _CalculateAttenuateValue(int tauntValue)
        {
            return tauntValue * _curAttenuateRatio;
        }

        // 更新衰减
        private void _OnTauntUpdateAttenuate()
        {
            // 衰减时间赋值
            if (_curAttenuatePeriod <= 0)
            {
                LogProxy.LogFormat("【目标】{0}嘲讽衰减周期开始", actor.name);
                _curAttenuatePeriod = _attenuatePeriod;
            }
            // 衰减次数赋值
            _curTauntTimes += 1;
            // 衰减比例赋值
            for (int i = 0; i < _tauntTimes.Length; i++)
            {
                if (_curTauntTimes == _tauntTimes[i])
                {
                    _curAttenuateRatio = _attenuateRatio[i];
                    return;
                }
            }
        }
        
        public bool AddTaunt(IBuff buff, int tauntValue)
        {
            var attenuateValue = _CalculateAttenuateValue(tauntValue);
            if (attenuateValue <= _antiTauntStrength)
            {
                return false;
            }
            // 策划需求：成功被嘲讽才开始计算
            _OnTauntUpdateAttenuate();
            var tauntActor = buff.GetCaster();
            _searchData.TryGetValue(tauntActor, out var tauntData);
            if (tauntData == null)
            {
                tauntData = ObjectPoolUtility.TauntData.Get();
                tauntData.sourceActor = tauntActor;
                tauntData.lockable = !tauntActor.stateTag?.IsActive(ActorStateTagType.LockIgnore) ?? true;
                tauntData.index = _addOperationIndex++;  // 每次操作索引都要增加，用于排序
                _searchData.Add(tauntActor, tauntData);
                _taunts.Add(tauntData);
            }
            else
            {
                tauntData.index = _addOperationIndex++;  // 每次操作索引都要增加，用于排序
                _taunts.Remove(tauntData);
                _taunts.Add(tauntData);
            }
            
            tauntData.buffs.Add(buff);

            _SelectTaunt();
            return true;
        }

        private void _SelectTaunt()
        {
            TauntData cacheTaunt = _taunt;
            _taunt = null;
            
            foreach (var data in _taunts)
            {
                // 字典已经排过序了，后更新的在前，此处直接从前往后取即可
                if (data.lockable)
                {
                    _taunt = data;
                    break;
                }
            }
            
            // 嘲讽目标变化
            if (_taunt != cacheTaunt)
            {
                var eventData = actor.eventMgr.GetEvent<EventTauntActor>();
                eventData.Init(actor, tauntTarget);
                PapeGames.X3.LogProxy.LogFormat("【目标】：{0}的被嘲讽目标变为{1}", actor.name, _taunt == null ? "空" : tauntTarget?.name);
                actor.eventMgr.Dispatch(EventType.TauntActorChange, eventData);
            }
        }
        
        /// <summary>
        /// 状态标签发生变化
        /// </summary>
        /// <param name="stateTagChange"></param>
        private void _OnStateTagChange(EventStateTagChangeBase stateTagChange)
        {
            _searchData.TryGetValue(stateTagChange.actor, out var taunt);
            if (taunt != null)
            {
                taunt.lockable = !stateTagChange.active;
                _SelectTaunt();
            }
        }
        
        /// <summary>
        /// 角色死亡
        /// </summary>
        /// <param name="eventActor"></param>
        private void _OnActorDead(EventActorBase eventActor)
        {
            _searchData.TryGetValue(eventActor.actor, out var taunt);
            if (taunt != null)
            {
                _searchData.Remove(eventActor.actor);
                _taunts.Remove(taunt);
                if (taunt == _taunt)//死亡的正是嘲讽目标
                {
                    _SelectTaunt();
                }
                ObjectPoolUtility.TauntData.Release(taunt);
            }
        }

        public void RemoveTaunt(IBuff buff)
        {
            Actor caster = buff.GetCaster();
            _searchData.TryGetValue(caster, out var taunt);
            
            if (taunt != null)
            {
                taunt.buffs.Remove(buff);  // buffs内部是hashSet，无脑移除即可
                if (taunt.buffs.Count == 0)
                {
                    _searchData.Remove(caster);
                    _taunts.Remove(taunt);
                    if (taunt == _taunt)  // 死亡的正是嘲讽目标
                    {
                        _SelectTaunt();   
                    }
                    ObjectPoolUtility.TauntData.Release(taunt);
                }
            }
        }
        
        public override void OnRecycle()
        {
            actor.eventMgr.RemoveListener(EventType.LockIgnoreStateTagChange, _actionStateTagChange);
            battle.eventMgr.RemoveListener(EventType.ActorDead, _actionActorDead);

            foreach (var iter in _searchData)
            {
                ObjectPoolUtility.TauntData.Release(iter.Value);
            }
            _taunts.Clear();
            _searchData.Clear();
            _taunt = null;
        }
    }
}