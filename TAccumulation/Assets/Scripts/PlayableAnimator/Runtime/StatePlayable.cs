using UnityEngine;

namespace X3.PlayableAnimator
{
    public abstract class StatePlayable : State
    {
        public abstract int internalHashID { get; }
        public abstract bool isValid { get; }
        public abstract float speed { get; }
        public abstract float defaultSpeed { get; }
        public abstract bool isRunning { get; }
        public abstract bool isLooping { get; }
        public abstract float length { get; }
        public abstract float weight { get; }
        public abstract double normalizedTime { get; }
        public abstract Motion motion { get; }
        public abstract bool hasEmptyClip { get; }

        public abstract void OnEnter(float startTime, StatePlayable prevState);
        public abstract void OnUpdate(float deltaTime, float lifeTime = float.MaxValue);
        public abstract void OnExit(float lifeTime, StatePlayable nextState);
        public abstract void OnDestroy();

        public abstract void TickTime(float deltaTime);
        public abstract void SetWeight(float weight);
        public abstract void SetSpeed(float speed);

        protected StatePlayable(Vector2 position, string name, string tag) : base(position, name, tag)
        {
        }

        protected enum InternalStatusType
        {
            Exit = 0,
            PrepExit,
            Enter,
            PrepEnter,
        }
    }
}