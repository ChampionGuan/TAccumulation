using System;
using System.Collections.Generic;
using System.Linq;
using Unity.Profiling;
using UnityEngine;
using UnityEngine.Animations;
using UnityEngine.Playables;
using Object = UnityEngine.Object;
using X3;

namespace X3.PlayableAnimator
{
    public class AnimatorController : ScriptableObject
    {
        private static ProfilerMarker OnUpdatePMarmer = new ProfilerMarker("AnimatorController.OnUpdate()");
        private static ProfilerMarker StateNotifyInvokePMarmer = new ProfilerMarker("AnimatorController.StateNotify.Invoke()");

        private static List<int> m_InstanceControllers = new List<int>();

        [SerializeField] private List<AnimatorControllerLayer> m_Layers = new List<AnimatorControllerLayer>();
        [SerializeField] private List<AnimatorControllerParameter> m_Parameters = new List<AnimatorControllerParameter>();

        [NonSerialized] private int m_CallDepth;
        [NonSerialized] private bool m_IsValid;
        [NonSerialized] private int m_InputIndex;
        [NonSerialized] private string m_AssetPath;
        [NonSerialized] private TickEvent m_OnPrevUpdateTick = new TickEvent();
        [NonSerialized] private TickEvent m_OnPostUpdateTick = new TickEvent();
        [NonSerialized] private StateNotifyEvent m_StateNotifyEvent = new StateNotifyEvent();
        [NonSerialized] private List<AnimationClip> m_AnimationClips;
        [NonSerialized] private BoneLayerMixer.BoneLayerMixerPlayable m_Playable;
        [NonSerialized] private AnimationMixerPlayable m_OutputMixer; // 中间层playable，用于连接m_Playable与最外层

        public AnimatorControllerContext context { get; private set; }
        public Animator unityAnimator { get; private set; }
        public PlayableAnimator playableAnimator { get; private set; }
        public PlayableGraph playableGraph { get; private set; }
        public Playable playableParent { get; private set; }
        public BoneLayerMixer.BoneLayerMixerPlayable playable => m_Playable; 
        public TickEvent onPrevUpdateTick => m_OnPrevUpdateTick;
        public TickEvent onPostUpdateTick => m_OnPostUpdateTick;
        public StateNotifyEvent stateNotify => m_StateNotifyEvent;
        public int layersCount => m_Layers.Count;
        public int parametersCount => m_Parameters.Count;

        public List<AnimationClip> animationClips
        {
            get
            {
                if (null == m_AnimationClips)
                {
                    RecollectAnimationClips();
                }

                return m_AnimationClips;
            }
        }

        public bool isValid
        {
            get
            {
                if (!m_IsValid)
                {
                    return false;
                }

                for (var index = 0; index < m_Layers.Count; index++)
                {
                    if (!m_Layers[index].isValid)
                    {
                        return false;
                    }
                }

                return true;
            }
        }

        public static AnimatorController CreateDefault()
        {
            var ctrl = CreateInstance();
            var layer = new AnimatorControllerLayer("Base Layer", 1, AnimatorControllerLayerBlendingType.Override);
            ctrl.AddLayer(layer);
            return ctrl;
        }

        public static AnimatorController CreateInstance(List<AnimatorControllerLayer> layers = null, List<AnimatorControllerParameter> parameters = null)
        {
            var ctrl = ScriptableObject.CreateInstance<AnimatorController>();
            ctrl.AddLayer(layers);
            ctrl.AddParameter(parameters);
            m_InstanceControllers.Add(ctrl.GetInstanceID());
            return ctrl;
        }

        public static AnimatorController CopyInstance(AnimatorController ctrl)
        {
            if (null == ctrl)
            {
                return null;
            }

            var nCtrl = Instantiate(ctrl);
            nCtrl.name = ctrl.name;
#if UNITY_EDITOR
            nCtrl.m_AssetPath = UnityEditor.AssetDatabase.GetAssetPath(ctrl);
#endif
            m_InstanceControllers.Add(nCtrl.GetInstanceID());
            return nCtrl;
        }

