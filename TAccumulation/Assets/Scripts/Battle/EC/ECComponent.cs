namespace X3Battle
{
    public interface IECComponent : IECObject
    {
        int type { get; }
        ECEntity entity { get; set; }
        bool requiredUpdate { get; set; }
        bool requiredAnimationJobRunning { get; set; }
        bool requiredLateUpdate { get; set; }
        bool requiredPhysicalJobRunning { get; set; }
        bool requiredFixedUpdate { get; set; }
    }

    public class ECComponent : ECObject, IECComponent
    {
        public int type { get; }
        public ECEntity entity { get; set; }
        public IECComponent[] comps => entity?.comps;
        public bool requiredUpdate { get; set; } = true;
        public bool requiredAnimationJobRunning { get; set; } = false;
        public bool requiredLateUpdate { get; set; } = false;
        public bool requiredPhysicalJobRunning { get; set; } = false;
        public bool requiredFixedUpdate { get; set; } = false;

        public ECComponent(int type)
        {
            this.type = type;
        }

        public T GetComponent<T>(int type) where T : ECComponent
        {
            return entity?.GetComponent<T>(type);
        }

        public T GetComponent<T>() where T : ECComponent
        {
            return entity?.GetComponent<T>();
        }
    }
}