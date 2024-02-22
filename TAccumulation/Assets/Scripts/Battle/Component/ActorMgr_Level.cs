using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using Random = UnityEngine.Random;

namespace X3Battle
{
    public partial class ActorMgr
    {
        private List<ActorGroup> _actorGroups;

        /// <summary> {timerId : ActivateInfo} 每个timerID对应的激活信息 </summary>
        private Dictionary<int, ActivateInfo> _timerActivateInfos = new Dictionary<int, ActivateInfo>(50);

        private List<SpawnPointConfig> _tempSpawnPointConfigs = new List<SpawnPointConfig>();

        private Action<int> _actionStartCreateGroupMonster;
        private Action<int, int> _actionTickCreateGroupMonster;
        private Action<int> _actionCompleteCreateGroupMonster;

        public void OnLevelStart()
        {
            _ForEach(_stageConfig.SpawnPoints, config => config.IsStart ? CreateMonster(config.ID) : null);
            _ForEach(_stageConfig.TriggerAreas, config => CreateTriggerArea(config.ID));
            _ForEach(_stageConfig.Obstacles, config => config.Active ? CreateObstacle(config.ID) : null);
            _ForEach(_stageConfig.Machines, config => CreateMachine(config.ID));
        }

        public void CreateStage()
        {
            var stagePointData = new StagePointData
            {
                ID = 0,
                ConfigID = 0,
                Position = Vector3.zero,
                Rotation = Vector3.zero
            };
            CreateActor(ActorType.Stage, stagePointData);
        }

        public void CreateHero()
        {
            _CreateHero(HeroType.Girl);
            _CreateHero(HeroType.Boy);
        }

        private void _CreateAllGroups()
        {
            foreach (var config in _stageConfig.SpawnPoints)
            {
                if (!_groupTypes.Contains(config.GroupType))
                {
                    continue;
                }
                _TryCreateGroup(config.GroupID);
            }
        }

        private void _ResetTimerSpawnPoint()
        {
            foreach (var kActivateInfo in _timerActivateInfos)
            {
                ObjectPoolUtility.ActivateInfoPool.Release(kActivateInfo.Value);
                Battle.Instance.battleTimer.Discard(kActivateInfo.Key);
            }

            _timerActivateInfos.Clear();
        }

        private ActorGroup _TryCreateGroup(int groupId)
        {
            var group = GetActorGroup(groupId);
            if (group == null)
            {
                group = ObjectPoolUtility.ActorGroupPool.Get();
                group.Init(this, groupId);
                _actorGroups.Add(group);
            }

            return group;
        }

        public Actor CreateMonster(int spawnPointID)
        {
            var spawnPoint = _GetElement(_stageConfig.SpawnPoints, spawnPointID);
            if (spawnPoint == null)
            {
                LogProxy.LogError($"刷怪点(ID = {spawnPointID}) 没有找到，请找策划");
                return null;
            }
            if (!_groupTypes.Contains(spawnPoint.GroupType))
            {
                return null;
            }
            return CreateActor(ActorType.Monster, spawnPoint);
        }

        public Actor CreateTriggerArea(int id)
        {
            var triggerArea = _GetElement(_stageConfig.TriggerAreas, id);
            if (triggerArea != null) return CreateActor(ActorType.TriggerArea, triggerArea);

            LogProxy.LogError($"区域触发器(ID = {id}) 没有找到，请找策划");
            return null;
        }

        public Actor CreateMachine(int id)
        {
            var machine = _GetElement(_stageConfig.Machines, id);
            if (machine != null) return !machine.IsDisplay ? null : CreateActor(ActorType.Machine, machine);

            LogProxy.LogError($"机关(ID = {id}) 没有找到，请找策划");
            return null;
        }

        public Actor CreateObstacle(int id)
        {
            var obstacle = _GetElement(_stageConfig.Obstacles, id);
            if (obstacle != null) return CreateActor(ActorType.Obstacle, obstacle);

            LogProxy.LogError($"碰撞体(ID = {id}) 没有找到，请找策划");
            return null;
        }
        
