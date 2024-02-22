using System;
using UnityEngine;
using X3Battle.Timeline.Extension;

namespace X3Battle.Timeline.Preview
{
    public class PreviewWarnEffect : PreviewActionBase
    {
#if UNITY_EDITOR

        private FxPlayer _fxPlayer;
        private FxMgr _fxMgr;

        protected override void OnEnter()
        {        
            TbUtil.Init();
            var playWarnFxAction = GetRunTimeAction<PlayWarnFxAsset>();
            if (playWarnFxAction == null)
            {
                return;
            }

            _fxMgr = new FxMgr(null);
            float duration = (float)GetDuration();
            ActionPlayWarnFx.SetWarnEffectDuration(playWarnFxAction.warnEffectData, duration);
            
            var warnEffectData = BattleUtil.ConvertWarnFxCfg(playWarnFxAction.warnEffectData);
            var actorPos = TimelinePreviewTool.instance.GetActorModel() ? TimelinePreviewTool.instance.GetActorModel().transform.position : Vector3.zero;
            warnEffectData.pos += actorPos;
            _fxPlayer = _fxMgr.PlayWarnFx(warnEffectData, 0);
            _fxPlayer.Init();
        }

        protected override void OnUpdate(float deltaTime)
        {
            var playWarnFxAction = GetRunTimeAction<PlayWarnFxAsset>();
            if (_fxPlayer.isLoop && _fxPlayer.IsRunning)
            {
                _fxPlayer?.SetPlayTime((float)GetCurTime());
                if (GetRemainTime() < _fxPlayer.endTime)
                    _fxPlayer.Stop();
            }
            _fxPlayer?.SetPlayTime((float)GetCurTime());
        }

        protected override void OnExit()
        {
            _fxMgr.OnDestroy();
            _fxMgr = null;
            _fxPlayer = null;
        }
#endif
    }
}