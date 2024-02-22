namespace X3Battle.Timeline.Extension
{
    public interface IAction
    {
        void Init(PreviewActionBehaviour behaviour);
        void Enter(PreviewActionBehaviour behaviour);
        void Update(PreviewActionBehaviour behaviour);
        void Exit(PreviewActionBehaviour behaviour);
        void Destroy(PreviewActionBehaviour behaviour);
    }
}