using System;
using UnityEngine.Timeline;
using X3Battle.Timeline;

namespace X3Battle
{
    [TimelineMenu("技能动作(法术场)/循环播放")]
    [Serializable]
    public class MagicFieldLoopAsset: BSActionAsset<ActionLoop>
    {
    }

    public class ActionLoop : BSAction<MagicFieldLoopAsset>
    {
        protected override void _OnExit()
        {
            var timeline = battleSequencer;
            if (timeline != null)
            {
                if (timeline.bsState == BSState.Playing)
                {
                    timeline.SetTime(cfgStartTime);
                }
            }
        }
    }
}