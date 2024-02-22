using FlowCanvas;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Condition")]
    [Name(("判断对象阵营\nCheckActorFaction"))]
    public class FCCheckActorFaction : FlowCondition
    {
        public BBParameter<FactionType> factionType = new BBParameter<FactionType>(FactionType.Hero);
        private ValueInput<Actor> _viActor;
        protected override void _OnAddPorts()
        {
            _viActor = AddValueInput<Actor>(nameof(Actor));
        }

        protected override bool _IsMeetCondition()
        {
            var target = _viActor.GetValue();
            if (target == null)
            {
                return false;
            }
            
            if (target.factionType != factionType.GetValue())
            {
                return false;
            }

            return true;
        }
    }
}
