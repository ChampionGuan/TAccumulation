using System;
using UnityEngine.Playables;
using UnityEngine.Serialization;

namespace UnityEngine.Timeline
{
  [Serializable]
     public class VisibilityClip:InterruptClip
     {
        [LabelText("角色是否可见")]
        public bool m_visible;
        [LabelText("      骨骼仍然可见", showCondition = "!m_visible")]       
        public bool m_rootsVisible;
             
         // 虚函数：继承自InterruptClip的类只实现这个方法
         protected override Playable OnCreateInterruptPlayable(PlayableGraph graph, GameObject owner, out InterruptBehaviour interruptBehaviourParam)
         {
             var playable = ScriptPlayable<VisibilityPlayable>.Create(graph);
             VisibilityPlayable behaviour = playable.GetBehaviour();
             behaviour.SetParam(m_visible, m_rootsVisible);
             interruptBehaviourParam = behaviour;
             return playable;
         }  
     } 
 }