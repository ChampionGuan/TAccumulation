using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("获取指定队伍内的对象总数\nFAGetInGroupTotalCount")]
    public class FAGetInGroupTotalCount : FlowAction
    {
        public BBParameter<int> GroupID = new BBParameter<int>();

        protected override void _OnRegisterPorts()
        {
            AddValueOutput("Count", () =>
            {
                int result = _battle.actorMgr.GetSpawnPointConfigCount(GroupID.value);
                return result;
            });
        }
    }
}
