using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("切换战斗镜头状态\nSwitchCamState")]
    public class FASwitchBattleCameraState : FlowAction
    {
        [Name("是否进入战斗镜头状态")] public BBParameter<bool> isEnter = new BBParameter<bool>(false); 
        protected override void _Invoke()
        {
            if (isEnter.GetValue())
            {
                Battle.Instance.levelFlow.EnterLevelState();
            }
            else
            {
                Battle.Instance.levelFlow.LeaveLevelState();
            }
        }
    }
}
