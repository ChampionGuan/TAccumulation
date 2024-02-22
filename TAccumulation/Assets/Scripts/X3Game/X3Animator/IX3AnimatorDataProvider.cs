namespace X3Game
{
    public interface IX3AnimatorDataProvider
    {
        bool OnLoadStateData(X3Animator animator, string stateName, ExternalX3AnimatorStateData data);
    }

    public class ExternalX3AnimatorStateData
    {
        public int AssetType;
        public string AssetPathOrName;
        public float TransitionDuration;
        public int WrapMode;
        public bool InheritTransform;
        public bool SetDefault;
    }
}