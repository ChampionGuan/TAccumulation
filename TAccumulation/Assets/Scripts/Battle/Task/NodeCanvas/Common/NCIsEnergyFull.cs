using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Condition")]
    [Name(("IsEnergyFull"))]
    [Description("判断Actor能量是否充满")]
    public class NCIsEnergyFull : BattleCondition
    {
        public BBIsEnergyFull isEnergyFull = new BBIsEnergyFull();
        
        protected override bool OnCheck()
        {
            return isEnergyFull.CheckEnergyFull();
        } 
    }
}
