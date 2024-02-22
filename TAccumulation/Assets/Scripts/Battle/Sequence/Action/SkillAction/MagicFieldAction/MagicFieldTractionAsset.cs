using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Timeline;
using X3Battle.Timeline.Extension;

namespace X3Battle
{
    [TimelineMenu("技能动作(法术场)/法术场进行牵引")]
    [Serializable]
    public class MagicFieldTractionAsset : BSActionAsset<ActionTraction>
    {
        [LabelText("向心速度")] 
        public float speed = 1.0f;
    }

    public class ActionTraction : BSAction<MagicFieldTractionAsset>
    {
        private const float _thresholdDistance = 0.15f;
        private static List<Actor> _reuseActors = new List<Actor>(20);
        
        protected override void _OnEnter()
        {
            var skillMagicField = context.skill as SkillMagicField;
            if (skillMagicField == null)
                return;
            _UpdatePosition();
        }

        protected override void _OnUpdate()
        {
            _UpdatePosition();
        }

        private void _UpdatePosition()
        {
            var skillMagicField = context.skill as SkillMagicField;
            if (context.actor?.model == null)
            {
                return;
            }

            if (skillMagicField == null)
            {
                return;
            }
            
            var battle = context.battle;
            var actor = context.actor;
            var targetPosition = skillMagicField.shapeBox.GetCurWorldPos();
            var prevPosition = skillMagicField.shapeBox.GetPrevWorldPos();
            var angleY = skillMagicField.shapeBox.GetCurWorldEuler().y;
            var bundingShape = skillMagicField.shapeBox.GetBoundingShape();

            // DONE: 将收到牵引的目标筛选出来.
            var targets = _reuseActors;
            BattleUtil.PickAOETargets(
                battle,
                ref targets,
                targetPosition,
                prevPosition,
                new Vector3(0f, angleY, 0f),
                bundingShape,
                actor,
                false,
                null,
                false,
                null,
                skillMagicField.magicFieldCfg.Relationships,
                false);

            foreach (Actor target in targets)
            {
                if (target.isDead)
                    continue;

                if (target.stateTag == null || target.stateTag.IsActive(ActorStateTagType.TractionImmunity))
                {
                    continue;
                }

                if (target.model == null)
                {
                    continue;
                }
                
                //判断是否到中心的
                float distance = (context.actor.transform.position - target.transform.position).magnitude;
                var leftDistance = distance - _thresholdDistance;
                if (leftDistance <= 0)
                {
                    continue;
                }

                // DONE: 向心方向
                Vector3 centerForward = context.actor.transform.position - target.transform.position;
                centerForward.y = 0f;
                centerForward.Normalize();
                
                // 计算向心速度
                float weight = 0;
                if (target.type == ActorType.Hero || target.type == ActorType.Monster)
                {
                    weight = target.config.Weight;
                }

                if (weight <= 0 || weight > TbUtil.battleConsts.TractionWeight)
                {
                    continue;
                }

                float moveDistance = (clip.speed * TbUtil.battleConsts.TractionFactor) / (weight * weight) *  skillMagicField.GetDeltaTime();
                if (moveDistance > leftDistance)
                {
                    moveDistance = leftDistance;
                }
                // DONE: 向心速度
                var pos = target.transform.position + centerForward * moveDistance;
                // var trans = GameObject.CreatePrimitive(PrimitiveType.Sphere).transform;
                // trans.position = pos;
                // trans.localScale = Vector3.one * 0.25f;  
                target.transform.SetPosition(pos);
            }
        }   
    }
}