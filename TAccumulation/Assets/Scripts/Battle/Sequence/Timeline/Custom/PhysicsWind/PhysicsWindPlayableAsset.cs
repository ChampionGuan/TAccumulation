using System;
using UnityEngine.Playables;
using X3Battle;

namespace UnityEngine.Timeline
{
    // 物理风场clip资源
    [Serializable]
    public class PhysicsWindPlayableAsset : InterruptClip
    {
        [SerializeField]
        public PhysicsWindParam physicsWindParam;

        [HideInInspector]
        [SerializeField] 
        public bool isLerp = false;
        
        [HideInInspector]
        [SerializeField] 
        public PhysicsWindParam physicsWindParam2 = null;

        [NonSerialized] public float Duration;
        [NonSerialized] public PhysicsWindBehaviour behaviour;
        [NonSerialized] public ActionStaticWind Wind;

        // 虚函数：继承自InterruptClip的类只实现这个方法
        protected override Playable OnCreateInterruptPlayable(PlayableGraph graph, GameObject owner, out InterruptBehaviour interruptBehaviourParam)
        {
            var playable = ScriptPlayable<PhysicsWindBehaviour>.Create(graph);
            behaviour = playable.GetBehaviour();
            
            var needLerp = false;
            if (isLerp)
            {
                if (physicsWindParam != null && physicsWindParam2 != null)
                {
                    if (physicsWindParam.volumeParams?.Count == physicsWindParam2.volumeParams?.Count)
                    {
                        needLerp = true;
                    }
                }
            }
            
            if (needLerp)
            {
                behaviour.SetPhysicsWindParam(physicsWindParam, physicsWindParam2);
                behaviour.SetDuration(Duration);
            }
            else
            {
                behaviour.SetPhysicsWindParam(physicsWindParam, null); 
            }
            interruptBehaviourParam = behaviour;
            return playable;
        }
    }
}