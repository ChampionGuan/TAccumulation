using UnityEngine;
using UnityEngine.Animations;
using UnityEngine.Playables;

namespace X3Battle
{
    public abstract class PlayableNode
    {
        public PlayableNode parent { get; protected set; }
        public PlayableNode[] children { get; }
        public int inputIndex { get; }
        public float weight { get; protected set; }
        public Playable playable { get; protected set; }
        public PlayableGraph graph => parent?.graph ?? _graph;

        [Range(0, 1)] private float _crossFadeWeight;
        private float _crossFadeTime;
        protected PlayableGraph _graph;

        public PlayableNode(float weight, int inputIndex, int childrenCount = 0)
        {
            this.inputIndex = inputIndex;
            this.weight = _crossFadeWeight = weight;
            this.children = new PlayableNode[childrenCount];
        }

        public virtual void OnUpdate(float deltaTime)
        {
            if (weight != _crossFadeWeight)
            {
                weight += _crossFadeTime <= 0 ? _crossFadeWeight : (weight > _crossFadeWeight ? -1 : 1) * (deltaTime / _crossFadeTime);
                weight = Mathf.Clamp01(weight);
                parent.playable.SetInputWeight(inputIndex, weight);
            }

            if (children.Length < 1)
            {
                return;
            }

            for (var i = 0; i < children.Length && null != children[i]; i++)
            {
                children[i].OnUpdate(deltaTime);
            }
        }

        public virtual void OnDestroy()
        {
            for (var i = 0; i < children.Length && null != children[i]; i++)
            {
                children[i].OnDestroy();
            }

            playable.Destroy();
        }

        /// <summary>
        /// 创建playable
        /// </summary>
        /// <returns></returns>
        public virtual Playable CreatePlayable()
        {
            return AnimationMixerPlayable.Create(graph, children.Length);
        }

        /// <summary>
        /// 重绘playable
        /// </summary>
        /// <returns></returns>
        public virtual Playable RebuildPlayable()
        {
            playable = CreatePlayable();
            if (null != parent && parent.playable.IsValid())
            {
                parent.playable.DisconnectInput(inputIndex);
                parent.playable.ConnectInput(inputIndex, playable, 0, weight);
            }

            for (var i = 0; i < children.Length; i++)
            {
                children[i]?.RebuildPlayable(this);
            }

            return playable;
        }

        /// <summary>
        /// 重绘playable
        /// </summary>
        public virtual Playable RebuildPlayable(PlayableNode parentNode)
        {
            if (null != parentNode && !parentNode.ContainChild(this))
            {
                playable = Playable.Null;
                return playable;
            }

            if (parent != parentNode)
            {
                parent?.RemoveChild(this);
            }

            parent = parentNode;
            return RebuildPlayable();
        }

        /// <summary>
        /// 是否为有效playable
        /// </summary>
        /// <returns></returns>
        public virtual bool IsValidPlayable()
        {
            return playable.IsValid() && playable.GetInputCount() == children.Length && playable.GetGraph().Equals(graph);
        }

        /// <summary>
        /// 权重过渡
        /// </summary>
        /// 孩子节点进入/退出
        /// <param name="fadeInChildType"></param> 进入的孩子节点类型
        /// <param name="fadeInTime"></param> 进入时间
        /// <param name="fadeOutChildType"></param> 退出的孩子节点类型
        /// <param name="fadeOutTime"></param> 退出时间
        public virtual void CrossFade(int? fadeInChildType, float? fadeInTime, int? fadeOutChildType, float? fadeOutTime)
        {
            if (null != fadeInChildType && children.Length > fadeInChildType)
            {
                children[fadeInChildType.Value].CrossFade(true, fadeInTime ?? 0);
            }

            if (null != fadeOutChildType && children.Length > fadeOutChildType)
            {
                children[fadeOutChildType.Value].CrossFade(false, fadeOutTime ?? 0);
            }
        }

        /// <summary>
        /// 权重过渡
        /// 自身节点进入/退出
        /// </summary>
        public virtual void CrossFade(bool fadeIn, float time = 0)
        {
            _crossFadeTime = time;
            _crossFadeWeight = fadeIn ? 1 : 0;
        }

        /// <summary>
        /// 添加孩子节点
        /// </summary>
        /// <param name="child"></param>
        public void AddChild(PlayableNode child)
        {
            if (null == child || child.inputIndex >= children.Length || children[child.inputIndex] == child)
            {
                return;
            }

            children[child.inputIndex] = child;
            child.RebuildPlayable(this);
        }

        /// <summary>
        /// 移除孩子节点
        /// </summary>
        /// <param name="child"></param>
        public void RemoveChild(PlayableNode child)
        {
            if (!ContainChild(child))
            {
                return;
            }

            children[child.inputIndex] = null;
            if (playable.IsValid()) playable.DisconnectInput(child.inputIndex);
        }

        /// <summary>
        /// 移除孩子节点
        /// </summary>
        /// <param name="index"></param>
        public void RemoveChild(int index)
        {
            if (index >= children.Length || null == children[index])
            {
                return;
            }

            children[index] = null;
            if (playable.IsValid()) playable.DisconnectInput(index);
        }

        /// <summary>
        /// 是否含有孩子节点
        /// </summary>
        /// <param name="child"></param>
        /// <returns></returns>
        public bool ContainChild(PlayableNode child)
        {
            if (null == child)
            {
                return false;
            }

            for (var i = 0; i < children.Length; i++)
            {
                if (children[i] == child)
                {
                    return true;
                }
            }

            return false;
        }
    }
}