        public static void DestroyInstance(AnimatorController ctrl)
        {
            if (null == ctrl)
            {
                return;
            }

            m_InstanceControllers.Remove(ctrl.GetInstanceID());
            DestroyImmediate(ctrl);
        }

        public static bool ContainInstance(AnimatorController ctrl)
        {
            if (null == ctrl)
            {
                return false;
            }

            bool result = m_InstanceControllers.Contains(ctrl.GetInstanceID());
#if UNITY_EDITOR
            if (!UnityEditor.EditorUtility.IsPersistent(ctrl) && !result)
            {
                result = true;
                m_InstanceControllers.Add(ctrl.GetInstanceID());
            }
#endif
            return result;
        }

#if UNITY_EDITOR
        public static T GetMasterAsset<T>(Object childAsset) where T : Object
        {
            if (null == childAsset)
                return default;
            var path = UnityEditor.AssetDatabase.GetAssetPath(childAsset);
            var asset = UnityEditor.AssetDatabase.LoadAssetAtPath<T>(path);
            return UnityEditor.AssetDatabase.Contains(childAsset) ? asset : default;
        }

        public static List<Object> GetAllChildAssets(Object masterAsset)
        {
            if (null == masterAsset)
            {
                return null;
            }

            var path = UnityEditor.AssetDatabase.GetAssetPath(masterAsset);
            if (string.IsNullOrEmpty(path))
            {
                return null;
            }

            var assets = UnityEditor.AssetDatabase.LoadAllAssetsAtPath(path).ToList();
            assets.Remove(masterAsset);
            return assets;
        }

        public static void SaveAssetIntoObject(Object childAsset, Object masterAsset)
        {
            if (childAsset == null || masterAsset == null)
                return;
            if (!(childAsset is ScriptableObject))
                return;

            if ((masterAsset.hideFlags & HideFlags.DontSave) != 0)
            {
                childAsset.hideFlags |= HideFlags.DontSave;
            }
            else
            {
                childAsset.hideFlags |= HideFlags.HideInHierarchy;
                if (!UnityEditor.AssetDatabase.Contains(childAsset) && UnityEditor.AssetDatabase.Contains(masterAsset))
                    UnityEditor.AssetDatabase.AddObjectToAsset(childAsset, masterAsset);
            }
        }

        public static void RemoveAssetFromObject(Object childAsset)
        {
            if (null == childAsset)
            {
                return;
            }

            UnityEditor.AssetDatabase.RemoveObjectFromAsset(childAsset);
        }
#endif

        public static bool IsReachingThreshold(float currValue, float prevValue, float circleValue, float threshold, out float stepValue)
        {
            stepValue = 0;
            if (currValue == prevValue || prevValue < 0)
            {
                return false;
            }

            var dValue = currValue - prevValue;
            if (currValue > 10 * circleValue)
            {
                currValue %= circleValue;
                prevValue = currValue - dValue;
            }
            else
            {
                while (currValue > circleValue)
                {
                    currValue -= circleValue;
                    prevValue -= circleValue;
                }
            }

            if (prevValue < 0)
            {
                currValue += circleValue;
            }

            stepValue = currValue - threshold;
            if (stepValue > circleValue)
            {
                stepValue -= circleValue;
            }

            var result = dValue != 0 && ((prevValue + dValue >= threshold && prevValue < threshold) || (currValue >= threshold && currValue - dValue < threshold));
            return result;
        }

        public void OnStart()
        {
            for (var i = 0; i < parametersCount; i++)
            {
                m_Parameters[i].OnStart();
            }

            for (var i = 0; i < layersCount; i++)
            {
                m_Layers[i].OnStart();
            }
        }

