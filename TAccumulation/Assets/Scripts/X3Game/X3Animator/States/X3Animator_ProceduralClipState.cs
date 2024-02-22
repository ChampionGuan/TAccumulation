using PapeGames.X3;
using System.Collections.Generic;
using ProceduralAnimation;
using Framework;
using UnityEngine.Playables;

namespace X3Game
{
    public partial class X3Animator
    {
        public class ProceduralClipState : X3Game.X3RuntimeStateController.State, IClearable
        {
            public Context Context { set; get; }
            public ProceduralAnimationClip Clip { get; private set; }
            private ProceduralAnimationNode m_AnimationNode;
            private ManualDirector m_ManualDirector;

            public static ProceduralClipState Create(string name, ProceduralAnimationClip clip, DirectorWrapMode defaultWrapMode = DirectorWrapMode.None, float exitTime = 0.9f, IList<KeyFrame> kfList = null)
            {
                if (string.IsNullOrEmpty(name))
                    return null;
                var state = ClearableObjectPool<ProceduralClipState>.Get();
                {
                    state.Name = name;
                    state.Clip = clip;
                    state.Length = clip ? (float)clip.Length : 0;
                    state.DefaultWrapMode = defaultWrapMode;
                    state.ExitTime = exitTime;
                }
                state.AddKeyFrameList(kfList);
                state.m_ManualDirector = new ManualDirector(state.Length);

                return state;
            }

            protected override void OnEnter(float transitonDuration, bool reEnter)
            {
                base.OnEnter(transitonDuration, reEnter);
                if (!reEnter && m_AnimationNode == null && Clip != null)
                {
                    m_AnimationNode = Clip.CreateInstanceNode(m_ManualDirector, this.Context.Animator,
                        this.Context.RootBone);
                    if (m_AnimationNode != null)
                        this.Context.AnimationTree.AddSubNode(m_AnimationNode);
                }
                m_ManualDirector.SetTime(this.WrapTime);
            }
            
            protected override void OnUpdate(float dt)
            {
                base.OnUpdate(dt);
                this.Time += dt;
                m_ManualDirector.SetTime(this.WrapTime);
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

            protected override void OnPostEnter()
            {
                if ((this.Layer.PrevState != null && (this.Layer.PrevState is CutsceneState)) ||
                    this.Layer.PrevState == null)
                {
                    PlayableAnimationManager.Instance().SetBlendingWeight(this.Context.Animator.gameObject, EStaticSlot.Gameplay, 1);
                }
            }

            protected override void OnExit()
            {
                m_AnimationNode?.SetWeight(0);
            }

            protected override void OnStop()
            {
                base.OnStop();
                if (m_AnimationNode != null)
                    this.Context.AnimationTree.RemoveSubNode(m_AnimationNode);
                m_AnimationNode = null;
            }

            protected override void OnDestroy()
            {
                base.OnDestroy();
                if (m_AnimationNode != null)
                    this.Context.AnimationTree.RemoveSubNode(m_AnimationNode);
                m_AnimationNode = null;
                ClearableObjectPool<ProceduralClipState>.Release(this);
            }

            public override void Clear()
            {
                base.Clear();
                Context = null;
                Clip = null;
                m_ManualDirector = null;
                m_AnimationNode = null;
            }
        }
    }
}