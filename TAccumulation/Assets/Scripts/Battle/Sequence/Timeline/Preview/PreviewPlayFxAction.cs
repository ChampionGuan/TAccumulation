using UnityEngine;
using X3Battle.Timeline.Extension;

namespace X3Battle.Timeline.Preview
{
    // 预览播放特效
    public class PreviewPlayFxAction : PreviewActionBase
    {
#if UNITY_EDITOR
        protected override void OnInit()
        {
            TbUtil.Init();
        }

        protected override void OnEnter()
        {
            var playFxAsset = GetRunTimeAction<PlayFxAsset>();
            var _fxMgr = new FxMgr(null);
            _fxMgr.PlayBattleFx(playFxAsset.FxID);
        }
#endif
    }
}
