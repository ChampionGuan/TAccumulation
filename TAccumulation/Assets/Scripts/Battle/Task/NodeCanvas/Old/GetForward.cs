using ParadoxNotion.Design;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Old")]
    [Description("获取Actor的朝向")]
    public class GetForward : BattleAction
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<Vector3> storeResult = new BBParameter<Vector3>();

        /*
        protected override string info
        {
            get
            {
                if ((Application.isPlaying && source.isNoneOrNull) || (!source.useBlackboard || source.isNone))
                {
                    return "获取自身的朝向";
                }

                return "获取目标单位的朝向";
            }
        }
        */

        protected override void OnExecute()
        {
            storeResult.value = source.isNoneOrNull ? _actor.transform.forward : source.value.transform.forward;
            EndAction(true);
        }
    }
}
