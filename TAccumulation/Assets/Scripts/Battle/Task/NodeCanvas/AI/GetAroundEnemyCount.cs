using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI")]
    [Description("计算单位周围敌人数量（仇恨列表中）")]
    public class GetAroundEnemyCount: BattleAction
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<float> minDistance = new BBParameter<float>();
        public BBParameter<float> maxDistance = new BBParameter<float>();
        public BBParameter<int> storeResult = new BBParameter<int>();

        protected override void OnExecute()
        {
            if (source.isNoneOrNull)
            {
                EndAction(false);
                return;
            }

            int count = 0;
            var actor = source.value;
            var listHates = actor.actorHate.hates;
            foreach (var hateData in listHates)
            {
                if ( !hateData.lockable)
                {
                    continue;
                }
                Actor hateActor = actor.battle.actorMgr.GetActor(hateData.insId);
                float distance = BattleUtil.GetActorDistance(actor, hateActor);
                if (distance <= maxDistance.value && distance >= minDistance.value)
                {
                    count++;
                }
            }
            storeResult.value = count;
            EndAction(true);
        }
    }
}
