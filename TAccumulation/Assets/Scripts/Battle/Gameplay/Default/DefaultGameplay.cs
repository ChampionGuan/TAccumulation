namespace X3Battle
{
    public class DefaultGameplay : BattleGameplayBase
    {
        public override LevelFlowBase levelFlow { get; } = new DefaultLevelFlow();
    }
}