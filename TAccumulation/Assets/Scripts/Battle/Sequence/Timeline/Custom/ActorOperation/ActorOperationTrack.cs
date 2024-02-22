using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace PapeGames
{
    /// <summary>
    /// 角色操作通用轨道
    /// </summary>
    [Serializable]
    [TrackClipType(typeof(ActorSetStencilClip))]
    [TrackBindingType(typeof(GameObject))]
    public class ActorOperationTrack : TrackAsset, IInterruptTrack
    {
        [HideInInspector] public TrackExtData extData = null;
    }
}