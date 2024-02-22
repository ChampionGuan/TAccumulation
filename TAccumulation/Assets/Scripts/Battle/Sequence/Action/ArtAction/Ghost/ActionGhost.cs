using PapeGames.CutScene;
using UnityEngine;
using UnityEngine.Profiling;

namespace X3Battle
{
    public class ActionGhost : BSAction
    {
        private GhostActionItem _ghostActionItem = new GhostActionItem();
        
        protected override void _OnInit()
        {
            base._OnInit();

            var track = GetTrackAsset<GhostTrack>();
            var bindObj = GetTrackBindObj<GameObject>();
            var clipAsset = GetClipAsset<GhostClip>();

            _ghostActionItem.SetTrackInfo(bindObj, clipAsset.colorCurve, null, clipAsset.animationClip,
                clipAsset.ghostParam, track.referTarget, clipAsset.pool);
            _ghostActionItem.PreloadGhostItem(duration);
            _ghostActionItem.SetGhostShaderData(clipAsset.ghostShaderData);
            _ghostActionItem.FindBoneSrc();
            _ghostActionItem.SetFadeScale(clipAsset.fadeScale);
        }


        // 开始
        protected override void _OnEnter()
        {
            base._OnEnter();
            using (ProfilerDefine.ActionGhostOnStartMarker.Auto())
            {
                _ghostActionItem.OnStart(this.track.curTime);
            }
        }

        // 帧更新
        protected override void _OnUpdate()
        {
            base._OnUpdate();
            using (ProfilerDefine.ActionGhostOnProcessFrameMarker.Auto())
            {
                _ghostActionItem.OnProcessFrame(this.track.curTime);
            }
        }

        // 结束
        protected override void _OnExit()
        {
            base._OnExit();
            using (ProfilerDefine.ActionGhostOnStopFrameMarker.Auto())
            {
                _ghostActionItem.OnStop();
            }
        }
    }
}