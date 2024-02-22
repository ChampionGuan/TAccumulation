using System;
using System.Collections.Generic;
using FlowCanvas.Nodes;
using Framework;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle.TargetSelect
{
    public static class TargetSelectUtil
    {
        private static List<EnemyItem> _sEnemyItems = new List<EnemyItem>();
        private static List<EnemyItem> _minEnemyItems = new List<EnemyItem>();
        private static List<EnemyItem> _middleEnemyItems = new List<EnemyItem>();
        private static List<EnemyItem> _maxEnemyItems = new List<EnemyItem>();
        private static List<Actor> _EnemyActors = new List<Actor>();
        
#if UNITY_EDITOR
        private static Vector3 _lastSmartModelDir;
        private static Vector3 _lastActorPos;

        public static Vector3 lastSmartModelDir => _lastSmartModelDir;
        public static Vector3 lastActorPos => _lastActorPos;
#endif
        
        public static void ClearCache()
        {
            _sEnemyItems.Clear();
            _minEnemyItems.Clear();
            _middleEnemyItems.Clear();
            _maxEnemyItems.Clear();
            _EnemyActors.Clear();
        }
        
        /// <summary>
        /// 当前锁定范围内是否有可锁定的目标
        /// </summary>
        public static bool HasTargetInLockRange(TargetSelector logicSelector, List<Actor> refTargetList)
        {
            if (refTargetList != null)
            {
                refTargetList.Clear();
            }

            var count = 0;
            float maxRadius = TbUtil.battleConsts.MaxRadius;
            
            // DONE: 将MaxRadius范围内的目标加入候选列表, 不需要排序.
            _GetEnemys(logicSelector.actor, maxRadius, maxRadius, maxRadius, true, false, false, false);
            if (_minEnemyItems != null)
            {
                foreach (var enemyItem in _minEnemyItems)
                {
                    refTargetList?.Add(enemyItem.actor);
                    count ++;
                }    
            }

            return count > 0;
        }

        /// <summary>
        /// 排序范围内可锁定的目标列表
        /// 排序规则:
        /// [ 
        ///     相机内-距离当前锁定目标较近
        ///     相机内-距离当前锁定目标较远
        ///     相机外-距离当前锁定目标较近
        ///     相机外-距离当前锁定目标较远
        ///     当前锁定目标
        /// ]
        /// </summary>
        /// <param name="list"> 范围内可锁定的目标列表 </param>
        /// <param name="curLockTarget"> 当前锁定目标 </param>
        public static void SortLockCache(List<Actor> list, Actor curLockTarget)
        {
            foreach (var item in _sEnemyItems)
            {
                ObjectPoolUtility.EnemyItem.Release(item);    
            }
            _sEnemyItems.Clear();
            var transform = curLockTarget.GetDummy();
            var actors = list;
            var selfPos = transform.position;
            foreach (var targetActor in actors)
            {
                if (targetActor.IsRole() && !targetActor.stateTag.IsActive(ActorStateTagType.LockIgnore) &&
                    !targetActor.isDead && curLockTarget != targetActor && curLockTarget.GetFactionRelationShip(targetActor) == FactionRelationship.Enemy && (targetActor.aiOwner?.isActive ?? true))
                {
                    var targetPos = targetActor.transform.position;
                    var delta = targetPos - selfPos;
                    var magnitude = delta.magnitude;
                    var inSight = Battle.Instance.cameraTrace.IsInSight(targetActor);
                    
                    // DONE: 辅助排序.
                    var enemyItem = ObjectPoolUtility.EnemyItem.Get();
                    enemyItem.actor = targetActor;
                    enemyItem.distance = magnitude;
                    enemyItem.newDistance =
                        GetNewDistance(targetActor.GetSelectRadius(), magnitude);
                    enemyItem.inSight = inSight;
                    _sEnemyItems.Add(enemyItem);
                }
            }
            
            _sEnemyItems.Sort((a, b) =>
            {
                if (a.inSight != b.inSight)
                    return a.inSight == true ? -1 : 1;
                return (int) (a.distance - b.distance);
            });

            list.Add(curLockTarget);
            foreach (var enemyItem in _sEnemyItems)
            {
                list.Add(enemyItem.actor);
            }
        }

        /// <summary>
        /// 普通技能选敌规则
        /// </summary>
        /// <param name="targetSelector"></param>
        /// <param name="considerSmart">是否启用智能选点逻辑</param>
        /// <param name="fromSmart">目标是否由智能选点筛选出来</param>
        /// <returns></returns>
        public static Actor CommonSkillSelect(TargetSelector targetSelector, bool considerSmart, out bool fromSmart)
        {
            fromSmart = false;
            var curTarget = targetSelector.actor.GetTarget();
            //优先选择虚弱目标
            Actor target = TargetSelectUtil.CommonSkillSelectWeak(targetSelector);
            if (target != null)
            {
                LogProxy.LogFormat("【目标】 索敌规则：其它技能 搜索到虚弱目标 = " + target.name);
            }
            // 没有搜索到虚弱目标 
            if (target == null)
            {
                // 当前目标为空 或者 当前目标不为虚弱目标 
                if (curTarget == null || !curTarget.actorWeak.weak)
                {
                    // 直接走普通搜索逻辑
                    if (considerSmart)
                    {
                        target = TargetSelectUtil.CalculateSmartModeTarget(targetSelector);
                        fromSmart = true;
                    }
                    else
                    {
                        // 如果不考虑普通搜索，就直接用当前目标避免切换
                        target = curTarget;
                    }
                }
                else
                {
                    target = curTarget;
                    LogProxy.LogFormat("【目标】 索敌规则：当前目标为虚弱目标 不走普通搜索流程 并且目标 =  " + curTarget.name);
                }
            }
            else if (curTarget != null)
            {
                // 当前目标也为虚弱目标 
                if (curTarget.actorWeak.weak)
                {
                    var radius = GetActorRadius(targetSelector.actor);
                    target = ChangeTargetByRadiusAndCam(targetSelector.actor, target, radius);
                }
            }

            return target;
        }
        
        /// <summary>
        /// 共鸣技能选敌规则
        /// </summary>
        /// <param name="targetSelector"></param>
        /// <param name="considerSmart">是否启用智能选点逻辑</param>
        /// <param name="fromSmart">目标是否由智能选点筛选出来</param>
        /// <returns></returns>
        public static Actor CoopSkillSelect(TargetSelector targetSelector, bool considerSmart, out bool fromSmart)
        {
            fromSmart = false;
            var curTarget = targetSelector.actor.GetTarget();
            //优先选择目标
            Actor target = TargetSelectUtil.CoopSkillSelectWeak(targetSelector);
            if (target != null)
            {
                LogProxy.LogFormat("【目标】 索敌规则：共鸣技能 搜索到目标 = " + target.name);
            }
            //没有搜索到目标 
            if (target == null)
            {
                //当前目标为空 或者 当前目标不为虚弱并且没有芯核
                if (curTarget == null || (!curTarget.actorWeak.weak
                                          && !curTarget.actorWeak.IsHaveCore()))
                {
                    if (considerSmart)
                    {
                        //直接走普通搜索逻辑
                        target = TargetSelectUtil.CalculateSmartModeTarget(targetSelector);
                        fromSmart = true;
                    }
                    else
                    {
                        // 如果不考虑普通搜索，就直接用当前目标避免切换
                        target = curTarget;
                    }
                }
                else
                {
                    target = curTarget;
                    LogProxy.LogFormat("【目标】 索敌规则：当前目标为高优先级目标 不走普通搜索流程 并且目标 =  " + curTarget.name);
                }
            }
            //搜索到虚弱目标 并且当前目标不为空
            else if(curTarget != null)
            {
                //当前目标和搜索目标都为芯核目标 走目标切换流程
                if (curTarget.actorWeak.IsHaveCore() && target.actorWeak.IsHaveCore())
                {
                    target = ChangeTargetByRadiusAndCam(targetSelector.actor, target, TbUtil.battleConsts.CoopSkillSelectRadius);
                }
                
                //当前目标和搜索目标都为虚弱目标 走目标切换流程
                if (curTarget.actorWeak.weak &&
                    target.actorWeak.weak)
                {
                    target = ChangeTargetByRadiusAndCam(targetSelector.actor, target, TbUtil.battleConsts.CoopSkillSelectRadius);
                }
            }

            // 释放共鸣技时，如果女主当前没有目标，且选敌逻辑也没有选到任何一个目标，但此时男主当前的目标在镜头范围内，就以男主目标作为共鸣技释放目标作为保底，避免把正在攻击的男主拉到附近空放技能。
            if (target == null)
            {
                var boy = targetSelector.actor.battle.actorMgr.boy;
                if (boy != null)
                {
                    var boyTarget = boy.targetSelector.GetTarget();
                    if (boyTarget != null && Battle.Instance.cameraTrace.IsInSight(boyTarget))
                    {
                        target = boyTarget;
                        LogProxy.LogFormat("【目标】 索敌规则：共鸣技女主没找到目标，男主目标在视野内，用它保底。切换前：{0}, 切换后{1}" ,curTarget == null? "empty" : curTarget.name, target.name);
                    }
                }
            }
            return target;
        }

        /// <summary>
        /// 根据配置半径  是否在镜头内   是否满足角度切换流程
        /// 切换目标
        /// </summary>
        /// <param name="actor"></param>
        /// selectTarget == 搜索到的目标
        /// curTarget == 当前目标
        /// <returns></returns>
        public static Actor ChangeTargetByRadiusAndCam(Actor actor,Actor selectTarget, float radius)
        {
            var curTarget = actor.GetTarget();
            if (curTarget == null || selectTarget == null)
            {
                return null;
            }
            //当前目标在射程并且在镜头内
            if (IsRadiusAndCam(curTarget, radius))
            {
                //判断切换角度 需不需要切换目标
                if (IsChangeTarget(actor))
                {
                    LogProxy.LogFormat("【目标】 索敌规则：其它技能 切换虚弱目标 切换前 = " + curTarget.name + "切换后 = " + selectTarget.name);
                    return selectTarget;
                }
                else
                {
                    return curTarget;
                }
            }
            else
            {
                LogProxy.LogFormat("【目标】 索敌规则：其它技能 切换虚弱目标 切换前 = " + curTarget.name + "切换后 = " + selectTarget.name);
                //当前目标不在射程 或者不在镜头内 直接切换目标
                return selectTarget;
            }
        }
        /// <summary>
        /// 获取单位切换目标所需夹角 区分远程近战
        /// </summary>
        /// <returns></returns>
        public static int GetActorSelectAngle(Actor actor)
        {
            if (actor == null)
            {
                return 0;
            }

            if (actor.weapon != null && actor.weapon.weaponLogicCfg != null)
            {
                if (actor.weapon.weaponLogicCfg.LockRangeType == (int) LockRangeType.Melee)
                {
                    return TbUtil.battleConsts.MeleeChangeTargetAngle;
                }
                else
                {
                    return TbUtil.battleConsts.RemoteChangeTargetAngle;
                }
            }
            
            return 0;
        }

        /// <summary>
        /// 设置普通搜索的方向和位置
        /// </summary>
        /// <param name="dir"></param>
        /// <param name="pos"></param>
        private static void _SetSmartModelDirInput(Vector3 dir, Vector3 pos)
        {
#if UNITY_EDITOR
            _lastSmartModelDir = dir;
            _lastActorPos = pos;
#endif
        }
        
        public static Actor CalculateSmartModeTarget(TargetSelector logicSelector)
        {
            Actor target = null;
            var curTarget = logicSelector.GetTarget();
            var actor = logicSelector.actor;
            var hasInputDir = actor.HasDirInput();
            
            if (hasInputDir)
            {
                _SetSmartModelDirInput(actor.GetDestDir(), actor.transform.position);
            }

            LogProxy.LogFormat("【普通索敌流程】1：普通索敌流程开始 搜索者name = " + logicSelector.actor.name + " 当前锁定目标name = " +
                               curTarget?.name + " 当前有无摇杆输入 = " + hasInputDir);

            if (!hasInputDir && curTarget != null)
            {
                LogProxy.LogFormat("【普通索敌流程】2：当前有目标 无摇杆输入 不进行搜索 不切换目标");
            }
            
            if (curTarget != null)
            {
                // 当前有锁定目标走切换逻辑分支
                var isUpdateTarget = false;
                if (hasInputDir)
                {
                    var destDir = actor.GetDestDir();
                    var targetPosition = curTarget.transform.position;
                    var actorPosition = actor.transform.position;
                    var targetDir = targetPosition - actorPosition;
                    var angle = Vector3.Angle(targetDir, destDir);
                    var radius = GetActorRadius(actor);
                    if (IsRadiusAndCam(actor, radius))
                    {
                        // 角度大于目标角度
                        var changeAngle = GetActorSelectAngle(logicSelector.actor);
                        if (angle >= changeAngle)
                        {
                            isUpdateTarget = true;
                        }
                        else
                        {
                            LogProxy.Log("【普通索敌流程】1: 本次选择 输入方向角度 = " +angle + " 小于目标切换角度 = " + changeAngle + " 不切换目标");
                        }
                    }
                    else
                    {
                        //当前目标不在射程内 或者 不在镜头内
                        isUpdateTarget = true;
                    }
                }
                else
                {
                    isUpdateTarget = true;
                }

                if (isUpdateTarget)
                {
                    // 走切换锁定单位逻辑
                    LogProxy.LogFormat("【普通索敌流程】2：走切换锁定单位逻辑 搜索者name = " + logicSelector.actor.name + " 当前锁定目标name = " + curTarget?.name + " 当前有无摇杆输入 = " + hasInputDir);
                    
                    target = GetSmartModeTarget(logicSelector, hasInputDir, hasInputDir);
                    if (target == null)
                    {
                        target = curTarget;
                    }
                }
                else
                {
                    target = curTarget;
                }
            }
            else
            {
                // 当前无锁定目标，走新锁定逻辑
                LogProxy.LogFormat("【普通索敌流程】2：当前无锁定目标，走新锁定逻辑 搜索者name = " + logicSelector.actor.name);
                
                target = GetSmartModeTarget(logicSelector, false, hasInputDir);
            }
            
            LogProxy.LogFormat("【普通索敌流程】4：搜索流程结束 搜索到目标name =  " + target?.name);
            return target;
        }

        /// <summary>
        /// 普通技能搜索虚弱目标规则
        /// </summary>
        /// <param name="logicSelector"></param>
        /// <returns></returns>
        public static Actor CommonSkillSelectWeak(TargetSelector logicSelector)
        {
            var curTarget = logicSelector.GetTarget();
            var actor = logicSelector.actor;
            if (actor == null)
            {
                return null;
            }
            Actor enemy = null;
            var hasInputDir = actor.HasDirInput();
            var radius = GetActorRadius(actor);
            var angle = TbUtil.battleConsts.CommonSkillSelectAngle;
            var actorPosition = actor.transform.position;
            var camForward = GlobalMainCameraManager.Instance.MainCamera.transform.forward;
            var inputDir = actor.GetDestDir();
            _GetEnemys(actor);

            //有摇杆方向
            if (hasInputDir)
            {
                //获取符合要求的虚弱的怪物
                if (curTarget == null)
                {
                    // 有摇杆无目标，在镜头范围内直接搜索最近的虚弱目标
                    enemy = _GetNearestWeakTarget(_EnemyActors, logicSelector.actor.transform.position, inputDir, 180, radius, false, true);
                }
                else
                {
                    // 有摇杆有目标，只考虑在镜头范围和摇杆方向+配置夹角都符合的情况
                    enemy = _GetNearestWeakTarget(_EnemyActors, logicSelector.actor.transform.position, inputDir, angle / 2.0f, radius, false, true);
                }
            }
            //无输入摇杆方向
            else
            {
                if (curTarget == null)
                {
                    //镜头方向，配置夹角内搜索虚弱目标
                    enemy = _GetNearestWeakTarget(_EnemyActors, actorPosition, camForward, angle / 2.0f, radius, false, false);
                }
                else
                {
                    //人物和目标连线，配置夹角内搜索虚弱目标
                    var desDir = curTarget.transform.position - actorPosition;
                    enemy = _GetNearestWeakTarget(_EnemyActors, actorPosition, desDir, angle / 2.0f, radius, false, false);
                }
            }

            return enemy;
        }

        public static Actor CoopSkillSelectWeak(TargetSelector logicSelector)
        {
            var curTarget = logicSelector.GetTarget();
            var actor = logicSelector.actor;
            if (actor == null)
            {
                return null;
            }
            Actor enemy = null;
            var hasInputDir = actor.HasDirInput();
            var radius = TbUtil.battleConsts.CoopSkillSelectRadius;
            var angle = TbUtil.battleConsts.CoopSkillSelectAngle;
            var actorPosition = actor.transform.position;
            var camForward = GlobalMainCameraManager.Instance.MainCamera.transform.forward;
            var inputDir = actor.GetDestDir();
            _GetEnemys(actor);

            //有摇杆方向
            if (hasInputDir)
            {
                if (curTarget == null)
                {
                    // 有摇杆无目标，摇杆方向，半径，搜索角度(不限制就是180°)，并且优先镜头范围内
                    enemy = _GetCoopNearestTarget(_EnemyActors, logicSelector.actor.transform.position, inputDir, 180, radius, true);
                }
                else
                {
                    // 有摇杆有目标，用摇杆方向，半径，搜索角度搜索目标
                    enemy = _GetCoopNearestTarget(_EnemyActors, logicSelector.actor.transform.position, inputDir, angle / 2.0f, radius, false);
                }
            }
            //无输入摇杆方向
            else
            {
                if (curTarget == null)
                {
                    //镜头方向，配置夹角内搜索虚弱目标
                    enemy = _GetCoopNearestTarget(_EnemyActors, actorPosition, camForward, angle / 2.0f, radius, false);
                }
                else
                {
                    //人物和目标连线，配置夹角内搜索虚弱目标
                    var desDir = curTarget.transform.position - actorPosition;
                    enemy = _GetCoopNearestTarget(_EnemyActors, actorPosition, desDir, angle / 2.0f, radius, false);
                }
            }

            return enemy;
        }

        private static Actor _GetCoopNearestTarget(List<Actor> enemys, Vector3 worldPos, Vector3 destDir,float angle, float radius, bool prioritizeInSight)
        {
            //获取符合要求的芯核的怪物
            var enemy = _GetNearstCoreTarget(enemys, worldPos, destDir, angle, radius, prioritizeInSight);
            if (enemy == null)
            {
                //获取符合要求的虚弱的怪物
                enemy = _GetNearestWeakTarget(enemys, worldPos, destDir, angle, radius, prioritizeInSight, false);
            }

            return enemy;
        }

        public class EnemyItem : IReset
        {
            public Actor actor;
            public float distance;
            public float newDistance;
            public bool? inSight;
            public void Reset()
            {
                actor = null;
                distance = 0;
                inSight = null;
            }
        }
        
        //todo 后期整理逻辑 Bge
        public static Actor GetSmartModeTarget(TargetSelector logicSelector, bool isOnlyMinRadius, bool hasInputDir)
        {
            var curTarget = logicSelector.GetTarget();
            var actor = logicSelector.actor;
            var minRadius = GetActorRadius(actor);
            var destDir = actor.GetDestDir();
            var worldPos = actor.transform.position;
            
            if (hasInputDir)
            { 
                LogProxy.LogFormat("【普通索敌流程】2：有摇杆输入 走摇杆输入搜索逻辑 搜索者name = " + logicSelector.actor.name);
                return GetSmartModelHasInput(logicSelector);
            }

            // 在攻击范围内, 并且仍在相机镜头内, 则继续用当前目标.
            if (curTarget != null && IsRadiusAndCam(actor, minRadius))
            {
                return curTarget;
            }

            // 有摇杆输入，无目标，不需要考虑新增的范围角限制，否则跟之前逻辑一样
            var notConsiderAngle = curTarget == null;
            if (isOnlyMinRadius)
            {
                _GetEnemys(actor, minRadius, minRadius, minRadius, true, false, false, notConsiderAngle, curTarget);
            }
            else
            {
                _GetEnemys(actor, minRadius, TbUtil.battleConsts.StandbyRadius, TbUtil.battleConsts.MaxRadius, true, true, true, notConsiderAngle, curTarget);
            }

            // DONE: 当无锁定目标并且无摇杆时，使用相机的朝向进行目标检测。（举例：当玩家控制的角色面朝怪物A，镜头朝向怪物B时，普攻会攻击B目标.）
            var checkDir = destDir;
            if (curTarget == null)
            {
                checkDir = GlobalMainCameraManager.Instance.MainCamera.transform.forward;
            }

            var target = _GetNearestDirTarget(_minEnemyItems, worldPos, checkDir, true); 
            LogProxy.LogFormat("【普通索敌流程】3：获取小圈内 & 在镜头范围内 & 角度最小的目标  目标name = " + target?.name);
            
            if (target == null)
            {
                target = _GetNearestTarget(_middleEnemyItems, true);
                LogProxy.LogFormat("【普通索敌流程】3：获取中圈内 & 在镜头范围内 & 距离最近  目标name = " + target?.name);
            }

            // 边缘区直接取相机视角作为理想视角
            Vector3 fCameraForward = Vector3.zero;
            if (target == null)
            {
                var cameraTrans = Battle.Instance.cameraTrace.GetCameraTransform();
                var cameraForward = cameraTrans.forward;
                fCameraForward.x = cameraForward.x;
                fCameraForward.z = cameraForward.z;
                target = _GetNearestDirTarget(_maxEnemyItems, worldPos, fCameraForward, true);
                LogProxy.LogFormat("【普通索敌流程】3：获取边缘区内 & 在镜头范围内 & 角度最小的目标  目标name = " + target?.name);
            }

            if (target == null)
            {
                target = _GetNearestDirTarget(_minEnemyItems, worldPos, destDir, false);
                LogProxy.LogFormat("【普通索敌流程】3：获取小圈内  & 角度最小的目标  目标name = " + target?.name);
            }

            if (target == null)
            {
                target = _GetNearestTarget(_middleEnemyItems, false);
                LogProxy.LogFormat("【普通索敌流程】3：获取中圈内最近的目标    目标name = " + target?.name);
            }

            if (target == null)
            {
                target = _GetNearestDirTarget(_maxEnemyItems, worldPos, fCameraForward, false);
                LogProxy.LogFormat("【普通索敌流程】3：获取边缘区内  & 角度最小的目标  目标name = " + target?.name);
            }
            return target;
        }

        /// <summary>
        /// 常规选敌 有摇杆输入的情况下
        /// </summary>
        /// <param name="_logicSelector"></param>
        /// <returns></returns>
        private static Actor GetSmartModelHasInput(TargetSelector _logicSelector)
        {
            var curTarget = _logicSelector.GetTarget();
            var actor = _logicSelector.actor;
            var minRadius = GetActorRadius(actor);
            var destDir = actor.GetDestDir();
            var worldPos = actor.transform.position;
            
            //获取射程区内目标 & 获取待选区内目标 &并且需要判断角度
            _GetEnemys(actor, minRadius, TbUtil.battleConsts.StandbyRadius, TbUtil.battleConsts.StandbyRadius, true, true, false, false, curTarget);
                
            //获取射程区内 & 在镜头范围内 & 角度最小的目标
            var selectTarget = _GetNearestDirTarget(_minEnemyItems, worldPos, destDir, true);
            LogProxy.LogFormat("【普通索敌流程】3：获取射程区内 & 在镜头范围内 & 角度最小的目标  目标name = " + selectTarget?.name);
            
            if (selectTarget == null)
            {
                //选择优先待选区内目标
                selectTarget = _GetStandNearestTarget(_middleEnemyItems, worldPos, destDir, TbUtil.battleConsts.StandByAngle,
                    true);
                LogProxy.LogFormat("【普通索敌流程】3：选择优先待选区内目标  目标name = " + selectTarget?.name);
            }

            if (selectTarget == null)
            {
                //选择次优待选区内目标
                selectTarget = _GetStandNearestTarget(_middleEnemyItems, worldPos, destDir,
                    TbUtil.battleConsts.CommonSkillSelectAngle,
                    true);
                LogProxy.LogFormat("【普通索敌流程】3：选择次优待选区内目标  目标name = " + selectTarget?.name);
            }
                
            //如果当前没有目标并且也没有搜索到目标
            if (curTarget == null && selectTarget == null)
            {
                selectTarget = _GetNearestEnemy(actor);
                LogProxy.LogFormat("【普通索敌流程】3：全范围搜索目标  目标name = " + selectTarget?.name);
            }
            
            return selectTarget;
        }
        
        // 获取视野范围内视角最近的敌方单位
        // param enemys table<_EnemyItem>
        // param worldPos FVector3
        // param destDir FVector3
        // return Actor
        private static Actor _GetNearestDirTarget(List<EnemyItem> enemys, Vector3 worldPos, Vector3 destDir,
            bool isInSight)
        {
            Actor target = null;
            if (enemys != null)
            {
                float? maxAngleValue = null;
                foreach (var item in enemys)
                {
                    if (item.inSight == null)
                    {
                        item.inSight = Battle.Instance.cameraTrace.IsInSight(item.actor);
                    }

                    var checkItem = (isInSight && item.inSight.Value) || (!isInSight && !item.inSight.Value);
                    if (checkItem)
                    {
                        var selectActor = item.actor;
                        var angle = GetNewAngle(worldPos, destDir, selectActor.transform.position,
                            selectActor.GetSelectRadius());
                        LogProxy.Log("【普通索敌流程】 索敌规则: 目标name = " + selectActor.name + " 夹角 = "+ angle + " 选择圆半径 = " + selectActor.GetSelectRadius());
                        // var targetPos = item.actor.transform.position;
                        // var dir = (targetPos - worldPos).normalized;
                        // var cosValue = Vector3.Dot(dir, destDir);

                        if (maxAngleValue == null || angle < maxAngleValue)
                        {
                            maxAngleValue = angle;
                            target = item.actor;
                        }
                    }
                }
            }

            return target;
        }
        
        // 获取优先待选区内距离最近的敌方单位
        // return Actor
        private static Actor _GetStandNearestTarget(List<EnemyItem> enemys, Vector3 worldPos, Vector3 destDir,
            int standByAngle, bool isInSight)
        {
            Actor target = null;
            if (enemys != null)
            {
                float? minDistance = null;
                foreach (var item in enemys)
                {
                    if (item.inSight == null)
                    {
                        item.inSight = Battle.Instance.cameraTrace.IsInSight(item.actor);
                    }

                    var checkItem = (isInSight && item.inSight.Value) || (!isInSight && !item.inSight.Value);
                    if (!checkItem)
                    {
                        continue;
                    }
                    
                    var targetPos = item.actor.transform.position;
                    var dir = (targetPos - worldPos).normalized;
                    var angle = Vector3.Angle(dir, destDir);
                    LogProxy.Log("【普通索敌流程】 索敌规则: 目标name = " + item.actor.name + " 角度 = "+ angle);
                    if (angle > standByAngle / 2.0f)
                    {
                        continue;
                    }
                    LogProxy.Log("【普通索敌流程】 索敌规则: 目标name = " + item.actor.name + " 距离 = "+ item.newDistance + " 选择圆半径 = " + item.actor.GetSelectRadius());
                    if (minDistance == null || item.newDistance < minDistance)
                    {
                        target = item.actor;
                        minDistance = item.newDistance;
                    }
                }
            }

            return target;
        }

        /// <summary>
        /// 获取给定视野范围内视角最近的敌方虚弱单位
        /// </summary>
        /// <param name="enemys"></param>
        /// <param name="worldPos"></param>人物位置
        /// <param name="destDir"></param>目标方向
        /// <param name="angle"></param>搜索的角度
        /// <param name="radius"></param>搜索的半径
        /// <returns></returns>
        private static Actor _GetNearestWeakTarget(List<Actor> enemys, Vector3 worldPos, Vector3 destDir,float angle, float radius, bool prioritizeInSight, bool onlyInSight)
        {
            Actor target = null;
            Actor inSightTarget = null;
            
            if (enemys == null)
            {
                return null;
            }
            
            float minDistance = float.MaxValue;
            foreach (var item in enemys)
            {
                var targetPos = item.transform.position;
                
                //判断是否是虚弱怪
                if (!item.actorWeak.weak)
                {
                    continue;
                }
                
                //判断是否在角度内
                var targetLine = targetPos - worldPos;
                var targetAngle = Vector3.Angle(destDir, targetLine);
                if (targetAngle > angle)
                {
                    LogProxy.LogFormat("【目标】 索敌规则： 搜索到虚弱目标 = " + item.name + " 角度 = " + targetAngle +
                                       " 大于搜索角度 angle = " + angle);
                    continue;
                }
                
                //判断是否在半径内
                var distance = Vector3.Distance(worldPos, targetPos);
                if (distance > radius)
                {
                    continue;
                }

                if (distance < minDistance)
                {
                    minDistance = distance;
                    target = item;
                    
                    // 如果相机范围内优先，则设置一下
                    if ((prioritizeInSight || onlyInSight) && Battle.Instance.cameraTrace.IsInSight(item))
                    {
                        inSightTarget = item;
                    }
                }
            }

            return onlyInSight? inSightTarget : (inSightTarget ?? target);
        }

        /// <summary>
        /// 搜索符合规则的芯核目标
        /// </summary>
        /// <param name="enemys"></param>
        /// <param name="worldPos"></param>
        /// <param name="destDir"></param>
        /// <param name="angle"></param>
        /// <param name="radius"></param>
        /// <returns></returns>
        private static Actor _GetNearstCoreTarget(List<Actor> enemys, Vector3 worldPos, Vector3 destDir, float angle, float radius, bool prioritizeInSight)
        {
            Actor target = null;
            if (enemys == null)
            {
                return null;
            }

            Actor inSightTarget = null;  // 在相机范围内的最优Target
            
            float maxValue = float.MaxValue;
            float maxDistance = 0;
            foreach (var item in enemys)
            {
                var targetPos = item.transform.position;
                
                //判断是否有星核
                if (!item.actorWeak.IsHaveCore())
                {
                    continue;
                }
                
                //判断是否在角度内
                var targetLine = targetPos - worldPos;
                var targetAngle = Vector3.Angle(destDir, targetLine);
                if (targetAngle > angle)
                {
                    LogProxy.LogFormat("【目标】 索敌规则： 搜索到芯核目标 = " + item.name + " 角度 = " + targetAngle +
                                       " 大于搜索角度 angle = " + angle);
                    continue;
                }
                
                //判断是否在半径内
                var distance = Vector3.Distance(worldPos, targetPos);
                if (distance > radius)
                {
                    continue;
                }

                if (item.actorWeak.GetWeakNum() < maxValue)
                {
                    maxValue = item.actorWeak.GetWeakNum();
                    target = item;
                    maxDistance = distance;
                    
                    // 如果相机范围内优先，则设置一下
                    if (prioritizeInSight && Battle.Instance.cameraTrace.IsInSight(item))
                    {
                        inSightTarget = item;
                    }
                }
                else if ((int)item.actorWeak.GetWeakNum() == (int)maxValue && distance < maxDistance) 
                {
                    maxValue = item.actorWeak.GetWeakNum();
                    target = item;
                    
                    // 如果相机范围内优先，则设置一下
                    if (prioritizeInSight && Battle.Instance.cameraTrace.IsInSight(item))
                    {
                        inSightTarget = item;
                    }
                }
                
            }

            return inSightTarget ?? target;
        }
        
        // 获取视野范围内距离最近的敌方单位
        // param enemys table<_EnemyItem>
        // return Actor
        private static Actor _GetNearestTarget(List<EnemyItem> enemys, bool isInSight)
        {
            Actor target = null;
            if (enemys != null)
            {
                float? minDistance = null;
                foreach (var item in enemys)
                {
                    if (item.inSight == null)
                    {
                        item.inSight = Battle.Instance.cameraTrace.IsInSight(item.actor);
                    }

                    var checkItem = (isInSight && item.inSight.Value) || (!isInSight && !item.inSight.Value);
                    if (checkItem)
                    {
                        LogProxy.Log("【目标】 索敌规则: 目标name = " + item.actor.name + " 距离 = "+ item.newDistance + " 选择圆半径 = " + item.actor.GetSelectRadius());
                        if (minDistance == null || item.newDistance < minDistance)
                        {
                            target = item.actor;
                            minDistance = item.newDistance;
                        }
                    }
                }
            }

            return target;
        }

        //取第一个Boss怪物
        public static Actor GetBossTarget()
        {
            Actor target = null;
            var monsters = ObjectPoolUtility.CommonActorList.Get();
            Battle.Instance.actorMgr.GetActors(ActorType.Monster, outResults: monsters);
            foreach (var actor in monsters)
            {
                if (actor.isDead)
                {
                    continue;
                }

                if (!actor.bornCfg.EnableBeLocked)
                {
                    continue;
                }

                if (actor.IsEnableBossCamera())
                {
                    target = actor;
                    break;
                }
            }
            ObjectPoolUtility.CommonActorList.Release(monsters);
            return target;
        }
        
        // class _EnemyItem
        // field actor
        // field distance
        // field inSight

        // 获取不大于MaxRadius范围内的、可被选中的、存活的、排序后的目标列表
        // 如果有摇杆输入 会选取摇杆角度内的 && 摄像机视野范围内的目标
        // param actor Role
        // param maxRadius Fix
        // return table<_EnemyItem>, table<_EnemyItem>, table<_EnemyItem>
        private static void _GetEnemys(Actor actor, float minRadius, float midRadius, float maxRadius, bool min, bool mid, bool max, bool notConsiderAngle,Actor curTarget = null)
        {
            for (int i = 0; i < _minEnemyItems.Count; i++)
            {
                ObjectPoolUtility.EnemyItem.Release(_minEnemyItems[i]);
            }
            for (int i = 0; i < _middleEnemyItems.Count; i++)
            {
                ObjectPoolUtility.EnemyItem.Release(_middleEnemyItems[i]);
            }
            for (int i = 0; i < _maxEnemyItems.Count; i++)
            {
                ObjectPoolUtility.EnemyItem.Release(_maxEnemyItems[i]);
            }
            _minEnemyItems.Clear();
            _middleEnemyItems.Clear();
            _maxEnemyItems.Clear();
            
            var transform = actor.GetDummy();
            var selfPos = transform.position;
            var actors = actor.battle.actorMgr.actors;
            var hasInputDir = actor.HasDirInput();
            var destDir = actor.GetDestDir();
            var includedAngle = TbUtil.battleConsts.CommonSkillSelectAngle;
            foreach (var targetActor in actors)
            {
                if (!targetActor.IsRole() || targetActor.isDead)
                {
                    continue;
                }

                if (targetActor.stateTag.IsActive(ActorStateTagType.LockIgnore))
                {
                    continue;
                }

                if (actor == targetActor)
                {
                    continue;
                }

                if (actor.GetFactionRelationShip(targetActor) != FactionRelationship.Enemy)
                {
                    continue;
                }

                if (!(targetActor.aiOwner?.isActive ?? true))
                {
                    continue;
                }
                
                // DONE: 有摇杆输入, 判断目标是否在摇杆输入方向的夹角内. && 并且要在视野范围内 （举例：当正在打A目标，连续放普攻技能时，摇杆朝向变化到B目标侧，则会切换目标攻击B.）
                if (hasInputDir)
                {
                    //是否判断角度
                    if (!notConsiderAngle)
                    {
                        var inAngle =
                            _IsWithinIncludedAngle(selfPos, destDir, targetActor.transform.position, includedAngle, out float checkAngle);
                        var inSight = Battle.Instance.cameraTrace.IsInSight(targetActor);
                        //如果 不在摇杆输入方向 或者 不在视野内
                        if (!inAngle || !inSight)
                        {
                            if (curTarget != targetActor)
                            {
                                if (!inAngle)
                                {
                                    LogProxy.Log("【普通索敌流程】 2：  actor name = " + targetActor.name + "的位置 = " + " 不在摇杆输入方向 当前目标和摇杆方向的角度 = " + checkAngle);
                                }

                                if (!inSight)
                                {
                                    LogProxy.Log("【普通索敌流程】 2： actor name = " + targetActor.name + "的位置 = " + "不在视野范围内");
                                }
                            }
                            continue;
                        }
                    }
                }
                
                var targetPos = targetActor.transform.position;
                var delta = targetPos - selfPos;
                var magnitude = delta.magnitude;
                if (magnitude <= maxRadius)
                {
                    // type _EnemyItem
                    var dataItem = ObjectPoolUtility.EnemyItem.Get();
                    dataItem.actor = targetActor;
                    dataItem.distance = magnitude;
                    dataItem.newDistance =
                        GetNewDistance(targetActor.GetSelectRadius(), magnitude);
                    if (magnitude <= minRadius)
                    {
                        if (min)
                        {
                            _minEnemyItems.Add(dataItem);   
                        }
                    }
                    else if (magnitude <= midRadius)
                    {
                        if (mid)
                        {
                            _middleEnemyItems.Add(dataItem);
                        }
                    }
                    else
                    {
                        if (max)
                        {
                            _maxEnemyItems.Add(dataItem);
                        }
                    }
                }
                else
                {
                    LogProxy.Log("【普通索敌流程】 2： actor name = " + targetActor.name + "的位置 = " + magnitude + " 大于了最大射程 maxradius = " + maxRadius);
                }
            }
        }
        
        /// <summary>
        /// 获取敌方怪物 不排序
        /// </summary>
        /// <param name="actor"></param>
        private static void _GetEnemys(Actor actor)
        {
            _EnemyActors.Clear();
            
            var transform = actor.GetDummy();
            var actors = actor.battle.actorMgr.actors;
            foreach (var targetActor in actors)
            {
                if (targetActor.IsRole() && !targetActor.stateTag.IsActive(ActorStateTagType.LockIgnore) &&
                    !targetActor.isDead && actor != targetActor && actor.GetFactionRelationShip(targetActor) == FactionRelationship.Enemy && (targetActor.aiOwner?.isActive ?? true))
                {
                    _EnemyActors.Add(targetActor);
                }
            }
        }
        
        /// <summary>
        /// 获取最近的敌方怪物
        /// </summary>
        /// <param name="actor"></param>
        private static Actor _GetNearestEnemy(Actor actor)
        {
            Actor target = null;
            float minDistance = float.MaxValue;
            var selfPos = actor.transform.position;
            foreach (var targetActor in actor.battle.actorMgr.actors)
            {
                if (targetActor.IsRole() && !targetActor.stateTag.IsActive(ActorStateTagType.LockIgnore) &&
                    !targetActor.isDead && actor != targetActor && actor.GetFactionRelationShip(targetActor) == FactionRelationship.Enemy)
                {
                    var targetPos = targetActor.transform.position;
                    var delta = targetPos - selfPos;
                    var distance = GetNewDistance(targetActor.GetSelectRadius(), delta.magnitude);
                    if (distance < minDistance)
                    {
                        target = targetActor;
                        minDistance = distance;
                    }
                }
            }

            return target;
        }

        /// <summary>
        /// 根据远程近战 和有无摇杆输入 选择射程半径大小
        /// </summary>
        /// <param name="actor"></param>
        /// <returns></returns>
        public static float GetActorRadius(Actor actor)
        {
            var minRadius = 0.0f;
            var hasInputDir = actor.HasDirInput();
            if (actor.weapon != null && actor.weapon.weaponLogicCfg != null)
            {
                if (actor.weapon.weaponLogicCfg.LockRangeType == (int) LockRangeType.Melee)
                {
                    // 近战
                    minRadius = TbUtil.battleConsts.MeleeRadius;
                    if (hasInputDir)
                    {
                        minRadius = TbUtil.battleConsts.MeleeRadiusWithJoystic;
                    }
                }
                else
                {
                    // 远程
                    minRadius = TbUtil.battleConsts.RemoteRadius;
                    if (hasInputDir)
                    {
                        minRadius = TbUtil.battleConsts.RemoteRadiusWithJoystic;
                    }
                }
            }

            return minRadius;
        }

        /// <summary>
        /// 当前目标根据角度规则是否要切换
        /// </summary>
        /// <returns></returns>
        public static bool IsChangeTarget(Actor actor)
        {
            var curTarget = actor.GetTarget();
            
            if (curTarget == null)
            {
                return true;
            }
            
            if (!actor.HasDirInput())
            {
                return false;
            }

            var destDir = actor.GetDestDir();
            var targetDir = curTarget.transform.position - actor.transform.position;
            var angle = Vector3.Angle(targetDir, destDir);
                
            if (angle >= GetActorSelectAngle(actor))
            {
                // 角度大于目标角度
                return true;
            }

            return false;
        }

        /// <summary>
        /// 判断目标是否在射程内并且在镜头范围内
        /// </summary>
        /// <param name="my"></param>
        /// <param name="target"></param>
        /// <param name="radius"></param>
        /// <returns></returns>
        public static bool IsRadiusAndCam(Actor actor, float radius)
        {
            var curTarget = actor.GetTarget();
            
            if (curTarget == null)
            {
                return true;
            }

            float distance = BattleUtil.GetActorDistance(actor, curTarget);
            bool isCam = Battle.Instance.cameraTrace.IsInSight(curTarget);
            if (distance > radius)
            {
                LogProxy.Log("【普通索敌流程】 1: actor.name = " + actor.name + " 所选择的目标 name = " + curTarget.name + " 不在射程内" + " 射程为："+radius + " 距离为：" + distance);
            }
            
            if (!isCam)
            {
                LogProxy.Log("【普通索敌流程】 1: actor.name = " + actor.name + " 所选择的目标 name = " + curTarget.name + " 不在镜头内");
            }
            
            if (distance < radius && isCam)
            {
                return true;
            }

            return false;
        }

        /// <summary>
        /// 是否在夹角内
        /// </summary>
        /// <param name="originPos"> 原点位置 </param>
        /// <param name="originDir"> 原点朝向 </param>
        /// <param name="checkPos"> 待检测目标点 </param>
        /// <param name="includedAngle"> 夹角(<180°) </param>
        /// <returns></returns>
        private static bool _IsWithinIncludedAngle(Vector3 originPos, Vector3 originDir, Vector3 checkPos, float includedAngle, out float checkAngle)
        {
            checkAngle = 0;
            if (includedAngle >= 180f)
            {
                LogProxy.LogError("TargetSelectUtil._IsWithinIncludedAngle 参数夹角应小于180°.");
                return false;
            }
            
            var checkDir = checkPos - originPos;
#if UNITY_EDITOR
            checkAngle = Vector3.Angle(originDir, checkDir);
#endif
            var halfAngle =  includedAngle / 2f;
            var leftDir = Quaternion.AngleAxis(-halfAngle, Vector3.up) * originDir;
            var rightDir = Quaternion.AngleAxis(halfAngle, Vector3.up) * originDir;
            if (!(Vector3.Dot(checkDir, originDir) > 0))
            {
                return false;
            }
            
            return Vector3.Dot(Vector3.Cross(leftDir, checkDir), Vector3.Cross(checkDir, rightDir)) > 0;
        }

        /// <summary>
        /// 获取一个向量和一个圆之间的角度，
        /// 如果向量和圆相交 获取比值 筛选圆心到摇杆输入方向垂线/筛选圆半径
        /// 如果不相交 摇杆输入和筛选圆的切线作为夹角
        /// </summary>
        /// <returns></returns>
        private static float GetNewAngle(Vector3 pos, Vector3 dir, Vector3 circle, float circleRadius)
        {
            Vector3 dir2 = (circle - pos).normalized;
            //如果圆的半径小于等于0
            if (circleRadius <= 0)
            {
                return Vector3.Angle(dir, dir2);
            }
            else
            {
               var isIntersect = BattleUtil.IsCircleRayIntersect(new Vector2(pos.x, pos.z), new Vector2(dir.x, dir.z),
                    new Vector2(circle.x, circle.z), circleRadius);
               //如果向量和圆相交
               if (isIntersect)
               {
                   var dis = BattleUtil.GetCircleRayPerpendicular(new Vector2(pos.x, pos.z),
                       new Vector2(dir.x, dir.z),
                       new Vector2(circle.x, circle.z));
                   var ratio = dis / circleRadius;
                   if(ratio > 1) LogProxy.LogError("【目标选择】 向量与圆相交的比值计算错误 比值大于 1");
                   if (float.IsNaN(ratio))
                       LogProxy.LogError("【目标选择】 向量与圆相交的比值计算错误 比值 = NAN dis = " + dis + " circleRadius = " +
                                         circleRadius + " dir = " + dir + " circle = " + circle);
                   return ratio;
               }
               else
               {
                   var angle = Vector3.Angle(dir, dir2);
                   var lineAngle = BattleUtil.GetCirclePointLineAngle(new Vector2(pos.x, pos.z), new Vector2(circle.x, circle.z), circleRadius);
                   var newAngle = angle - lineAngle;
                   if (newAngle <= 0)
                       LogProxy.LogError("【目标选择】 向量与圆的角度计算错误 角度小于 0 = " + newAngle + " pos =  " + pos + " circle = " +
                                         circle + " circleRadius" + circleRadius + " dir = " + dir + " lineAngle = " + lineAngle + " angle = " + angle);
                   return newAngle;
               }
            }
        }

        /// <summary>
        /// 取新式距离
        /// 筛选圆不包含玩家位置 怪物到玩家距离 - 筛选圆半径
        /// 筛选圆包含玩家位置  - （1 - 怪物到玩家距离 / 筛选圆半径）
        /// <param name="pos"></param>
        /// <param name="dir"></param>
        /// <param name="circle"></param>
        /// <param name="circleRadius"></param>
        /// <returns></returns>
        private static float GetNewDistance(float circleRadius, float distance)
        {
            if (distance < circleRadius)
            {
                return - (1 - distance / circleRadius);
            }

            return distance - circleRadius;
        }
    }
    

}