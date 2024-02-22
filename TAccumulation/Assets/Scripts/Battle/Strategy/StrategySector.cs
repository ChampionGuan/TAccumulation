namespace X3Battle
{
    public class StrategySector
    {
        public StrategyAreaType areaType;
        public int index;
        public float downAngle;
        public float upAngle;
        public int refCount;

        public bool IsMatch(StrategyAreaType areaType, int index)
        {
            return areaType == this.areaType && index == this.index;
        }
        
        public bool IsEmpty(StrategyAreaType areaType)
        {
            return areaType == this.areaType && refCount == 0;
        }

        public bool Check(StrategyAreaType areaType, float angle)
        {
            if (areaType != this.areaType)
            {
                return false;
            }
            if (angle < upAngle)
            {
                return true;
            }
            return false;
        }

        public void PlusRefCount()
        {
            refCount++;
        }
        
        public void MinusRefCount()
        {
            refCount--;
        }

        public void ClearRefCount()
        {
            refCount = 0;
        }
    }
}