        /// <summary>
        /// 创建交互物
        /// </summary>
        /// <param name="interActorId"></param>
        /// <param name="coverInterActorId"></param>关卡编辑器中的InterActors的ID
        /// <returns></returns>
        public Actor CreateInterActor(int interActorId, int coverInterActorId = 0, string desc = "")
        {
            if (interActorId == 0)
            {
                return null;
            }

            var interActorCfgOne = _GetElement(_stageConfig.InterActors, interActorId);
            if (interActorCfgOne == null)
            {
                LogProxy.LogErrorFormat("请联系策划【一只喵】, 关卡编辑器interActorCfg配置获取失败, ID={0}", interActorId);
                return null;
            }

            InterActorCreateType createType = interActorCfgOne.CreateType;
            int monsterSpawnId = interActorCfgOne.MonsterSpawnId;
            int interActorComponentId = interActorCfgOne.ConfigID;
            
            var interActorCfgTwo = _GetElement(_stageConfig.InterActors, coverInterActorId);
            if (interActorCfgTwo != null)
            {
                createType = interActorCfgTwo.CreateType;
                monsterSpawnId = interActorCfgTwo.MonsterSpawnId;
                interActorComponentId = interActorCfgTwo.ConfigID;
            }

            ActorType actorType;
            PointBase pointCfg;
            //如果创建的是怪物交互物，直接创建怪物
            if (createType == InterActorCreateType.MonsterInterActor)
            {
                var pointConfig = _GetElement(_stageConfig.SpawnPoints, monsterSpawnId);
                if (pointConfig == null)
                {
                    LogProxy.LogError("创建怪物交互物的怪物刷新点为空 ID = " + monsterSpawnId);
                    return null;
                }

                pointConfig.Position = interActorCfgOne.Position;
                pointConfig.Rotation = interActorCfgOne.Rotation;
                pointCfg = pointConfig;
                actorType = ActorType.Monster;
            }
            else
            {
                pointCfg = interActorCfgOne;
                actorType = ActorType.InterActor;
            }

            var bornCfg = _CreateBornCfg<ActorBornCfg>(actorType, pointCfg);
            if (bornCfg is RoleBornCfg roleBornCfg)
            {
                roleBornCfg.interActorState = InterActorState.Not;
                roleBornCfg.InterActorDesc = desc;
                roleBornCfg.InterActorComponentId = interActorComponentId;
                roleBornCfg.InterActorId = interActorId;
            }

            return null == bornCfg ? null : CreateActor(actorType, bornCfg);
        }

        public void ActiveObstacle(int spawnID, bool active)
        {
            if (active)
            {
                var actor = GetActor(spawnID) ?? CreateObstacle(spawnID);
                if (null != actor)
                {
                    actor.obstacle.Enable(active);
                    actor.transform.SetVisible(active);
                }
            }
            else
            {
                RecycleActor(GetActor(spawnID));
            }
        }

        public void TransferActor(int spawnID, int pointID)
        {
            var actor = GetActor(spawnID);
            if (actor == null)
            {
                LogProxy.LogError($"配置错误, 不存在actor.spawnID={spawnID}的种植单位。");
                return;
            }

            TransferActor(actor, pointID);
        }

        public void TransferActor(Actor actor, int pointID)
        {
            if (actor == null)
            {
                LogProxy.LogError($"参数错误, 传递的actor为null。");
                return;
            }

            var point = _GetElement(stageConfig.Points, pointID);
            if (point == null)
            {
                LogProxy.LogError($"配置错误, 该关卡{this.battle.config.StageID}配置不存在PointConfig.ID={pointID}的点。");
                return;
            }

            actor.transform.SetPosition(point.Position, true);
            actor.transform.SetForward(Quaternion.Euler(point.Rotation) * Vector3.forward);
        }

