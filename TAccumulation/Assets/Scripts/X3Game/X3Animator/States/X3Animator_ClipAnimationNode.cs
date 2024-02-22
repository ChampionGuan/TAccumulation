using PapeAnimation;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Animations;
using UnityEngine.Playables;

namespace X3Game
{
    public partial class X3Animator
    {
        public class X3Animator_ClipAnimationNode : GenericAnimationNode, IClearable
        {
            private Animator m_Animator;
            private AnimationClip m_Clip;
            private Playable m_Output;
            private float m_Time = 0;

            public static X3Animator_ClipAnimationNode Create(Animator animator, AnimationClip clip)
            {
                if (animator == null || clip == null)
                    return null;
                var node = ClearableObjectPool<X3Animator_ClipAnimationNode>.Get();
                node.ParentIndex = 0;
                node.m_Animator = animator;
                node.m_Clip = clip;
                return node;
            }

            public static void Release(X3Animator_ClipAnimationNode node)
            {
                if (node == null)
                    return;
                ClearableObjectPool<X3Animator_ClipAnimationNode>.Release(node);
            }

            public void SetTime(float time)
            {
                m_Time = time;
            }

            protected override void OnBuild()
            {
                if (m_Clip == null)
                {
                    m_Output = Playable.Null;
                    return;
                }

                m_Output = AnimationClipPlayable.Create(animationSystem.graph, m_Clip);
            }

            protected override void OnDestroy()
            {
                if (GetOutput().IsValid())
                {
                    GetOutput().Destroy();
                }
            }

            public override GenericAnimationMixer GetMixer()
            {
                return null;
            }

            public override Playable GetOutput()
            {
                return m_Output;
            }

            protected override float EvaluateNodeTime()
            {
                return m_Time;
            }

            public override void Tick(float deltaTime)
            {
            }

            public void Clear()
            {
                Dispose();
                m_Clip = null;
                m_Animator = null;
                if (m_Output.IsValid())
                    m_Output.Destroy();
                m_Time = 0;
                ParentIndex = 0;
            }
        }
    }
}