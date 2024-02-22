using ParadoxNotion.Design;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("获取Actor的EulerAnglesY值")]
    public class SetAngleY : BattleAction
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<float> angleY = new BBParameter<float>();

        /*
        protected override string info
        {
            get
            {
                if ((Application.isPlaying && source.isNoneOrNull) || (!source.useBlackboard || source.isNone))
                {
                    return $"设置自身的欧拉角Y为{angleY.value}";
                }

                return $"设置目标对象的欧拉角Y为{angleY.value}";
            }
        }
        */

        protected override void OnExecute()
        {
            if (source.isNoneOrNull)
            {
                _actor.transform.SetEulerAnglesY(angleY.value);
            }
            else
            {
                source.value.transform.SetEulerAnglesY(angleY.value);
            }

            EndAction(true);
        }
    }
}
