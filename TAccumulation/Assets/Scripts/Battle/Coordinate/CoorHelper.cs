using System;
using UnityEngine;
using Random = UnityEngine.Random;

namespace X3Battle
{
    // Trans信息
    public class TransInfo
    {
        public Vector3 position { get; private set; }
        public Vector3 forward { get; private set; }

        public TransInfo(Vector3 pos, Vector3 forwardParam)
        {
            position = pos;
            forward = forwardParam;
        }
    }

    public static class CoorHelper
    {
        // DONE: 编辑器下目标距离selfGameObject的距离.
        public const float EditorTargetDistance = 20.0f;

        // 尝试获取一个adapter（蓝图里调用）
        private static ActorAdapter _TryGetActorAdapter(Actor targetActor)
        {
            ActorAdapter adapter = null;
            if (targetActor != null)
            {
                adapter = ObjectPoolUtility.ActorAdapter.Get();
                adapter.SetData(targetActor);
            }
            return adapter;
        }
        
        // 尝试获取一个adapter
        private static ActorAdapter _TryGetActorAdapter(Actor selfActor, CoorTargetType coorTargetType, int targetID, TransInfoCache targetTransInfo)
        {
            ActorAdapter adapter = null;
            if (coorTargetType == CoorTargetType.Record)
            {
                // 使用ID取
                if (targetTransInfo != null)
                {
                    var transInfo = targetTransInfo.TryGetInfo(targetID);
                    if (transInfo != null)
                    {
                        adapter = ObjectPoolUtility.ActorAdapter.Get();
                        adapter.SetData(transInfo);
                    }
                }
            }
            else
            {
                // 使用actor取目标
                if (selfActor != null)
                {
                    var actor = selfActor.GetTarget((TargetType)coorTargetType);
                    if (actor != null)
                    {
                        adapter = ObjectPoolUtility.ActorAdapter.Get();
                        adapter.SetData(actor);
                    }
                }
            }
            return adapter;
        }

        // 尝试release adapter
        private static void _TryReleaseActorAdapter(ActorAdapter adapter)
        {
            if (adapter != null)
            {
                ObjectPoolUtility.ActorAdapter.Release(adapter);
            }
        }
        
        /// <summary>
        /// 编辑器下获取位置
        /// </summary>
        /// <param name="coorPoint"> 统一坐标点配置 </param>
        /// <param name="selfGameObject"></param>
        /// <returns></returns>
        public static Vector3 GetCoordinatePointEditor(this CoorPoint coorPoint, GameObject selfGameObject)
        {
            Vector3 result = Vector3.zero;
            
            if (coorPoint == null)
            {
                return result;
            }

            if (selfGameObject == null)
            {
                return result;
            }
            
            if (coorPoint.coorPointMode == CoorPointMode.CoorPoint)
            {
                Vector3 offsetPos = coorPoint.offsetPos;
                Vector3 p0 = Vector3.zero; // 根据步骤1，可以确定坐标系原点：P0
                
                // DONE: 策划编辑器需求, 当前目标朝向20m外的假想目标位置.
                Vector3 p1 = selfGameObject.transform.position + selfGameObject.transform.forward * EditorTargetDistance;
                
                // 步骤1.确定坐标系原点.
                if (coorPoint.coorOriginType == CoorOriginType.World)
                {
                    p0 = Vector3.zero;
                }
                else if (coorPoint.coorOriginType == CoorOriginType.Actor)
                {
                    if (coorPoint.targetType1 == CoorTargetType.Self)
                    {
                        p0 = selfGameObject.transform.position;
                    }
                    else
                    {
                        p0 = p1;    
                    }
                }
                
                Vector3 forward = Vector3.forward;

                // 步骤2: 确定坐标系朝向参数
                if (coorPoint.coorOrientationType == CoorOrientationType.World)
                {
                    forward = Vector3.forward;
                }
                else if (coorPoint.coorOrientationType == CoorOrientationType.Actor)
                {
                    // DONE: 策划编辑器预览特殊需求, 该枚举下直接选择selfGameObject的朝向作为选点朝向. 
                    forward = selfGameObject.transform.forward;
                }
                else if (coorPoint.coorOrientationType == CoorOrientationType.Line)
                {
                    // DONE: 策划编辑器预览特殊需求, 该枚举下直接选择selfGameObject的朝向作为选点朝向.
                    forward = selfGameObject.transform.forward;
                }

                // 步骤3: 确定坐标偏移量.
                result = Quaternion.LookRotation(forward) * offsetPos;
                
                // 步骤4: 确定坐标随机偏移.
                if (coorPoint.coorPointRandomType == CoorPointRandomType.RandomRingXZ)
                {
                    var angle = UnityEngine.Random.Range(0f, 360f);
                    var offsetXZ = Quaternion.AngleAxis(angle, Vector3.up) * (Vector3.forward * UnityEngine.Random.Range(coorPoint.randomMinRadius, coorPoint.randomMaxRadius));
                    result.x += offsetXZ.x;
                    result.z += offsetXZ.z;
                }
                
                // 步骤5：进行贴地
                if (coorPoint.isDown)
                {
                    result.y = 0;
                }
            }
            else if (coorPoint.coorPointMode == CoorPointMode.HangPoint)
            {
                if (coorPoint.hangPointData == null)
                {
                    return result;
                }
                
                var dummies = selfGameObject.GetComponent<DummiesMono>();
                if (dummies == null)
                {
                    return result;
                }
                
                if (string.IsNullOrEmpty(coorPoint.hangPointData.name)) 
                {
                    return result;
                }

                var dummyTrans = dummies.GetDummyTrans(coorPoint.hangPointData.name);
                if (dummyTrans == null)
                {
                    return result;
                }
                
                result = dummyTrans.position;
                result += coorPoint.hangPointData.offsetPos;
            }
            
            return result;
        }

