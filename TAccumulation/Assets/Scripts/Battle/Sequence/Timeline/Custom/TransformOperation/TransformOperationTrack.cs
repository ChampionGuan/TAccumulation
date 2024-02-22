using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace PapeGames
{
    [Serializable]
    [TrackClipType(typeof(TransformOperationClip))]
    [TrackBindingType(typeof(GameObject))]
    public class TransformOperationTrack : TrackAsset, IInterruptTrack
    {
        [HideInInspector] public TrackExtData extData = null;      
    }
}