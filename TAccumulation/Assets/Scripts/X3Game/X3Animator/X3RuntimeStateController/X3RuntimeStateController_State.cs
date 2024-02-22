using PapeGames.X3;
using UnityEngine;
using UnityEngine.Playables;
using System.Collections.Generic;

namespace X3Game
{
    public partial class X3RuntimeStateController
    {
        public abstract class State
        {
            public string Name { protected set; get; }
            public int NameHash
            {
                get { return StateNameToHash(Name); }
            }
            public float Length { protected set; get; }
            /// <summary>
            /// normalized exit time: 0=begin, 1=time of length
            /// </summary>
            protected float ExitTime { set; get; } = 1.0f;
            public float InitialTime { private set; get; }
            public float PrevTime { private set; get; }
            public float Time { protected set; get; }
            public float DeltaTime { private set; get; }
            public DirectorWrapMode DefaultWrapMode { protected set; get; } = DirectorWrapMode.None;
            /// <summary>
            /// less than 0 means using layer.DefualtTransitionDuration
            /// </summary>
            public float DefaultTransitionDuration { protected set; get; } = -1;
            public MotionKeyFrame KeyFrameList { protected set; get; }
            public DirectorWrapMode WrapMode {private set; get; }
            public bool IsEntering {private set; get; } = false;
            public bool IsExiting {private set; get; } = false;
            public float Weight {private set; get; } = 1;
            protected float FrameRate { set; get; } = 30;
            public Layer Layer { set; get; }
            public float RemainingTime
            {
                get
                {
                    return Length - WrapTime;
                }
            }
            public float WrapTime
            {
                get
                {
                    float wrapTime = 0;
                    if (this.Length > 0)
                    {
                        if (this.WrapMode == DirectorWrapMode.Loop)
                            wrapTime = this.Time % this.Length;
                        else
                            wrapTime = Mathf.Clamp(this.Time, 0, this.Length);
                    }
                    return wrapTime;
                }
            }
            public float FixedExitTime
            {
                get
                {
                    return Length * Mathf.Clamp01(ExitTime);
                }
            }
            public bool HasCrossedEnd
            {
                get
                {
                    if (this.DeltaTime > 0 && this.PrevTime < this.Length && this.Length - this.Time < 0.0001)
                        return true;
                    return false;
                }
            }

            #region Available FadeOut/FadeIn Duration
            public virtual float GetMaxFadeOutDuration()
            {
                var duration = Length;
                return duration;
            }
            
            public virtual float GetMaxFadeInDuration(float initialTime)
            {
                var duration = Mathf.Max(0, Length - Mathf.Max(initialTime, 0));
                return duration;
            }
            #endregion

            #region External Manipulation from Layer...
            public void ExternalWillEnter()
            {
                OnWillEnter();
            }
            
            public void ExternalSetWeight(float weight)
            {
                Weight = weight;
                OnUpdateWeight(weight);
            }
            
            public void ExternalInitStateInfo(float initialTime, DirectorWrapMode wrapMode)
            {
                this.InitialTime = initialTime;
                this.PrevTime = this.Time;
                this.Time = initialTime;
                this.WrapMode = wrapMode;
                if (LogEnabled)
                    X3Debug.LogFormat("Layer.State: {0}.ExternalInitStateInfo(initialTime:{1}, wrapMode:{2})", Name, initialTime, wrapMode);
            }
            
            public void ExternalUpdateWrapMode(DirectorWrapMode wrapMode)
            {
                this.WrapMode = wrapMode;
                if (LogEnabled)
                    X3Debug.LogFormat("Layer.State: {0}.ExternalUpdateWrapMode(initialTime:{1}, wrapMode:{2})", Name,  wrapMode);
            }

            public void ExternalEnter(float transitonDuration, bool reEnter = false)
            {
                IsEntering = true;
                IsExiting = false;
                if (LogEnabled)
                    X3Debug.LogFormat("Layer.State: {0}.ExternalEnter(transitonDuration:{1}, reEnter:{2})", Name, transitonDuration, reEnter);
                OnEnter(transitonDuration, reEnter);
            }
            
            public void ExternalPostEnter()
            {
                if (LogEnabled)
                    X3Debug.LogFormat("Layer.State: {0}.ExternalPostEnter()", Name);
                OnPostEnter();
                IsEntering = false;
            }
            
            public void ExternalPreExit(float transitonDuration)
            {
                IsEntering = false;
                IsExiting = true;
                if (LogEnabled)
                    X3Debug.LogFormat("Layer.State: {0}.ExternalPreExit({1})", Name, transitonDuration);
                OnPreExit(transitonDuration);
            }
            