        /// <summary>
        /// 编辑器下获取朝向
        /// </summary>
        /// <returns></returns>
        public static Vector3 GetCoordinateForwardEditor(this CoorOrientation coorOrientation, GameObject selfGameObject)
        {
            Vector3 result = Vector3.forward;
            if (coorOrientation == null)
            {
                return result;
            }

            if (selfGameObject == null)
            {
                return result;
            }

            if (coorOrientation.orientationCoorType == OrientationCoorType.LookAtActor)
            {
                result = selfGameObject.transform.forward;
            }
            else if (coorOrientation.orientationCoorType == OrientationCoorType.LookAtPoint)
            {
                Vector3 targetPoint = GetCoordinatePointEditor(coorOrientation.coorPoint, selfGameObject);
                result = (targetPoint - selfGameObject.transform.position).normalized;
            }
            else if (coorOrientation.orientationCoorType == OrientationCoorType.WorldCoor)
            {
                result = Vector3.forward;
            }
            else if(coorOrientation.orientationCoorType == OrientationCoorType.ActorLocalCoor)
            {
                // DONE: 策划编辑器预览特殊需求, 该枚举下直接选择selfGameObject的朝向作为选点朝向.
                result = selfGameObject.transform.forward;
            }
            else if (coorOrientation.orientationCoorType == OrientationCoorType.ActorLineCoor)
            {
                // DONE: 策划编辑器预览特殊需求, 该枚举下直接选择selfGameObject的朝向作为选点朝向. 
                result = selfGameObject.transform.forward;
            }

            // 保底容错方向
            if (result == Vector3.zero)
            {
                result = Vector3.forward;
            }
            
            // 旋转偏移量
            Vector3 offsetAngle = coorOrientation.offsetAngle + new Vector3(0f, coorOrientation.offsetAngleY, 0f);
            
            // 随机角度偏移
            Vector3 randomAngle = new Vector3(Random.Range(0f, coorOrientation.randomAngle.x), Random.Range(0f, coorOrientation.randomAngle.y), Random.Range(0f, coorOrientation.randomAngle.z));
            
            // 旋转偏移量
            result = (Quaternion.LookRotation(result) * Quaternion.Euler(offsetAngle + randomAngle) * Vector3.forward).normalized;
            
            return result;
        }

