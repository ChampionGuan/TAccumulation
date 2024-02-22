using System;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TrackClipYellowColor]
    [TimelineMenu("角色动作/显示残影")]
    [Serializable]
    public class ShadowActiveAsset : BSActionAsset<ActionShadowActive>
    {
        [LabelText("残影数据路径")]
        public string shadowDataPath;
    }

    public class ActionShadowActive : BSAction<ShadowActiveAsset>
    {
        
        protected override void _OnEnter()
        {
            context.actor.shadowPlayer?.StartShadow(clip.shadowDataPath);
        }

        protected override void _OnExit()
        {
            context.actor.shadowPlayer?.StopShadow();
        }
    }
}