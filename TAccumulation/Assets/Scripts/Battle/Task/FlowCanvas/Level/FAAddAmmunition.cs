using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/关卡/Action")]
    [Name("【关卡】添加弹药\nFAAddAmmunition")]
    public class FAAddAmmunition : FlowAction
    {
        public BBParameter<int> count = new BBParameter<int>();
        
        protected override void _Invoke()
        {
            BattleEnv.LuaBridge.AddAmmunition(count.GetValue());
        }
    }
}