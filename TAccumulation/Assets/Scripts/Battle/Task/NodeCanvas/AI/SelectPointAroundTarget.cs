using System.Collections.Generic;
using NodeCanvas.Framework;
using ParadoxNotion;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Description("计算到目标周围范围内一点")]
    [Name("计算到目标周围范围内一点")]
    public class SelectPointAroundTarget : BattleAction
    {
        public BBParameter<Actor> target = new BBParameter<Actor>();
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<float> minMinDistance = new BBParameter<float>();
        public BBParameter<float> maxMaxDistance = new BBParameter<float>();
        public BBParameter<Vector3> resultPos = new BBParameter<Vector3>();

        //均匀控制
        private static readonly List<int> _tempArray = new List<int>{ -80, -70, -60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90 };
        protected override void OnExecute()
        {
            var actor = target.isNoneOrNull ? _actor : target.value;
            Vector3 startPos = actor.transform.position;
            
            var sourceActor = source.isNoneOrNull ? _actor : source.value;
            Vector3 sourcePos = sourceActor.transform.position;

            Vector3 direction = sourcePos - startPos;
            if (direction == Vector3.zero)
            {
                direction = Vector3.forward;
            }
            direction.Normalize();
            
            //面向圆环的前半部分
            _tempArray.Shuffle();
            
            //策划说找不到的情况下返回0;
            Vector3 tempResultPos = Vector3.zero;
            
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
                //判断是否在镜头内
                if (BattleUtil.GetPositionIsInViewByPosition(selectPoint))
                {
                    break;
                }
            }
            return isFindFinished;
        }
    }
}
