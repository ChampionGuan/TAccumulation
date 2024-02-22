using System;
using System.Collections.Generic;
using UnityEngine.Playables;

namespace UnityEngine.Timeline
{
    [Serializable]
    public class TransformOperationClip : InterruptClip
    {
        [LabelText("Transform信息")]
        public TransformOperationData operationData;

        [NonSerialized] public Func<GameObject> dynamicGetter;
        
        protected override Playable OnCreateInterruptPlayable(PlayableGraph graph, GameObject owner, out InterruptBehaviour interruptBehaviourParam)
        {
            var playable = ScriptPlayable<TransformOperationPlayable>.Create(graph);
            var behaviour = playable.GetBehaviour();
            behaviour.SetData(operationData);
            // TODO 二测性能优化，临时做法
            behaviour.SetDynamicTransGetter(dynamicGetter);
            dynamicGetter = null;
            interruptBehaviourParam = behaviour;
            return playable;
        } 
    }

    [Serializable]
    public class TransformOperationData
    {
        // 位置
        [LabelText("位置")]
        public Vector3 position;
        // 旋转
        [LabelText("旋转")]
        public Vector3 rotation;

        [LabelText("结束是否复原")] 
        public bool isEndResume = false;
    }
}