using System;
using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public abstract class ActorHate : ActorComponent,IFrameUpdate
    {
        public bool requiredFrameUpdate => true;
        public bool canFrameUpdate { get; set; }
        /// <summary>
        /// 仇恨触发的范围半径
        /// </summary>
        protected float _hateSqrRadius;
        /// <summary>
        /// 距离平方
        /// </summary>
        protected float[] _upSqrDistance;
        /// <summary>
        /// 仇恨列表
        /// </summary>
        protected List<HateDataBase> _hates;
        /// <summary>
        /// 缓存的仇恨列表
        /// </summary>
        protected List<HateDataBase> _cacheHates;
        /// <summary>
        /// 自己位置
        /// </summary>
        protected Vector3 position => actor.transform?.position ?? Vector3.zero;
        /// <summary>
        /// 角色列表
        /// </summary>
        protected List<Actor> _actors => actor.battle.actorMgr.actors;
        /// <summary>
        /// 当前仇恨数据
        /// </summary>
        protected HateDataBase _hate;
        /// <summary>
        /// 更新仇恨目标成功后的重置cd
        /// </summary>
        protected float _updateHateCd;
        /// <summary>
        /// 更新仇恨目标失败后的重置cd
        /// </summary>
        protected const float _updateHateFailCd = 1f;
        /// <summary>
        /// 当前更新仇恨目标的计时器
        /// </summary>
        protected float _curUpdateHateTime;
        /// <summary>
        /// 主控的友方标识
        /// </summary>
        protected bool _isPlayerFriend;
        /// <summary>
        /// 更新仇恨列表的重置cd
        /// </summary>
        private const float _updateHatesCd = 0.5f;
        /// <summary>
        /// 当前更新仇恨列表的计时器
        /// </summary>
        private float _curUpdateHatesTime;
        /// <summary>
        /// 当前仇恨目标
        /// </summary>
        public Actor hateTarget => _hate != null ? actor.battle.actorMgr.GetActor(_hate.insId) : null;
        public List<HateDataBase> hates => _hates;
        
        /// <summary>
        /// 怪物类型评分---友方专用
        /// </summary>
        protected int[] _monsterTypePoints;
        /// <summary>
        /// 锁定与否评分---男主专用
        /// </summary>
        protected int[] _lockPoints;
        /// <summary>
        /// 镜头内外评分---友方专用
        /// </summary>
        protected int[] _cameraPoints;
        /// <summary>
        /// 距离评分---友方专用
        /// </summary>
        protected int[] _distancePoints;
        
        private float _actorTime;

        private Action<EventStateTagChangeBase> _actionStateTagChange;
        private Action<EventActorBase> _actionActorBorn;
        private Action<EventActorBase> _actionActorDead;

        protected ActorHate() : base(ActorComponentType.Hate)
        {
            _actionStateTagChange = _OnStateTagChange;
            _actionActorBorn = _OnActorBorn;
            _actionActorDead = _OnActorDead;
        }

        protected override void OnAwake()
        {
            _cacheHates = new List<HateDataBase>(10);
            _hates = new List<HateDataBase>(10);
        }

        public override void OnBorn()
        {
            _actorTime = actor.time;
            _curUpdateHatesTime = _updateHatesCd;
            //出生的召唤物需要继承主人的仇恨目标
            if (actor.roleBornCfg.CreatureType != CreatureType.None && actor.master != null && actor.roleBornCfg.InheritHatred)
            {
                Actor masterTarget = actor.master.actorHate.hateTarget;
                if (masterTarget != null)
                {
                    _hate = AddHate(masterTarget);
                    var eventData = actor.eventMgr.GetEvent<EventHateActor>();
                    eventData.Init(actor, hateTarget);
                    actor.eventMgr.Dispatch(EventType.HateActorChange, eventData);
                }
            }
            battle.eventMgr.AddListener(EventType.LockIgnoreStateTagChange, _actionStateTagChange, "ActorHate._OnStateTagChange");
            battle.eventMgr.AddListener(EventType.ActorBorn, _actionActorBorn, "ActorHate._OnActorBorn");
            battle.eventMgr.AddListener(EventType.ActorDead, _actionActorDead, "ActorHate._OnActorDead");
            battle.frameUpdateMgr.Add(this);
        }

        public override void OnRecycle()
        {
            battle.frameUpdateMgr.Remove(this);
            battle.eventMgr.RemoveListener(EventType.LockIgnoreStateTagChange, _actionStateTagChange);
            battle.eventMgr.RemoveListener(EventType.ActorBorn, _actionActorBorn);
            battle.eventMgr.RemoveListener(EventType.ActorDead, _actionActorDead);
            ClearHates();
        }
        
        protected override void OnUpdate()
        {
            if (!canFrameUpdate)
            {
                return;
            }
            float deltaTime = actor.time - _actorTime;
            _actorTime = actor.time;
            //非友方，例如怪物、女主
            if (!_isPlayerFriend)
            {
                _curUpdateHatesTime -= deltaTime;
                if (_curUpdateHatesTime < 0)
                {
                    UpdateHates();
                }
            }
            _curUpdateHateTime -= deltaTime;
            if (_curUpdateHateTime < 0)
            {
                SelectHate();
            }
        }

        /// <summary>
        /// 更新仇恨列表
        /// </summary>
        public void UpdateHates()
        {
            if (_isPlayerFriend)
            {
                return;
            }
            //AI不在战斗态
            if (!actor.aiOwner.isBattleState)
            {
                _curUpdateHatesTime = _updateHatesCd;
                return;
            }
            for (int i = 0; i < _actors.Count; i++)
            {
                Actor curActor = _actors[i];
                if (curActor == actor)
                {
                    continue;
                }
                if (!curActor.IsRole() || curActor.isDead)
                {
                    continue;
                }

                FactionRelationship relationship = actor.GetFactionRelationShip(curActor);
                //非敌方
                if (relationship != FactionRelationship.Enemy)
                {
                    continue;
                }
                bool isExistHate = false;
                for (int j = 0; j < _hates.Count; j++)
                {
                    HateDataBase hate = _hates[j];
                    if (hate.insId == curActor.insID)
                    {
                        isExistHate = true;
                        break;
                    }
                }

                if (isExistHate)
                {
                    continue;
                }
                float sqrDistance = (position - curActor.transform.position).sqrMagnitude;
                if (sqrDistance < _hateSqrRadius)
                {
                    AddHate(curActor);
                }
            }
            _curUpdateHatesTime = _updateHatesCd;
        }
        
        /// <summary>
        /// 添加仇恨到列表里
        /// </summary>
        /// <param name="actor"></param>
        /// <returns></returns>
        protected HateDataBase AddHate(Actor actor) 
        {
            HateDataBase hateData = CreateHate(actor);
            _hates.Add(hateData);
            return hateData;
        }
        
        /// <summary>
        /// 创建仇恨数据
        /// </summary>
        /// <param name="actor"></param>
        /// <returns></returns>
        protected virtual HateDataBase CreateHate(Actor actor)
        {
            return null;
        }

        /// <summary>
        /// 更新仇恨目标
        /// </summary>
        protected virtual void SelectHate()
        {
            
        }

        protected void _SelectRoleHate(List<HateDataBase> hates, bool isGirl = false)
        {
            HateDataBase cacheHate = _hate;
            if (!hates.Contains(_hate) || !_hate.lockable)
            {
                _hate = null;
            }
            _cacheHates.Clear();
            for (int i = 0; i < hates.Count; i++)
            {
                PlayerHateData hate = hates[i] as PlayerHateData;
                if (hate.lockable && hate.active)//可锁定并且已激活
                {
                    Actor curActor = battle.actorMgr.GetActor(hate.insId);
                    if (curActor == null)
                    {
                        PapeGames.X3.LogProxy.LogError(string.Format("ID：{0}角色数据未找到！数据异常！", hate.insId));
                        continue;
                    }
                    if (curActor.config.Type == ActorType.Monster)
                    {
                        if (actor.config.SubType == (int) MonsterType.Boss)
                        {
                            hate.typePoint = _monsterTypePoints[0];
                        }
                        else if (actor.config.SubType == (int) MonsterType.Elite)
                        {
                            hate.typePoint = _monsterTypePoints[1];
                        }
                        else if (actor.config.SubType == (int) MonsterType.Mobs)
                        {
                            hate.typePoint = _monsterTypePoints[2];
                        }
                        else
                        {
                            hate.typePoint = _monsterTypePoints[3];
                        }
                    }
                    else
                    {
                        hate.typePoint = _monsterTypePoints[3];
                    }

                    if (!isGirl)
                    {
                        if (actor.battle.player.GetTarget() == curActor)
                        {
                            hate.lockPoint = _lockPoints[0];
                        }
                        else
                        {
                            hate.lockPoint = _lockPoints[1];
                        }
                    }
                    
                    //根据镜头内外初始化镜头评分
                    if (curActor.battle.cameraTrace.IsInSight(curActor))
                    {
                        hate.cameraPoint = _cameraPoints[0];
                    }
                    else
                    {
                        hate.cameraPoint = _cameraPoints[1];
                    }
                    hate.sqrDistance = (position - curActor.transform.position).sqrMagnitude;
                    _UpdateDistancePoint(hate);
                    _cacheHates.Add(hate);
                }
            }
            PlayerHateData targetHate = null;
            //计算权重
            for (int i = 0; i < _cacheHates.Count; i++)
            {
                PlayerHateData hate = _cacheHates[i] as PlayerHateData;
                if (isGirl)
                {
                    hate.weight = hate.threatenPoint + hate.typePoint + hate.cameraPoint + hate.distancePoint;
                }
                else
                {
                    hate.weight = hate.threatenPoint + hate.typePoint + hate.lockPoint + hate.cameraPoint + hate.distancePoint;
                }
                if (targetHate == null || targetHate.weight < hate.weight)
                {
                    targetHate = hate;
                }
            }
            _hate = targetHate;
            if (_hate != cacheHate)//仇恨目标变化，发送事件
            {
                var eventData = actor.eventMgr.GetEvent<EventHateActor>();
                eventData.Init(actor, hateTarget);
                PapeGames.X3.LogProxy.LogFormat("【目标】：{0}的仇恨目标变为{1}", actor.name, _hate == null ? "空" : hateTarget?.name);
                actor.eventMgr.Dispatch(EventType.HateActorChange, eventData);
                _curUpdateHateTime = _updateHateCd;
            }
            else
            {
                _curUpdateHateTime = _updateHateFailCd;
            }
        }
        
        private void _UpdateDistancePoint(PlayerHateData hate)
        {
            if (_upSqrDistance != null)
            {
                for (int i = 0; i < _upSqrDistance.Length; i++)
                {
                    if (hate.sqrDistance <= _upSqrDistance[i])
                    {
                        hate.distancePoint = _distancePoints[i];
                        return;
                    }
                }
            }
            hate.distancePoint = 0;
        }

        private void _HandleSelectHateByHate(HateDataBase hate)
        {
            //仇恨目标为空或仇恨目标是当前目标或当前角色是
            if (_hate == null || hate == _hate || actor == battle.player)
            {
                _HandleSelectHate();
            }
        }

        private void _HandleSelectHate()
        {
            SelectHate();
            if (actor == Battle.Instance.player)
            {
                battle.eventMgr.Dispatch(EventType.UpdateFriendHate, null);
            }
        }
        
        /// <summary>
        /// 清空仇恨数据
        /// </summary>
        public void ClearHates()
        {
            if (_hates == null)
            {
                return;
            }
            foreach (var hate in _hates)
            {
                if (hate is EnemyHateData)
                {
                    EnemyHateData enemyHateData = hate as EnemyHateData;
                    ObjectPoolUtility.EnemyHateData.Release(enemyHateData);
                }
                else if (hate is PlayerHateData)
                {
                    PlayerHateData playerHateData = hate as PlayerHateData;
                    ObjectPoolUtility.PlayerHateData.Release(playerHateData);
                }
            }
            _hates.Clear();
            _HandleSelectHate();
            _cacheHates.Clear();
        }
        
        /// <summary>
        /// 状态标签发生变化
        /// </summary>
        /// <param name="stateTagChange"></param>
        private void _OnStateTagChange(EventStateTagChangeBase stateTagChange)
        {
            for (int i = 0; i < _hates.Count; i++)
            {
                HateDataBase hate = _hates[i];
                if (hate.insId == stateTagChange.actor.insID)
                {
                    hate.lockable = !stateTagChange.active;
                    _HandleSelectHateByHate(hate);
                    break;
                }
            }
        }

        /// <summary>
        /// 角色死亡
        /// </summary>
        /// <param name="eventActor"></param>
        private void _OnActorDead(EventActorBase eventActor)
        {
            if (_hates == null || !eventActor.actor.IsRole())
            {
                return;
            }

            for (int i = 0; i < _hates.Count; i++)
            {
                HateDataBase hate = _hates[i];
                if (hate.insId == eventActor.actor.insID)
                {
                    _hates.RemoveAt(i);
                    _HandleSelectHateByHate(hate);
                    break;
                }
            }

            //仇恨主体为主控且仇恨列表清空
            if (_hates.Count == 0 && actor == battle.player)
            {
                battle.player.aiOwner.SetCombatTreeStatus(ActorAIStatus.Standby);
                battle.actorMgr.boy?.aiOwner.SetCombatTreeStatus(ActorAIStatus.Standby);
            }
        }

        /// <summary>
        /// 角色出生
        /// </summary>
        /// <param name="eventActor"></param>
        private void _OnActorBorn(EventActorBase eventActor)
        {
            if (_hates == null || !eventActor.actor.IsRole())
            {
                return;
            }

            if (eventActor.actor.master != null
                && eventActor.actor.type == ActorType.Monster
                && eventActor.actor.subType == (int)MonsterType.Summon) //1、召唤物出生并且有主人 2、尝试寻找出生的召唤物的主人是否是仇恨列表里的目标
            {
                for (int i = 0; i < _hates.Count; i++)
                {
                    HateDataBase hate = _hates[i];
                    //出生的召唤物主人存在于仇恨列表里
                    if (hate.insId == eventActor.actor.master.insID)
                    {
                        AddHate(eventActor.actor);
                        break;
                    }
                }
            }
            else //非召唤物
            {
                UpdateHates();
            }
        }

        protected override void OnDestroy()
        {
            _hates = null;
            _cacheHates = null;
        }
    }
}