        public void TransferGroup(int actorGroupID, int pointGroupId)
        {
            var group = GetActorGroup(actorGroupID);
            if (group == null)
            {
                return;
            }

            List<int> actorIds = group.actorIds;
            List<PointConfig> points = new List<PointConfig>();
            foreach (var point in _stageConfig.Points)
            {
                if (point.GroupID == pointGroupId)
                {
                    points.Add(point);
                }
            }

            if (actorIds.Count > points.Count)
            {
                return;
            }

            for (int i = 0; i < actorIds.Count; i++)
            {
                int actorId = actorIds[i];
                TransferActor(actorId, points[i].ID);
            }
        }

        /// <summary>
        /// 获取到所有满足条件的怪物
        /// </summary>
        /// <param name="groupId"></param> 当<= 0时会从所有group中取
        /// <param name="monsterTemplateId"></param> 当<= 0时会取所有的templateId
        /// <param name="monsterSpawnId">怪物的种植ID</param>
        /// <param name="mode"></param>
        /// <param name="outActors"></param> 满足条件的Actor列表，仅mode选alive时有效
        /// <returns></returns>
        public int GetMonstersByCondition(LevelMonsterMode mode, int groupId, int monsterTemplateId, int monsterSpawnId = -1, List<Actor> outActors = null)
        {
            int result = 0;
            if (mode == LevelMonsterMode.Alive)
                result = this.GetAliveCount(ActorType.Monster, groupId, monsterTemplateId, monsterSpawnId, outActors);
            else
                result = this.GetDeadCount(ActorType.Monster, groupId, monsterTemplateId, monsterSpawnId);

            return result;
        }

        public bool IsGroupAllDead(int groupID, ActorType? actorType = null)
        {
            var result = true;
            var list = _tempSpawnPointConfigs;
            GetSpawnPointConfigCount(groupID, list);
            foreach (var spawnPointConfig in list)
            {
                var actorInfo = battle.statistics.GetActorInfo(spawnPointConfig.ID);
                if (actorInfo == null || actorInfo.state == ActorInfo.State.Alive || actorInfo.deadCount <= 0)
                {
                    result = false;
                    break;
                }
            }

            list.Clear();
            return result;
        }

        public int GetAliveCount(ActorType actorType, int groupID, int templateID, int spawnID, List<Actor> outActors)
        {
            int result = 0;
            var list = ObjectPoolUtility.ActorInfoListPool.Get();
            battle.statistics.QueryActorInfos(outList: list, actorType: actorType, groupID: groupID, templateID: templateID, spawnID: spawnID, state: ActorInfo.State.Alive);
            foreach (ActorInfo actorInfo in list)
            {
                var actor = this.GetActor(actorInfo.spawnID);
                outActors?.Add(actor);
                result++;
            }

            ObjectPoolUtility.ActorInfoListPool.Release(list);
            return result;
        }

        public int GetSpawnPointConfigCount(int groupId, List<SpawnPointConfig> outList = null)
        {
            var count = 0;
            outList?.Clear();
            foreach (var spawnPoint in _stageConfig.SpawnPoints)
            {
                if (_groupTypes.Contains(spawnPoint.GroupType) && spawnPoint.GroupID == groupId)
                {
                    outList?.Add(spawnPoint);
                    count++;
                }
            }

            return count;
        }

        /// <summary>
        /// 通过Tag获取交互物配置.
        /// </summary>
        public int GetInterActorConfigCountByTag(RogueInterActorTag tag, List<InterActorPointConfig> outList = null)
        {
            var count = 0;
            outList?.Clear();
            foreach (var interActorConfig in _stageConfig.InterActors)
            {
                if (interActorConfig.Tag == (int)tag)
                {
                    outList?.Add(interActorConfig);
                    count++;
                }
            }

            return count;
        }

