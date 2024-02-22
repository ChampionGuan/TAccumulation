using System;
using System.Collections.Generic;

namespace X3Battle
{
    /// <summary>
    /// 角色状态矩阵
    /// https://papergames.feishu.cn/wiki/SW0jwjqL9iXwVakXk6gcnwyUnqc
    /// </summary>
    public static class ActorStateMatrix
    {
        /// <summary>
        /// 结果
        /// </summary>
        public enum Result
        {
            Succeed,
            Failure,
            SucceedAndMutex
        }

        /// <summary>
        /// 状态切换的数据，由外部传入
        /// </summary>
        public interface IArg
        {
        }

        /// <summary>
        /// 到技能状态所需的数据
        /// </summary>
        public class ToSkillStateArg : IArg
        {
            public int targetSlotID;
            public bool reportError;
            public bool notCheckPriority;
            public PlayerBtnStateType? btnStateType;
        }

        /// <summary>
        /// 到移动状态所需的数据
        /// </summary>
        public class ToMoveStateArg : IArg
        {
            public bool checkMoveDir;
        }

        /// <summary>
        /// 状态切换的数据，由内部构造
        /// </summary>
        private struct ToStateInfo
        {
            public Actor actor { get; internal set; }
            public IArg arg { get; internal set; }
        }

        /// <summary>
        /// 返回失败
        /// </summary>
        private static Func<ToStateInfo, Result> _Failure = info => Result.Failure;

        /// <summary>
        /// 返回成功
        /// </summary>
        private static Func<ToStateInfo, Result> _Succeed = info => Result.Succeed;

        /// <summary>
        /// 返回成功但互斥
        /// </summary>
        private static Func<ToStateInfo, Result> _SucceedAndMutex = info => Result.SucceedAndMutex;

        /// <summary>
        /// 是否能进入Idle态
        /// </summary>
        private static Func<ToStateInfo, Result> _CanEnterIdle = info =>
        {
            var actor = info.actor;
            if (null != actor.mainState.GetDestAbnormalInfo())
            {
                return Result.Failure;
            }

            if (null != actor.frozen && actor.frozen.isFrozen)
            {
                return Result.Failure;
            }

            return Result.Succeed;
        };

        /// <summary>
        /// 是否能进入移动态
        /// </summary>
        private static Func<ToStateInfo, Result> _CanEnterMove = info =>
        {
            var result = true;
            var actor = info.actor;

            // 不能进入移动标签检测
            if (null != actor.stateTag && actor.stateTag.IsActive(ActorStateTagType.CannotEnterMove))
            {
                result = false;
            }

            // 技能可被打断检测
            if (result && actor.mainState.mainStateType == ActorMainStateType.Skill && null != actor.skillOwner)
            {
                result = actor.skillOwner.SkillCanMove();
            }

            // 受击可被打断检测
            if (result && actor.mainState.abnormalType == ActorAbnormalType.Hurt && null != actor.hurt?.hurtInterruptController && !actor.hurt.hurtInterruptController.hurtInterruptByMove)
            {
                result = false;
            }

            // 有移动方向检测
            if (result && (null == info.arg || info.arg is ToMoveStateArg extraArg && extraArg.checkMoveDir) && null != actor.locomotion)
            {
                result = actor.locomotion.HasDestDir;
            }

            return result ? Result.Succeed : Result.Failure;
        };

        /// <summary>
        /// 是否能进入技能态
        /// </summary>
        private static Func<ToStateInfo, Result> _CanEnterSkill = info =>
        {
            var result = true;
            var actor = info.actor;

            // 技能释放检测
            if (info.arg is ToSkillStateArg extraArg)
            {
                result = actor.skillOwner.CanCastSkillBySlot(extraArg.targetSlotID, extraArg.reportError, extraArg.notCheckPriority, extraArg.btnStateType);
            }
            // 不能释放技能标签检测
            else if (null != actor.stateTag && actor.stateTag.IsActive(ActorStateTagType.CannotCastSkill))
            {
                result = false;
            }

            return result ? Result.Succeed : Result.Failure;
        };