            public void ExternalExit()
            {
                if (LogEnabled)
                    X3Debug.LogFormat("Layer.State: {0}.ExternalExit()", Name);
                OnExit();
                IsExiting = false;
                this.PrevTime = 0;
                this.Time = 0;
            }
            
            public void ExternalUpdate(float dt)
            {
                this.PrevTime = this.Time;
                OnUpdate(dt);
                this.DeltaTime = this.Time - this.PrevTime;
                KeyFrameList?.ProcKeyFrame(WrapTime, Length);
            }
            
            public void ExternalLateUpdate()
            {
                OnLateUpdate();
            }
            
            public void ExternalPauseOrResume(bool paused)
            {
                if (LogEnabled)
                    X3Debug.LogFormat("Layer.State: {0}.OnPaused({1})", Name, paused);
                OnPaused(paused);
            }
            
            public void ExternalStop()
            {
                if (LogEnabled)
                    X3Debug.LogFormat("Layer.State: {0}.OnStop()", Name);
                OnStop();
                this.PrevTime = 0;
                this.Time = 0;
            }
            
            public void Destroy()
            {
                if (LogEnabled)
                    X3Debug.LogFormat("Layer.State: {0}.OnDestroy()", Name);
                OnDestroy();
                this.PrevTime = 0;
                this.Time = 0;
            }
            #endregion
            
            #region Inner Events
            /*
* stateA.OnPreExit(), stateB.OnEnter()
* after some transition time...
* StateA.OnExit(), stateB.OnPostEnter()
*/
            protected virtual void OnWillEnter()
            {
                //override this
            }
            
            protected virtual void OnUpdateWeight(float weight)
            {
                //override this
            }
            protected virtual void OnEnter(float transitonDuration, bool reEnter = false)
            {
                //override this
            }
            protected virtual void OnPostEnter()
            {
                //override this
            }
            protected virtual void OnPreExit(float transitonDuration)
            {
                //override this
            }
            protected virtual void OnExit()
            {
                //override this
            }
            protected virtual void OnPaused(bool paused)
            {
                //override this
            }
            protected virtual void OnUpdate(float dt)
            {
                //override this
            }
            protected virtual void OnLateUpdate()
            {
                //override this
            }
            protected virtual void OnStop()
            {
                //override this
            }
            protected virtual void OnDestroy()
            {
                //override this
            }
            #endregion

            #region Transform

            /// <summary>
            /// 设置位置
            /// </summary>
            /// <param name="x"></param>
            /// <param name="y"></param>
            /// <param name="z"></param>
            public virtual void SetPosition(float x, float y, float z)
            {
                
            }

            /// <summary>
            /// 设置旋转
            /// </summary>
            /// <param name="x"></param>
            /// <param name="y"></param>
            /// <param name="z"></param>
            /// <param name="w"></param>
            public virtual void SetRotation(float x, float y, float z, float w)
            {
                
            }

            /// <summary>
            /// 设置欧拉角
            /// </summary>
            /// <param name="x"></param>
            /// <param name="y"></param>
            /// <param name="z"></param>
            public virtual void SetEulerAngles(float x, float y, float z)
            {
                
            }
            #endregion
            
            protected void AddKeyFrameList(IList<KeyFrame> kfList)
            {
                if (kfList != null && kfList.Count > 0)
                {
                    KeyFrameList = new MotionKeyFrame();
                    KeyFrameList.AddFrameKeys(kfList, FrameRate, Length);
                }
            }

            public virtual void Clear()
            {
                Name = null;
                Length = 0;
                ExitTime = 1.0f;
                InitialTime = 0;
                PrevTime = 0;
                Time = 0;
                DeltaTime = 0;
                DefaultWrapMode = DirectorWrapMode.None;
                DefaultTransitionDuration = -1;
                KeyFrameList = null;
                WrapMode = DirectorWrapMode.None;
                IsEntering = false;
                IsExiting = false;
                Weight = 1;
                Layer = null;
            }
        }

        public class TestState : State
        {
            public static TestState Create(string name, float length)
            {
                if (string.IsNullOrEmpty(name))
                    return null;
                var state = new TestState()
                {
                    Name = name,
                    Length = length,
                    DefaultTransitionDuration = -1
                };
                return state;
            }

            protected override void OnUpdate(float dt)
            {
                base.OnUpdate(dt);
                Time += dt;
            }
        }
    }
}