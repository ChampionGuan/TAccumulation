using System.Collections.Generic;
using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("添加/移除角色状态标签")]
    public class SetActorStateTag : BattleAction
    {
        public bool isAcquire = true;
        public BBParameter<List<ActorStateTagType>> stateType = new BBParameter<List<ActorStateTagType>>();

        protected override string info
        {
            get
            {
                if (stateType.isNull || stateType.isNoneOrNull)
                {
                    return "SetActorStateTag";
                }

                return (isAcquire ? "AddTag:" : "RemoveTag:") + BattleUtil.GetArrayDesc(stateType.GetValue().ToArray());
            }
        }

        protected override void OnExecute()
        {
            var stateTag = _actor?.stateTag;
            if (null == stateTag)
            {
                EndAction(false);
                return;
            }

            foreach (var stateType in stateType.GetValue())
            {
                if (isAcquire)
                {
                    stateTag.AcquireTag(stateType);
                }
                else
                {
                    stateTag.ReleaseTag(stateType);
                }
            }

            EndAction(true);
        }
    }
}
