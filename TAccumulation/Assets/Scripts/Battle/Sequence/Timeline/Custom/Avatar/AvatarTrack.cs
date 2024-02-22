using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using PapeGames.X3;

namespace PapeGames
{
    [Serializable]
    [TrackClipType(typeof(AvatarClip))]
    [TrackBindingType(typeof(GameObject))]
    public class AvatarTrack : TrackAsset, IInterruptTrack
    {
        [HideInInspector] public TrackExtData extData = null;
        
        // 序列化到Track上，用于生成分身用
        [LabelText("分身材质")]
        public Material material;

#if UNITY_EDITOR
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            // 非运行时走这个逻辑
            if (!Application.isPlaying && go != null)
            {
                var director = go.GetComponent<PlayableDirector>();
                if (director != null)
                {
                    var bindObj = director.GetGenericBinding(this) as GameObject;
                    if (bindObj != null && bindObj.CompareTag("player"))
                    {
                        var parent = bindObj.transform.parent;
                        if (parent != null)
                        {
                            var strSuitId = TimelineExtInfo.StripConstName(parent.name);
                            if (TimelineExtInfo.TryConvertSuitID(strSuitId, out int iSuitId))
                            {
                                foreach (var timelineClip in GetClipsArray())
                                {
                                    if (timelineClip.asset is AvatarClip avatar)
                                    {
                                        avatar.bindSuitID = iSuitId;
                                        avatar.bindMmaterial = material;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return base.CreateTrackMixer(graph, go, inputCount);
        }
#endif
    }
}