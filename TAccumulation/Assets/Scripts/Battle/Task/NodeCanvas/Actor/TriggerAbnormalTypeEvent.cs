using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("触发异常状态的子状态事件")]
    public class TriggerAbnormalTypeEvent : BattleAction
    {
        public new ActorMainStateContext _context => base._context as ActorMainStateContext;
        
        protected override void OnExecute()
        {
            ActorAbnormalType actorAbnormalType = _context?.actor?.mainState?.GetDestAbnormalInfo()?.type ?? ActorAbnormalType.None;
            _context?.actor?.mainState?.TriggerFSMEvent(FSMEventName.AbnormalEvent[actorAbnormalType]);
            EndAction(true);
        }
    }
}
