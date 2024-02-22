using System.Collections.Generic;
using UnityEngine;
using Framework;
using PapeAnimation;
using UnityEngine.Animations;
using UnityEngine.Playables;

namespace X3Battle
{
    public class X3AnimGraphNode : GenericAnimationNode
    {
        private DynamicAnimationGraph _thisGraph = null;
        private readonly Animator _cachedAnimator = null;
        private AnimationLayerMixerPlayable _rootPlayable;

        // 对外的graph
        public PlayableGraph graph => animationSystem.graph;
        // 根rootPlayable
        public AnimationLayerMixerPlayable rootPlayable => _rootPlayable;
        
        public X3AnimGraphNode(Animator animator)
        {
            _cachedAnimator = animator;
            SetWeight(1);
            _Build();
        }
        
        private void _Build()
        {
            PlayableAnimationManager.Instance().AddAnimation(_cachedAnimator, this, EStaticSlot.Battle);
        }
        
        #region 对外接口

        // 设置播放时开启BattleAnimator
        private bool _isOpenBattleAnimator;

        public void SetOpenBattleAnimator(bool isOpen)
        {
            _isOpenBattleAnimator = isOpen;
        }
        
        // 销毁
        public void Destroy()
        {
            PlayableAnimationManager.Instance().RemoveAnimation(this);
        }

        // 设置权重
        public void SetPlayableWeight(float weight)
        {
            if (weight == 0)
            {
                RecoverOtherInstance();
            }
            else if (weight == 1)
            {
                _StopOtherInstance();
            }
            SetWeight(weight);
        }
        #endregion

        private void _StopOtherInstance()
        {
            if (_isOpenBattleAnimator)
            {
                return;
            }

            GenericAnimationTree tree = _thisGraph.GetStaticSlotTree(EStaticSlot.Battle);
            if (tree == null)
                return;

            List<GenericAnimationNode> instances = tree.GetSubNodes();
            if (instances == null)
                return;

            for (int i = 0; i < instances.Count; i++)
            {
                var ins = instances[i];
                if (ins != this)
                {
                    ins.SetWeight(0);
                }
            }
        }

        private void RecoverOtherInstance()
        {
            GenericAnimationTree tree = _thisGraph.GetStaticSlotTree(EStaticSlot.Battle);
            if (tree == null)
                return;

            List<GenericAnimationNode> instances = tree.GetSubNodes();
            if (instances == null)
                return;

            for (int i = 0; i < instances.Count; i++)
            {
                var ins = instances[i];
                ins.SetWeight(1);
            }
        }

        protected override void OnBuild()
        {
            // 生成anim轨道，并把主parent轨道playable禁用
            _rootPlayable = AnimationLayerMixerPlayable.Create(animationSystem.graph, 0);
            _thisGraph = PlayableAnimationManager.Instance().FindPlayGraph(_cachedAnimator.gameObject);
            _StopOtherInstance();
        }

        protected override void OnDestroy()
        {
            if (_rootPlayable.IsValid())
                _rootPlayable.Destroy();

            RecoverOtherInstance();
        }

        public override GenericAnimationMixer GetMixer()
        {
            return null;
        }

        public override Playable GetOutput()
        {
            return _rootPlayable.IsValid() ? _rootPlayable : Playable.Null;
        }

        public override void Tick(float deltaTime)
        {
        }
    }
}