        /// <summary>
        /// 返回的是世界点坐标
        /// </summary>
        public static Vector3 GetCoordinatePoint(this CoorPoint coorPoint, Actor selfActor, bool bIsTargetType, TransInfoCache transInfoCache = null)
        {
            Vector3 result = Vector3.zero;
            if (coorPoint == null)
            {
                return result;
            }

            var selfActorAdapter = _TryGetActorAdapter(selfActor);
            if (coorPoint.coorPointMode == CoorPointMode.CoorPoint)
            {
                ActorAdapter actor1 = null;
                ActorAdapter actor2 = null;
                ActorAdapter actor3 = null;
                Vector3 offsetPos = Vector3.zero;
                if (bIsTargetType)
                {
                    // actor1 = selfActor?.GetTarget((TargetType)coorPoint.targetType1);
                    // actor2 = selfActor?.GetTarget((TargetType)coorPoint.targetType2);
                    // actor3 = selfActor?.GetTarget((TargetType)coorPoint.targetType3);

                    actor1 = _TryGetActorAdapter(selfActor, coorPoint.targetType1, coorPoint.recordTargetID1, transInfoCache);
                    actor2 = _TryGetActorAdapter(selfActor, coorPoint.targetType2, coorPoint.recordTargetID2, transInfoCache);
                    actor3 = _TryGetActorAdapter(selfActor, coorPoint.targetType3, coorPoint.recordTargetID3, transInfoCache);
                    
                    offsetPos = coorPoint.offsetPos;
                }
                else
                {
                    // actor1 = coorPoint.viActor1?.GetValue();
                    // actor2 = coorPoint.viActor2?.GetValue();
                    // actor3 = coorPoint.viActor3?.GetValue();
                    
                    actor1 = _TryGetActorAdapter(coorPoint.viActor1?.GetValue());
                    actor2 = _TryGetActorAdapter(coorPoint.viActor2?.GetValue());
                    actor3 = _TryGetActorAdapter(coorPoint.viActor3?.GetValue());
                    Vector3 tempV3 = new Vector3(coorPoint.offsetPos.x, coorPoint.offsetPos.y, coorPoint.offsetPos.z);
                    offsetPos = coorPoint.viOffsetPos == null ? tempV3 : coorPoint.viOffsetPos.isConnected ? coorPoint.viOffsetPos.GetValue() : tempV3;
                }

                Vector3 p0 = Vector3.zero; // 根据步骤1，可以确定坐标系原点：P0
                // 步骤1.确定坐标系原点.
                if (coorPoint.coorOriginType == CoorOriginType.World)
                {
                    p0 = Vector3.zero;
                }
                else if (coorPoint.coorOriginType == CoorOriginType.Actor)
                {
                    p0 = actor1?.position ?? (selfActorAdapter?.position ?? Vector3.zero);
                }

                Vector3 forward = Vector3.forward;

                // 步骤2: 确定坐标系朝向参数
                if (coorPoint.coorOrientationType == CoorOrientationType.World)
                {
                    forward = Vector3.forward;
                }
                else if (coorPoint.coorOrientationType == CoorOrientationType.Actor)
                {
                    forward = actor2?.forward ?? (selfActorAdapter?.forward ?? Vector3.forward);
                }
                else if (coorPoint.coorOrientationType == CoorOrientationType.Line)
                {
                    ActorAdapter startActor = actor2 ?? selfActorAdapter;
                    ActorAdapter endActor = actor3 ?? selfActorAdapter;
                    if (startActor is null || endActor is null)
                    {
                        forward = Vector3.forward;
                    }
                    else if (startActor == endActor && startActor == selfActorAdapter)
                    {
                        forward = selfActorAdapter?.forward ?? Vector3.forward;
                    }
                    else
                    {
                        forward = (endActor.position - startActor.position).normalized;
                    }
                }

                // 步骤3: 确定坐标偏移量
                if (coorPoint.isMoveOffset)
                {
                    if (actor1?.actor != null && actor1.actor.mainState.IsState(ActorMainStateType.Move))
                    {
                        result = p0 + Quaternion.LookRotation(forward) * offsetPos;
                    }
                    else
                    {
                        result = p0;
                    }
                }
                else
                {
                    result = p0 + Quaternion.LookRotation(forward) * offsetPos;
                }

                // 步骤4: 确定坐标随机偏移.
                if (coorPoint.coorPointRandomType == CoorPointRandomType.RandomRingXZ)
                {
                    var angle = UnityEngine.Random.Range(0f, 360f);
                    var offsetXZ = Quaternion.AngleAxis(angle, Vector3.up) * (Vector3.forward * UnityEngine.Random.Range(coorPoint.randomMinRadius, coorPoint.randomMaxRadius));
                    result.x += offsetXZ.x;
                    result.z += offsetXZ.z;
                }
                // 步骤5：进行贴地
                if (coorPoint.isDown)
                {
                    result.y = BattleUtil.GetPosY();
                }

                _TryReleaseActorAdapter(actor1);
                _TryReleaseActorAdapter(actor2);
                _TryReleaseActorAdapter(actor3);
            }
            else if (coorPoint.coorPointMode == CoorPointMode.HangPoint)
            {
                if (coorPoint.hangPointData != null)
                {
                    if (selfActor?.model != null)
                    {
                        result = selfActor.GetDummy(coorPoint.hangPointData.name).position;
                    }

                    result += coorPoint.hangPointData.offsetPos;
                }
            }
            
            _TryReleaseActorAdapter(selfActorAdapter);
            return result;
        }

