using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("设置角色的异常状态")]
    public class SetActorAbnormalType : BattleAction
    {
        public BBParameter<ActorAbnormalType> abnormalType = new BBParameter<ActorAbnormalType>(ActorAbnormalType.None);
        
        public new ActorMainStateContext _context => base._context as ActorMainStateContext;
        
        protected override string info => $"设置异常表现状态:{abnormalType}";
        
        protected override void OnExecute()
        {
            _context.SetAbnormalType(abnormalType.GetValue());
            EndAction(true);
        }
    }
}