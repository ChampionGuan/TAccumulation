using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/移除Buff")]
    [Serializable]
    public class RemoveBuffAsset : BSActionAsset<ActionRemoveBuff>
    {
        [Serializable]
        public class BuffRemoveParam
        {
            [LabelText("buffID", jumpType:JumpModuleType.ViewBuff)]
            public int bufId;

            [LabelText("勾选则削减层数")]
            [Tooltip("勾选时移除对应层数，默认不勾选，直接无视层数移除buff")]
            public bool reduceStack;
            
            [LabelText("削减层数", showCondition = "reduceStack")]
            public int stackCount;
        }
        
        [LabelText("目标类型")]
        public TargetType targetType;
        [LabelText("Buff")]
        public List<BuffRemoveParam> buffs;
    }

    public class ActionRemoveBuff : BSAction<RemoveBuffAsset>
    {
        protected override void _OnEnter()
        {
            var target = context.actor.GetTarget(clip.targetType);
            if (target != null && clip.buffs != null && clip.buffs.Count > 0)
            {
                for (int i = 0; i < clip.buffs.Count; i++)
                {
                    var param = clip.buffs[i];
                    if (param.reduceStack)
                    {
                        // 削减层数
                        target.buffOwner.ReduceStack(param.bufId, param.stackCount); 
                    }
                    else
                    {
                        // 移除buff
                        target.buffOwner.Remove(param.bufId);
                    }
                }
            }        
        }    
    }
}