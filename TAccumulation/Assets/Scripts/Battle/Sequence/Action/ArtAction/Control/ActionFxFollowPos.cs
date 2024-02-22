using UnityEngine;
using UnityEngine.Timeline;

namespace X3Battle
{
    public class ActionFxFollowPos : BSAction
    {
        private Actor _followTarget; // 跟随的目标.
        private Transform _fxTrans; // 当前特效.
        private Vector3 _offsetPos; // 偏移
        private bool _enableFollow = false; // 是否启动跟随逻辑.

        protected override void _OnInit()
        {
            var track = GetTrackAsset<ControlTrack>();
            var clip = GetClipAsset<ControlPlayableAsset>();
            var go = GetExposedValue(clip.sourceGameObject);
            if (go == null)
            {
                return;
            }

            _fxTrans = go.transform;
            _followTarget = context.actor;
            _offsetPos = track.extData.localPosition;
            _enableFollow = track.extData.trackType == TrackExtType.IsolateEffect && track.extData.isFollowReferencePos && _followTarget != null && _fxTrans != null;

            if (_enableFollow)
            {
                needLateUpdate = true;
            }
        }

        protected override void _OnLateUpdate()
        {
            if (_enableFollow)
            {
                if (_fxTrans.position != _followTarget.transform.position)
                {
                    // TODO for 长空. 封个函数.
                    _fxTrans.position = _followTarget.transform.position + Quaternion.LookRotation(_followTarget.transform.forward) * _offsetPos;
                }
            }
        }
    }
}