using MessagePack;

namespace X3Battle
{
    [MessagePackObject]
    public class ActorBtnStateCommand : ActorCmd
    {
        [Key(0)] public PlayerBtnType btnType;

        [Key(1)] public bool isDown;

        [IgnoreMember] public override bool isBgCmd => true;

        public ActorBtnStateCommand()
        {
        }

        public void Init(PlayerBtnType _btnType, bool _isDown)
        {
            btnType = _btnType;
            isDown = _isDown;
        }

        protected override void _OnReset()
        {
            btnType = PlayerBtnType.Attack;
            isDown = false;
        }

        protected override void _OnEnter()
        {
            if (isDown)
            {
                actor.input?.RecordBtnDownTime(btnType);
            }
            else
            {
                actor.input?.RecordBtnUpTime(btnType);
            }
        }
    }
}
