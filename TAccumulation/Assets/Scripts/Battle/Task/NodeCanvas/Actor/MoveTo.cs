using ParadoxNotion.Design;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("移动到目标位置或目标点")]
    public class MoveTo : BattleAction
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<Actor> target = new BBParameter<Actor>();
        public BBParameter<Vector3> moveTo = new BBParameter<Vector3>();

        /*
        protected override string info
        {
            get
            {
                if ((Application.isPlaying && target.isNoneOrNull) || (!target.useBlackboard || target.isNone))
                {
                    return $"移动到目标点{moveTo.value}";
                }

                return "移动到目标单位处";
            }
        }
        */

        protected override void OnExecute()
        {
            var actor = source.isNoneOrNull ? _actor : source.value;
            var cmd = ObjectPoolUtility.GetActorCmd<ActorMovePosCmd>();
            
            if (target.isNoneOrNull)
            {
                cmd.Init(moveTo.value, 0);
            }
            else
            {
                cmd.Init(target.value.insID);
            }
            
            actor.commander.TryExecute(cmd);
            EndAction(true);
        }
    }
}
