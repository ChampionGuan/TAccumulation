using UnityEngine;
using System.Collections.Generic;
using Framework;
using PapeGames.CutScene;
using UnityEngine.Playables;
using PapeGames.X3;

namespace X3Game
{
    public partial class X3Animator
    {
        public class CutsceneState : X3Game.X3RuntimeStateController.State, IClearable
        {
            public event System.Action<CutsceneState> OnWillEnterAction;
            public Context Context { set; get; }
            public string CutsceneName { private set; get; }
            private float m_ActualLength = 0;
            private bool m_InheritTransform = false;
            private CtsHandle m_Handle;
            public bool UpdatedFromExternal { set; get; } = false;
            //上面那个标记位在换装后就会被强制设为False
            public bool IsExternalState { set; get; } = false;

            public static CutsceneState Create(string name, string ctsName, DirectorWrapMode defaultWrapMode, bool inheritTransform, float transitionDuration, IList<KeyFrame> kfList = null)
            {
                if (string.IsNullOrEmpty(name))
                    return null;
                var state = ClearableObjectPool<CutsceneState>.Get();
                state.Name = name;
                state.CutsceneName = ctsName;
                state.Length =  CutSceneCollector.GetLength(ctsName);
                state.DefaultWrapMode = defaultWrapMode;
                state.m_InheritTransform = inheritTransform;
                state.DefaultTransitionDuration = transitionDuration;
                state.m_ActualLength = CutSceneCollector.GetActualLength(ctsName);
                state.ExitTime = 1.0f;
                state.AddKeyFrameList(kfList);
                return state;
            }

            public void UpdateInfo(string ctsName, bool inheritTransform, float transitionDuration, DirectorWrapMode defaultWrapMode)
            {
                CutsceneName = ctsName;
                Length =  CutSceneCollector.GetLength(ctsName);
                m_ActualLength = CutSceneCollector.GetActualLength(ctsName);
                m_InheritTransform = inheritTransform;
                DefaultTransitionDuration = transitionDuration;
                DefaultWrapMode = defaultWrapMode;
                UpdatedFromExternal = true;
            }

            private DirectorWrapMode WrapMode
            {
                get
                {
                    var theWrapMode = base.WrapMode;
                    if (theWrapMode == DirectorWrapMode.None)
                        theWrapMode = DirectorWrapMode.Hold;
                    return theWrapMode;
                }
            }

            protected override void OnWillEnter()
            {
                if (UpdatedFromExternal)
                    return;
                OnWillEnterAction?.Invoke(this);
            }

            protected override void OnEnter(float transitonDuration, bool reEnter)
            {
                base.OnEnter(transitonDuration, reEnter);
                if (!reEnter || (m_Handle.IsValid() && m_Handle.Name != CutsceneName))
                {
                    ExePlayCts(transitonDuration);
                }
                else
                {
                    m_Handle.UpdateWrapMode(this.WrapMode);
                    m_Handle.SetTime(this.WrapTime);
                }

                this.Context?.RegisterCtsPlayIdAction(m_Handle.PlayId);
            }

            protected override void OnUpdateWeight(float weight)
            {
                if (IsEntering && ((this.Layer.PrevState != null && !(this.Layer.PrevState is CutsceneState)) || this.Layer.PrevState == null))
                {
                    PlayableAnimationManager.Instance().SetBlendingWeight(this.Context.Animator.gameObject, EStaticSlot.Timeline, weight);
                }
            }

            protected override void OnUpdate(float dt)
            {
                base.OnUpdate(dt);
                bool isValid = m_Handle.IsValid();
                if (isValid)
                {
                    m_Handle.Tick(dt);
                    this.Time = m_Handle.Time;
                }
                else if (!IsExiting && !isValid)
                {
                    ExePlayCts(0);
                }
            }

            public override void SetPosition(float x, float y, float z)
            {
                base.SetPosition(x, y, z);
                if (m_Handle.IsValid() && m_Handle.Ctrl != null && m_Handle.Ctrl.transform)
                {
                    m_Handle.Ctrl.transform.position = new Vector3(x, y, z);
                }
            }

            public override void SetRotation(float x, float y, float z, float w)
            {
                base.SetRotation(x, y, z, w);
                if (m_Handle.IsValid() && m_Handle.Ctrl != null && m_Handle.Ctrl.transform)
                {
                    m_Handle.Ctrl.transform.rotation = new Quaternion(x, y, z, w);
                }
            }
            
            public override void SetEulerAngles(float x, float y, float z)
            {
                base.SetEulerAngles(x, y, z);
                if (m_Handle.IsValid() && m_Handle.Ctrl != null && m_Handle.Ctrl.transform)
                {
                    m_Handle.Ctrl.transform.eulerAngles = new Vector3(x, y, z);
                }
            }

            private void ExePlayCts(float crossfadeDuration)
            {
                var hostTF = this.Context.Animator.transform;
                var ctsPositon = Vector3.zero;
                var ctsRotation = Vector3.zero;
                if (m_InheritTransform || Context.InheritTransform)
                {
                    ctsPositon = hostTF.position;
                    ctsRotation = hostTF.eulerAngles;
                }

                var parent = Context.X3Animator.KeepParent ? GetNoneCtsParent() : null;
                m_Handle = X3CutSceneManager.PlayFromX3Animator(this.CutsceneName, this.Context.Tag,
                    CutScenePlayMode.Crossfade,
                    WrapMode, this.WrapTime, 0, crossfadeDuration, parent, ctsPositon, ctsRotation);
                if (m_Handle.IsValid() && m_Handle.Ctrl != null)
                {
                    m_Handle.SetLoopInitialTime(0);
                    m_Handle.AutoTick = false;
                }
            }

            private Transform GetNoneCtsParent()
            {
                var originalParent = Context.X3Animator.transform.parent;
                if (originalParent == null)
                    return null;
                
                int cnt = 0;
                Transform ctsParent = null;
                var parent = originalParent;
                while (cnt < 3)
                {
                    if (parent == null)
                    {
                        break;
                    }
                    if (parent.GetComponent<CutSceneCtrl>())
                    {
                        ctsParent = parent;
                        break;
                    }

                    parent = parent.parent;
                    cnt++;
                }

                if (ctsParent != null)
                    return ctsParent.parent;

                return originalParent;
            }

            protected override void OnPostEnter()
            {
                if ((this.Layer.PrevState != null && !(this.Layer.PrevState is CutsceneState)) || (this.Layer.PrevState == null))
                {
                    PlayableAnimationManager.Instance().SetBlendingWeight(this.Context.Animator.gameObject, EStaticSlot.Timeline, 1);
                }
                m_Handle.SetWeight(1);
            }

            protected override void OnExit()
            {
                m_Handle.Stop();
                //todo:should stop crossfade
            }

            protected override void OnStop()
            {
                base.OnStop();
                m_Handle.Stop();
            }

            protected override void OnPaused(bool paused)
            {
                base.OnPaused(paused);
                if (paused)
                    m_Handle.Pause(false);
                else
                    m_Handle.Resume(false);
            }

            protected override void OnDestroy()
            {
                base.OnDestroy();
                m_Handle.Stop();
                ClearableObjectPool<CutsceneState>.Release(this);
            }
            
            public override float GetMaxFadeOutDuration()
            {
                var duration = Mathf.Max(0, m_ActualLength - WrapTime);
                return duration;
            }

            public override void Clear()
            {
                base.Clear();
                Context = null;
                CutsceneName = null;
                m_ActualLength = 0;
                OnWillEnterAction = null;
                UpdatedFromExternal = false;
                IsExternalState = false;
            }
        }
    }
}