using MessagePack;

namespace X3Battle
{
    [MessagePackObject]
    public class ActorEndBattleCommand : ActorCmd
    {
        [Key(0)] public bool isWin;

        public ActorEndBattleCommand(bool isWin = false)
        {
            this.isWin = isWin;
        }

        protected override void _OnEnter()
        {
            actor.battle.End(isWin, BattleEndReason.ManualQuit);
        }
    }
}