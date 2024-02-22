using System;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("角色运动/设置FootIK")]
    [Serializable]
    public class FootIkAsset : BSActionAsset<ActionFootIk>
    {
        [LabelText("是否开启FootIK")]
        public bool enable = true;

        [LabelText("缓动时间(小于0为无效值)")]
        public float dampTime = 0.4f;

        [LabelText("结束时恢复")]
        public bool recover = false;
    }

    public class ActionFootIk:BSAction<FootIkAsset>
    {
        private float _formerDampTime;
        protected override void _OnEnter()
        {
            if (clip.recover)
            {
                _formerDampTime = context.actor.locomotionView.dampTime;
            }
            context.actor.locomotionView.EnableFootIk(clip.enable, clip.dampTime);
        }

        protected override void _OnExit()
        {
            if(clip.recover)
                context.actor.locomotionView.EnableFootIk(!clip.enable, _formerDampTime);
        }
    }
}
