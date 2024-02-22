using System;
using UnityEngine.Playables;

namespace UnityEngine.Timeline
{
    [Serializable]
    public class ChangeWeaponClip : InterruptClip
    {
        [LabelText("武器部件名")] 
        public string weaponPartName; 
        
        // 虚函数：继承自InterruptClip的类只实现这个方法
        protected override Playable OnCreateInterruptPlayable(PlayableGraph graph, GameObject owner, out InterruptBehaviour interruptBehaviourParam)
        {
            var playable = ScriptPlayable<ChangeWeaponBehaviour>.Create(graph);
            var behaviour = playable.GetBehaviour();
            behaviour.SetData(weaponPartName);
            interruptBehaviourParam = behaviour;
            return playable;
        }    
    }
}