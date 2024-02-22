using System;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

namespace X3Battle
{
    public class FriendHate : ActorHate
    {
        /// <summary>
        /// 获取主控的仇恨列表
        /// </summary>
        private List<HateDataBase> _playerHates => actor.battle.player.actorHate.hates;

        private Comparison<HateDataBase> _distanceComparison;
        private List<Actor> _cacheMonsters;
        private static readonly List<float> CacheStartAngles = new List<float>(9){-20, 20, 300, 60, 260, 100, 220, 140, 180};
        /// <summary>
        /// 缓存的仇恨列表
        /// </summary>
        private List<HateDataBase> _cacheAidHates;
        
        protected override void OnAwake()
        {
            base.OnAwake();
            _distanceComparison = _SortGirlDistance;
            _cacheMonsters = new List<Actor>(5);
            _cacheAidHates = new List<HateDataBase>(5);
            _isPlayerFriend = true;
            _updateHateCd = actor.boyCfg?.ChangeTargetCD > 0.1f ? actor.boyCfg.ChangeTargetCD : TbUtil.battleConsts.ChangeTargetCD;
            TbUtil.TryGetCfg(actor.boyCfg?.StrategyID ?? 0, out BattleManStrategy manStrategy);
            float[] upDistance;
            if (manStrategy == null)
            {
                _monsterTypePoints = TbUtil.battleConsts.HateMonsterTypePoint;
                _lockPoints = TbUtil.battleConsts.HateLockPoint;
                _cameraPoints = TbUtil.battleConsts.HateCameraPoint;
                upDistance = TbUtil.battleConsts.MaleUpDistance;
                _distancePoints = TbUtil.battleConsts.HateDistancePoint;
            }
            else
            {
                _monsterTypePoints = manStrategy.HateMonsterTypePoint;
                _lockPoints = manStrategy.HateLockPoint;
                _cameraPoints = manStrategy.HateCameraPoint;
                upDistance = manStrategy.UpDistance;
                _distancePoints = manStrategy.HateDistancePoint;
            }
            _upSqrDistance = new float[upDistance.Length];
            for (int i = 0; i < upDistance.Length; i++)
            {
                _upSqrDistance[i] = upDistance[i] * upDistance[i];
            }
        }
        
        protected override void OnStart()
        {
            battle.eventMgr.AddListener<ECEventDataBase>(EventType.UpdateFriendHate, _UpdateHate, "FriendHate._UpdateHate");
        }

        public override void OnBorn()
        {
            base.OnBorn();
            if (_hate != null)
            {
                _curUpdateHateTime = _updateHateCd;
            }
            else
            {
                SelectHate();
            }
        }

