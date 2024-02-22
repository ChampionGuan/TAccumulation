using System;
using UnityEngine.Timeline;
using X3Battle.Timeline.Extension;
using X3Battle.Timeline.Preview;

namespace X3Battle
{
    [PreviewActionCreator(typeof(PreviewWarnEffect))]
    [TrackClipYellowColor]
    [TimelineMenu("角色动作/播放预警特效")]
    [Serializable]
    public class PlayWarnFxAsset : BSActionAsset<ActionPlayWarnFx>
    {
        public WarnEffectData warnEffectData;
    }
    
    public class ActionPlayWarnFx: BSAction<PlayWarnFxAsset>
    {
        public FxPlayer fxObj = null;
        public bool ifFollow = false; // 是否有跟随逻辑.
        public float remainFollowTime = 0f;

        protected override void _OnEnter()
        {
            // DONE: 设置是否跟随.
            switch (clip.warnEffectData.warnEffectType)
            {
                case WarnEffectType.Shine:
                case WarnEffectType.Ray:
                case WarnEffectType.Lock:
                    ifFollow = false;
                    break;
                case WarnEffectType.Circle:
                case WarnEffectType.Sector:
                case WarnEffectType.Rectangle:
                    ifFollow = clip.warnEffectData.ifFollow;
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
            
            remainFollowTime = clip.warnEffectData.followStopTime;
            
            // DONE: 设置duration.
            SetWarnEffectDuration(clip.warnEffectData, duration);

            fxObj = context.actor.effectPlayer.PlayWarnFx(clip.warnEffectData);

            if (fxObj != null)
                fxObj.SetPlayTime(0);//由于action此帧只做Start 手动update一下
        }

        protected override void _OnUpdate()
        {
            if (fxObj == null)
                return;

            if (fxObj.isLoop && fxObj.IsRunning)
            {
                if (remainTime < fxObj.endTime)
                    fxObj.Stop();
            }
            fxObj.SetPlayTime(curOffsetTime);

            if (!ifFollow)
                return;
            if (remainFollowTime > 0f)
            {
                remainFollowTime -= deltaTime;
            }
            
            if (remainFollowTime <= 0f)
            {
                // DONE: 停止跟随, 设置特效不跟随.
                ifFollow = false;
                fxObj.SetParentNull();
            }
        }

        protected override void _OnExit()
        {
            if (fxObj == null)
            {
                return;
            }
            context.actor.effectPlayer.StopWarnFx(fxObj);
        }

        public static void SetWarnEffectDuration(WarnEffectData warnEffectData, float duration)
        {
            switch (warnEffectData.warnEffectType)
            {
                case WarnEffectType.Shine:
                    break;
                case WarnEffectType.Ray:
                    warnEffectData.rayWarnData.duration = duration;
                    break;
                case WarnEffectType.Lock:
                    break;
                case WarnEffectType.Circle:
                    warnEffectData.circleWarnData.duration = duration;
                    break;
                case WarnEffectType.Sector:
                    warnEffectData.sectorWarnData.duration = duration;
                    break;
                case WarnEffectType.Rectangle:
                    warnEffectData.rectangleWarnData.duration = duration;
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
        }
    }
}