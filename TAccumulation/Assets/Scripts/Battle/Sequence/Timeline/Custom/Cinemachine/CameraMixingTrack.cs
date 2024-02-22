using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using Cinemachine;

namespace PapeGames
{
    [Serializable]
    [TrackClipType(typeof(CinemachineShot))]
#if !UNITY_2018_2_OR_NEWER
    [TrackMediaType(TimelineAsset.MediaType.Script)]
#endif
#if UNITY_2018_3_OR_NEWER
    [TrackBindingType(typeof(CinemachineBrain), TrackBindingFlags.None)]
#else
    [TrackBindingType(typeof(CinemachineBrain))]
#endif
    [TrackColor(0.53f, 0.0f, 0.08f)]
    public class CameraMixingTrack : CinemachineTrack
    {
        [NonSerialized] 
        private static List<string> _assistNameList;
        [HideInInspector]
        public bool bindBrain;
        
        public override Playable CreateTrackMixer(
            PlayableGraph graph, GameObject go, int inputCount)
        {

            if (_assistNameList == null)
            {
                _assistNameList = new List<string>();  
            }

            var clips = GetClipsArray();
            for (int i = 0; i < clips.Length; i++)
            {
                _assistNameList.Add(clips[i].displayName); 
            }

            var mixer = base.CreateTrackMixer(graph, go, inputCount);
            
            for (int i = 0; i < clips.Length; i++)
            {
                clips[i].displayName = _assistNameList[i];
            } 

            _assistNameList.Clear();
            
            return mixer;
        }
    }
}


