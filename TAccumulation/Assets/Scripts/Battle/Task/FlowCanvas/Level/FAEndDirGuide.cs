using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("关闭方向指引\nDeactiveDirectionGuide")]
    public class FAEndDirGuide : FlowAction
    {
        protected override void _Invoke()
        {
            _battle.dirGuide.RemoveActorDirGuide();
        }
    }
}
