using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace PapeGames
{
    [Serializable]
    [TrackClipType(typeof(ChangeWeaponClip))]
    [TrackBindingType(typeof(GameObject))]
    public class ChangeWeaponTrack : TrackAsset, IInterruptTrack
    {
        [HideInInspector] public TrackExtData extData = null;  
    }
}