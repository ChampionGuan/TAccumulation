using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Animations;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace X3Battle
{
    public class AnimGraphOwner: MonoBehaviour
    {
        // 手动创建的graph TODO 考虑一个Graph+布尔变量
        private PlayableGraph? _createdGraph;
        // 从x3拿到的graph
        private PlayableGraph? _x3Graph;
        // 对外接口，让外部拿graph
        public PlayableGraph? graph => _createdGraph ?? _x3Graph;

        private AnimationLayerMixerPlayable _rootPlayable;  // 根playable
        private Stack<int> _idleSlots = new Stack<int>();  // 空闲槽位

        private X3AnimGraphNode _x3GraphNode;  // x3Graph上的playable

        private bool _isInited;
        
        public void TryInit(bool usingX3Graph)
        {
            if (_isInited)
            {
                return;
            }
            _isInited = true;
            
            var animator = GetComponent<Animator>();
            if (animator == null)
            {
                return;
            }

            if (usingX3Graph)
            {
                // 使用X3Graph
                _x3GraphNode = new X3AnimGraphNode(animator);
                _x3Graph = _x3GraphNode.graph;
                _rootPlayable = _x3GraphNode.rootPlayable;
            }
            else
            {
                // 手动创建Graph，并绑定output
                var createGraph = PlayableGraph.Create(gameObject.name);
                createGraph.SetTimeUpdateMode(DirectorUpdateMode.Manual);
                _createdGraph = createGraph;
            
                var playableOutput = AnimationPlayableOutput.Create(createGraph, "MixerOutPut", animator);
                _rootPlayable = AnimationLayerMixerPlayable.Create(createGraph, 0);
                playableOutput.SetSourcePlayable(_rootPlayable);    
            }
        }

        public void AttachPlayable(Playable playable)
        {
            if (graph == null)
            {
                return;    
            }
            
            var index = 0;
            if (_idleSlots.Count > 0)
            {
                // 从空闲槽位中取
                index = _idleSlots.Pop();
            }
            else
            {
                // 扩容槽位，然后取
                var oldCount = _rootPlayable.GetInputCount();   
                _rootPlayable.SetInputCount(oldCount + 1);
                index = oldCount;
            }
            _rootPlayable.ConnectInput(index, playable, 0, 1f);
            _rootPlayable.SetLayerAdditive((uint)index, false);       
        }

        public void DetachPlayable(Playable target)
        {
            if (graph == null)
            {
                return;
            }
            
            var count = _rootPlayable.GetInputCount();
            for (int i = 0; i < count; i++)
            {
                var playable = _rootPlayable.GetInput(i);
                if (playable.Equals(target))
                {
                    _rootPlayable.DisconnectInput(i);
                    _idleSlots.Push(i);
                    break;
                }
            }
        }

        public void Evaluate()
        {
            // 只有手动创建的需要手动Evaluate，挂到x3上的由底层框架驱动
            if (_createdGraph != null)
            {
                _createdGraph.Value.Evaluate();
            }
        }

        private void OnDestroy()
        {
            if (_createdGraph != null)
            {
                _createdGraph.Value.Destroy();
                _createdGraph = null;
            }

            if (_x3GraphNode != null)
            {
                _x3GraphNode.Destroy();
                _x3GraphNode = null;
            }
        }
    }
}