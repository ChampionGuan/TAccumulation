using System.Collections.Generic;
using NodeCanvas.Framework;
using ParadoxNotion;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Description("计算到目标周围的圆环最近的一点")]
    [Name("计算到目标周围的圆环最近的一点")]
    public class NASelectPointClosestRing: BattleAction
    {
        public BBParameter<Actor> target = new BBParameter<Actor>();
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<float> minMinDistance = new BBParameter<float>();
        public BBParameter<float> maxMaxDistance = new BBParameter<float>();
        public BBParameter<Vector3> resultPos = new BBParameter<Vector3>();
        
        protected override void OnExecute()
        {
            var actor = target.isNoneOrNull ? _actor : target.value;
            Vector3 targetPos = actor.transform.position;
            
            var sourceActor = source.isNoneOrNull ? _actor : source.value;
            Vector3 sourcePos = sourceActor.transform.position;

            Vector3 direction = sourcePos - targetPos;

            //两单位之间的坐标距离
            float distance = direction.magnitude;
            if (distance <= maxMaxDistance.value && distance >= minMinDistance.value)
            {
                //已经在圆环内部了
                this.resultPos.SetValue(sourcePos);
                EndAction(false);
                return;
            }
            
            if (direction == Vector3.zero)
            {
                direction = Vector3.forward;
            }

            Vector3 tempResultPos = Vector3.zero;
            direction.Normalize();
            if (distance < minMinDistance.value)
            {
                //在内圈里面
                float testDistance = minMinDistance.value - distance;
                Vector3 selectPoint = targetPos + direction * minMinDistance.value;
                Vector3 sourcePosToSelectPoint = selectPoint - sourcePos;
                bool findAirWall = BattleUtil.IsFindAirWall(sourcePos,Vector3.Normalize(sourcePosToSelectPoint), sourcePosToSelectPoint.magnitude);
                if (!findAirWall && BattleUtil.IsInNavMesh(selectPoint))
                {
                    //最近点就已经找到了
                    resultPos.SetValue(selectPoint);
                    EndAction(true);
                    return;
                }

                while (testDistance <= minMinDistance.value + distance)
                {
                    //先大致定一个累积频率
                    testDistance += Random.Range(1.0f, 5.0f);
                    Vector2 p1;
                    Vector2 p2;
                    int pointCount = BattleUtil.FindCircleCircleIntersections(new Vector2(sourcePos.x, sourcePos.z), testDistance,
                        targetPos, minMinDistance.value, out p1, out p2);
                    if (pointCount <= 0)
                    {
                        break;
                    }

                    if (Random.Range(0, 2) < 1)
                    {
                        selectPoint.x = p1.x;
                        selectPoint.z = p1.y;
                    }
                    else
                    {
                        selectPoint.x = p2.x;
                        selectPoint.z = p2.y;
                    }
                    findAirWall = BattleUtil.IsFindAirWall(sourcePos,Vector3.Normalize(sourcePosToSelectPoint), sourcePosToSelectPoint.magnitude);
                    if (!findAirWall && BattleUtil.IsInNavMesh(selectPoint))
                    {
                        //最近点就已经找到了
                        resultPos.SetValue(selectPoint);
                        EndAction(true);
                        return;
                    }

                }
            }
            else
            {
                //在外圈外面
                float testDistance = distance - maxMaxDistance.value;
                Vector3 selectPoint = targetPos + direction * maxMaxDistance.value;
                Vector3 sourcePosToSelectPoint = selectPoint - sourcePos;
                bool findAirWall = BattleUtil.IsFindAirWall(sourcePos,Vector3.Normalize(sourcePosToSelectPoint), sourcePosToSelectPoint.magnitude);
                if (!findAirWall && BattleUtil.IsInNavMesh(selectPoint))
                {
                    //最近点就已经找到了
                    resultPos.SetValue(selectPoint);
                    EndAction(true);
                    return;
                }

                while (testDistance <= distance)
                {
                    //先大致定一个累积频率
                    testDistance += Random.Range(1.0f, 5.0f);
                    Vector2 p1;
                    Vector2 p2;
                    int pointCount = BattleUtil.FindCircleCircleIntersections(new Vector2(sourcePos.x, sourcePos.z), testDistance,
                        targetPos, minMinDistance.value, out p1, out p2);
                    if (pointCount <= 0)
                    {
                        break;
                    }
                    if (Random.Range(0, 2) < 1)
                    {
                        selectPoint.x = p1.x;
                        selectPoint.z = p1.y;
                    }
                    else
                    {
                        selectPoint.x = p2.x;
                        selectPoint.z = p2.y;
                    }
                    findAirWall = BattleUtil.IsFindAirWall(sourcePos,Vector3.Normalize(sourcePosToSelectPoint), sourcePosToSelectPoint.magnitude);
                    if (!findAirWall && BattleUtil.IsInNavMesh(selectPoint))
                    {
                        //最近点就已经找到了
                        resultPos.SetValue(selectPoint);
                        EndAction(true);
                        return;
                    }
                }
            }
            
            this.resultPos.SetValue(tempResultPos);
            EndAction(true);
        }
    }
    
}
