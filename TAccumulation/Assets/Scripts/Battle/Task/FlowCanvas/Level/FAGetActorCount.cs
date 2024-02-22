using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("获取场上某个单位的数量\nGetActorCount")]
    public class FAGetActorCount : FlowAction
    {
        public BBParameter<int> ActorConfigID = new BBParameter<int>();

        protected override void _OnRegisterPorts()
        {
            AddValueOutput<int>("int", () =>
            {
                return Battle.Instance.actorMgr.GetActors(cfgId: ActorConfigID.GetValue(), includeSummoner:false);
            });
        }
    }
}
