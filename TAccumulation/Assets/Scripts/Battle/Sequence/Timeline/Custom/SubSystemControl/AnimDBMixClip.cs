using System;
using System.Collections.Generic;
using UnityEngine.Playables;

namespace UnityEngine.Timeline
{
    [Serializable]
    public class AnimDBMixClip : InterruptClip
    {
        [LabelText("部件PartName")]
        public List<string> partNames;
    
        // 虚函数：继承自InterruptClip的类只实现这个方法
        protected override Playable OnCreateInterruptPlayable(PlayableGraph graph, GameObject owner, out InterruptBehaviour interruptBehaviourParam)
        {
            var playable = ScriptPlayable<AnimDBMixPlayable>.Create(graph);
            AnimDBMixPlayable behaviour = playable.GetBehaviour();
            
            behaviour.SetData(partNames);
                
            interruptBehaviourParam = behaviour;
            return playable;
        }    
    } 
}

