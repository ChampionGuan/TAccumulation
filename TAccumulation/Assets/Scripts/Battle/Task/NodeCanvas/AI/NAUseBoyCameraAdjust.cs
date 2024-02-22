using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/AI/动作")]
    [Name(("UseBoyCameraAdjust"))]
    [Description("触发男主镜头")]
    public class NAUseBoyCameraAdjust : BattleAction
    {
        public BBParameter<Actor> target = new BBParameter<Actor>();
        protected override void OnExecute()
        {
            Battle.Instance.cameraTrace.UseBoyCameraAdjust(target.value);
            EndAction(true);
        }
    }
}
