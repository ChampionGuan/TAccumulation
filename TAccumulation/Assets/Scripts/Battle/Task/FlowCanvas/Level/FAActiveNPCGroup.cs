using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("激活NPCGroup\nActiveNPCGroup")]
    public class FAActiveNPCGroup : FlowAction
    {
        public BBParameter<int> GroupID = new BBParameter<int>();
        public BBParameter<bool> IsActive = new BBParameter<bool>(true);

        protected override void _Invoke()
        {
            var groupID = GroupID.GetValue();
            var actorGroup = Battle.Instance.actorMgr.GetActorGroup(groupID);
            for (int i = 0; i < actorGroup.actorIds.Count; i++)
            {
                var actorId = actorGroup.actorIds[i];
                var actor = Battle.Instance.actorMgr.GetActor(actorId);
                if (actor == null)
                {
                    continue;
                }
                actor.aiOwner?.ActiveAI(IsActive.GetValue());
            }
        }
    }
}