        //-------TODO 沧澜 原因：更方便的条件判断，更便捷的数据访问，与AI无关，与技能也无关，暂时考虑放在此处，后面考虑放在更合适的位置
        //-------AI 援护技能选点 开始 -----
        /// <summary>
        /// AI 镜头内选点
        /// </summary>
        /// <param name="minViewX">0~1</param>
        /// <param name="maxViewX">0~1</param>
        /// <param name="minViewY">0~1</param>
        /// <param name="maxViewY">0~1</param>
        /// <param name="minSkillDistance">最小施法距离</param>
        /// <param name="maxSkillDistance">技能施法最大距离</param>
        /// <param name="storedResult">男主原位置是否符合选点</param>
        /// <param name="storedFind">在result为false时有效，是否找到合适的点</param>
        /// <param name="storedTarget">男主目标</param>
        /// <param name="storedPoint">男主移动目标点</param>
        public void CalculateAidPoint(float minViewX, float maxViewX, float minViewY, float maxViewY, float minSkillDistance, float maxSkillDistance, out bool storedResult, out bool storedFind, out Actor storedTarget, out Vector3 storedPoint)
        {
            //返回参数初始化
            storedResult = false;
            storedFind = false;
            storedTarget = null;
            storedPoint = Vector3.zero;
            if (minViewX >= maxViewX || minViewY >= maxViewY)
            {
                PapeGames.X3.LogProxy.LogError(string.Format("ID：{0}角色的镜头内选点配置错误！请找AI负责人！", actor.insID));
                return;
            }
            Actor girl = actor.battle.player;
            
            _cacheAidHates.Clear();
            for (int i = 0; i < _playerHates.Count; i++)
            {
                PlayerHateData hate = _playerHates[i] as PlayerHateData;
                if (!hate.lockable || !hate.active) //可锁定并且已激活
                {
                    continue;
                }
                Actor monster = battle.actorMgr.GetActor(hate.insId);
                if (monster == null)
                {
                    continue;
                }
                hate.sqrGirlDistance = (girl.transform.position - monster.transform.position).sqrMagnitude;
                _cacheAidHates.Add(hate);
            }
            
            //按女主距离排序
            _cacheAidHates.Sort(_distanceComparison);
            //获得满足条件的角色列表
            _cacheMonsters.Clear();
            foreach (HateDataBase hate in _cacheAidHates)
            {
                Actor monster = Battle.Instance.actorMgr.GetActor(hate.insId);
                if (monster.actorHate.hateTarget != girl)
                {
                    continue;
                }
                _cacheMonsters.Add(monster);
            }

            //计算原男主位置是否满足选点规则
            foreach (Actor monster in _cacheMonsters)
            {
                float minSqrSkillDistance = (minSkillDistance + monster.radius) * (minSkillDistance + monster.radius);
                float maxSqrSkillDistance = (maxSkillDistance + monster.radius) * (maxSkillDistance + monster.radius);
                float sqrSkillDistance = (position - monster.transform.position).sqrMagnitude;
                if (sqrSkillDistance >= minSqrSkillDistance && sqrSkillDistance <= maxSqrSkillDistance)
                {
                    if (BattleUtil.GetPositionIsInViewByPosition(position, minViewX, maxViewX, minViewY, maxViewY))
                    {
                        storedResult = true;
                        storedTarget = monster;
                        storedPoint = position;
                        return;
                    }
                }
            }
            
            //计算满足选点规则的点
            float distance = Random.Range(minSkillDistance, maxSkillDistance);
            foreach (Actor monster in _cacheMonsters)
            {
                float radius = distance + monster.radius;
                Vector3 center = monster.transform.position;
                Vector3 startDir = position - center;
                foreach (float startAngle in CacheStartAngles)
                {
                    float curAngle = Random.Range(startAngle, startAngle + 40);
                    if (curAngle < 0)
                    {
                        curAngle = 360 - curAngle;
                    }
                    Vector3 realDir = Quaternion.AngleAxis(curAngle, Vector3.up) * startDir;
                    storedPoint = center + realDir.normalized * radius;
                    storedFind = BattleUtil.GetPositionIsInViewByPosition(storedPoint, minViewX, maxViewX, minViewY, maxViewY) 
                                 && BattleUtil.IsFindAirWall(center, realDir, radius);
                    if (storedFind)
                    {
                        storedTarget = monster;
                        return;
                    }
                }
            }
        }

        private int _SortGirlDistance(HateDataBase hate1, HateDataBase hate2)
        {
            PlayerHateData playerHate1 = hate1 as PlayerHateData;
            PlayerHateData playerHate2 = hate2 as PlayerHateData;
            if (playerHate1.sqrGirlDistance < playerHate2.sqrGirlDistance)
            {
                return -1;
            }
            else if (playerHate1.sqrGirlDistance > playerHate2.sqrGirlDistance)
            {
                return 1;
            }
            return 0;
        }
        
        //-------AI 援护技能选点 结束 -----
        
        /// <summary>
        /// 选择仇恨目标
        /// </summary>
        protected override void SelectHate()
        {
            if (actor.battle.player == null)
            {
                return;
            }
            _SelectRoleHate(_playerHates);
        }

        /// <summary>
        /// 尝试更新仇恨目标
        /// </summary>
        /// <param name="arg"></param>
        private void _UpdateHate(ECEventDataBase arg = null)
        {
            SelectHate();
        }

        protected override void OnDestroy()
        {
            _cacheMonsters.Clear();
            _cacheMonsters = null;
            battle.eventMgr.RemoveListener<ECEventDataBase>(EventType.UpdateFriendHate, _UpdateHate);
        }
    }
}