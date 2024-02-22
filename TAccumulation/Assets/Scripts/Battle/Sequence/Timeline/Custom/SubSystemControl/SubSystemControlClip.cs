using System;
using UnityEngine.Playables;
using X3Battle;

namespace UnityEngine.Timeline
{
    [Serializable]
    public class SubSystemControlClip : InterruptClip
    {
        [LabelText("组件类型 (默认DB)")]
        public X3.Character.ISubsystem.Type type = X3.Character.ISubsystem.Type.PhysicsCloth;

        [LabelText("开关 (Clip结束复原)")]
        public bool enable;

        [LabelText("是否按部件类型开关")] 
        public bool usePartType = false;

        [LabelText("部件类型", showCondition = "usePartType")] 
        public PartType partType;
        
        // 虚函数：继承自InterruptClip的类只实现这个方法
        protected override Playable OnCreateInterruptPlayable(PlayableGraph graph, GameObject owner, out InterruptBehaviour interruptBehaviourParam)
        {
            var playable = ScriptPlayable<SubSystemControlPlayable>.Create(graph);
            SubSystemControlPlayable behaviour = playable.GetBehaviour();
            
            behaviour.SetData(type, enable, usePartType, partType);
                
            interruptBehaviourParam = behaviour;
            return playable;
        }    
    }
}