        public void OnUpdate(float deltaTime)
        {
            using (OnUpdatePMarmer.Auto())
            {
                if (m_CallDepth++ == 0)
                {
                    if (!isValid) RebuildPlayable();
                    onPrevUpdateTick?.Dispatch();

                    for (var i = 0; i < layersCount; i++)
                    {
                        m_Layers[i].OnUpdate(deltaTime);
                    }

                    for (var i = 0; i < parametersCount; i++)
                    {
                        m_Parameters[i].OnUpdate(this, deltaTime);
                    }

                    onPostUpdateTick?.Dispatch();
                }
                else
                {
                    // Debug.LogError($"[AnimatorController.OnUpdate()]致命错误！出现循环调用，资源:{name}，将会出现动画表现异常，请检查！");
                }

                m_CallDepth--;
            }
        }

        private void OnDestroy()
        {
            for (var i = 0; i < layersCount; i++)
            {
                m_Layers[i].OnDestroy();
            }

            for (var i = 0; i < parametersCount; i++)
            {
                m_Parameters[i].OnDestroy();
            }

            if (m_Playable.IsValid())
            {
                m_Playable.Destroy();
            }

            stateNotify.Clear();
            onPrevUpdateTick.Clear();
            onPostUpdateTick.Clear();
            Reset();
        }

        public void Clear()
        {
            m_Layers.Clear();
            m_Parameters.Clear();
        }

        public void SetWeight(float weight)
        {
            if (!playableParent.IsValid())
            {
                return;
            }

            playableParent.SetInputWeight(m_InputIndex, weight);
        }

        public void Play(string stateName, int layerIndex = 0, float normalizedTime = float.NegativeInfinity)
        {
            m_Layers[Mathf.Clamp(layerIndex, 0, layersCount - 1)].Play(stateName, normalizedTime);
        }

        public void PlayInFixedTime(string stateName, int layerIndex = 0, float fixedTime = float.NegativeInfinity)
        {
            m_Layers[Mathf.Clamp(layerIndex, 0, layersCount - 1)].PlayInFixedTime(stateName, fixedTime);
        }

        public void CrossFade(string stateName, int layerIndex = 0, float normalizedOffsetTime = 0, float dValue = 0)
        {
            m_Layers[Mathf.Clamp(layerIndex, 0, layersCount - 1)].CrossFade(stateName, normalizedOffsetTime, dValue);
        }

        public void CrossFade(string stateName, float normalizedTransitionTime = 0, int layerIndex = 0, float normalizedOffsetTime = 0, float dValue = 0)
        {
            m_Layers[Mathf.Clamp(layerIndex, 0, layersCount - 1)].CrossFade(stateName, normalizedOffsetTime, normalizedTransitionTime, dValue);
        }

        public void CrossFadeInFixedTime(string stateName, int layerIndex = 0, float fixedOffsetTime = 0, float dValue = 0)
        {
            m_Layers[Mathf.Clamp(layerIndex, 0, layersCount - 1)].CrossFadeInFixedTime(stateName, fixedOffsetTime, dValue);
        }

        public void CrossFadeInFixedTime(string stateName, float fixedTransitionTime = 0, int layerIndex = 0, float fixedOffsetTime = 0, float dValue = 0)
        {
            m_Layers[Mathf.Clamp(layerIndex, 0, layersCount - 1)].CrossFadeInFixedTime(stateName, fixedOffsetTime, fixedTransitionTime, dValue);
        }

        public bool HasState(string stateName, int layerIndex)
        {
            return m_Layers[Mathf.Clamp(layerIndex, 0, layersCount - 1)].HasState(stateName);
        }

        public bool AddState(string stateName, AnimationClip clip, int layerIndex)
        {
            return m_Layers[Mathf.Clamp(layerIndex, 0, layersCount - 1)].AddState(stateName, new ClipMotion(clip));
        }

        public bool AddState(string stateName, Motion motion, int layerIndex)
        {
            return m_Layers[Mathf.Clamp(layerIndex, 0, layersCount - 1)].AddState(stateName, motion);
        }

        public AnimatorStateInfo GetPreviousStateInfo(int layerIndex)
        {
            return m_Layers[Mathf.Clamp(layerIndex, 0, layersCount - 1)].GetPreviousStateInfo();
        }

