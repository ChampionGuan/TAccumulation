using System;
using UnityEngine.Playables;

namespace UnityEngine.Timeline
{
    /// <summary>
    /// 物理风场轨道资源
    /// </summary>
    [Serializable]
    [TrackClipType(typeof(PhysicsWindPlayableAsset))]
    [TrackClipType(typeof(PhysicsWindDynamicClip))]
    [TrackBindingType(typeof(GameObject))]
    public class PhysicsWindTrack : TrackAsset, IInterruptTrack
    {
        [HideInInspector] public TrackExtData extData = null;

        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            var timelineClips = GetClipsArray();
            for (int i = 0; i < timelineClips.Length; i++)
            {
                var timelineClip = timelineClips[i];
                var clip = timelineClip.asset as PhysicsWindPlayableAsset;
                if (clip != null)
                {
                    clip.Duration = (float)timelineClip.duration;
                }
                
                if (timelineClip.asset is PhysicsWindDynamicClip physicsWindDynamicClip)
                {
                    physicsWindDynamicClip.duration = (float)timelineClip.duration;
                    physicsWindDynamicClip.bindObj = go.GetComponent<PlayableDirector>()?.GetGenericBinding(this) as GameObject;
                }
            }
            return base.CreateTrackMixer(graph, go, inputCount);
        }
    }
}