        /// <summary>
        /// 返回Forward. 朝向
        /// </summary>
        public static Vector3 GetCoordinateOrientation(this CoorOrientation coorOrientation, Actor selfActor, bool bIsTargetType, TransInfoCache transInfoCache = null)
        {
            Vector3 result = Vector3.forward;

            if (coorOrientation == null)
            {
                return result;
            }
            
            var selfActorAdapter = _TryGetActorAdapter(selfActor);
            ActorAdapter actor1 = null;
            ActorAdapter actor2 = null;
            ActorAdapter actor3 = null;
            ActorAdapter actor4 = null;
            
            if (bIsTargetType)
            {
                // actor1 = selfActor?.GetTarget((TargetType)coorOrientation.targetType1);
                // actor2 = selfActor?.GetTarget((TargetType)coorOrientation.targetType2);
                // actor3 = selfActor?.GetTarget((TargetType)coorOrientation.targetType3);
                // actor4 = selfActor?.GetTarget((TargetType)coorOrientation.targetType4);

                actor1 = _TryGetActorAdapter(selfActor, coorOrientation.targetType1, coorOrientation.recordTargetID1, transInfoCache);
                actor2 = _TryGetActorAdapter(selfActor, coorOrientation.targetType2, coorOrientation.recordTargetID2, transInfoCache);
                actor3 = _TryGetActorAdapter(selfActor, coorOrientation.targetType3, coorOrientation.recordTargetID3, transInfoCache);
                actor4 = _TryGetActorAdapter(selfActor, coorOrientation.targetType4, coorOrientation.recordTargetID4, transInfoCache);
            }
            else
            {
                // actor1 = coorOrientation.viActor1?.GetValue();
                // actor2 = coorOrientation.viActor1?.GetValue();
                // actor3 = coorOrientation.viActor1?.GetValue();
                // actor4 = coorOrientation.viActor2?.GetValue();

                actor1 = _TryGetActorAdapter(coorOrientation.viActor1?.GetValue());
                actor2 = _TryGetActorAdapter(coorOrientation.viActor1?.GetValue());
                actor3 = _TryGetActorAdapter(coorOrientation.viActor1?.GetValue());
                actor4 = _TryGetActorAdapter(coorOrientation.viActor2?.GetValue());
            }

            if (coorOrientation.orientationCoorType == OrientationCoorType.LookAtActor)
            {
                ActorAdapter targetActor = actor1 ?? selfActorAdapter;
                if (targetActor == selfActorAdapter)
                {
                    result = selfActorAdapter?.forward ?? Vector3.forward;
                }
                else
                {
                    if (targetActor != null)
                    {
                        result = (targetActor.position - selfActorAdapter.position).normalized;
                    }
                    else
                    {
                        result = selfActorAdapter?.forward ?? Vector3.forward;
                    }
                }
            }
            else if (coorOrientation.orientationCoorType == OrientationCoorType.LookAtPoint)
            {
                if (selfActorAdapter != null)
                {
                    Vector3 targetPoint = GetCoordinatePoint(coorOrientation.coorPoint, selfActor, bIsTargetType);
                    result = (targetPoint - selfActorAdapter.position).normalized;
                }
            }
            else if (coorOrientation.orientationCoorType == OrientationCoorType.WorldCoor)
            {
                result = Vector3.forward;
            }
            else if(coorOrientation.orientationCoorType == OrientationCoorType.ActorLocalCoor)
            {
                result = actor2?.forward ?? Vector3.forward;
            }
            else if (coorOrientation.orientationCoorType == OrientationCoorType.ActorLineCoor)
            {
                ActorAdapter startActor = actor3 ?? selfActorAdapter;
                ActorAdapter endActor = actor4 ?? selfActorAdapter;
                if (startActor == null || endActor == null)
                {
                    result = Vector3.forward;
                }
                else if (startActor == endActor && startActor == selfActorAdapter)
                {
                    result = selfActorAdapter?.forward ?? Vector3.forward;
                }
                else
                {
                    result = (endActor.position - startActor.position).normalized;
                }
            }
            
            // 保底容错方向
            if (result == Vector3.zero)
            {
                result = Vector3.forward;
            }

            Vector3 offsetAngle = coorOrientation.offsetAngle + new Vector3(0f, coorOrientation.offsetAngleY, 0f);
            
            // 随机角度偏移
            Vector3 randomAngle = new Vector3(Random.Range(0f, coorOrientation.randomAngle.x), Random.Range(0f, coorOrientation.randomAngle.y), Random.Range(0f, coorOrientation.randomAngle.z));
            
            // 旋转偏移量
            result = (Quaternion.LookRotation(result) * Quaternion.Euler(offsetAngle + randomAngle) * Vector3.forward).normalized;

            _TryReleaseActorAdapter(selfActorAdapter);
            _TryReleaseActorAdapter(actor1);
            _TryReleaseActorAdapter(actor2);
            _TryReleaseActorAdapter(actor3);
            _TryReleaseActorAdapter(actor4);
            
            return result;
        }