        public AnimatorStateInfo GetCurrentStateInfo(int layerIndex)
        {
            return m_Layers[Mathf.Clamp(layerIndex, 0, layersCount - 1)].GetCurrentStateInfo();
        }

        public AnimatorStateInfo GetStateInfo(int layerIndex, string stateName)
        {
            return m_Layers[Mathf.Clamp(layerIndex, 0, layersCount - 1)].GetStateInfo(stateName);
        }

        public BlendTreeInfo GetBlendTreeInfo(string stateName, int layerIndex)
        {
            return m_Layers[Mathf.Clamp(layerIndex, 0, layersCount - 1)].GetBlendTreeInfo(stateName);
        }

        public float GetBlendTick(int layerIndex)
        {
            return m_Layers[Mathf.Clamp(layerIndex, 0, layersCount - 1)].GetBlendTick();
        }

        public float? GetAnimatorStateLength(string stateName, int layerIndex)
        {
            return m_Layers[Mathf.Clamp(layerIndex, 0, layersCount - 1)].GetState<StateMotion>(stateName)?.length;
        }

        public void SetEnableBoneLayerBlend(bool enable)
        {
            m_Playable.SetEnableBoneLayerBlend(enable);
        }

        public AnimationClip GetAnimatorStateClip(string stateName, int layerIndex)
        {
            return (m_Layers[Mathf.Clamp(layerIndex, 0, layersCount - 1)].GetState<StateMotion>(stateName)?.motion as ClipMotion)?.clip;
        }

        public bool TryCalParameterValue(string blendTreeName, float inValue, int layerIndex, out float value, ComputeThresholdsType type = ComputeThresholdsType.Speed)
        {
            if (!(m_Layers[Mathf.Clamp(layerIndex, 0, layersCount - 1)].GetState<StateMotion>(blendTreeName)?.motion is BlendTree blendTree))
            {
                value = 0;
                return false;
            }

            value = blendTree.CalParameterValue(inValue, type);
            return true;
        }

        public int GetLayerIndex(string layerName)
        {
            for (var i = 0; i < layersCount; i++)
            {
                if (m_Layers[i].name == layerName)
                {
                    return i;
                }
            }

            return -1;
        }

        public void SetLayerWeight(int layerIndex, float weight)
        {
            GetLayer(layerIndex)?.SetWeight(weight);
        }

        public void SetLayerSpeed(int layerIndex, float speed)
        {
            GetLayer(layerIndex)?.SetSpeed(speed);
        }

        public void SetPrevBone(int layerIndex, Transform[] bones)
        {
            GetLayer(layerIndex)?.SetPrevBone(bones);
        }

        public void SetStateSpeed(string stateName, float speed, int layerIndex = 0)
        {
            GetLayer(layerIndex)?.SetStateSpeed(stateName, speed);
        }

        public bool GetBool(string parameterName)
        {
            var parameter = GetParameter(parameterName);
            return null != parameter && parameter.defaultBool;
        }

        public int GetInteger(string parameterName)
        {
            var parameter = GetParameter(parameterName);
            return parameter?.defaultInt ?? 0;
        }

        public float GetFloat(string parameterName)
        {
            var parameter = GetParameter(parameterName);
            return parameter?.defaultFloat ?? 0;
        }

        public void SetBool(string parameterName, bool value)
        {
            var parameter = GetParameter(parameterName);
            if (null != parameter)
            {
                parameter.defaultBool = value;
            }
        }

        public void SetInteger(string parameterName, int value)
        {
            var parameter = GetParameter(parameterName);
            if (null != parameter)
            {
                parameter.defaultInt = value;
            }
        }

        public void SetFloat(string parameterName, float value, float time = 0)
        {
            var parameter = GetParameter(parameterName);
            if (null != parameter)
            {
                parameter.SetFloat(value, time);
            }
        }

        /// <summary>
        /// 判断是否有某个参数
        /// </summary>
        /// <param name="parameterName"></param>
        /// <returns></returns>
        public bool HasParam(string parameterName)
        {
            var parameter = GetParameter(parameterName);
            return parameter != null;
        }

