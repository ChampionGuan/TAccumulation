using UnityEngine;
using UnityEngine.Playables;
using AnimatorController = X3.PlayableAnimator.AnimatorController;
using PapeGames.X3;
using Framework;
using ProceduralAnimation;
using UnityEngine.Animations;
using UnityEngine.Experimental.Animations;
using System.Collections.Generic;

namespace X3Game
{
    public partial class X3Animator
    {
        #region Play ...
        public bool CrossfadeWithLoopable(string stateName, float mormalizedTimeOffset = -1, float transitionDuration = -1, bool updateImmediate = true)
        {
            var ret = Crossfade(stateName, mormalizedTimeOffset, transitionDuration);
            return ret;
        }

        #endregion

        public bool AddState(AnimatorController controller)
        {
            return false;
        }

        public int AddState(string stateName, GameObject ctsPrefab, bool inheritTransform = false,
            DirectorWrapMode defaultWrapMode = DirectorWrapMode.None, float defaultTransitionDuration = -1,
            IList<KeyFrame> kfList = null)
        {
            string ctsName = ctsPrefab == null ? string.Empty : ctsPrefab.name;
            return AddState(stateName, ctsName, inheritTransform, defaultWrapMode, defaultTransitionDuration,
                kfList);
        }

        #region Embeded
        
        public string[] EmbededStateNames
        {
            get => null;
        }

        public List<State> EmbeddedStateList
        {
            get => m_EmbeddedStateList;
        }

        public enum StateType
        {
            AnimationClip,
            ProceduralAnimationClip,
            CutScene,
        }

        [System.Serializable]
        public class State
        {
            [SerializeField] protected StateType m_StateType;
            [SerializeField] protected string m_StateName;
            [SerializeField] protected AnimationClip m_AnimationClip;
            [SerializeField] protected ProceduralAnimationClip m_ProceduralAnimationClip;
            [SerializeField] protected string m_CutSceneName;
            [SerializeField] protected bool m_Loopable;
            [SerializeField] protected bool m_InheritTransform = false;
            [SerializeField] protected float m_ExitTime = 0.9f;

            public StateType StateType
            {
                get => m_StateType;
                set => m_StateType = value;
            }

            public AnimationClip AnimationClip
            {
                get => m_AnimationClip;
                set => m_AnimationClip = value;
            }

            public ProceduralAnimationClip ProceduralAnimationClip
            {
                get => m_ProceduralAnimationClip;
                set => m_ProceduralAnimationClip = value;
            }

            public string CutSceneName
            {
                get => m_CutSceneName;
                set => m_CutSceneName = value;
            }

            public string StateName
            {
                get => m_StateName;
                set => m_StateName = value;
            }
            
            public float ExitTime
            {
                get => m_ExitTime;
                set => m_ExitTime = value;
            }

            public bool Loopable
            {
                get => m_Loopable;
                set => m_Loopable = value;
            }

            public bool InheritTransform
            {
                get => m_InheritTransform;
                set => m_InheritTransform = value;
            }

            public List<KeyFrame> KeyFrameList = new List<KeyFrame>();

            public State Copy()
            {
                var newState = new State();

                newState.m_StateType = m_StateType;
                newState.m_StateName = m_StateName;
                newState.m_AnimationClip = m_AnimationClip;
                newState.m_ProceduralAnimationClip = m_ProceduralAnimationClip;
                newState.m_CutSceneName = m_CutSceneName;
                newState.m_Loopable = m_Loopable;
                newState.m_InheritTransform = m_InheritTransform;

                return newState;
            }
        }

        private void AddStatesFromEmbededList(IList<State> list)
        {
            if (list == null)
                return;
            foreach (var stateAsset in list)
            {
                DirectorWrapMode defaultWrapMode =
                    stateAsset.Loopable ? DirectorWrapMode.Loop : DirectorWrapMode.Hold;
                if (stateAsset.StateType == StateType.CutScene)
                {
                    AddState(stateAsset.StateName, stateAsset.CutSceneName, stateAsset.InheritTransform,
                        defaultWrapMode);
                }
                else if (stateAsset.StateType == StateType.AnimationClip)
                {
                    AddState(stateAsset.StateName, stateAsset.AnimationClip, defaultWrapMode, stateAsset.ExitTime, stateAsset.KeyFrameList);
                }
                else if (stateAsset.StateType == StateType.ProceduralAnimationClip)
                {
                    AddState(stateAsset.StateName, stateAsset.ProceduralAnimationClip, defaultWrapMode, stateAsset.ExitTime, 
                        stateAsset.KeyFrameList);
                }
            }
        }

        #endregion

        #region Static Manipulation

        public static X3Animator AddComponent(GameObject ins)
        {
            if (ins == null)
            {
                return null;
            }

            var comp = ins.GetComponent<X3Animator>();
            if (comp == null)
                comp = ins.AddComponent<X3Animator>();

            return comp;
        }

        static Dictionary<string, X3Animator> s_InsDict = new Dictionary<string, X3Animator>();