        /// <summary>
        /// 获取该配置的参照点位置
        /// </summary>
        /// <returns></returns>
        public static Vector3 GetRefCoordinatePoint(this CoorPoint coorPoint, Actor selfActor, bool bIsTargetType, TransInfoCache cache = null)
        {
            Vector3 result = Vector3.zero;
            if (coorPoint.coorPointMode == CoorPointMode.CoorPoint)
            {
                if (coorPoint.coorOriginType == CoorOriginType.World)
                {
                    result = Vector3.zero;
                }
                else if (coorPoint.coorOriginType == CoorOriginType.Actor)
                {
                    ActorAdapter actor1 = null;
                    if (bIsTargetType)
                    {
                        // actor1 = selfActor?.GetTarget((TargetType)coorPoint.targetType1);
                        actor1 = _TryGetActorAdapter(selfActor, coorPoint.targetType1, coorPoint.recordTargetID1, cache); 
                    }
                    else
                    {
                        // actor1 = coorPoint.viActor1?.GetValue();
                        actor1 = _TryGetActorAdapter(coorPoint.viActor1?.GetValue());
                    }
                    result = actor1?.position ?? (selfActor?.transform?.position ?? Vector3.zero);
                    _TryReleaseActorAdapter(actor1);
                }
            }
            else if (coorPoint.coorPointMode == CoorPointMode.HangPoint)
            {
                if (coorPoint.hangPointData != null)
                {
                    if (selfActor?.model != null)
                    {
                        result = selfActor.GetDummy(coorPoint.hangPointData.name).position;
                    }
                }
            }

            return result;
        }

        /// <summary>
        /// 判断统一选点与统一选朝向配置是否合法.
        /// </summary>
        /// <param name="selfActor"></param>
        /// <param name="coorPoint"></param>
        /// <param name="coorOrientation"></param>
        /// <param name="bIsTargetType"></param>
        /// <returns></returns>
        public static bool IsValidCoorConfig(Actor selfActor, CoorPoint coorPoint, CoorOrientation coorOrientation, bool bIsTargetType, TransInfoCache cache = null)
        {
            if (!IsValidCoorPoint(selfActor, coorPoint, bIsTargetType, cache))
            {
                return false;
            }
            
            if (!IsValidCoorOrientation(selfActor, coorOrientation, bIsTargetType, cache))
            {
                return false;
            }
            
            return true;
        }

