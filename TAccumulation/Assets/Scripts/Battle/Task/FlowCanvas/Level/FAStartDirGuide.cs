using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("开启方向指引\nActiveDirectionGuide")]
    public class FAStartDirGuide : FlowAction
    {
        public BBParameter<int> pointId = new BBParameter<int>();
        protected override void _Invoke()
        {
            if (pointId.isNoneOrNull)
            {
                return;
            }
            _battle.dirGuide.AddActorDirGuide(pointId.value);
        }
    }
}
