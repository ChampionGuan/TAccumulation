using ParadoxNotion.Design;
using NodeCanvas.Framework;

namespace X3Battle
{
    [Category("X3Battle/AI")]
    [Description("获取角色半径")]
    public class GetRadius : BattleAction
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<float> storeResult = new BBParameter<float>();

        protected override void OnExecute()
        {
            storeResult.value = source.isNoneOrNull ? _actor.radius : source.value.radius;
            EndAction(true);
        }
    }
}
