using ParadoxNotion.Design;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/AI")]
    [Description("获取锁定目标")]
    public class GetLockTarget : BattleAction
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<Actor> storeResult = new BBParameter<Actor>();

        protected override void OnExecute()
        {
            storeResult.value = (source.isNoneOrNull ? _actor : source.value).GetTarget();
            EndAction(true);
        }
    }
}
