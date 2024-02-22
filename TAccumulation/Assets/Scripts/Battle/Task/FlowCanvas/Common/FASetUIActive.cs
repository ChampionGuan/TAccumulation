using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("显隐UI\nShowUI")]
    public class FASetUIActive : FlowAction
    {
        public BBParameter<bool> active = new BBParameter<bool>();

        protected override void _Invoke()
        {
            BattleUtil.SetUIActive(active.value);
        }
    }
}
