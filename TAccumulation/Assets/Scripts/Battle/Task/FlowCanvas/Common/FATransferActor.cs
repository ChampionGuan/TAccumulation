using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("传送对象\nTransmitActor")]
    public class FATransferActor : FlowAction
    {
        [Name("SpawnID")]
        public BBParameter<int> actorId = new BBParameter<int>();
        public BBParameter<int> pointId = new BBParameter<int>();
        
        protected override void _Invoke()
        {
            _battle.actorMgr.TransferActor(actorId.value, pointId.value);
        }
    }
}