        /// <summary>
        /// 获取actorType的死亡数量.
        /// </summary>
        public int GetDeadCount(ActorType? actorType = null, int? groupID = null, int? templateID = null, int? spawnID = null,ActorInfo.State? state = ActorInfo.State.Dead)
        {
            var count = 0;
            var list = ObjectPoolUtility.ActorInfoListPool.Get();
            battle.statistics.QueryActorInfos(outList: list, actorType: actorType, groupID: groupID, templateID: templateID, spawnID: spawnID, state:state);
            foreach (var actorInfo in list)
            {
                count += actorInfo.deadCount;
            }

            ObjectPoolUtility.ActorInfoListPool.Release(list);
            return count;
        }

        /// <summary>
        /// 获取已被激活的个数
        /// </summary>
        public int GetActiveCount(ActorType? actorType = null, int? groupID = null, int? templateID = null, bool includeWaitingActive = false)
        {
            int result = 0;
            var list = ObjectPoolUtility.ActorInfoListPool.Get();

            // 统计活着的单位.
            battle.statistics.QueryActorInfos(outList: list, actorType: actorType, groupID: groupID, templateID: templateID, state: ActorInfo.State.Alive);
            result += list.Count;

            // 统计在激活列表里的单位.
            if (includeWaitingActive)
            {
                foreach (var kActivateInfo in _timerActivateInfos)
                {
                    var spawnPointConfigs = kActivateInfo.Value.spawnPointConfigs;
                    foreach (var spawnPointConfig in spawnPointConfigs)
                    {
                        var actorInfo = battle.statistics.GetActorInfo(spawnPointConfig.ID);
                        if (actorInfo == null || actorInfo.state == ActorInfo.State.None)
                        {
                            result += 1;
                        }
                    }
                }
            }

            ObjectPoolUtility.ActorInfoListPool.Release(list);
            return result;
        }

        public ActorGroup GetActorGroup(int groupID)
        {
            foreach (var curActorGroup in _actorGroups)
            {
                if (curActorGroup.id == groupID)
                {
                    return curActorGroup;
                }
            }

            return null;
        }

        public PointConfig GetPointConfig(int pointID)
        {
            return _GetElement(_stageConfig.Points, pointID);
        }

        public PointConfig GetBornPointConfig(HeroType heroType)
        {
            PointConfig point = null;
            foreach (var pointConfig in stageConfig.Points)
            {
                if (pointConfig.PointType != PointType.BornPoint)
                {
                    continue;
                }

                if ((pointConfig.RoleType != RoleType.Girl || heroType != HeroType.Girl) && (pointConfig.RoleType != RoleType.Boy || heroType != HeroType.Boy))
                {
                    continue;
                }

                point = pointConfig;
                break;
            }

            return point;
        }

        public TriggerAreaConfig GetTriggerAreaConfig(int id)
        {
            return _GetElement(_stageConfig.TriggerAreas, id);
        }

        /// <summary> 激活怪物 </summary>
        public void EnableActorsMove(bool enable)
        {
            for (var i = 0; i < _actors.Count; i++)
            {
                var actor = _actors[i];
                if (actor.model == null || null == actor.stateTag) continue;
                if (enable)
                {
                    actor.stateTag.ReleaseTag(ActorStateTagType.CannotMove);
                }
                else
                {
                    actor.stateTag.AcquireTag(ActorStateTagType.CannotMove);
                }
            }
        }

        #region 内部方法

        private Actor _CreateHero(HeroType type)
        {
            var point = GetBornPointConfig(type);
            if (point == null)
            {
                return null;
            }

            int cfgID;
            int suitID;
            switch (type)
            {
                case HeroType.Girl:
                    suitID = battle.arg.girlSuitID;
                    cfgID = battle.arg.girlID;
                    break;
                case HeroType.Boy:
                    suitID = battle.arg.boySuitID;
                    cfgID = battle.arg.boyID;
                    break;
                default:
                    LogProxy.LogError($"ActorMgr._CreateHero()  errorMsg:创建Hero异常，无此类型:{type}的英雄！！！");
                    return null;
            }

            point.ConfigID = cfgID;
            var bornConfig = _CreateBornCfg<RoleBornCfg>(ActorType.Hero, point);
            bornConfig.SuitID = suitID;
            bornConfig.IsPlayer = type == HeroType.Girl; // 女主为主控！！
            bornConfig.IsShowArrowIcon = type == HeroType.Boy; //男主需要显示指引图标
            return CreateActor(ActorType.Hero, bornConfig);
        }