        /// <summary>
        /// 是否能进入受击异常态
        /// </summary>
        private static Func<ToStateInfo, Result> _CanEnterHurt = info =>
        {
            var actor = info.actor;
            if (null != actor.frozen && actor.frozen.isFrozen)
            {
                return Result.Failure;
            }

            if (actor.mainState.HasAbnormalType(ActorAbnormalType.Weak))
            {
                return Result.Failure;
            }

            if (actor.mainState.HasAbnormalType(ActorAbnormalType.Hurt))
            {
                return Result.Failure;
            }

            return Result.Succeed;
        };

        /// <summary>
        /// 主状态冲突矩阵
        /// </summary>
        private static readonly Dictionary<ActorMainStateType, Dictionary<ActorMainStateType, Func<ToStateInfo, Result>>> _MainStateMatrix = new Dictionary<ActorMainStateType, Dictionary<ActorMainStateType, Func<ToStateInfo, Result>>>
        {
            {
                ActorMainStateType.Born, new Dictionary<ActorMainStateType, Func<ToStateInfo, Result>>
                {
                    { ActorMainStateType.Born, _Failure },
                    { ActorMainStateType.Idle, _Succeed },
                    { ActorMainStateType.Move, _CanEnterMove },
                    { ActorMainStateType.Skill, _CanEnterSkill },
                    { ActorMainStateType.Abnormal, _Succeed },
                    { ActorMainStateType.Dead, _Succeed },
                    { ActorMainStateType.Num, _Failure },
                }
            },
            {
                ActorMainStateType.Idle, new Dictionary<ActorMainStateType, Func<ToStateInfo, Result>>
                {
                    { ActorMainStateType.Born, _Failure },
                    { ActorMainStateType.Idle, _Succeed },
                    { ActorMainStateType.Move, _CanEnterMove },
                    { ActorMainStateType.Skill, _CanEnterSkill },
                    { ActorMainStateType.Abnormal, _Succeed },
                    { ActorMainStateType.Dead, _Succeed },
                    { ActorMainStateType.Num, _Failure },
                }
            },
            {
                ActorMainStateType.Move, new Dictionary<ActorMainStateType, Func<ToStateInfo, Result>>
                {
                    { ActorMainStateType.Born, _Failure },
                    { ActorMainStateType.Idle, _Succeed },
                    { ActorMainStateType.Move, _Succeed },
                    { ActorMainStateType.Skill, _CanEnterSkill },
                    { ActorMainStateType.Abnormal, _Succeed },
                    { ActorMainStateType.Dead, _Succeed },
                    { ActorMainStateType.Num, _Failure },
                }
            },
            {
                ActorMainStateType.Skill, new Dictionary<ActorMainStateType, Func<ToStateInfo, Result>>
                {
                    { ActorMainStateType.Born, _Failure },
                    { ActorMainStateType.Idle, _Succeed },
                    { ActorMainStateType.Move, _CanEnterMove },
                    { ActorMainStateType.Skill, _CanEnterSkill },
                    { ActorMainStateType.Abnormal, _Succeed },
                    { ActorMainStateType.Dead, _Succeed },
                    { ActorMainStateType.Num, _Failure },
                }
            },
            {
                ActorMainStateType.Abnormal, new Dictionary<ActorMainStateType, Func<ToStateInfo, Result>>
                {
                    { ActorMainStateType.Born, _Failure },
                    { ActorMainStateType.Idle, _CanEnterIdle },
                    { ActorMainStateType.Move, _CanEnterMove },
                    { ActorMainStateType.Skill, _CanEnterSkill },
                    { ActorMainStateType.Abnormal, _Succeed },
                    { ActorMainStateType.Dead, _Succeed },
                    { ActorMainStateType.Num, _Failure },
                }
            },
            {
                ActorMainStateType.Dead, new Dictionary<ActorMainStateType, Func<ToStateInfo, Result>>
                {
                    { ActorMainStateType.Born, _Failure },
                    { ActorMainStateType.Idle, _Failure },
                    { ActorMainStateType.Move, _Failure },
                    { ActorMainStateType.Skill, _Failure },
                    { ActorMainStateType.Abnormal, _Failure },
                    { ActorMainStateType.Dead, _Failure },
                    { ActorMainStateType.Num, _Succeed },
                }
            },
            {
                ActorMainStateType.Num, new Dictionary<ActorMainStateType, Func<ToStateInfo, Result>>
                {
                    { ActorMainStateType.Born, _Succeed },
                    { ActorMainStateType.Idle, _Failure },
                    { ActorMainStateType.Move, _Failure },
                    { ActorMainStateType.Skill, _Failure },
                    { ActorMainStateType.Abnormal, _Failure },
                    { ActorMainStateType.Dead, _Failure },
                    { ActorMainStateType.Num, _Failure },
                }
            },
        };

