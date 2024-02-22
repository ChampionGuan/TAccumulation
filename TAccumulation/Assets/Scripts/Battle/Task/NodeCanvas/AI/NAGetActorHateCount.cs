using System.Collections.Generic;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/Action")]
    [Name("GetActorHateCount(AI专用)")]
    public class NAGetActorHateCount : BattleAction
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<bool> lockable = true;
        public BBParameter<bool> cameraEnable = false;
        public BBParameter<int> storedCount = 0;
        protected override void OnExecute()
        {
            if (source.isNoneOrNull)
            {
                EndAction(false);
                return;
            }

            Actor actor = source.value;
            if (actor.actorHate == null)
            {
                EndAction(false);
                return;
            }
            int count = 0;
            List<HateDataBase> hates = actor.actorHate.hates;
            foreach (HateDataBase hate in hates)
            {
                if (lockable.value && !hate.lockable)
                {
                    continue;
                }
                Actor hateActor = actor.battle.actorMgr.GetActor(hate.insId);
                if (hateActor.actorHate == null || hateActor.actorHate.hateTarget != actor)
                {
                    continue;
                }
                if (cameraEnable.value && !hateActor.battle.cameraTrace.IsInSight(hateActor))
                {
                    continue;
                }

                count++;
            }
            storedCount.value = count;
            EndAction(true);
        }
    }
}