        public static bool IsValidCoorPoint(Actor selfActor, CoorPoint coorPoint, bool bIsTargetType, TransInfoCache cache = null)
        {
            if (coorPoint == null)
            {
                return false;
            }
            
            if (coorPoint.coorPointMode == CoorPointMode.CoorPoint)
            {
                switch (coorPoint.coorOriginType)
                {
                    case CoorOriginType.World:
                        break;
                    case CoorOriginType.Actor:
                    {
                        // Actor actor1 = bIsTargetType ? selfActor?.GetTarget((TargetType)coorPoint.targetType1) : coorPoint.viActor1.GetValue();
                        ActorAdapter actor1 = null;
                        if (bIsTargetType)
                        {
                            actor1 = _TryGetActorAdapter(selfActor, coorPoint.targetType1, coorPoint.recordTargetID1, cache);
                        }
                        else
                        {
                            actor1 = _TryGetActorAdapter(coorPoint.viActor1.GetValue());
                        }
                        _TryReleaseActorAdapter(actor1);
                        
                        if (actor1 == null)
                            return false;
                        break;
                    }
                }
            
                switch (coorPoint.coorOrientationType)
                {
                    case CoorOrientationType.World:
                        break;
                    case CoorOrientationType.Actor:
                    {
                        // Actor actor2 = bIsTargetType ? selfActor?.GetTarget((TargetType)coorPoint.targetType2) : coorPoint.viActor2.GetValue();
                        ActorAdapter actor2 = null;
                        if (bIsTargetType)
                        {
                            actor2 = _TryGetActorAdapter(selfActor, coorPoint.targetType2, coorPoint.recordTargetID2, cache);
                        }
                        else
                        {
                            actor2 = _TryGetActorAdapter(coorPoint.viActor2.GetValue());
                        }
                        _TryReleaseActorAdapter(actor2);
                        if (actor2 == null)
                            return false;
                        break;
                    }
                    case CoorOrientationType.Line:
                    {
                        // Actor actor2 = bIsTargetType ? selfActor?.GetTarget((TargetType)coorPoint.targetType2) : coorPoint.viActor2.GetValue();
                        
                        ActorAdapter actor2 = null;
                        if (bIsTargetType)
                        {
                            actor2 = _TryGetActorAdapter(selfActor, coorPoint.targetType2, coorPoint.recordTargetID2, cache);
                        }
                        else
                        {
                            actor2 = _TryGetActorAdapter(coorPoint.viActor2.GetValue());
                        }
                        _TryReleaseActorAdapter(actor2);
                        
                        if (actor2 == null)
                            return false;

                        // Actor actor3 = bIsTargetType ? selfActor?.GetTarget((TargetType)coorPoint.targetType3) : coorPoint.viActor3.GetValue();
                        
                        ActorAdapter actor3 = null;
                        if (bIsTargetType)
                        {
                            actor3 = _TryGetActorAdapter(selfActor, coorPoint.targetType3, coorPoint.recordTargetID3, cache);
                        }
                        else
                        {
                            actor3 = _TryGetActorAdapter(coorPoint.viActor3.GetValue());
                        }
                        _TryReleaseActorAdapter(actor3);
                        
                        if (actor3 == null)
                            return false;

                        break;
                    }
                }
            }
            else if (coorPoint.coorPointMode == CoorPointMode.HangPoint)
            {
                if (coorPoint.hangPointData == null)
                {
                    return false;
                }

                if (selfActor == null)
                {
                    return false;
                }
            }
            
            return true;
        }

        public static bool IsValidCoorOrientation(Actor selfActor, CoorOrientation coorOrientation, bool bIsTargetType, TransInfoCache cache = null)
        {
            switch (coorOrientation.orientationCoorType)
            {
                case OrientationCoorType.LookAtActor:
                {
                    // Actor actor1 = bIsTargetType ? selfActor?.GetTarget((TargetType)coorOrientation.targetType1) : coorOrientation.viActor1.GetValue();
                    ActorAdapter actor1 = null;
                    if (bIsTargetType)
                    {
                        actor1 = _TryGetActorAdapter(selfActor, coorOrientation.targetType1, coorOrientation.recordTargetID1, cache);
                    }
                    else
                    {
                        actor1 = _TryGetActorAdapter(coorOrientation.viActor1.GetValue());
                    }
                    _TryReleaseActorAdapter(actor1);
                    
                    if (actor1 == null)
                        return false;
                }
                    break;
                case OrientationCoorType.LookAtPoint:
                {
                    if (!IsValidCoorPoint(selfActor, coorOrientation.coorPoint, bIsTargetType))
                    {
                        return false;
                    }
                }
                    break;
                case OrientationCoorType.WorldCoor:
                    break;
                case OrientationCoorType.ActorLocalCoor:
                {
                    // Actor actor2 = bIsTargetType ? selfActor?.GetTarget((TargetType)coorOrientation.targetType2) : coorOrientation.viActor1.GetValue();
                   
                    ActorAdapter actor2 = null;
                    if (bIsTargetType)
                    {
                        actor2 = _TryGetActorAdapter(selfActor, coorOrientation.targetType2, coorOrientation.recordTargetID2, cache);
                    }
                    else
                    {
                        actor2 = _TryGetActorAdapter(coorOrientation.viActor1.GetValue());
                    }
                    _TryReleaseActorAdapter(actor2);
                    
                    if (actor2 == null)
                        return false;
                    break;
                }
                case OrientationCoorType.ActorLineCoor:
                {
                    // Actor actor3 = bIsTargetType ? selfActor?.GetTarget((TargetType)coorOrientation.targetType3) : coorOrientation.viActor1.GetValue();
                    
                    ActorAdapter actor3 = null;
                    if (bIsTargetType)
                    {
                        actor3 = _TryGetActorAdapter(selfActor, coorOrientation.targetType3, coorOrientation.recordTargetID3, cache);
                    }
                    else
                    {
                        actor3 = _TryGetActorAdapter(coorOrientation.viActor1.GetValue());
                    }
                    _TryReleaseActorAdapter(actor3);
                    
                    if (actor3 == null)
                        return false;
                    
                    // Actor actor4 = bIsTargetType ? selfActor?.GetTarget((TargetType)coorOrientation.targetType4) : coorOrientation.viActor2.GetValue();
                    ActorAdapter actor4 = null;
                    if (bIsTargetType)
                    {
                        actor4 = _TryGetActorAdapter(selfActor, coorOrientation.targetType4, coorOrientation.recordTargetID4, cache);
                    }
                    else
                    {
                        actor4 = _TryGetActorAdapter(coorOrientation.viActor2.GetValue());
                    }
                    _TryReleaseActorAdapter(actor4);
                    
                    if (actor4 == null)
                        return false;
                    break;
                }
            }

            return true;
        }
        
