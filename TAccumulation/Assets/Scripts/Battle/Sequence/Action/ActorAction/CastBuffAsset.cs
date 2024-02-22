using System;
using System.Collections.Generic;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/释放Buff")]
    [Serializable]
    public class CastBuffAsset : BSActionAsset<ActionCastBuff>
    {
        [LabelText("目标类型")]
        public TargetType targetType;
        [LabelText("Buff")]
        public List<BuffAddParam> buffs;
    }

    public class ActionCastBuff : BSAction<CastBuffAsset>
    {
        protected override void _OnEnter()
        {
            var target = context.actor.GetTarget(clip.targetType);
            if (target == null)
            {
                return;
            }

            if (context.skill != null)
                target.buffOwner?.CreateBuffs(context.skill.level, clip.buffs, context.actor, context.skill);
            else
                target.buffOwner?.CreateBuffs(1, clip.buffs, context.actor);
        }

        protected override void _OnExit()
        {
            var target = context.actor.GetTarget(clip.targetType);
            if (target == null)
            {
                return;
            }
            
            for (int i = 0; i < clip.buffs.Count; i++)
            {
                if (clip.buffs[i].interrupted)
                {
                    target.buffOwner.Remove(clip.buffs[i].bufId);
                }
            }
        }   
    }
}