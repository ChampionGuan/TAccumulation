using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Function")]
    [Name("获得锁定目标\nGetLockTarget")]
    public class FAGetLockTarget: FlowAction
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<Actor> storeResult = new BBParameter<Actor>();

        protected override void _Invoke()
        {
            storeResult.value = (source.isNoneOrNull ? _actor : source.value).GetTarget();
        }
    }
}
