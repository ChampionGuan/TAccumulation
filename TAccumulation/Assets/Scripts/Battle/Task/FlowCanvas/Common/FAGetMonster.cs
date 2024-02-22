using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Function")]
    [Name("获取怪物\nGetMonster")]
    public class FAGetMonster : FlowAction
    {
        [Name("SpawnID")]
        public BBParameter<int> InsID = new BBParameter<int>();
        
        protected override void _OnRegisterPorts()
        {
            AddValueOutput<Actor>("Actor", () =>
            {
                var insID = InsID.GetValue();
                var actor = Battle.Instance.actorMgr.GetActor(insID);
                if (actor == null)
                {
                    return null;
                }
                
                if (!actor.IsMonster())
                {
                    return null;
                }

                return actor;
            });
        }
    }
}
