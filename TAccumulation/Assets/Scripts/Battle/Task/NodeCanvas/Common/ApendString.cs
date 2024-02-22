using NodeCanvas.Framework;
using PapeGames.X3;
using ParadoxNotion.Design;
using X3Battle;

namespace NodeCanvas.Tasks.Actions
{
    [Name("String Apend")]
    [Category("✫ Blackboard")]
    public class ApendString : ActionTask
    {
        [BlackboardOnly]
        public BBParameter<string> result = new BBParameter<string>();
        [BlackboardOnly]
        public BBParameter<string> a = new BBParameter<string>();
        public BBParameter<string> b = new BBParameter<string>();

        protected override string info
        {
            get { return string.Format("{0} = {1} + {2}", result, a, b); }
        }

        protected override void OnExecute()
        {
            EndAction();
            if (a.isNull || b.isNull)
            {
                LogProxy.LogError("拼接字符串为空");
                result = default;
                return;
            }

            using (zstring.Block())
            {
                zstring str = (zstring)a.value + b.value;
                result.value = str.Intern();
            }
        }
    }
}