        public void Combine(AnimatorController other)
        {
            if (null == other)
            {
                return;
            }

            for (var index = 0; index < other.m_Layers.Count; index++)
            {
                AddLayer(other.m_Layers[index]);
            }

            for (var index = 0; index < other.m_Parameters.Count; index++)
            {
                AddParameter(other.m_Parameters[index]);
            }
        }

        public void AddLayer(List<AnimatorControllerLayer> layers)
        {
            if (null == layers)
            {
                return;
            }

            for (var index = 0; index < layers.Count; index++)
            {
                AddLayer(layers[index]);
            }
        }

        public void AddLayer(AnimatorControllerLayer layer)
        {
            if (null == layer || string.IsNullOrEmpty(layer.name) || null != GetLayer(layer.name))
            {
                return;
            }

            layer.Reset();
            m_Layers.Add(layer);
        }

        public void RemoveLayer(string name)
        {
            var layer = GetLayer(name);
            if (null == layer)
            {
                return;
            }

            m_Layers.Remove(layer);
        }

        public AnimatorControllerLayer GetLayer(string name)
        {
            if (string.IsNullOrEmpty(name))
            {
                return null;
            }

            for (var index = 0; index < m_Layers.Count; index++)
            {
                var layer = m_Layers[index];
                if (layer.name == name)
                {
                    return layer;
                }
            }

            return null;
        }

        public AnimatorControllerLayer GetLayer(int index)
        {
            if (index < 0 || index >= layersCount)
            {
                return null;
            }

            return m_Layers[index];
        }

        public void AddParameter(List<AnimatorControllerParameter> parameters)
        {
            if (null == parameters)
            {
                return;
            }

            for (var index = 0; index < parameters.Count; index++)
            {
                AddParameter(parameters[index]);
            }
        }

        public void AddParameter(AnimatorControllerParameter parameter)
        {
            if (null == parameter || string.IsNullOrEmpty(parameter.name) || null != GetParameter(parameter.name))
            {
                return;
            }

            m_Parameters.Add(parameter);
        }

        public void RemoveParameter(string name)
        {
            var parameter = GetParameter(name);
            if (null == parameter)
            {
                return;
            }

            m_Parameters.Remove(parameter);
        }

        public AnimatorControllerParameter GetParameter(string name)
        {
            if (string.IsNullOrEmpty(name))
            {
                return null;
            }

            for (var index = 0; index < m_Parameters.Count; index++)
            {
                var parameter = m_Parameters[index];
                if (parameter.name == name)
                {
                    return parameter;
                }
            }

            return null;
        }

        public AnimatorControllerParameter GetParameter(int index)
        {
            if (index < 0 || index >= parametersCount)
            {
                return null;
            }

            return m_Parameters[index];
        }

        public void RecollectAnimationClips()
        {
            if (null == m_AnimationClips)
            {
                m_AnimationClips = new List<AnimationClip>();
            }
            else
            {
                m_AnimationClips.Clear();
            }

            for (var i = 0; i < layersCount; i++)
            {
                m_Layers[i].GetAnimationClips(m_AnimationClips);
            }
        }

        public void Reset()
        {
            if (null != playableAnimator && playableAnimator.runtimeAnimatorController == this)
            {
                playableAnimator.runtimeAnimatorController = null;
            }

            unityAnimator = null;
            playableAnimator = null;
            context = null;
        }

        public Playable RebuildPlayable(AnimatorControllerContext context, PlayableAnimator animator, Playable parent, int inputIndex)
        {
            m_InputIndex = inputIndex;
            playableParent = parent;
            playableGraph = parent.GetGraph();
            playableAnimator = animator;
            unityAnimator = animator?.animator;
            this.context = context ?? new AnimatorControllerContext();
            this.context.SetOwner(this);
            RebuildPlayable();
            return m_OutputMixer;
        }

