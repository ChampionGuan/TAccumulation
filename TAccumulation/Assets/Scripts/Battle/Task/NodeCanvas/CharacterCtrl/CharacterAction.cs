using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("Locomotion")]
    [Description("基类")]
    public class CharacterAction : BattleAction
    {
        protected new ActorCharacterContext _context => blackboard.GetVariable(BattleConst.ContextVariableName).value as ActorCharacterContext;
    }
}
