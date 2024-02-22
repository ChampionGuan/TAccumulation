using ParadoxNotion.Design;
using NodeCanvas.Framework;

namespace X3Battle
{
    [Category("X3Battle/AI")]
    [Description("获取自身Actor")]
    public class GetSelf : BattleAction
    {
        public BBParameter<Actor> storeResult = new BBParameter<Actor>();

        protected override void OnExecute()
        {
            storeResult.value = _actor;
            EndAction(true);
        }
    }
}