        public static X3Animator Add(string key, GameObject ins)
        {
            if (ins == null || string.IsNullOrEmpty(key))
            {
                X3Debug.LogErrorFormat("X3Animator.Add null ins({0}) or null key({1})", ins == null ? "null" : ins.name,
                    key);
                return null;
            }

            var comp = ins.GetComponent<X3Animator>();
            if (comp == null)
                comp = ins.AddComponent<X3Animator>();
            s_InsDict[key] = comp;
            return comp;
        }

        public static void Remove(string key)
        {
            s_InsDict.Remove(key);
        }

        public static X3Animator GetIns(string key)
        {
            if (!s_InsDict.TryGetValue(key, out X3Animator comp))
                return null;
            return comp;
        }

        public static void Detach(GameObject ins)
        {
            if (ins == null)
                return;
            var comp = ins.GetComponent<X3Animator>();
            if (comp != null)
                Destroy(comp);
        }

        public static void SetDataProviderEnabled(GameObject ins, bool enabled)
        {
            if (ins == null)
                return;
            var comp = ins.GetComponent<X3Animator>();
            if (comp)
                comp.DataProviderEnabled = enabled;
        }

        #endregion

        #region ControlRig

        public ControlRigGraph controlRigAsset;
        public Transform controlRigTarget;

        private bool enableControlRig = false;

        private ControlRigGraphContext m_ControlRigContext;
        private ControlRigMixerWorkspace m_MixerWorkspace;

        AnimationPlayableOutput controlRigOutput;

        private enum BlendDirection
        {
            Open,
            Close
        }

        private BlendDirection blendDirection;
        private float totalWeight = 0.0f;
        private float blendStartTime = 0.0f;
        private float startBlendWeight = 0.0f;
        private float blendTime;

        public void UpdateControlRig()
        {
            if (!enableControlRig)
            {
                return;
            }

            if (!controlRigOutput.IsOutputValid()) // To prevent character graph has been rebuilt
            {
                RebuildControlRig();
            }

            if (m_ControlRigContext != null)
            {
                if (blendTime > 0.05f)
                {
                    float blendAlpha = Mathf.Clamp01((Time.time - blendStartTime) / blendTime);

                    if (blendDirection == BlendDirection.Open)
                    {
                        m_ControlRigContext.totalWeight =
                            Mathf.Clamp01(startBlendWeight + (1 - startBlendWeight) * blendAlpha);
                    }
                    else if (blendDirection == BlendDirection.Close)
                    {
                        m_ControlRigContext.totalWeight =
                            Mathf.Clamp01(startBlendWeight - startBlendWeight * blendAlpha);

                        if (m_ControlRigContext.totalWeight == 0)
                        {
                            CleanControlRig();
                            enableControlRig = false;
                            return;
                        }
                    }
                }
                else
                {
                    if (blendDirection == BlendDirection.Open)
                    {
                        m_ControlRigContext.totalWeight = 1;
                    }
                    else if (blendDirection == BlendDirection.Close)
                    {
                        CleanControlRig();
                        enableControlRig = false;
                        return;
                    }
                }

                //m_ControlRigContext.SetVariableValue("ArmTwistWeight", 0.0f);

                // Control rig的参数
                m_ControlRigContext.SetVariableValue("Target", controlRigTarget);
            }
        }

        public void OpenControlRig(float blendTime = 0.4f)
        {
            if (Animator == null || controlRigAsset == null)
            {
                return;
            }

            if (!enableControlRig)
            {
                RebuildControlRig();

                enableControlRig = true;

                this.blendTime = blendTime;

                blendStartTime = Time.time;
                blendDirection = BlendDirection.Open;
                if (m_ControlRigContext != null)
                {
                    startBlendWeight = 0;
                }
            }
        }

        public void CloseControlRig(float blendTime = 0.4f)
        {
            blendStartTime = Time.time;
            blendDirection = BlendDirection.Close;
            this.blendTime = blendTime;

            if (m_ControlRigContext != null)
            {
                startBlendWeight = m_ControlRigContext.totalWeight;
            }
        }

        private void CleanControlRig()
        {
            if (m_MixerWorkspace != null)
            {
                m_MixerWorkspace.Dispose();
                m_MixerWorkspace = null;
            }

            if (controlRigOutput.IsOutputValid())
            {
                controlRigOutput.SetSourcePlayable(Playable.Null);
            }

            m_ControlRigContext = null;
        }

        private void RebuildControlRig()
        {
            CleanControlRig();

            var characterGraph = PlayableAnimationManager.Instance().FindPlayGraph(this.gameObject);

            m_MixerWorkspace = new ControlRigMixerWorkspace(Animator, characterGraph.GetPlayableGraph(), false, false);
            m_ControlRigContext =
                controlRigAsset.InitializeRunningJobContext(Animator.transform, Animator,
                    characterGraph.GetPlayableGraph());
            m_MixerWorkspace.SetContexts(new ControlRigGraphContext[] { m_ControlRigContext });

            if (!controlRigOutput.IsOutputValid())
            {
                controlRigOutput =
                    AnimationPlayableOutput.Create(characterGraph.GetPlayableGraph(), "ControlRig", Animator);
                controlRigOutput.SetAnimationStreamSource(AnimationStreamSource.PreviousInputs);
                controlRigOutput.SetSortingOrder(2000);
            }

            controlRigOutput.SetSourcePlayable(m_MixerWorkspace.WorkspacePlayable);
        }

        #endregion
    }
}