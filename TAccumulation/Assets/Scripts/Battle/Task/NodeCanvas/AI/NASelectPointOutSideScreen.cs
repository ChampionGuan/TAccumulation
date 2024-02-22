using System.Collections.Generic;
using NodeCanvas.Framework;
using ParadoxNotion;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Description("计算目标周围镜头外一点")]
    [Name("计算目标周围镜头外一点")]
    public class NASelectPointOutSideScreen : BattleAction
    {
        public BBParameter<Actor> target = new BBParameter<Actor>();
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<float> minMinDistance = new BBParameter<float>();
        public BBParameter<float> maxMaxDistance = new BBParameter<float>();
        public BBParameter<Vector3> resultPos = new BBParameter<Vector3>();

        //均匀控制
        private static readonly List<int> _tempArray = new List<int>
            { 0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180 };
        protected override void OnExecute()
        {
            var actor = target.isNoneOrNull ? _actor : target.value;
            Vector3 startPos = actor.transform.position;
            
            var sourceActor = source.isNoneOrNull ? _actor : source.value;
            Vector3 sourcePos = sourceActor.transform.position;

            Vector2 randomDirection = Random.insideUnitCircle;
            Vector3 direction = new Vector3(randomDirection.x, 0f, randomDirection.y);
            direction.Normalize();
            
            //策划说找不到的情况下返回0;
            Vector3 tempResultPos = Vector3.zero;
            //面向圆环的前半部分
            _tempArray.Shuffle();
            
            if (_TryFindPoint(direction, actor.radius, startPos, sourcePos,ref tempResultPos))
            {
                this.resultPos.SetValue(tempResultPos);
                EndAction(true);
                return;
            }
            
            //查找后半边
            direction = -direction;
            _TryFindPoint(direction, actor.radius, startPos, sourcePos, ref tempResultPos);
            this.resultPos.SetValue(tempResultPos);
            EndAction(true);
        }
        
        //条件是镜头外的点
        private bool _TryFindPoint(Vector3 direction,float radius,Vector3 targetPos,Vector3 sourcePos,ref Vector3 tempResultPoint)
        {
            bool isFindFinished = false;
            foreach (var angle in _tempArray)
            {
                Vector3 realDir = Quaternion.AngleAxis(angle, Vector3.up) * direction;
                float distance = Random.Range(minMinDistance.value, maxMaxDistance.value) + radius;
                Vector3 selectPoint = realDir * distance + targetPos;
                Vector3 sourcePosToSelectPoint = selectPoint - sourcePos;
                if (!BattleUtil.IsInNavMesh(selectPoint))
                {
                    continue;
                }
                bool findAirWall = BattleUtil.IsFindAirWall(sourcePos,Vector3.Normalize(sourcePosToSelectPoint), sourcePosToSelectPoint.magnitude);
                if (findAirWall)
                {
                    continue;
                }
                tempResultPoint = selectPoint;
                isFindFinished = true;
                //判断是否在镜头外
                if (!BattleUtil.GetPositionIsInViewByPosition(selectPoint))
                {
                    break;
                }
            }
            return isFindFinished;
        }
    }
}
