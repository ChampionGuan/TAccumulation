using System;
using UnityEngine.Playables;

namespace UnityEngine.Timeline
{
    public class LODClip: InterruptClip
    {
        public float LOD;
        [NonSerialized] public LODBehavior behaviour;

        protected override Playable OnCreateInterruptPlayable(PlayableGraph graph, GameObject owner, out InterruptBehaviour interruptBehaviour)
        {
            var playable = ScriptPlayable<LODBehavior>.Create(graph);
            behaviour = playable.GetBehaviour();
            behaviour.LOD = LOD;
            interruptBehaviour = behaviour;
            return playable;
        }
    }
}