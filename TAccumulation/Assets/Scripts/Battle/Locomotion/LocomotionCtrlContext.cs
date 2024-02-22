using UnityEngine;
using X3.PlayableAnimator;
using AnimatorStateInfo = X3.PlayableAnimator.AnimatorStateInfo;

namespace X3Battle
{
    public interface ILocomotionContext
    {
        Vector3 position { get; }
        Quaternion rotation { get; }
        Vector3 forward { get; }
        StateNotifyEvent onStateNotify { get; }

        void SetPosition(Vector3 position, bool isForce = false);
        void SetRotation(Quaternion rotation);
        void TranslateEulerAnglesY(float deltaEulerAnglesY);
        void AddChild(Transform child, bool worldPositionStays = false);
        void PlayAnim(string stateName, bool skipSameState = true, float fadeTime = 0, int layerIndex = 0, float? stateSpeed = null);
        void PlayAnim(string stateName, float offsetTime, float fadeTime, int layerIndex = 0, float? stateSpeed = null);
        AnimatorStateInfo GetCurrentAnimatorStateInfo(int layerIndex = 0);
        AnimatorStateInfo GetPreviousAnimatorStateInfo(int layerIndex = 0);
        BlendTreeInfo GetBlendTreeInfo(string stateName, int layerIndex = 0);
        string GetCurrentAnimatorStateName(int layerIndex = 0);
        float GetAnimatorStateLength(string stateName, int layerIndex = 0);
        float GetBlendTick(int layerIndex = 0);
        void SetFloat(string parameterName, float value, float time = 0);
        void SetBool(string stateName, bool value);
        void SetInteger(string stateName, int value);
        float GetFloat(string stateName);
        bool HasParam(string paramName);
        bool HasState(string stateName, int layerIndex = 0);
        AnimationClip GetAnimatorStateClip(string stateName, int layerIndex = 0);
        bool TryCalBlendTreeParamValue(string blendTreeName, float speed, out float value, int layerIndex = 0, ComputeThresholdsType type = ComputeThresholdsType.Speed);
        void SetRootMotionMultiplier(float? x = null, float? y = null, float? z = null, bool? live = null, RMMultiplierType type = RMMultiplierType.Base);
        void SetLayerWeight(int layerIndex, float weight);
    }

    public class LocomotionCtrlContext : ILocomotionContext
    {
        private BattleAnimator _animator;
        private ActorTransform _transform;

        public Vector3 position => _transform.position;
        public Quaternion rotation => _transform.rotation;
        public Vector3 forward => _transform.forward;
        public StateNotifyEvent onStateNotify => _animator.onStateNotify;

        public LocomotionCtrlContext(Actor actor)
        {
            _animator = actor.animator;
            _transform = actor.transform;
        }

        public void SetPosition(Vector3 position, bool isForce = false)
        {
            _transform.SetPosition(position, isForce);
        }

        public void SetRotation(Quaternion rotation)
        {
            _transform.SetRotation(rotation);
        }

        public void TranslateEulerAnglesY(float deltaEulerAnglesY)
        {
            _transform.TranslateEulerAnglesY(deltaEulerAnglesY);
        }

        public void AddChild(Transform child, bool worldPositionStays = false)
        {
            _transform.AddChild(child, worldPositionStays);
        }

        public void PlayAnim(string stateName, bool skipSameState = true, float fadeTime = 0, int layerIndex = 0, float? stateSpeed = null)
        {
            _animator.PlayAnim(stateName, skipSameState, fadeTime, layerIndex, stateSpeed);
        }

        public void PlayAnim(string stateName, float offsetTime, float fadeTime, int layerIndex = 0, float? stateSpeed = null)
        {
            _animator.PlayAnim(stateName, offsetTime, fadeTime, layerIndex, stateSpeed);
        }

        public AnimatorStateInfo GetCurrentAnimatorStateInfo(int layerIndex = 0)
        {
            return _animator.GetCurrentAnimatorStateInfo(layerIndex);
        }

        public AnimatorStateInfo GetPreviousAnimatorStateInfo(int layerIndex = 0)
        {
            return _animator.GetPreviousAnimatorStateInfo(layerIndex);
        }

        public BlendTreeInfo GetBlendTreeInfo(string stateName, int layerIndex = 0)
        {
            return _animator.GetBlendTreeInfo(stateName, layerIndex);
        }

        public string GetCurrentAnimatorStateName(int layerIndex = 0)
        {
            return _animator.GetCurrentAnimatorStateName(layerIndex);
        }

        public float GetAnimatorStateLength(string stateName, int layerIndex = 0)
        {
            return _animator.GetAnimatorStateLength(stateName, layerIndex);
        }

        public float GetBlendTick(int layerIndex = 0)
        {
            return _animator.GetBlendTick(layerIndex);
        }

        public void SetFloat(string parameterName, float value, float time = 0)
        {
            _animator.SetFloat(parameterName, value, time);
        }

        public void SetBool(string stateName, bool value)
        {
            _animator.SetBool(stateName, value);
        }

        public void SetInteger(string stateName, int value)
        {
            _animator.SetInteger(stateName, value);
        }

        public float GetFloat(string stateName)
        {
            return _animator.GetFloat(stateName);
        }

        public bool HasParam(string paramName)
        {
            return _animator.HasParam(paramName);
        }

        public bool HasState(string stateName, int layerIndex = 0)
        {
            return _animator.HasState(stateName, layerIndex);
        }

        public AnimationClip GetAnimatorStateClip(string stateName, int layerIndex = 0)
        {
            return _animator.GetAnimatorStateClip(stateName, layerIndex);
        }

        public bool TryCalBlendTreeParamValue(string blendTreeName, float speed, out float value, int layerIndex = 0, ComputeThresholdsType type = ComputeThresholdsType.Speed)
        {
            return _animator.TryCalBlendTreeParamValue(blendTreeName, speed, out value, layerIndex, type);
        }

        public void SetRootMotionMultiplier(float? x = null, float? y = null, float? z = null, bool? live = null, RMMultiplierType type = RMMultiplierType.Base)
        {
            _animator.SetRootMotionMultiplier(x, y, z, live, type);
        }

        public void SetLayerWeight(int layerIndex, float weight)
        {
            _animator.SetLayerWeight(layerIndex, weight);
        }
    }
}