        private T _GetElement<T>(T[] elements, int id) where T : RowBase
        {
            if (null == elements)
            {
                return null;
            }

            foreach (var t in elements)
            {
                if (t.ID == id)
                {
                    return t;
                }
            }

            return null;
        }

        private void _ForEach<T1, T2>(T1[] elements, Func<T1, T2> todo)
        {
            if (null == elements)
            {
                return;
            }

            foreach (var t in elements)
            {
                todo(t);
            }
        }

        private void _InsertToActorGroup(Actor actor)
        {
            using (ProfilerDefine.InsertToActorGroup.Auto())
            {
                var group = _TryCreateGroup(actor.groupId);
                group.InsertActorId(actor.insID);
            }
        }

        private void _RemoveFromActorGroup(Actor actor)
        {
            var group = GetActorGroup(actor.groupId);
            if (group == null)
            {
                LogProxy.LogError($"【_RemoveFromActorGroup】ActorGroup(ID = {actor.groupId}) 没有找到！！！");
                return;
            }

            group.RemoveActorId(actor.insID);
        }

        private void _DestroyAllGroup()
        {
            for (int i = _actorGroups.Count - 1; i >= 0; i--)
            {
                ObjectPoolUtility.ActorGroupPool.Release(_actorGroups[i]);
                _actorGroups.Remove(_actorGroups[i]);
            }
        }

        #endregion

        #region 计时器每隔x秒创建怪物逻辑.

        private void _StartCreateGroupMonster(int timerId)
        {
            _TickCreateGroupMonster(timerId, 0);
        }

        /// <summary>
        /// 按顺序生成怪物
        /// </summary>
        /// <param name="_"></param>
        private void _TickCreateGroupMonster(int timerId, int count)
        {
            if (_timerActivateInfos.TryGetValue(timerId, out var activateInfo))
            {
                var configs = activateInfo.spawnPointConfigs;
                if (count < configs.Count)
                {
                    this.CreateMonster(configs[count].ID);

                    // DONE: 每一只创建完时.
                    activateInfo.createCallback?.Invoke();

                    // DONE: 最后一只创建完时.
                    if (count >= configs.Count - 1)
                    {
                        activateInfo.allCreateCallback?.Invoke();
                    }
                }
            }
        }

        /// <summary>
        /// 计时器完成时, 将激活信息和计时器Id释放.
        /// </summary>
        /// <param name="timerId"></param>
        private void _CompleteCreateGroupMonster(int timerId)
        {
            if (_timerActivateInfos.TryGetValue(timerId, out var activateInfo))
            {
                ObjectPoolUtility.ActivateInfoPool.Release(activateInfo);
                _timerActivateInfos.Remove(timerId);
            }
        }

