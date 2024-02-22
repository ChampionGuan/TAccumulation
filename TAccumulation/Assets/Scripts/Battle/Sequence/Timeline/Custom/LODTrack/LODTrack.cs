using System;

namespace UnityEngine.Timeline
{
    [Serializable]
    [TrackClipType(typeof(LODClip))]
    [TrackBindingType(typeof(GameObject))]
    public class LODTrack : TrackAsset, IInterruptTrack
    {
        [HideInInspector] public TrackExtData extData = null;
    }
}