using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("切换男女主的数值用状态\nChangeHeroNumericalState")]
    public class FAChangeHeroNumericalState : FlowAction
    {
        public BBParameter<NumericalState> numericalState = new BBParameter<NumericalState>(NumericalState.Prepare);

        protected override void _Invoke()
        {
            
        }
    }
}