        /// <summary>
        /// 异常子态冲突矩阵
        /// </summary>
        private static readonly Dictionary<ActorAbnormalType, Dictionary<ActorAbnormalType, Func<ToStateInfo, Result>>> _AbnormalStateMatrix = new Dictionary<ActorAbnormalType, Dictionary<ActorAbnormalType, Func<ToStateInfo, Result>>>
        {
            {
                ActorAbnormalType.None, new Dictionary<ActorAbnormalType, Func<ToStateInfo, Result>>
                {
                    { ActorAbnormalType.None, _Failure },
                    { ActorAbnormalType.Hurt, _CanEnterHurt },
                    { ActorAbnormalType.Vertigo, _Succeed },
                    { ActorAbnormalType.Weak, _Succeed },
                }
            },
            {
                ActorAbnormalType.Hurt, new Dictionary<ActorAbnormalType, Func<ToStateInfo, Result>>
                {
                    { ActorAbnormalType.None, _Failure },
                    { ActorAbnormalType.Hurt, _CanEnterHurt },
                    { ActorAbnormalType.Vertigo, _Succeed },
                    { ActorAbnormalType.Weak, _SucceedAndMutex },
                }
            },
            {
                ActorAbnormalType.Vertigo, new Dictionary<ActorAbnormalType, Func<ToStateInfo, Result>>
                {
                    { ActorAbnormalType.None, _Failure },
                    { ActorAbnormalType.Hurt, _CanEnterHurt },
                    { ActorAbnormalType.Vertigo, _Succeed },
                    { ActorAbnormalType.Weak, _Succeed },
                }
            },
            {
                ActorAbnormalType.Weak, new Dictionary<ActorAbnormalType, Func<ToStateInfo, Result>>
                {
                    { ActorAbnormalType.None, _Failure },
                    { ActorAbnormalType.Hurt, _CanEnterHurt },
                    { ActorAbnormalType.Vertigo, _Succeed },
                    { ActorAbnormalType.Weak, _Succeed },
                }
            },
        };

        public static bool CanToState(Actor actor, ActorMainStateType toState, IArg arg = null)
        {
            using (ProfilerDefine.ActorToMainStateMatrix.Auto())
            {
                if (null == actor?.mainState)
                {
                    return true;
                }

                var info = new ToStateInfo
                {
                    actor = actor,
                    arg = arg
                };
                var result = _MainStateMatrix[actor.mainState.mainStateType][toState](info) == Result.Succeed;
                return result;
            }
        }

        public static Result CanToAbnormal(Actor actor, ActorAbnormalType toState, IArg arg = null)
        {
            using (ProfilerDefine.ActorToAbnormalStateMatrix.Auto())
            {
                if (null == actor?.mainState)
                {
                    return Result.Succeed;
                }

                if (actor.mainState.mainStateType != ActorMainStateType.Abnormal && !CanToState(actor, ActorMainStateType.Abnormal, arg))
                {
                    return Result.Failure;
                }

                var info = new ToStateInfo
                {
                    actor = actor,
                    arg = arg
                };
                var result = _AbnormalStateMatrix[actor.mainState.abnormalType][toState](info);
                return result;
            }
        }
    }
}