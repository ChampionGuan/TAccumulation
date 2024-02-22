using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("关闭战斗指引\nCloseBattleGuide")]
    public class FACloseMissionTips : FlowAction
    {
        public BBParameter<int> id = new BBParameter<int>();

        protected override void _Invoke()
        {
            BattleUtil.SetMissionTipsVisible(ShowMissionTipsType.Close, id.value);
        }
    }
}
