using System;
using UnityEngine;
using X3Battle.Timeline.Extension;
using X3Battle.Timeline.Preview.Sequence;

namespace X3Battle.Timeline.Preview
{
    public class PreviewPPV : PreviewActionBase
    {
#if UNITY_EDITOR
        private PreviewSequencer _sequencer;
        private float _playTime;
        private bool _end;

        protected override void OnInit()
        {
            var clip = GetRunTimeAction<PlayPPVAsset>();
            if (clip == null)
                return;

            if (string.IsNullOrEmpty(clip.path))
                return;

            _sequencer = new PreviewSequencer(clip.path);
        }

        protected override void OnEnter()
        {
            var clip = GetRunTimeAction<PlayPPVAsset>();
            if (clip == null)
                return;
            if (_sequencer == null)
                return;

            if (string.IsNullOrEmpty(clip.path))
                return;

            //Debug.LogError("OnEnter");
            _playTime = 0;
            _end = false;
            if (Camera.main != null)
            {
                _sequencer.artObj.transform.SetParent(Camera.main.transform);
                _sequencer.artObj.transform.localPosition = Vector3.zero;
                _sequencer.artObj.transform.localEulerAngles = Vector3.zero;
            }
            if (clip.stopType == PlayPPVAsset.StopType.EnterPlay ||
                clip.stopType == PlayPPVAsset.StopType.ClipDutaion)
                _sequencer.Play();
            else if (clip.stopType == PlayPPVAsset.StopType.PeriodTime)
                _sequencer.Play();
            else if (clip.stopType == PlayPPVAsset.StopType.EnterStop)
                _sequencer.Stop();
        }

        protected override void OnUpdate(float deltaTime)
        {
            var clip = GetRunTimeAction<PlayPPVAsset>();
            if (clip == null)
                return;
            if (_sequencer == null)
                return;

            //Debug.LogError("Update:" + deltaTime);
            _playTime += deltaTime;
            _sequencer.Update(deltaTime);
            if(!_end && clip.stopType == PlayPPVAsset.StopType.PeriodTime && _playTime >= clip.time)
            {
                _end = true;
                //Debug.LogError("End:" + deltaTime);
                _sequencer.StopLoopState();
            }
        }

        protected override void OnExit()
        {
            var clip = GetRunTimeAction<PlayPPVAsset>();
            if (clip == null)
                return;

            if (_sequencer == null)
                return;
            //Debug.LogError("OnExit:");
            _sequencer.Stop();
        }

        protected override void OnDestroy()
        {
            if (_sequencer == null)
                return;

            _sequencer.Destroy();
        }
#endif
    }
}