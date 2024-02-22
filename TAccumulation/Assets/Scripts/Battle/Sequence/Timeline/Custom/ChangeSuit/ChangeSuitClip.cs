using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Serialization;
using UnityEngine.Timeline;

namespace PapeGames
{
    [Serializable]
    public class ChangeSuitClip : InterruptClip
    {
        public bool useOriginal;
        public int targetSuitID;

        [NonSerialized] public int bindSuitID;
        
        // 虚函数：继承自InterruptClip的类只实现这个方法
        protected override Playable OnCreateInterruptPlayable(PlayableGraph graph, GameObject owner, out InterruptBehaviour interruptBehaviourParam)
        {
            var playable = ScriptPlayable<ChangeSuitBehaviour>.Create(graph);
            var behaviour = playable.GetBehaviour();
            behaviour.Init(useOriginal, targetSuitID, bindSuitID);
            interruptBehaviourParam = behaviour;
            return playable;
        }      
    }
}