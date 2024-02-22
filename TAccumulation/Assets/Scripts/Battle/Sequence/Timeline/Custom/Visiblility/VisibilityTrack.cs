using System;
namespace UnityEngine.Timeline
{
    [Serializable]
    [TrackClipType(typeof(VisibilityClip))]
    [TrackBindingType(typeof(GameObject))]
    public class VisibilityTrack:TrackAsset, IInterruptTrack
    {
        [HideInInspector] public TrackExtData extData = null; 
    }
}