        public static void DrawFlowNodePoint(this BattleFlowNode battleFlowNode, CoorPoint coorPoint, bool isSecond = false)
        {
            if (coorPoint == null)
                return;
            if (coorPoint.coorPointMode != CoorPointMode.CoorPoint)
                return;
            if (coorPoint.coorOriginType == CoorOriginType.Actor)
            {
                coorPoint.viActor1 = battleFlowNode.AddValueInput<Actor>(!isSecond ? "OriginActor" : "OriginActor2");
            }

            if (coorPoint.coorOrientationType == CoorOrientationType.Actor)
            {
                coorPoint.viActor2 = battleFlowNode.AddValueInput<Actor>(!isSecond ? "LookAtActor" : "LookAtActor2");
            }

            if (coorPoint.coorOrientationType == CoorOrientationType.Line)
            {
                coorPoint.viActor2 = battleFlowNode.AddValueInput<Actor>(!isSecond ? "LinePointStart" : "LinePointStart2");
                coorPoint.viActor3 = battleFlowNode.AddValueInput<Actor>(!isSecond ? "LinePointEnd" : "LinePointEnd2");
            }

            if (coorPoint.coorPointMode == CoorPointMode.CoorPoint)
            {
                coorPoint.viOffsetPos = battleFlowNode.AddValueInput<Vector3>(!isSecond ? "OffsetPos" : "OffsetPos2");
            }
        }

        public static void DrawFlowNodeOrientation(this BattleFlowNode battleFlowNode, CoorOrientation coorOrientation, bool isSecond = false)
        {
            if (coorOrientation == null)
                return;
            if (coorOrientation.orientationCoorType == OrientationCoorType.LookAtActor)
            {
                coorOrientation.viActor1 = battleFlowNode.AddValueInput<Actor>(!isSecond ? "LookAtActor" : "LookAtActor2");
            }
            else if (coorOrientation.orientationCoorType == OrientationCoorType.LookAtPoint)
            {
                DrawFlowNodePoint(battleFlowNode, coorOrientation.coorPoint);
            }
            else if (coorOrientation.orientationCoorType == OrientationCoorType.ActorLocalCoor)
            {
                coorOrientation.viActor1 = battleFlowNode.AddValueInput<Actor>(!isSecond ? "LocalActor" : "LocalActor2");
            }
            else if (coorOrientation.orientationCoorType == OrientationCoorType.ActorLineCoor)
            {
                coorOrientation.viActor1 = battleFlowNode.AddValueInput<Actor>(!isSecond ? "LineOrientationStart" : "LineOrientationStart2");
                coorOrientation.viActor2 = battleFlowNode.AddValueInput<Actor>(!isSecond ? "LineOrientationEnd" : "LineOrientationEnd2");
            }
        }
    }
}