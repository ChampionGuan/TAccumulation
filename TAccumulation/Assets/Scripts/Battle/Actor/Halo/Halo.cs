using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public class Halo
    {
        public int insID { get; private set; }
        private ShapeBox _shapeBox;
        public ShapeBox shapeBox => _shapeBox;
        public HaloCfg haloCfg { get; private set; }
        public Actor master { get; private set; }
        public int level { get; private set; }
        public bool isDestroy { get; private set; }
        public DamageExporter casterExporter { get; private set; }
        public Actor caster => casterExporter?.GetCaster();
        
        private bool _bIsRegister;

        // 处于光环区域内的Actor列表.
        private List<Actor> _enterAreas;

        // 辅助双列表检查差异用的HashSet.
        private HashSet<Actor> _enterHashSet;
        private HashSet<Actor> _tempHashSet;

        private Battle _battle;
        private List<FactionRelationship> _relationShips;

        private float _lifeTime;
        private bool _bIsforever;

        // 光环负责添加的Buff.
        private List<int> _buffIds;

        private List<Actor> _reuseActors = new List<Actor>(20);
        private Action<EventActorBase> _actionOnActorRecycle;
        
        // 筛选TriggerContext
        private TriggerHaloContext _triggerContext;
        private int _triggerInsID = -1;
        
        /// <summary>
        /// 初始化光环
        /// </summary>
        /// <param name="insId"> 唯一ID </param>
        /// <param name="master"> 光环组件的拥有者 & 光环的主人(目前有: Buff的主人Actor, 法术场的Actor) </param>
        /// <param name="haloCfg"> 光环的配置 </param>
        /// <param name="level"> 从光环的主人处继承过来的等级 </param>
        /// <param name="shapeBoxInfo"> 形状盒子数据 用于覆盖逻辑 </param>
        /// <param name="lifeTime"> 存活时长 用于覆盖逻辑 </param>
        public Halo()
        {
            _actionOnActorRecycle = _OnActorRecycle;
        }

        public void Init(int insId, Actor master, HaloCfg haloCfg, int level, ShapeBoxInfo shapeBoxInfo, float? lifeTime, DamageExporter casterExporter = null)
        {
            this.insID = insId;
            this.master = master;
            this.haloCfg = haloCfg;
            this.level = level;
            // DONE: 覆盖逻辑.
            this._lifeTime = lifeTime ?? haloCfg.Duration;
            // DONE: 是否永久.
            this._bIsforever = this._lifeTime <= 0f;
            this._battle = master.battle;
            this._enterAreas = new List<Actor>();
            this._enterHashSet = new HashSet<Actor>();
            this._tempHashSet = new HashSet<Actor>();
            this.casterExporter = casterExporter;
            LogProxy.Log("Create Halo skillType = " + this.casterExporter.GetSkillType() + "ID = " + haloCfg.ID);
            // DONE: 需要添加的BuffId.
            this._buffIds = new List<int>();
            if (haloCfg.BuffIds != null && haloCfg.BuffIds.Count > 0)
            {
                for (int i = 0; i < haloCfg.BuffIds.Count; i++)
                {
                    this._buffIds.Add(haloCfg.BuffIds[i]);
                }
            }

            // DONE: 挂点
            var root = this.master.GetDummy();

            // DONE: 形状数据优先采用传参的.(目前: 法术场有覆盖逻辑)
            if (shapeBoxInfo == null)
            {
                if (haloCfg.ShapeBoxInfo.ShapeInfo.DebugInfo == null)
                {
                    haloCfg.ShapeBoxInfo.ShapeInfo.SetDebugInfo("【Alt+Z/光环/{0}】", haloCfg.ID);
                }
                
                shapeBoxInfo = haloCfg.ShapeBoxInfo;
            }
            // DONE: 光环默认跟随主人, 所以没有形状偏移.
            shapeBoxInfo.ShapeBoxFollowMode = ShapeBoxFollowMode.PositionAndRotation;
            this._shapeBox = ObjectPoolUtility.ShapeBoxPool.Get();
            this._shapeBox.Init(shapeBoxInfo, new VirtualTrans(root), Vector3.zero, Vector3.zero);
            this.isDestroy = false;

            // DONE: 根据配置, 初始化阵营筛选列表, 与DamageBox初始化处理一致.
            _relationShips = new List<FactionRelationship>();
            if (haloCfg.FactionRelationship != null && haloCfg.FactionRelationship.Length > 0)
            {
                foreach (var relationship in haloCfg.FactionRelationship)
                {
                    this._relationShips.Add(relationship);
                }
            }
            else
            {
                this._relationShips.Add(FactionRelationship.Enemy);
            }
            
            // DONE：创建筛选触发器
            if (haloCfg.TriggerID > 0)
            {
                _triggerContext = new TriggerHaloContext(this);
                _triggerInsID = master.battle.triggerMgr.AddTrigger(haloCfg.TriggerID, _triggerContext);
            }
            
            Battle.Instance.eventMgr.AddListener<EventActorBase>(EventType.ActorRecycle, _actionOnActorRecycle, "Halo._OnActorRecycle");
        }
        
        public void Destroy()
        {
            this.isDestroy = true;
            Battle.Instance.eventMgr.RemoveListener<EventActorBase>(EventType.ActorRecycle, _actionOnActorRecycle);
            
            // DONE: 光环死亡时, 应移除现光环内所有的目标.
            foreach (Actor actor in _enterAreas)
            {
                _RemoveBuffFromActor(actor);
            }
            
            // Destroy时销毁Trigger
            if (_triggerInsID > 0)
            {
                master.battle.triggerMgr.RemoveTrigger(_triggerInsID);
                _triggerInsID = -1;
            }

            _enterAreas.Clear();
            _enterHashSet.Clear();
            ObjectPoolUtility.ShapeBoxPool.Release(_shapeBox);
            _shapeBox = null;
        }
        
        private void _OnActorRecycle(EventActorBase eventActor)
        {
            if (_enterHashSet.Contains(eventActor.actor))
            {
                _enterAreas.Remove(eventActor.actor);
                _enterHashSet.Remove(eventActor.actor);
            }
        }

        public void Update(float delta)
        {
            // DONE: 光环被销毁时, 不允许再tick了.
            if (this.isDestroy)
            {
                return;
            }

            // DONE: 不是永久的要Tick倒计时
            if (!_bIsforever)
            {
                _lifeTime -= delta;
                if (_lifeTime <= 0f)
                {
                    this.isDestroy = true;
                }
            }

            // DONE: 形状盒子更新
            _shapeBox.Update();

            var prevPosition = _shapeBox.GetPrevWorldPos();
            var targetPosition = _shapeBox.GetCurWorldPos();
            var angleY = _shapeBox.GetCurWorldEuler().y;
            var bundingShape = _shapeBox.GetBoundingShape();

            var result = _reuseActors;
            BattleUtil.PickAOETargets(
                _battle,
                ref result,
                targetPosition,
                prevPosition,
                new Vector3(0f, angleY, 0f),
                bundingShape,
                this.master,
                sameFaction: false,
                excludeSet: null,
                isContinuousMode: false,
                null,
                factionRelationShips: _relationShips,
                bIncludeSelf: haloCfg.IsFactionRelationshipSelf, X3LayerMask.HaloTest);
            
            // 触发器筛选
            if (_triggerInsID > 0)
            {
                var eventFilterActorStart = _triggerContext.eventMgr.GetEvent<NotionEventFilterActorStart>();
                eventFilterActorStart.Init(result);
                _battle.triggerMgr.TriggerEvent(_triggerInsID, NotionGraphEventType.FilterActorStart, eventFilterActorStart);
                result = _triggerContext.actorList;
            }
            
            // DONE: 判断谁刚进入光环区域.
            this._tempHashSet.Clear();
            foreach (Actor actor in result)
            {
                if (actor.buffOwner == null)
                {
                    continue;
                }

                if (haloCfg.IgnoreCreature && actor.IsCreature())
                {
                    continue;
                }

                if (actor.stateTag != null && actor.stateTag.IsActive(ActorStateTagType.LogicTestIgnore))
                {
                    continue;
                }

                _tempHashSet.Add(actor);
                bool bIsAdd = _enterHashSet.Add(actor);
                if (bIsAdd)
                {
                    _enterAreas.Add(actor);

                    // DONE: 为它添加Buff, 默认添加一层.
                    foreach (int buffId in this._buffIds)
                    {
                        bool b = actor.buffOwner.Add(buffId, layer: 1, time: -1, level: this.level, caster, casterExporter);
                        if (b)
                        {
                            PapeGames.X3.LogProxy.LogFormat("[光环] InsID={0}, Actor[{1}] 对 目标actor[{2}] 添加了[1]层Buff[{3}], 继承等级为[{4}]", insID, caster?.name, actor.name, buffId, level);       
                        }
                    }
                }
            }

            // DONE: 判断谁刚离开光环区域.
            for (int i = _enterAreas.Count - 1; i >= 0; i--)
            {
                var actor = _enterAreas[i];
                if (!_tempHashSet.Contains(actor))
                {
                    _enterAreas.RemoveAt(i);
                    _enterHashSet.Remove(actor);
                    _RemoveBuffFromActor(actor);
                }
            }
            
            // DONE: 保证光环能给目标添加上buff.
            for (var i = 0; i < _enterAreas.Count; i++)
            {
                var actor = _enterAreas[i];
                if (actor == null || actor.isDead || actor.isRecycled)
                {
                    continue;
                }

                // DONE: 为它添加Buff, 默认添加一层.
                foreach (int buffId in this._buffIds)
                {
                    if (actor.buffOwner.HasBuff(buffId))
                    {
                        continue;
                    }
                    
                    PapeGames.X3.LogProxy.LogFormat("[光环] InsID={0}, Actor[{1}] 对 目标actor[{2}] 添加了[1]层Buff[{3}], 继承等级为[{4}]", insID, caster?.name, actor.name, buffId, level);
                    actor.buffOwner.Add(buffId, layer: 1, time: -1, level: this.level, caster, casterExporter);
                }
            }
        }

        /// <summary>
        /// 从某Actor上移除Buff.
        /// </summary>
        /// <param name="actor"> 某Actor </param>
        private void _RemoveBuffFromActor(Actor actor)
        {
            if (haloCfg.BuffHoldUpTime > 0f)
            {
                // DONE: 为它添加Buff, 时间为BuffHoldUpTime.
                foreach (int buffId in this._buffIds)
                {
                    bool b = actor.buffOwner.Add(buffId, layer: 1, time: haloCfg.BuffHoldUpTime, level: this.level, caster, casterExporter);
                    if (b)
                    {
                        PapeGames.X3.LogProxy.LogFormat("[光环] InsID={0}, Actor[{1}] 对 目标actor[{2}] 添加了[1]层Buff[{3}], 继承等级为[{4}], 持续时间为[{5}]", insID, caster?.name, actor.name, buffId, level, haloCfg.BuffHoldUpTime);       
                    }
                }
            }
            else
            {
                // DONE: 为它移除Buff, 默认移除一层.
                foreach (int buffId in this._buffIds)
                {
                    PapeGames.X3.LogProxy.LogFormat("[光环] InsID={0}, Actor[{1}] 为目标 actor[{2}] 移除了[1]层Buff[{3}]", insID, this.caster?.name, actor.name, buffId);
                    actor.buffOwner.ReduceStack(buffId, 1);
                }
            }
        }
    }
}