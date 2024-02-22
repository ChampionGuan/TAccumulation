using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Rogue")]
    public class NAEndLevel : BattleAction
    {
        protected override void OnExecute()
        {
            _battle.levelFlow.EndFlowFinished();
            EndAction(true);
        }
    }
}