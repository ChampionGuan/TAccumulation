using System;
using NodeCanvas.Framework;

namespace X3Battle
{
    [Serializable]
    public class BBIsEnergyFull
    {
        public BBParameter<Actor> targetActor = new BBParameter<Actor>();
        public BBParameter<EnergyType> energyType = new BBParameter<EnergyType>(EnergyType.Ultra);

        public bool CheckEnergyFull()
        {
            var target = targetActor?.GetValue();
            if (target == null)
            {
                return false;
            }
            
            if (target.energyOwner == null)
            {
                return false;
            }

            return AttrUtil.IsEnergyFull(target, energyType.GetValue());
        }
    }
}
