using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/Action")]
    [Name("TickCombatAI")]
    public class FATickCombatAI : FlowAction
    {
        protected override void _Invoke()
        {
            _actor.aiOwner?.TickCombatAI();
        }
    }
}
