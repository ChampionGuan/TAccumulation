using System;
using System.Collections.Generic;
using UnityEngine.Playables;

namespace UnityEngine.Timeline
{
    [Serializable]
    public class PhysicsVelocityThresholdClip : InterruptClip
    {
        [LabelText("部件(PartName)")]
        public string partName;

        [LabelText("速度(VelocityThreshold)")]
        public float velocityThreshold;
        
        [LabelText("角度(AngularVelocityThreshold)")]
        public float angularVelocityThreshold;
    
        // 虚函数：继承自InterruptClip的类只实现这个方法
        protected override Playable OnCreateInterruptPlayable(PlayableGraph graph, GameObject owner, out InterruptBehaviour interruptBehaviourParam)
        {
            var playable = ScriptPlayable<PhysicsVelocityThresholdPlayable>.Create(graph);
            PhysicsVelocityThresholdPlayable behaviour = playable.GetBehaviour();
            
            behaviour.SetData(partName, velocityThreshold, angularVelocityThreshold);
                
            interruptBehaviourParam = behaviour;
            return playable;
        }    
    } 
}