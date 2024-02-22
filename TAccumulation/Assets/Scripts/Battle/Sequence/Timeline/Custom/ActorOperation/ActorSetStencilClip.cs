using System;
using System.Collections.Generic;
using UnityEngine.Playables;

namespace UnityEngine.Timeline
{
    [Serializable]
    public class ActorSetStencilClip : InterruptClip
    {
        [HideInInspector] public bool OnlyCloth = true;
        [HideInInspector] public int StencilValue = 2;
        protected override Playable OnCreateInterruptPlayable(PlayableGraph graph, GameObject owner, out InterruptBehaviour interruptBehaviourParam)
        {
            var playable = ScriptPlayable<ActorSetStencilBehaviour>.Create(graph);
            var behaviour = playable.GetBehaviour();
            behaviour.SetData(StencilValue, OnlyCloth);
            interruptBehaviourParam = behaviour;
            return playable;
        }
    }
}