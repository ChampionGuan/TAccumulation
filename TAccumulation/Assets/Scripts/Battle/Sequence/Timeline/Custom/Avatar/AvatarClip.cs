using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Serialization;
using UnityEngine.Timeline;
using PapeGames.X3;

namespace PapeGames
{
    [Serializable]
    public class AvatarClip : InterruptClip
    {
        [NonSerialized] public int bindSuitID;
        [NonSerialized] public Material bindMmaterial;
        
        // 虚函数：继承自InterruptClip的类只实现这个方法
        protected override Playable OnCreateInterruptPlayable(PlayableGraph graph, GameObject owner, out InterruptBehaviour interruptBehaviourParam)
        {
            if (!Application.isPlaying)
            {
                // 编辑器下走这个逻辑
                var playable = ScriptPlayable<AvatarBehaviour>.Create(graph);
                var behaviour = playable.GetBehaviour();
                behaviour.bindSuitId = bindSuitID;
                behaviour.bindMaterial = bindMmaterial;
                interruptBehaviourParam = behaviour;
                return playable;  
            }
            else
            {
                // 运行时要结合battle运行时动态创建，还涉及到缓存池和LateUpdate位置同步，所以使用Sequencer实现
                interruptBehaviourParam = null;
                return Playable.Null;
            }
        }      
    }
}