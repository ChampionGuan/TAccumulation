using System;
using UnityEngine.Playables;

namespace UnityEngine.Timeline
{
    [Serializable]
    public class InterruptClip : PlayableAsset, ITimelineClipAsset
    {
        public ClipCaps clipCaps
        {
            get { return OnGetClipCaps(); }
        }
        
        [NonSerialized] private InterruptBehaviour interruptBehaviour;

        public sealed override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            var playable = OnCreateInterruptPlayable(graph, owner, out interruptBehaviour);
            return playable;
        }

        // 虚函数：继承自InterruptClip的类只实现这个方法
        protected virtual Playable OnCreateInterruptPlayable(PlayableGraph graph, GameObject owner, out InterruptBehaviour interruptBehaviourParam)
        {
            interruptBehaviourParam = null;
            return default;
        }

        //虚函数
        protected virtual ClipCaps OnGetClipCaps()
        {
            return ClipCaps.None;
        }
    }
}