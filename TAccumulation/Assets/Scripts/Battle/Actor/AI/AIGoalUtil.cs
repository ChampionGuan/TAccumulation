using System;

namespace X3Battle
{
    public class AIGoalUtil
    {
        private static Type TypeWaitCurrActionCondition = typeof(AIWaitCurrActionFinishConditionGoal);
        private static ActorStateMatrix.ToMoveStateArg ToMoveStateArg = new ActorStateMatrix.ToMoveStateArg { checkMoveDir = false };

        /// <summary>
        /// 是否能进入移动状态
        /// </summary>
        public static bool CanEnterMove(Actor actor)
        {
            using (ProfilerDefine.AICanEnterMovePMarker.Auto())
            {
                if (!actor.mainState.CanToState(ActorMainStateType.Move, ToMoveStateArg))
                {
                    return false;
                }
            }

            using (ProfilerDefine.AICanMoveInterruptPMarker.Auto())
            {
                if (null != actor.locomotion && !actor.locomotion.CanMoveInterrupt())
                {
                    return false;
                }
            }

            return true;
        }

        /// <summary>
        /// 是否有等待当前行为的AI条件
        /// </summary>
        /// <param name="action"></param>
        /// <param name="phaseType"></param>
        /// <returns></returns>
        public static bool HasWaitCurrActionCondition(IAIActionGoal action, AIConditionPhaseType phaseType)
        {
            using (ProfilerDefine.AIHasWaitCurrActionPMarker.Auto())
            {
                bool ret = null != action && action.HasCondition(phaseType, TypeWaitCurrActionCondition);
                return ret;
            }
        }

        /// <summary>
        /// 角色死亡或不可锁定
        /// </summary>
        /// <param name="actor"></param>
        /// <returns></returns>
        public static bool ActorIsDeadOrLockIgnore(Actor actor)
        {
            using (ProfilerDefine.AIActorIsDeadOrLockIgnore.Auto())
            {
                //note：角色为空，返回false
                if (null == actor)
                {
                    return false;
                }

                if (actor.isDead)
                {
                    return true;
                }

                bool ret = null != actor.stateTag && actor.stateTag.IsActive(ActorStateTagType.LockIgnore);
                return ret;
            }
        }

        /// <summary>
        /// 取移动动画
        /// </summary>
        /// <param name="moveType"></param>
        /// <returns></returns>
        public static string GetMoveAnimName(AIMoveType moveType)
        {
            switch (moveType)
            {
                case AIMoveType.Run:
                    return MoveRunAnimName.Run;
                case AIMoveType.Walk:
                    return MoveRunAnimName.Walk;
                default:
                    return null;
            }
        }
    }
}