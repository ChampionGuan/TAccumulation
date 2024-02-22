using System;
using Unity.Profiling;
using UnityEngine;
using UnityEngine.Animations;

namespace X3.PlayableAnimator
{
    [Serializable]
    public abstract class Motion
    {
        private static ProfilerMarker OnPrepEnterPMarmer = new ProfilerMarker("Concurrent.OnPrepEnter()");
        private static ProfilerMarker OnEnterPMarmer = new ProfilerMarker("Concurrent.OnEnter()");
        private static ProfilerMarker OnPrepExitPMarmer = new ProfilerMarker("Concurrent.OnPrepExit()");
        private static ProfilerMarker OnExitPMarmer = new ProfilerMarker("Concurrent.OnExit()");
        private static ProfilerMarker SetTimePMarmer = new ProfilerMarker("Concurrent.SetTime()");

        public IConcurrent concurrent { get; private set; }
        public abstract bool isLooping { get; }
        public abstract float length { get; }
        public abstract double normalizedTime { get; }
        public abstract bool hasEmptyClip { get; }
        public abstract void Reset();
        public abstract Motion DeepCopy();
        public abstract void RebuildPlayable(AnimatorController ctrl, BonePrevMixer.BonePrevMixerPlayable parent, int inputIndex, float weight);

        public virtual void OnPrepEnter(Motion prevMotion)
        {
            using (OnPrepEnterPMarmer.Auto())
            {
                try
                {
                    concurrent?.OnPrepEnter();
                }
                catch (Exception e)
                {
                    Debug.LogError(e);
                }
            }
        }

        public virtual void OnEnter(Motion prevMotion)
        {
            using (OnEnterPMarmer.Auto())
            {
                try
                {
                    concurrent?.OnEnter();
                }
                catch (Exception e)
                {
                    Debug.LogError(e);
                }
            }
        }

        public virtual void OnPrepExit(Motion nextMotion)
        {
            using (OnPrepExitPMarmer.Auto())
            {
                try
                {
                    concurrent?.OnPrepExit();
                }
                catch (Exception e)
                {
                    Debug.LogError(e);
                }
            }
        }

        public virtual void OnExit(Motion nextMotion)
        {
            using (OnExitPMarmer.Auto())
            {
                try
                {
                    concurrent?.OnExit();
                }
                catch (Exception e)
                {
                    Debug.LogError(e);
                }
            }
        }

        public virtual void OnDestroy()
        {
            try
            {
                concurrent?.OnDestroy();
            }
            catch (Exception e)
            {
                Debug.LogError(e);
            }
        }

        public virtual void SetTime(double time)
        {
            using (SetTimePMarmer.Auto())
            {
                try
                {
                    concurrent?.SetTime(time);
                }
                catch (Exception e)
                {
                    Debug.LogError(e);
                }
            }
        }

        public virtual void SetWeight(float weight)
        {
            try
            {
                concurrent?.SetWeight(weight);
            }
            catch (Exception e)
            {
                Debug.LogError(e);
            }
        }

        public virtual void SetConcurrent(IConcurrent concurrent)
        {
            if (null != concurrent)
            {
                concurrent.owner = this;
            }

            this.concurrent = concurrent;
        }
    }
}