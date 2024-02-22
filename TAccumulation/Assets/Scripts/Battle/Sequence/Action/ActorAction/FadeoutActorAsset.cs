using System;
using System.Collections.Generic;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/隐藏范围内单位")]
    [Serializable]
    public class FadeoutActorAsset : BSActionAsset<ActionFadeoutActor>
    {
        [LabelText("范围半径")]
        public float radius;

        [LabelText("淡出渐变时间")]
        public float fadeoutChangingDuration;

        [LabelText("淡入渐变时间")]
        public float fadeinChangingDuration;
        
        [LabelText("忽略隐藏目标类型")]
        public TargetType targetType = TargetType.Lock;

        [LabelText("阵营关系")]
        public FactionRelationshipFlag relationShipFlag = FactionRelationshipFlag.Enemy;

        [LabelText("角色类型")]
        public ActorFlag actorTypeFlag = ActorFlag.Monster;
    }

    public class ActionFadeoutActor : BSAction<FadeoutActorAsset>
    {
        private List<int> _actorInsIDs = new List<int>(8);
        private float _sqrRadius;
        
        protected override void _OnInit()
        {
            _sqrRadius = clip.radius * clip.radius;
        }

        protected override void _OnEnter()
        {
            if (context.actor == null)
            {
                return;
            }
            
            _actorInsIDs.Clear();
            
            var targetActor = context.actor.GetTarget(clip.targetType);
            var actors = context.battle.actorMgr.actors;
            foreach (var actor in actors)
            {
                // 判断角色类型是否满足
                if (actor != targetActor && BattleUtil.ContainActorType(clip.actorTypeFlag, actor.config.Type))
                {
                    // 判断阵营类型是否满足
                    var containsShip = BattleUtil.ContainFactionRelationShip(clip.relationShipFlag, context.actor.GetFactionRelationShip(actor));
                    if (containsShip)
                    {
                        // 判断距离是否满足
                        var inRadius = (actor.transform.position - context.actor.transform.position).sqrMagnitude <= _sqrRadius;
                        if (inRadius)
                        {
                            actor.model.DissolveFade(clip.fadeoutChangingDuration, false); 
                            _actorInsIDs.Add(actor.insID); 
                        }
                    }
                }
            }
        }

        protected override void _OnExit()
        {
            if (context.actor == null)
            {
                return;
            }

            foreach (var insID in _actorInsIDs)
            {
                var actor = context.battle.actorMgr.GetActor(insID);
                if (actor != null)
                {
                    actor.model.DissolveFade(clip.fadeinChangingDuration, true);
                }
            }
        }
    }
}