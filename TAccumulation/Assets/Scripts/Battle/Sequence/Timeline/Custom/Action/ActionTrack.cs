using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Serialization;
using UnityEngine.Timeline;

namespace X3Battle.Timeline.Extension
{
    [Serializable]
    [TrackClipType(typeof(PreviewActionAsset))]
    public class ActionTrack:TrackAsset, IInterruptTrack
    {
        private PreviewActionIContext _previewActionIContext;

        private BattleSequencer _logicBattleSequencer;
        
        [HideInInspector]
        public List<int> tags;
        
        // 设置环境包
        public void SetContext(PreviewActionIContext previewActionIContext)
        {
            _previewActionIContext = previewActionIContext;
        }
        
        // 设置运行时Timeline
        public void SetLogicTimeline(BattleSequencer logicBattleSequencer)
        {
            _logicBattleSequencer = logicBattleSequencer;
        }

        // 构建时设置参数到clip上
        public sealed override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            var timelineClips = GetClipsArray();
            for (int i = 0; i < timelineClips.Length; i++)
            {
                var timelineClip = timelineClips[i];
                var clip = timelineClip.asset as PreviewActionAsset;
                if (clip != null)
                {
                    // 设置clip时长
                    clip.SetDuration((float)timelineClip.duration);
                    // 设置环境包
                    clip.SetClipContext(_previewActionIContext);
                    clip.mDebugTrack = this;
                    clip.mDebugTimeline = this.timelineAsset;
                    clip.SetClipBattleTimeline(_logicBattleSequencer);
                } 
            }
            
            this._previewActionIContext = null;
            this._logicBattleSequencer = null;
            
            return base.CreateTrackMixer(graph, go, inputCount);
        }

        public override bool NeedCreateMarkerMenu()
        {
            return false;
        }
        
    }
}