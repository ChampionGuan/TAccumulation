using System;
using UnityEngine.Timeline;

namespace X3Battle
{
    [TimelineMenu("Battle动作/子弹时间")]
    [Serializable]
    public class BulletTimeAsset : BSActionAsset<ActionBulletTime>
    {
        [LabelText("缩放倍率")]
        public float scale = 1;
        
        [LabelText("持续时间 (-1一直持续)")]
        public float scaleDuration = -1;
    }

    public class ActionBulletTime : BSAction<BulletTimeAsset>
    {
        protected override void _OnEnter()
        {
            if (clip.scaleDuration <= 0)
            {
                context.battle.SetTimeScale(clip.scale, null, (int)LevelTimeScaleType.Bullet);   
            }
            else
            {
                context.battle.SetTimeScale(clip.scale, clip.scaleDuration, (int) LevelTimeScaleType.Bullet);
            }
        }    
    }
}