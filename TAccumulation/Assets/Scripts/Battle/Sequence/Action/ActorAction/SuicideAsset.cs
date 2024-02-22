using System;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色动作/自杀")]
    [Serializable]
    public class SuicideAsset : BSActionAsset<ActionSuicide>
    {
        [LabelText("是否跳过死亡技能和死亡动作模组")]
        public bool isSkipDeadEffect;
    }

    public class ActionSuicide : BSAction<SuicideAsset>
    {
        protected override void _OnEnter()
        {
            if (context.actor == null)
            {
                return;
            }

            if (clip.isSkipDeadEffect)
            {
                context.actor.mainState.SkipDeadEffect();
            }

            // DONE: 自杀.
            context.actor.Dead();
        }    
    }
}