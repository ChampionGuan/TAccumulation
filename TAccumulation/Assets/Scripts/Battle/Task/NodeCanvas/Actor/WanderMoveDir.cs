using ParadoxNotion.Design;
using NodeCanvas.Framework;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("以指定移动类型向某点所在方向移动")]
    public class WanderMoveDir : BattleAction
    {
        public BBParameter<Actor> source = new BBParameter<Actor>();
        public BBParameter<Vector3> lookAtPoint = new BBParameter<Vector3>();
        public WanderAnimType moveType;

        /*
        protected override string info => $"{_GetAnimName()}到点:{lookAtPoint.value}所在方向";
        */

        protected override void OnExecute()
        {
            var source = this.source.isNoneOrNull ? _actor : this.source.value;
            var dir = lookAtPoint.value - source.transform.position;
            var animName = _GetAnimName();
            
            //指令从池取
            var cmd = ObjectPoolUtility.GetActorCmd<ActorMoveDirCmd>();
            cmd.Init(dir, MoveType.Wander, animName);
            
            source.commander?.TryExecute(cmd);
            EndAction(true);
        }

        private string _GetAnimName()
        {
            var animName = string.Empty;
            switch (moveType)
            {
                case WanderAnimType.Forward:
                    animName = MoveWanderAnimName.Forward;
                    break;
                case WanderAnimType.Right:
                    animName = MoveWanderAnimName.Right;
                    break;
                case WanderAnimType.Back:
                    animName = MoveWanderAnimName.Back;
                    break;
                case WanderAnimType.Left:
                    animName = MoveWanderAnimName.Left;
                    break;
            }

            return animName;
        }

        public enum WanderAnimType
        {
            Forward = 0,
            Right,
            Back,
            Left
        }
    }
}
