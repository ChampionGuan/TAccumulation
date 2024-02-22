using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    public class ActionFxPlayer : BSAction
    {
        protected GameObject go;
        protected FxPlayer fx;
        protected ControlTrack.TimeScaleType timeScaleType;

        protected override void _OnInit()
        {
            needInterruptNotify = true;
            needLateUpdate = true;//由于设置位置在LateUpdate所以fx也在

            var track = GetTrackAsset<ControlTrack>();
            timeScaleType = track.timeScaleType;

            var clip = GetClipAsset<ControlPlayableAsset>();
            go = GetExposedValue(clip.sourceGameObject);
            if (go == null)
                return;

            fx = go.GetComponent<FxPlayer>();
            if (fx == null)
                return;

            fx.isAutoPlay = false;
            fx.SetDuration(duration + clipInTime);
            fx.InitFadeOut();//仅战斗，支持淡出
        }

        protected override void _OnEnter()
        {
            if (fx == null)
                return;

            fx.RePlay();
        }

        protected override void _OnLateUpdate()
        {
            if (fx == null)
                return;

            _UpdateFxTime();//对于跳时间,需先update时间
            LoopEnd();
        }

        protected void _UpdateFxTime()
        {
            if (timeScaleType == ControlTrack.TimeScaleType.Actor)
                fx.SetPlayTime(finalCurOffsetTime);
            else if (timeScaleType == ControlTrack.TimeScaleType.Battle)
                fx.OnUpdate(context.battle.deltaTime);
            else if (timeScaleType == ControlTrack.TimeScaleType.UnScale)
                fx.OnUpdate(context.battle.unscaledDeltaTime);
        }

        protected void LoopEnd()
        {
            if (!fx.isLoop || fx.IsEndState || fx.IsDestroy)
                return;

            if (duration + clipInTime - finalCurOffsetTime < fx.endTime)
            {
                fx.Stop();
            }
        }

        protected override void _OnInterruptNotify()
        {
            if (fx == null)
                return;
            var trackData = GetTrackAsset<ControlTrack>().extData;
            if (trackData != null && trackData.isStopByTime)// 因时间而结束(不随打断结束)
            {
            }
            else
            {
                //TODO 因为淡出设计与Active轨冲突,所以重新打开一下 后面改为正式
                go.SetActiveAndVisible(true, true);
                var fadeTime = Mathf.Min(remainTime, TbUtil.battleConsts.FxFadeOutTime);
                fx.Stop(fadeTime);
            }
        }

        protected override void _OnExit()
        {
            if (fx == null)
                return;

            fx.Stop(true);//一定结束并隐藏
        }
    }
}