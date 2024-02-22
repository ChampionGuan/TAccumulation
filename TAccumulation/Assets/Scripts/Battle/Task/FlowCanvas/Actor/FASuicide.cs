using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor/Action")]
    [Name("自杀\nSuicide")]
    public class FASuicide : FlowAction
    {
        protected override void _Invoke()
        {
            if (_actor == null)
            {
                return;
            }
            
            // DONE: 自杀.
            _actor.Dead();
        }
    }
}
