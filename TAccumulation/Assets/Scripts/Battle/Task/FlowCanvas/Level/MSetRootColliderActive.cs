using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("开关Collider\nEnableCollider")]
    public class MSetRootColliderActive : FlowAction
    {
        public BBParameter<bool> active = new BBParameter<bool>();
        
        protected override void _Invoke()
        {
            _actor.collider.isColliderActive = active.value;
        }
    }
}
