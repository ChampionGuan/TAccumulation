using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace PapeGames
{
    [Serializable]
    [TrackClipType(typeof(ChangeSuitClip))]
    [TrackBindingType(typeof(GameObject))]
    public class ChangeSuitTrack : TrackAsset, IInterruptTrack
    {
        [HideInInspector] public TrackExtData extData = null;
        
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            if (extData != null && extData.bindSuitID > 0)
            {
                foreach (var timelineClip in GetClipsArray())
                {
                    if (timelineClip.asset is ChangeSuitClip changeSuitClip)
                    {
                        changeSuitClip.bindSuitID = extData.bindSuitID;
                    }
                }
            }
            return base.CreateTrackMixer(graph, go, inputCount);
        }
    }
}