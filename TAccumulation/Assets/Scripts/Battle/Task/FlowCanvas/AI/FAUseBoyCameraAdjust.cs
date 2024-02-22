using ParadoxNotion.Design;
using FlowCanvas;
using NodeCanvas.Framework;

namespace X3Battle
{
    [Category("X3Battle/AI/Action")]
    [Name("BoyCameraAdjust")]
    public class FAUseBoyCameraAdjust : FlowAction
    {
        public BBParameter<Actor> target = new BBParameter<Actor>();
        protected override void _Invoke()
        {
            _battle.cameraTrace.UseBoyCameraAdjust(target.value);
        }
    }
}