        private void RebuildPlayable()
        {
            if (!playableParent.IsValid())
            {
                return;
            }
            m_IsValid = true;
            m_Playable = context.CreateBoneLayerMixerPlayable(playableGraph, layersCount);
            m_OutputMixer = AnimationMixerPlayable.Create(playableGraph, 1);
            m_OutputMixer.ConnectInput(0, m_Playable, 0, 1);
            var weight = playableParent.GetInputWeight(m_InputIndex);
            playableParent.DisconnectInput(m_InputIndex);
            playableParent.ConnectInput(m_InputIndex, m_OutputMixer, 0, weight);

            for (var i = 0; i < layersCount; i++)
            {
                var layer = m_Layers[i];
                var layerIndex = i;
                layer.RebuildPlayable(this, layerIndex, (updatedType, stateName) =>
                {
                    using (StateNotifyInvokePMarmer.Auto())
                    {
                        stateNotify.Dispatch(layerIndex, updatedType, stateName);
                        playableAnimator?.stateNotify?.Dispatch(layerIndex, updatedType, stateName);
                    }
                });
            }
        }

        public void OnAfterDeserialize()
        {
        }

//        public void OnBeforeSerialize()
//        {
//#if UNITY_EDITOR
//            var oldAssets = GetAllChildAssets(this);
//            if (null == oldAssets)
//            {
//                return;
//            }

//            var newAssets = new List<Object>();
//            foreach (var layer in m_Layers)
//            {
//                GatheringLayerAssets(layer, newAssets);
//            }

//            var addAssets = new List<Object>();
//            foreach (var asset in newAssets)
//            {
//                if (oldAssets.Contains(asset))
//                {
//                    oldAssets.Remove(asset);
//                }
//                else
//                {
//                    addAssets.Add(asset);
//                }
//            }

//            foreach (var asset in oldAssets)
//            {
//                if (Application.isBatchMode)
//                {
//                    throw new Exception($"[PlayableAnimator] 动画控制器异常，存在无效子资源，请留意检查！ path：{UnityEditor.AssetDatabase.GetAssetPath(this)}");
//                }

//                if (null == asset)
//                {
//                    Debug.LogError($"[PlayableAnimator] 动画控制器异常，待删除资源为空，请留意检查！ path：{UnityEditor.AssetDatabase.GetAssetPath(this)}");
//                }

//                RemoveAssetFromObject(asset);
//            }

//            foreach (var asset in addAssets)
//            {
//                SaveAssetIntoObject(asset, this);
//            }

//            if (oldAssets.Count > 0 || addAssets.Count > 0)
//            {
//                UnityEditor.EditorUtility.SetDirty(this);
//            }
//#endif
//        }

//        private void GatheringLayerAssets(AnimatorControllerLayer layer, List<Object> assets)
//        {
//            for (var i = 0; i < layer.statesCount; i++)
//            {
//                GatheringStateAssets(layer.GetState<StateMotion>(i), assets);
//            }

//            for (var i = 0; i < layer.groupsCount; i++)
//            {
//                GatheringStateAssets(layer.GetState<StateGroup>(i), assets);
//            }
//        }

//        private void GatheringStateAssets(State state, List<Object> assets)
//        {
//            for (var i = 0; i < state.transitionsCount; i++)
//            {
//                GatheringTransitionAssets(state.GetTransition(i), assets);
//            }
//        }

//        private void GatheringTransitionAssets(Transition transition, List<Object> assets)
//        {
//            for (var i = 0; i < transition.conditionsCount; i++)
//            {
//                assets.Add(transition.GetCondition(i));
//            }
//        }
    }

    public enum StateNotifyType
    {
        /// <summary>
        /// 状态准备进入
        /// </summary>
        PrepEnter = 0,

        /// <summary>
        /// 状态进入
        /// </summary>
        Enter,

        /// <summary>
        /// 状态准备退出
        /// </summary>
        PrepExit,

        /// <summary>
        /// 状态退出
        /// </summary>
        Exit,

        /// <summary>
        /// 动画播放完毕
        /// </summary>
        Complete
    }

    public class StateNotifyEvent : CustomEvent.CustomEvent<int, StateNotifyType, string>
    {
    }

    public class TickEvent : CustomEvent.CustomEvent
    {
    }
}