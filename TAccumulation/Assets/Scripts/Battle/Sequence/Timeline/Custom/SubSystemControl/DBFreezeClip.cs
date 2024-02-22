using System;
using System.Collections.Generic;
using UnityEngine.Playables;

namespace UnityEngine.Timeline
{
    [Serializable]
    public class DBFreezeClip : InterruptClip
    {
        [LabelText("部件PartName")]
        public string partName;
        public List<string> boneNames;
    
        // 虚函数：继承自InterruptClip的类只实现这个方法
        protected override Playable OnCreateInterruptPlayable(PlayableGraph graph, GameObject owner, out InterruptBehaviour interruptBehaviourParam)
        {
            var playable = ScriptPlayable<DBFreezePlayable>.Create(graph);
            DBFreezePlayable behaviour = playable.GetBehaviour();
            
            behaviour.SetData(partName, boneNames);
                
            interruptBehaviourParam = behaviour;
            return playable;
        }    
    } 
}