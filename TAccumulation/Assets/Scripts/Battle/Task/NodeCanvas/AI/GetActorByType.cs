using ParadoxNotion.Design;
using NodeCanvas.Framework;

namespace X3Battle
{
    [Category("X3Battle/AI")]
    [Description("获取战斗单位")]
    public class GetActorByType : BattleAction
    {
        public BBParameter<ActorType> actorType = new BBParameter<ActorType>();
        public BBParameter<int> subType = new BBParameter<int>();
        public BBParameter<Actor> storeResult = new BBParameter<Actor>();

        protected override void OnExecute()
        {
            storeResult.value = _battle.actorMgr.GetFirstActor(actorType.value, subType.value, includeSummoner: false);
            EndAction(true);
        }
    }
}
