using MessagePack;

namespace X3Battle
{
    [MessagePackObject]
    public class ActorLockModeCommand : ActorCmd, IReset
    {
        [Key(0)] public TargetLockModeType lockModeType;

        public ActorLockModeCommand()
        {
        }

        public void Init(TargetLockModeType _lockModeType)
        {
            lockModeType = _lockModeType;
        }

        protected override void _OnEnter()
        {
            base._OnEnter();
            actor.targetSelector.SwitchMode(lockModeType);
        }

        protected override void _OnReset()
        {
            base._OnReset();
            lockModeType = TargetLockModeType.Smart;
        }
    }
}