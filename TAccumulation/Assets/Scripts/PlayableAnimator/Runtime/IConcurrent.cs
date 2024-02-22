namespace X3.PlayableAnimator
{
    public interface IConcurrent
    {
        Motion owner{ get; set; }
        void SetWeight(float weight);
        void SetTime(double time);
        void OnEnter();
        void OnExit();
        void OnPrepExit();
        void OnPrepEnter();
        void OnDestroy();
        IConcurrent DeepCopy();
    }
}