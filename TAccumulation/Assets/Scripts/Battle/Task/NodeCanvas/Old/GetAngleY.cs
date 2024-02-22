using ParadoxNotion.Design;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Old")]
    [Description("获取Actor的EulerAnglesY值")]
    public class GetAngleY : BattleAction
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<float> storeResult = new BBParameter<float>();

        /*
        protected override string info
        {
            get
            {
                if ((Application.isPlaying && source.isNoneOrNull) || (!source.useBlackboard || source.isNone))
                {
                    return "获取自身的欧拉角Y值";
                }

                return "获取目标单位的欧拉角Y值";
            }
        }
        */

        protected override void OnExecute()
        {
            storeResult.value = source.isNoneOrNull ? _actor.transform.eulerAngles.y : source.value.transform.eulerAngles.y;
            EndAction(true);
        }
    }
}
