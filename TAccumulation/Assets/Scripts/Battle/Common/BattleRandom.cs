using System;

namespace X3Battle
{
    public class BattleRandom
    {
    	// TODO 
        public static BattleRandom instance { get; set; }
        public int seed { get; private set; }
        public BattleRandom(int seed)
        {
            this.seed = seed;
        }

        public int Next()
        {
            seed = (seed * 214013 + 2531011) & 0x7FFFFFFF;
            return (seed >> 16) & 0x7FFF;
        }
        
        public virtual int Next(int minValue, int maxValue)
        {
            if (minValue > maxValue)
                throw new ArgumentOutOfRangeException(nameof (minValue), "Argument_MinMaxValue");
            long num = (long) maxValue - (long) minValue;
            return num <= (long) int.MaxValue ? (int) (NextDouble() * (double) num) + minValue : (int) ((long) (this.GetSampleForLargeRange() * (double) num) + (long) minValue);
        }
        
        public virtual int Next(int maxValue)
        {
            if (maxValue < 0)
                throw new ArgumentOutOfRangeException(nameof (maxValue), "ArgumentOutOfRange_MustBePositive");
            return (int)(GetSampleForLargeRange() * (double)maxValue);
        }
        
        public double NextDouble()
        {
            return Next() / (double)0x8000;
        }
        
        private double GetSampleForLargeRange()
        {
            int num = this.Next();
            if (this.Next() % 2 == 0)
                num = -num;
            return ((double) num + 2147483646.0) / 4294967293.0;
        }
    }
}