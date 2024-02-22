using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("设置角色主状态的锁")]
    public class SetActorMainStateLock : BattleAction
    {
        [Name("上锁时用的Key")]
        public BBParameter<ActorMainStateType> State = new BBParameter<ActorMainStateType>();

        [Name("是否上锁")]
        public BBParameter<bool> Lock = new BBParameter<bool>(false);
        
        public new ActorMainStateContext _context => base._context as ActorMainStateContext;

        protected override string info => (Lock.value ? "上锁" : "解锁") + $"({State.value})";


        protected override void OnExecute()
        {
            _context.SetLock(State.GetValue(), Lock.GetValue());
            EndAction(true);
        }
    }
}
