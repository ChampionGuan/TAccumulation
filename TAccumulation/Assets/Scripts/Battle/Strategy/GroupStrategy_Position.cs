using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public partial class GroupStrategy
    {
        private int _innerCircleMax;
        private float _innerRadius;
        private float _middleRadius;
        private float _outerRadius;
        private float _innerSqrRadius;
        private float _middleSqrRadius;
        private float _outerSqrRadius;
        private float _innerRandomDown;
        private float _innerRandomUp;
        private float _outerRandomDown;
        private float _outerRandomUp;
        private float _downInnerSectorRandomAngle;
        private float _upInnerSectorRandomAngle;
        private float _downOuterSectorRandomAngle;
        private float _upOuterSectorRandomAngle;
        private float _sectorMinAngle;
        private float _lockChangeAngle;
        
        private const float _randomRadiusRatio = 0.2f;
        private const float _randomAngleRatio = 0.2f;
        private int _rightOffset;
        private int _rightExtraOffset;
        private int _leftOffset;
        private int _leftExtraOffset;
        private StrategySector _rightMinRefStrategySector;
        private StrategySector _leftMinRefStrategySector;
        private const float _calculateMonstersMoveCd = 0.5f;
        private float _curCalculateMonstersMoveTime;
        private const float _ownerPosChangeSqrDistance = 1.5f;
        private Vector3 _ownerPos;
        
#if UNITY_EDITOR
        /// <summary>
        /// Actor属性面板使用
        /// </summary>
        public List<StrategySector> strategySectors => _strategySectors;
        public float innerRadius => _innerRadius;
        public float middleRadius => _middleRadius;
        public float outerRadius => _outerRadius;
#endif
        
        /// <summary>
        /// 添加扇形信息
        /// </summary>
        /// <param name="areaType"></param>
        /// <param name="index"></param>
        /// <param name="downAngle"></param>
        /// <param name="upAngle"></param>
        private void _AddStrategySector(StrategyAreaType areaType, int index, float downAngle, float upAngle)
        {
            StrategySector strategySector = ObjectPoolUtility.StrategySector.Get();
            strategySector.areaType = areaType;
            strategySector.index = index;
            strategySector.downAngle = downAngle;
            strategySector.upAngle = upAngle;
            strategySector.refCount = 0;
            _strategySectors.Add(strategySector);
        }
        
        /// <summary>
        /// 查找扇形
        /// </summary>
        /// <param name="actorStrategy"></param>
        /// <returns></returns>
        public StrategySector FindStrategySector(ActorStrategy actorStrategy)
        {
            foreach (StrategySector strategySector in _strategySectors)
            {
                if (strategySector.IsMatch(actorStrategy.targetAreaType, actorStrategy.sectorIndex))
                {
                    return strategySector;
                }
            }
            return null;
        }

        /// <summary>
        /// 获得角度所落区域的扇形
        /// </summary>
        /// <param name="areaType"></param>
        /// <param name="angle"></param>
        /// <returns></returns>
        private int _FindSectorIndexWithCheck(StrategyAreaType areaType, float angle)
        {
            for (int i = 0; i < _strategySectors.Count; i++)
            {
                StrategySector strategySector = _strategySectors[i];
                if (strategySector.Check(areaType, angle))
                {
                    return i;
                }
            }
            return 0;
        }
        
        /// <summary>
        /// 获得内圈引用计数总数
        /// </summary>
        /// <returns></returns>
        private int _GetInnerCircleRefCount()
        {
            int refCount = 0;
            foreach (StrategySector strategySector in _strategySectors)
            {
                if (strategySector.areaType == StrategyAreaType.InnerCircle)
                {
                    refCount += strategySector.refCount;
                }
            }

            foreach (ActorStrategy actorStrategy in _actorStrategys)
            {
                if (actorStrategy.state != StrategyState.Negative && actorStrategy.curAreaType == StrategyAreaType.InnerCircleIn)
                {
                    refCount++;
                }
            }
            return refCount;
        }
        
        /// <summary>
        /// 内圈是满的
        /// </summary>
        /// <returns></returns>
        private bool _InnerCircleIsFull()
        {
            return _GetInnerCircleRefCount() >= _innerCircleMax;
        }
        
        /// <summary>
        /// 内圈是超的
        /// </summary>
        /// <returns></returns>
        private bool _InnerCircleIsOverload()
        {
            return _GetInnerCircleRefCount() > _innerCircleMax;
        }

        /// <summary>
        /// 获得距离指定扇形附近最近的引用计数最小的扇形
        /// </summary>
        /// <param name="areaType"></param>
        /// <param name="strategyIndex"></param>
        /// <param name="oppositeIndex"></param>
        /// <returns></returns>
        private StrategySector _FindSectorWithMinRefByIndex(StrategyAreaType areaType, int strategyIndex, int oppositeIndex)
        {
            _rightMinRefStrategySector = _strategySectors[strategyIndex];
            _rightOffset = 0;
            _rightExtraOffset = 0;
            _leftMinRefStrategySector = _strategySectors[strategyIndex];
            _leftOffset = 0;
            _leftExtraOffset = 0;
            if (oppositeIndex < strategyIndex)
            {
                for (int i = strategyIndex - 1; i >= oppositeIndex; i--)
                {
                    _CalculateRightMinRefSector(i, areaType);
                }
                
                for (int i = strategyIndex + 1; i < _strategySectors.Count; i++)
                {
                    _CalculateLeftMinRefSector(i, areaType);
                }

                for (int i = 0; i < oppositeIndex; i++)
                {
                    _CalculateLeftMinRefSector(i, areaType);
                }
            }
            else
            {
                for (int i = strategyIndex - 1; i >= 0; i--)
                {
                    _CalculateRightMinRefSector(i, areaType);
                }

                for (int i = _strategySectors.Count - 1; i >= oppositeIndex; i--)
                {
                    _CalculateRightMinRefSector(i, areaType);
                }
                
                for (int i = strategyIndex + 1; i < oppositeIndex; i++)
                {
                    _CalculateLeftMinRefSector(i, areaType);
                }
            }
            _rightOffset -= _rightExtraOffset;
            _leftOffset -= _leftExtraOffset;
            return _CalculateMinRefSector();
        }

        /// <summary>
        /// 计算怪物右边引用计数最小的扇形
        /// </summary>
        /// <param name="strategyIndex"></param>
        /// <param name="areaType"></param>
        private void _CalculateRightMinRefSector(int strategyIndex, StrategyAreaType areaType)
        {
            StrategySector strategySector = _strategySectors[strategyIndex];
            if (strategySector.areaType != areaType)
            {
                return;
            }
            _rightOffset++;
            _rightExtraOffset++;
            if (!StrategyUtil.CheckAngle(strategySector.downAngle, strategySector.upAngle, owner.transform.position, areaType == StrategyAreaType.OuterCircle ? _outerRadius : _middleRadius))
            {
                return;
            }
            if (_rightMinRefStrategySector == null || strategySector.refCount < _rightMinRefStrategySector.refCount)
            {
                _rightMinRefStrategySector = strategySector;
                _rightExtraOffset = 0;
            }
        }

        /// <summary>
        /// 计算怪物左边引用计数最小的扇形
        /// </summary>
        /// <param name="strategyIndex"></param>
        /// <param name="areaType"></param>
        private void _CalculateLeftMinRefSector(int strategyIndex, StrategyAreaType areaType)
        {
            StrategySector strategySector = _strategySectors[strategyIndex];
            if (strategySector.areaType != areaType)
            {
                return;
            }
            _leftOffset++;
            _leftExtraOffset++;
            if (!StrategyUtil.CheckAngle(strategySector.downAngle, strategySector.upAngle, owner.transform.position, areaType == StrategyAreaType.OuterCircle ? _outerRadius : _middleRadius))
            {
                return;
            }
            if (_leftMinRefStrategySector == null || strategySector.refCount < _leftMinRefStrategySector.refCount)
            {
                _leftMinRefStrategySector = strategySector;
                _leftExtraOffset = 0;
            }
        }
        
        /// <summary>
        /// 计算最终最小引用计数的扇形
        /// </summary>
        /// <returns></returns>
        private StrategySector _CalculateMinRefSector()
        {
            StrategySector minRefStrategySector;
            if (_rightMinRefStrategySector == _leftMinRefStrategySector)
            {
                minRefStrategySector = _rightMinRefStrategySector;
            }
            else if(_rightMinRefStrategySector.refCount == _leftMinRefStrategySector.refCount)
            {
                minRefStrategySector = _leftOffset < _rightOffset ? _leftMinRefStrategySector : _rightMinRefStrategySector;
            }
            else if (_rightMinRefStrategySector.refCount < _leftMinRefStrategySector.refCount)
            {
                minRefStrategySector = _rightMinRefStrategySector;
            }
            else
            {
                minRefStrategySector = _leftMinRefStrategySector;
            }
            return minRefStrategySector;
        }

        private bool _CheckMovePos(ActorStrategy actorStrategy, Vector3 movePos)
        {
            return BattleUtil.IsInNavMesh(movePos) && !BattleUtil.IsFindAirWall(actorStrategy.owner.transform.position,
                movePos - actorStrategy.owner.transform.position,
                (movePos - actorStrategy.owner.transform.position).magnitude);
        }

        //计算怪物和目标的连线方向内引用计数最少的扇形区域内的移动目标点
        public bool CalculateMovePos(ActorStrategy actorStrategy, Vector3 dir)
        {
            StrategyAreaType areaType = actorStrategy.targetAreaType;
            if (actorStrategy.owner.locomotion != null && !actorStrategy.owner.locomotion.isMoveFinish && actorStrategy.lockOffset != Vector3.zero)
            {
                Vector3 monsterToMoveDir = actorStrategy.movePos - actorStrategy.owner.transform.position;
                Vector3 lastMonsterToLockDir = _ownerPos - actorStrategy.owner.transform.position;
                Vector3 monsterToLockDir = owner.transform.position - actorStrategy.owner.transform.position;
                if (StrategyUtil.IsTwoDirInSameArea(monsterToMoveDir, lastMonsterToLockDir, monsterToLockDir, _lockChangeAngle))
                {
                    Vector3 tempMovePos = owner.transform.position + actorStrategy.lockOffset;
                    if (_CheckMovePos(actorStrategy, tempMovePos))
                    {
                        actorStrategy.movePos = tempMovePos;
                        return true;
                    }
                }
            }
            float angle = StrategyUtil.CalculateAngleByDir(dir);
            float rightAngle = angle - 90;
            float leftAngle = angle + 90;
            StrategySector minRefStrategySector = null;
            bool isFind = false;
            int forwardIndex = -1;
            for (int i = 0; i < _strategySectors.Count; i++)
            {
                StrategySector strategySector = _strategySectors[i];
                if (strategySector.Check(areaType, angle))
                {
                    minRefStrategySector = strategySector;
                    if (strategySector.IsEmpty(areaType))
                    {
                        isFind = true;
                    }
                    else
                    {
                        forwardIndex = i;
                    }
                    break;
                }
            }

            if (minRefStrategySector == null)
            {
                PapeGames.X3.LogProxy.LogFormat("【群体策略】角度{0}所在的扇形未找到，请检查", angle);
                return false;
            }
            _rightMinRefStrategySector = minRefStrategySector;
            _rightOffset = 0;
            _rightExtraOffset = 0;
            _leftMinRefStrategySector = minRefStrategySector;
            _leftOffset = 0;
            _leftExtraOffset = 0;
            if (!isFind)
            {
                if (rightAngle < 0)
                {
                    rightAngle = rightAngle + 360;
                    int rightIndex = _FindSectorIndexWithCheck(areaType, rightAngle);
                    int maxIndex = _strategySectors.Count - 1;
                    int leftIndex = _FindSectorIndexWithCheck(areaType, leftAngle);
                    
                    for (int i = forwardIndex - 1; i >= 0; i--)
                    {
                        _CalculateRightMinRefSector(i, areaType);
                    }
                    for (int i = maxIndex; i >= rightIndex; i--)
                    {
                        _CalculateRightMinRefSector(i, areaType);
                    }
                    _rightOffset -= _rightExtraOffset;
                    
                    for (int i = forwardIndex + 1; i <= leftIndex; i++)
                    {
                        _CalculateLeftMinRefSector(i, areaType);
                    }
                    _leftOffset -= _leftExtraOffset;
                }
                else if (leftAngle > 360)
                {
                    leftAngle = leftAngle - 360;
                    int rightIndex = _FindSectorIndexWithCheck(areaType, rightAngle);
                    int maxIndex = _strategySectors.Count - 1;
                    int leftIndex = _FindSectorIndexWithCheck(areaType, leftAngle);
                    for (int i = forwardIndex - 1; i >= rightIndex; i--)
                    {
                        _CalculateRightMinRefSector(i, areaType);
                    }
                    _rightOffset -= _rightExtraOffset;
                    
                    for (int i = forwardIndex + 1; i <= maxIndex; i++)
                    {
                        _CalculateLeftMinRefSector(i, areaType);
                    }
                    for (int i = 0; i <= leftIndex; i++)
                    {
                        _CalculateLeftMinRefSector(i, areaType);
                    }
                    _leftOffset -= _leftExtraOffset;
                }
                else
                {
                    int rightIndex = _FindSectorIndexWithCheck(areaType, rightAngle);
                    int leftIndex = _FindSectorIndexWithCheck(areaType, leftAngle);
                    
                    for (int i = forwardIndex - 1; i >= rightIndex; i--)
                    {
                        _CalculateRightMinRefSector(i, areaType);
                    }
                    _rightOffset -= _rightExtraOffset;
                    
                    for (int i = forwardIndex + 1; i <= leftIndex; i++)
                    {
                        _CalculateLeftMinRefSector(i, areaType);
                    }
                    _leftOffset -= _leftExtraOffset;
                }
                minRefStrategySector = _CalculateMinRefSector();
            }
            else
            {
                if (rightAngle < 0)
                {
                    rightAngle = rightAngle + 360;
                }
                else if (leftAngle > 360)
                {
                    leftAngle = leftAngle - 360;
                }
            }

            float downAngle = rightAngle > minRefStrategySector.downAngle && rightAngle < minRefStrategySector.upAngle ? rightAngle : minRefStrategySector.downAngle;
            float upAngle = leftAngle > minRefStrategySector.downAngle && leftAngle < minRefStrategySector.upAngle ? leftAngle : minRefStrategySector.upAngle;
            float randomAngleOffset = (upAngle - downAngle) * _randomAngleRatio;
            float realAngle = Random.Range(downAngle + randomAngleOffset, upAngle - randomAngleOffset);
            Vector3 realDir = Quaternion.AngleAxis(realAngle, Vector3.up) * Vector3.forward;
            float realDistance = GetRandomRadius(areaType);
            Vector3 calculateLockOffset = realDistance * realDir;
            Vector3 calculateMovePos = owner.transform.position + calculateLockOffset;
            if (!_CheckMovePos(actorStrategy, calculateMovePos))
            {
                return false;
            }
            actorStrategy.lockOffset = calculateLockOffset;
            actorStrategy.movePos = calculateMovePos;
            actorStrategy.sectorIndex = minRefStrategySector.index;
            minRefStrategySector.PlusRefCount();
            return true;
        }
        
        /// <summary>
        /// 获得随机的半径
        /// </summary>
        /// <param name="areaType"></param>
        /// <returns></returns>
        public float GetRandomRadius(StrategyAreaType areaType)
        {
            return areaType == StrategyAreaType.InnerCircle ? Random.Range(_innerRandomDown, _innerRandomUp) : Random.Range(_outerRandomDown, _outerRandomUp);
        }
        
        /// <summary>
        /// 获得随机的角度
        /// </summary>
        /// <param name="strategySector"></param>
        /// <returns></returns>
        private float _GetRandomAngle(StrategySector strategySector)
        {
            float randomAngleOffset = (strategySector.upAngle - strategySector.downAngle) * _randomAngleRatio;
            float randomAngle = Random.Range(strategySector.downAngle + randomAngleOffset, strategySector.upAngle - randomAngleOffset);
            return randomAngle;
        }
        
        /// <summary>
        /// 添加扇形
        /// </summary>
        /// <param name="areaType"></param>
        /// <param name="index"></param>
        /// <param name="angleCursor"></param>
        private void _AddStrategySectors(StrategyAreaType areaType, int index, float angleCursor)
        {
            float remainAngle = 360 - angleCursor;
            float upSectorRandomAngle = areaType == StrategyAreaType.InnerCircle ? _upInnerSectorRandomAngle : _upOuterSectorRandomAngle;
            if (remainAngle <= upSectorRandomAngle)
            {
                _AddStrategySector(areaType, index, angleCursor, angleCursor + remainAngle);
                return;
            }
            float downSectorRandomAngle = areaType == StrategyAreaType.InnerCircle ? _downInnerSectorRandomAngle : _downOuterSectorRandomAngle;
            float randomAngle = Random.Range(downSectorRandomAngle, upSectorRandomAngle);
            float newAngleCursor = angleCursor + randomAngle;
            if (360 - newAngleCursor < _sectorMinAngle)
            {
                newAngleCursor = 360;
                _AddStrategySector(areaType, index++, angleCursor, newAngleCursor);
                return;
            }
            _AddStrategySector(areaType, index++, angleCursor, newAngleCursor);
            _AddStrategySectors(areaType, index, newAngleCursor);
        }

        private void _PlusSectorRefCountByIndex(ActorStrategy actorStrategy)
        {
            foreach (StrategySector strategySector in _strategySectors)
            {
                if (strategySector.areaType == actorStrategy.targetAreaType && strategySector.index == actorStrategy.sectorIndex)
                {
                    strategySector.PlusRefCount();
                    break;
                }
            }
        }
        
        private StrategySector _FindStrategySectorByPos(ActorStrategy actorStrategy, Vector3 monsterPos)
        {
            Vector3 lockToMonsterPosDir = monsterPos - owner.transform.position;
            float angle = StrategyUtil.CalculateAngleByDir(lockToMonsterPosDir);
            foreach (StrategySector strategySector in _strategySectors)
            {
                if (strategySector.Check(actorStrategy.targetAreaType, angle))
                {
                    return strategySector;
                }
            }
            return null;
        }
        
        public void PlusSectorRefCountByPos(ActorStrategy actorStrategy, Vector3 monsterPos)
        {
            StrategySector strategySector = _FindStrategySectorByPos(actorStrategy, monsterPos);
            if (strategySector != null)
            {
                actorStrategy.sectorIndex = strategySector.index;
                strategySector.PlusRefCount();
            }
        }

        private bool _IsMove(ActorStrategy actorStrategy)
        {
            return actorStrategy.IsRunOrWalk() || actorStrategy.IsBack() ||
                   actorStrategy.IsWander() && _IsCorrectWander(actorStrategy);
        }

        private bool _IsCorrectWander(ActorStrategy actorStrategy)
        {
            StrategySector curStrategySector = FindStrategySector(actorStrategy);
            if (curStrategySector == null)
            {
                return false;
            }
            StrategySector strategySector = _FindStrategySectorByPos(actorStrategy, actorStrategy.owner.transform.position);
            if (curStrategySector == strategySector)
            {
                return true;
            }
            if(actorStrategy.owner.locomotion != null)
            {
                Vector3 lockToMonsterDir = actorStrategy.owner.transform.position - owner.transform.position;
                float angle = StrategyUtil.CalculateAngleByDir(lockToMonsterDir);
                float randomAngle = (curStrategySector.downAngle + curStrategySector.upAngle) * 0.5f;
                string animName = angle > randomAngle && angle - randomAngle < 180 || angle < randomAngle && randomAngle - angle > 180 ? MoveWanderAnimName.Right : MoveWanderAnimName.Left;
                if (animName == actorStrategy.owner.locomotion.moveAnim)
                {
                    return true;
                }
                actorStrategy.owner.commander?.ClearMoveCmd();
                PapeGames.X3.LogProxy.Log($"【Strategy】ClearToIdle:NotCorrectWander:{actorStrategy.owner.insID}|{actorStrategy.groupStrategy.owner.insID}");
            }
            return false;
        }

        /// <summary>
        /// 计算消极状态怪物区域、扇形Index、移动点、站位
        /// </summary>
        private void _CalculateStrategy()
        {
            //---区域划分---
            foreach (StrategySector strategySector in _strategySectors)
            {
                strategySector.ClearRefCount();
            }

            //---计算区域类型、扇形下标、距离锁定目标距离---
            foreach (ActorStrategy actorStrategy in _actorStrategys)
            {
                if (!actorStrategy.isStrategy)
                {
                    continue;
                }
                Vector3 monsterPos = actorStrategy.GetMonsterPos(actorStrategy.areaType == StrategyAreaType.InnerCircle ? _middleSqrRadius : _outerSqrRadius);
                actorStrategy.sqrDistance = (monsterPos - owner.transform.position).sqrMagnitude;
                if (actorStrategy.sqrDistance < _innerSqrRadius)
                {
                    actorStrategy.curAreaType = StrategyAreaType.InnerCircleIn;
                }
                else if (actorStrategy.sqrDistance < _middleSqrRadius)
                {
                    actorStrategy.curAreaType = StrategyAreaType.InnerCircle;
                }
                else if (actorStrategy.sqrDistance < _outerSqrRadius)
                {
                    actorStrategy.curAreaType = StrategyAreaType.OuterCircle;
                }
                else
                {
                    actorStrategy.curAreaType = StrategyAreaType.OuterCircleOut;
                }

                if (actorStrategy.state == StrategyState.Negative && actorStrategy.sectorIndex >= 0 && _IsMove(actorStrategy))//处于消极态，处于移动、后退、左右徘徊，存在目标扇形
                {
                    if (actorStrategy.IsBack())
                    {
                        actorStrategy.ExecuteBack(actorStrategy.targetAreaType);
                    }
                    else
                    {
                        _PlusSectorRefCountByIndex(actorStrategy);
                    }
                }
                else
                {
                    if (actorStrategy.curAreaType == actorStrategy.areaType || actorStrategy.curAreaType == StrategyAreaType.OuterCircle)//区域正确或者近程怪在外圈
                    {
                        actorStrategy.targetAreaType = actorStrategy.curAreaType;
                        PlusSectorRefCountByPos(actorStrategy, monsterPos);
                    }
                    else
                    {
                        actorStrategy.targetAreaType = actorStrategy.areaType;
                        actorStrategy.sectorIndex = -1;
                    }
                }
            }

            _actorStrategys.Sort(_actorStrategyComparisonByDistance);
            
            //---计算后退、左右徘徊
            for (int i = 0; i < _actorStrategys.Count; i++)
            {
                ActorStrategy actorStrategy = _actorStrategys[i];
                if (!actorStrategy.strategyIsWork || _IsMove(actorStrategy))
                {
                    continue;
                }
                actorStrategy.isWander = false;
                if (actorStrategy.curAreaType == actorStrategy.areaType)//区域正确
                {
                    StrategySector strategySector = FindStrategySector(actorStrategy);
                    if (strategySector == null)
                    {
                        PapeGames.X3.LogProxy.LogError($"【Strategy】Sector:NotFind|{actorStrategy.owner.insID}|{owner.insID}");
                        continue;
                    }
                    if (_InnerCircleIsOverload() && actorStrategy.curAreaType == StrategyAreaType.InnerCircle)
                    {
                        actorStrategy.ExecuteBack(StrategyAreaType.OuterCircle);
                        strategySector?.MinusRefCount();
                    }
                    else
                    {
                        if (strategySector.refCount > 1)
                        {
                            //获得距离最近的空闲扇形
                            StrategySector minRefStrategySector;
                            Vector3 lockToMonsterDir = actorStrategy.owner.transform.position - owner.transform.position;
                            float angle = StrategyUtil.CalculateAngleByDir(lockToMonsterDir);
                            float oppositeAngle = angle - 180;
                            if (oppositeAngle < 0)
                            {
                                oppositeAngle += 360;
                            }
                            int oppositeIndex = _FindSectorIndexWithCheck(actorStrategy.targetAreaType, oppositeAngle);
                            minRefStrategySector = _FindSectorWithMinRefByIndex(actorStrategy.targetAreaType, _strategySectors.IndexOf(strategySector), oppositeIndex);

                            if (strategySector == minRefStrategySector)//当前扇形就是引用计数最小的
                            {
                                actorStrategy.TryExecuteIdle(_randomAngleRatio);
                            }
                            else
                            {
                                float randomAngle = _GetRandomAngle(minRefStrategySector);
                                float angleOffset = Mathf.Abs(randomAngle - angle);
                                if (angleOffset > 180)
                                {
                                    angleOffset = 360 - angleOffset;
                                }
                                actorStrategy.sectorIndex = minRefStrategySector.index;
                                minRefStrategySector.PlusRefCount();
                                strategySector?.MinusRefCount();

                                string animName = angle > randomAngle && angle - randomAngle < 180 || angle < randomAngle && randomAngle - angle > 180 ? MoveWanderAnimName.Right : MoveWanderAnimName.Left;
                                ActorMoveDirCmd cmd = ObjectPoolUtility.GetActorCmd<ActorMoveDirCmd>();
                                cmd.Init(owner.insID, MoveType.Wander, animName, float.MaxValue, angleOffset);
                                actorStrategy.owner.commander.TryExecute(cmd);
                                PapeGames.X3.LogProxy.Log($"【Strategy】MoveDir:Wander:{animName}|{actorStrategy.owner.insID}|{owner.insID}");
                            }
                        }
                        else
                        {
                            actorStrategy.TryExecuteIdle(_randomAngleRatio);
                        }
                    }
                }
                else//区域不正确
                {
                    if (actorStrategy.areaType == StrategyAreaType.InnerCircle)//需要去内圈
                    {
                        if (_InnerCircleIsFull())//内圈满了
                        {
                            if (actorStrategy.curAreaType == StrategyAreaType.InnerCircleIn)//内圈内
                            {
                                actorStrategy.ExecuteBack(StrategyAreaType.OuterCircle);
                            }
                            else if (actorStrategy.curAreaType == StrategyAreaType.OuterCircle) //外圈
                            {
                                actorStrategy.TryExecuteIdle(_randomAngleRatio);
                            }
                        }
                        else//内圈未满
                        {
                            if (actorStrategy.curAreaType == StrategyAreaType.InnerCircleIn)//内圈内
                            {
                                actorStrategy.ExecuteBack(StrategyAreaType.InnerCircle);
                            }
                        }
                    }
                    else//需要去外圈
                    {
                        if (actorStrategy.curAreaType != StrategyAreaType.OuterCircleOut)//内圈内、内圈
                        {
                            actorStrategy.ExecuteBack(StrategyAreaType.OuterCircle);
                        }
                    }
                }

                if (!actorStrategy.isWander)
                {
                    actorStrategy.ResetWander();
                }
            }
            
            //---计算追逐---
            for (int i = _actorStrategys.Count - 1; i >= 0; i--)
            {
                ActorStrategy actorStrategy = _actorStrategys[i];
                if (!actorStrategy.strategyIsWork)
                {
                    continue;
                }
                if (actorStrategy.curAreaType != actorStrategy.areaType)//区域不正确
                {
                    if (actorStrategy.areaType == StrategyAreaType.InnerCircle)//需要去内圈
                    {
                        if (_InnerCircleIsFull())//内圈满了
                        {
                            if (actorStrategy.curAreaType == StrategyAreaType.OuterCircleOut) //外圈外
                            {
                                actorStrategy.TryExecuteMove(StrategyAreaType.OuterCircle);
                            }
                        }
                        else//内圈未满
                        {
                            if (actorStrategy.curAreaType != StrategyAreaType.InnerCircleIn)//外圈外、外圈
                            {
                                actorStrategy.TryExecuteMove(StrategyAreaType.InnerCircle);
                            }
                        }
                    }
                    else//需要去外圈
                    {
                        if (actorStrategy.curAreaType == StrategyAreaType.OuterCircleOut)//外圈外
                        {
                            actorStrategy.TryExecuteMove(StrategyAreaType.OuterCircle);
                        }
                    }
                }
            }
            
            _curCalculateMonstersMoveTime = _calculateMonstersMoveCd;
            _ownerPos = owner.transform.position;
        }

        /// <summary>
        /// 按照距离排序
        /// </summary>
        /// <param name="actorStrategy1"></param>
        /// <param name="actorStrategy2"></param>
        /// <returns></returns>
        private int _SortActorStrategyByDistance(ActorStrategy actorStrategy1, ActorStrategy actorStrategy2)
        {
            if (actorStrategy1.sqrDistance > actorStrategy2.sqrDistance)
            {
                return -1;
            }
            if (actorStrategy1.sqrDistance < actorStrategy2.sqrDistance)
            {
                return 1;
            }

            return 0;
        }
    }
}