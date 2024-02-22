using ParadoxNotion.Design;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/AI")]
    [Description("获取目标")]
    public class GetTarget : BattleAction
    {
        [Tooltip("如果此值为空，则取自身")] public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<TargetType> targetType = new BBParameter<TargetType>();
        public BBParameter<Actor> storeResult = new BBParameter<Actor>();

        protected override void OnExecute()
        {
            storeResult.value = null == source || source.isNoneOrNull ? _actor.GetTarget(targetType.value) : source.value.GetTarget(targetType.value);
            EndAction(true);
        }
    }
}
