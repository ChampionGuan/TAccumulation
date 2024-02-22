using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace PapeGames
{
    [Serializable]
    [TrackClipType(typeof(DBFreezeClip))]
    [TrackClipType(typeof(SubSystemControlClip))]
    [TrackClipType(typeof(AnimDBMixClip))]
    [TrackClipType(typeof(PhysicsVelocityThresholdClip))]
    [TrackBindingType(typeof(GameObject))]
    public class SubSystemControlTrack : TrackAsset, IInterruptTrack
    {
        [HideInInspector] public TrackExtData extData = null;  
    }
}