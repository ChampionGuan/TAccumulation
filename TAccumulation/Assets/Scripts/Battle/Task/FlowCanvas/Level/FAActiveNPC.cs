using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("激活NPC\nActiveNPC")]
    public class FAActiveNPC : FlowAction
    {
        [Name("SpawnID")]
        public BBParameter<int> InsID = new BBParameter<int>();
        public BBParameter<bool> IsActive = new BBParameter<bool>(true);

        protected override void _Invoke()
        {
            var spawnID = InsID.GetValue();
            var actor = Battle.Instance.actorMgr.GetActor(spawnID);
            if (actor == null)
            {
                _LogError($"请联系策划【五当】【激活NPC ActiveNPC】节点 SpawnID={spawnID}参数配置错误.");
                return;
            }
            actor.aiOwner?.ActiveAI(IsActive.GetValue());
        }
    }
}
