using PapeGames.X3;
using UnityEngine;
using System.Collections.Generic;
using Framework;
using UnityEngine.Playables;

namespace X3Game
{
    public partial class X3Animator
    {
        public class AnimationClipState : X3Game.X3RuntimeStateController.State, IClearable
        {
            public Context Context { set; get; }
            public AnimationClip Clip { private set; get; }
            private X3Animator_ClipAnimationNode m_AnimationNode;

            public static AnimationClipState Create(string name, AnimationClip clip, DirectorWrapMode defaultWrapMode = DirectorWrapMode.None, float exitTime = 0.9f, IList<KeyFrame> kfList = null)
            {
                if (string.IsNullOrEmpty(name))
                    return null;
                var state = ClearableObjectPool<AnimationClipState>.Get();
                {
                    state.Name = name;
                    state.Clip = clip;
                    state.Length = clip ? clip.length : 0;
                    state.DefaultWrapMode = defaultWrapMode;
                    state.ExitTime = exitTime;
                }
                state.AddKeyFrameList(kfList);

                return state;
            }

            protected override void OnEnter(float transitonDuration, bool reEnter)
            {
                base.OnEnter(transitonDuration, reEnter);
                if (!reEnter && m_AnimationNode == null)
                {
                    m_AnimationNode = X3Animator_ClipAnimationNode.Create(this.Context.Animator, this.Clip);
                    if (m_AnimationNode != null)
                    {
                        this.Context.AnimationTree.AddSubNode(m_AnimationNode);
                    }
                }
                m_AnimationNode?.SetTime(this.WrapTime);
            }

            protected override void OnUpdate(float dt)
            {
                base.OnUpdate(dt);
                this.Time += dt;
                m_AnimationNode?.SetTime(this.WrapTime);
            }

            protected override void OnUpdateWeight(float weight)
            {
                if (IsEntering && ((this.Layer.PrevState != null && (this.Layer.PrevState is CutsceneState)) ||
                    this.Layer.PrevState == null))
                {
                    PlayableAnimationManager.Instance().SetBlendingWeight(this.Context.Animator.gameObject, EStaticSlot.Gameplay, weight);
                    m_AnimationNode?.SetWeight(1);
                }
                else if (IsExiting && this.Layer.CurState != null && (this.Layer.CurState is CutsceneState))
                {
                    //next state is cutscene, fade out by mixer
                    m_AnimationNode?.SetWeight(1);
                }
                else
                {
                    m_AnimationNode?.SetWeight(weight);
                }
            }
            
            protected override void OnExit()
            {
                m_AnimationNode?.SetWeight(0);
            }

            protected override void OnPostEnter()
            {
                if ((this.Layer.PrevState != null && (this.Layer.PrevState is CutsceneState)) ||
                                   this.Layer.PrevState == null)
                {
                    PlayableAnimationManager.Instance().SetBlendingWeight(this.Context.Animator.gameObject, EStaticSlot.Gameplay, 1);
                }
            }

            protected override void OnStop()
            {
                base.OnStop();
                if (m_AnimationNode != null)
                {
                    this.Context.AnimationTree.RemoveSubNode(m_AnimationNode);
                    X3Animator_ClipAnimationNode.Release(m_AnimationNode);
                    m_AnimationNode = null;
                }
            }

            protected override void OnDestroy()
            {
                base.OnDestroy();
                if (m_AnimationNode != null)
                {
                    this.Context.AnimationTree.RemoveSubNode(m_AnimationNode);
                    X3Animator_ClipAnimationNode.Release(m_AnimationNode);
                    m_AnimationNode = null;
                }
                ClearableObjectPool<AnimationClipState>.Release(this);
            }

            public override void Clear()
            {
                base.Clear();
                Context = null;
                Clip = null;
                if (m_AnimationNode != null)
                {
                    X3Animator_ClipAnimationNode.Release(m_AnimationNode);
                    m_AnimationNode = null;
                }
            }
        }
    }
}