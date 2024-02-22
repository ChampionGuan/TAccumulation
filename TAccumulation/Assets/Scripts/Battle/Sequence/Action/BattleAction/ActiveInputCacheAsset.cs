using System;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TrackClipYellowColor]
    [TimelineMenu("Battle动作/激活输入缓存使用 (仅限当前动作模组)")]
    [Serializable]
    public class ActiveInputCacheAsset : BSActionAsset<ActionActiveInputCache>
    {
        [LabelText("按键类型(多选)")]
        public PlayerBtnTypeFlag flag = (PlayerBtnTypeFlag)(-1);

        [LabelText("按键状态(多选)")] 
        public BtnStateInputFlag stateFlag = (BtnStateInputFlag)(-1);
    }

    public class ActionActiveInputCache : BSAction<ActiveInputCacheAsset>
    {
        protected override void _OnEnter()
        {
            bsSharedVariables.activeInputCache.Record(this, clip.flag, clip.stateFlag, context.actor.time);
        }

        protected override void _OnExit()
        {
            base._OnExit();
            bsSharedVariables.activeInputCache.SetEndTime(this, context.actor.time);
        }
    }
}