        /// <summary>
        /// 创建一组怪物(每隔x秒创建一个)
        /// </summary>
        /// <param name="intervals"></param> 生成间隔 必须>=0
        /// <param name="mode"></param> 生成模式
        /// <param name="num"></param> 生成数量 
        /// <param name="ignoreDead"></param> true: 无论如何都刷出来 flase: 死过的不再刷出来</param>
        public void CreateGroupMonstersAtIntervals(int groupID, float intervals, CreateGroupMonsterMode mode, int num, bool ignoreDead, Action createCallback = null, Action allCreateCallback = null)
        {
            if (intervals <= 0)
                intervals = 0f;
            ActivateInfo activateInfo = ObjectPoolUtility.ActivateInfoPool.Get();
            activateInfo.Init(createCallback, allCreateCallback);
            var configs = activateInfo.spawnPointConfigs;
            var list = _tempSpawnPointConfigs;
            this.GetSpawnPointConfigCount(groupID, list);
            if (mode == CreateGroupMonsterMode.Sequence)
            {
                // 初始化预种怪顺序列表
                list.Sort((a, b) => a.ID.CompareTo(b.ID)); // 根据ID从小到大排序
            }
            else
            {
                // 打乱列表.
                BattleUtil.ShuffleList(list, 0, list.Count - 1);
                // 按照 [小怪|Boss] 分割列表.
                _PartitionMonsterList(list);
            }

            _GenActiveList(num, list, configs, ignoreDead);
            list.Clear();
            if (configs.Count <= 0)
            {
                return;
            }

            int timerId = Battle.Instance.battleTimer.AddTimer(null, delay: 0.001f, tickInterval: intervals, repeatCount: configs.Count, funcStart: _actionStartCreateGroupMonster, funcTick: _actionTickCreateGroupMonster, funcComplete: _actionCompleteCreateGroupMonster);
            if (timerId <= 0)
            {
                LogProxy.LogError("[ActorGroup]创建timer失败");
                return;
            }

            _timerActivateInfos[timerId] = activateInfo;
        }

        /// <summary>
        /// 获取本次要激活的列表
        /// </summary>
        /// <param name="num"></param>
        /// <param name="spawnPoints"></param>
        /// <param name="outList"></param>
        /// <param name="ignoreDead"> true: 无论如何都刷出来 flase: 死过的不再刷出来</param>
        private void _GenActiveList(int num, List<SpawnPointConfig> spawnPoints, List<SpawnPointConfig> outList, bool ignoreDead = true)
        {
            for (int i = 0; i < spawnPoints.Count && outList.Count < num; i++)
            {
                var spawnPointConfig = spawnPoints[i];
                var actorInfo = battle.statistics.GetActorInfo(spawnPointConfig.ID);
                if (actorInfo != null)
                {
                    // 不处于池子的去掉.
                    if (actorInfo.state != ActorInfo.State.None)
                    {
                        continue;
                    }

                    // 如果只希望激活未被杀死过的怪
                    if (!ignoreDead && actorInfo.deadCount > 0)
                    {
                        continue;
                    }
                }

                // 是否处于激活列表中.
                bool isActivating = false;
                foreach (var kActivateInfo in _timerActivateInfos)
                {
                    var activateInfo = kActivateInfo.Value;
                    foreach (var activateInfoSpawnPointConfig in activateInfo.spawnPointConfigs)
                    {
                        if (activateInfoSpawnPointConfig.ID == spawnPointConfig.ID && _groupTypes.Contains(activateInfoSpawnPointConfig.GroupType) && activateInfoSpawnPointConfig.GroupID == spawnPointConfig.GroupID)
                        {
                            isActivating = true;
                            break;
                        }
                    }
                }

                if (isActivating)
                {
                    continue;
                }

                outList.Add(spawnPointConfig);
            }
        }

        /// <summary>
        /// 将SpawnPointList划分为两部分，前半部分是小怪，后半部分是Boss， 返回第一个Boss怪的下标
        /// </summary>
        /// <param name="monsterIDs"></param>
        /// <returns></returns>
        private int _PartitionMonsterList(List<SpawnPointConfig> monsterIDs)
        {
            int index = monsterIDs.Count; // 第一个Boss怪的下标
            int i = 0;
            while (i < index)
            {
                if (monsterIDs[i].HudIsTop)
                {
                    for (int j = index - 1; j >= i; j--)
                    {
                        index -= 1;
                        if (!monsterIDs[j].HudIsTop)
                        {
                            var temp = monsterIDs[i];
                            monsterIDs[i] = monsterIDs[j];
                            monsterIDs[j] = temp;
                            break;
                        }
                    }
                }

                i += 1;
            }

            return index;
        }

        #endregion
    }
}