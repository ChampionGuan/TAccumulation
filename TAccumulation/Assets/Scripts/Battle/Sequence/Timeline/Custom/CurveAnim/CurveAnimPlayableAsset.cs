using System;
using UnityEngine.Playables;
using BattleCurveAnimator;
using System.Collections.Generic;
using System.Linq;
using PapeGames.CurveCore.Runtime;

namespace UnityEngine.Timeline
{
    [Serializable]
    public class CurveAnimPlayableAsset : InterruptClip, ITimelineClipAsset
    {
        [NonSerialized] public CurveAnimBehaviour AnimBehaviour;
        [NonSerialized] private GameObject _bindObj;
        [NonSerialized] private float _clipDuration;
        //会执行SerializedProperty.Get_isValid()消耗很高 但是hide就不会执行了
        //并且仅RYUltraSkill的这个Clip会有高消耗问题..
        //[HideInInspector] 
        public MultiAnimData multiAnimData;

        public ClipCaps clipCaps { get => ClipCaps.SpeedMultiplier; }

        public void SetBindObj(GameObject bindObj, float duration)
        {
            _bindObj = bindObj;
            _clipDuration = duration;
        }

        public GameObject GetBindObj()
        {
            return _bindObj;
        }


        protected override Playable OnCreateInterruptPlayable(PlayableGraph graph, GameObject owner, out InterruptBehaviour interruptBehaviour)
        {
            var playable = ScriptPlayable<CurveAnimBehaviour>.Create(graph);
            playable.GetBehaviour().multiAnimData = multiAnimData;
            playable.GetBehaviour().clipDuration = _clipDuration;
            AnimBehaviour = playable.GetBehaviour();
            interruptBehaviour = AnimBehaviour;
            return playable;
        }
    }
}