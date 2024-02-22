using System;
using ParadoxNotion.Design;
using NodeCanvas.Framework;
using NodeCanvas.Tasks.Actions;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle")]
    [Description("获取范围内最近或最远的（获取仇恨列表中可锁定的）敌人节点")]
    public class GetTargetByDistance : BattleAction
    {
        // 获取目标时目标类型
        public enum TargetTypeByDistance
        {
            nearest, //最近
            farthest //最远
        }

        [Tooltip("如果此值为空，则取自身")] public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<TargetTypeByDistance> targetType = new BBParameter<TargetTypeByDistance>();
        public BBParameter<float> radius = new BBParameter<float>();
        public BBParameter<Actor> storeResult = new BBParameter<Actor>();

        private struct TempHateData
        {
            public float sqrDistance;
            public int insId;
        }
        protected override void OnExecute()
        {
            var mainActor = source.isNoneOrNull ? _actor : source.value;
            var roleHates = mainActor.actorHate.hates;
            TempHateData maxDistanceTargetData = new TempHateData {sqrDistance = float.MinValue, insId = 0};
            TempHateData minDistanceTargetData = new TempHateData {sqrDistance = float.MaxValue, insId = 0};
            // float minDistance = float.MaxValue;
            // float maxDistance = 0f;
            float sqrRadius = radius.value * radius.value;
            foreach (var item in roleHates)
            {
                if (!item.lockable)
                {
                    continue;
                }
                PlayerHateData hate = item as PlayerHateData;
                TempHateData tempData = new TempHateData();
                if (hate == null)
                {
                    var actor = BattleUtil.GetActorByIDType(item.insId);
                    if (actor == null)
                    {
                        PapeGames.X3.LogProxy.LogError($"出现异常情况，{item.insId},获取到的单位为空！");
                        continue;
                    }
                    tempData.insId = item.insId;
                    // 这里是不考虑半径的情况 
                    tempData.sqrDistance = (actor.transform.position - mainActor.transform.position).sqrMagnitude;
                }
                else
                {
                    tempData.insId = hate.insId;
                    tempData.sqrDistance = hate.sqrDistance;
                }
                
                if (tempData.sqrDistance > sqrRadius)
                {
                    continue;
                }

                if (tempData.sqrDistance > maxDistanceTargetData.sqrDistance)
                {
                    maxDistanceTargetData = tempData;
                }

                if (tempData.sqrDistance < minDistanceTargetData.sqrDistance)
                {
                    minDistanceTargetData = tempData;
                }
            }

            switch (targetType.value)
            {
                case TargetTypeByDistance.nearest:
                {
                    if (minDistanceTargetData.insId != 0)
                    {
                        storeResult.value = _battle.actorMgr.GetActor(minDistanceTargetData.insId);
                    }
                }
                    break;
                case TargetTypeByDistance.farthest:
                {
                    if (maxDistanceTargetData.insId != 0)
                    {
                        storeResult.value = _battle.actorMgr.GetActor(maxDistanceTargetData.insId);
                    }
                }
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }

            EndAction(true);
        }
    }
}
