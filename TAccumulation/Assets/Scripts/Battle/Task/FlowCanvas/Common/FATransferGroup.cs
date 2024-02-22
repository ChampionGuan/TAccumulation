using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("传送对象组\nTransmitActorGroup")]
    public class FATransferGroup : FlowAction
    {
        public BBParameter<int> actorGroupId = new BBParameter<int>();
        public BBParameter<int> pointGroupId = new BBParameter<int>();

        protected override void _Invoke()
        {
            _battle.actorMgr.TransferGroup(actorGroupId.value, pointGroupId.value);
        }
    }
}
