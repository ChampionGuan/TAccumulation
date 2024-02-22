using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;

namespace X3Battle
{
    public class AbnormalState : BaseMainState
    {
        public override ActorMainStateType stateType => ActorMainStateType.Abnormal;

        private List<ActorMainState.AbnormalInfo> _allAbnormal = new List<ActorMainState.AbnormalInfo>(5);

        public AbnormalState(ActorMainState actorMainState) : base(actorMainState)
        {
            
        }
        
        protected override void OnUpdate()
        {
            base.OnUpdate();
            if (_actor.input == null || _actor.skillOwner == null)
            {
                return;
            }

            var sortDatas = _actor.input.sortDatas;
            if (sortDatas.Count < 0)
            {
                return;
            }

            var res = StateUtil.CommonSateUseCacheInput(_actor);
            if (res)
            {
                return;
            }

            //处理是否能被移动打断
            res = _actor.hurt.hurtInterruptController.HurtTryEndByMove();
            if (res)
            {
                LogProxy.Log("技能打断连招控制器：受击状态 被移动打断" + " frame = " + Battle.Instance.frameCount);
                return;
            }

            if (_actor.locomotion?.moveType != MoveType.Num && _actor.locomotion?.destDir != Vector3.zero)
            {
                _mainState.TryToState(ActorMainStateType.Move);
            }
        }

        protected override void OnExit(ActorMainStateType toStateType)
        {
            // 目标状态
            switch (toStateType)
            {
                // 如果是死亡或者异常态，则return
                case ActorMainStateType.Dead:
                case ActorMainStateType.Abnormal:
                    return;
                // LYDJS-47024 如果是技能
                case ActorMainStateType.Skill:
                {
                    // 结束其他添加者是buff的异常
                    _mainState.GetAllAbnormalInfo(_allAbnormal);
                    foreach (var abnormal in _allAbnormal)
                    {
                        if (abnormal.adder is X3Buff buff)
                        {
                            _mainState.actor.buffOwner.Remove(buff.ID);
                        }
                    }

                    break;
                }
            }

            var destAbnormal = _mainState.GetDestAbnormalInfo();
            if (destAbnormal != null)
            {
                LogProxy.LogFatal($"【战斗】【严重错误】角色(name={_actor.name})状态机：状态退出异常toStateName={toStateType}，fromStateType={stateType}，当前仍有未进行的异常状态 {destAbnormal}，请检查！");
            }
        }

        public void OnChangeAbnormalType(ActorAbnormalType abnormalType, object adder, bool isActive)
        {
            switch (abnormalType)
            {
                case ActorAbnormalType.None:
                    break;
                case ActorAbnormalType.Hurt:
                    if (isActive)
                    {

                    }
                    else
                    {
                        _actor.hurt?.StopHurt();
                    }
                    break;
                case ActorAbnormalType.Vertigo:
                    if (isActive)
                    {
                        _actor.stateTag.AcquireTag(ActorStateTagType.CannotEnterMove);
                    }
                    else
                    {
                        _actor.stateTag.ReleaseTag(ActorStateTagType.CannotEnterMove);
                    }

                    int[] skillTypes = null;
                    if (_actor.IsGirl())
                    {
                        skillTypes = TbUtil.battleConsts.FemaleSkillTypeBannedDuringVertigo;
                    }
                    else if (_actor.IsBoy())
                    {
                        skillTypes = TbUtil.battleConsts.MaleSkillTypeBannedDuringVertigo;
                    }
                    else
                    {
                        if (isActive)
                        {
                            _actor.stateTag.AcquireTag(ActorStateTagType.CannotCastSkill);
                        }
                        else
                        {
                            _actor.stateTag.ReleaseTag(ActorStateTagType.CannotCastSkill);
                        }
                    }

                    if (null != skillTypes)
                    {
                        _actor.DisableSkills(adder, skillTypes, isActive);
                    }
                    break;
                case ActorAbnormalType.Weak:
                    if (isActive)
                    {
                        _actor.stateTag.AcquireTag(ActorStateTagType.CannotEnterMove);
                        _actor.stateTag.AcquireTag(ActorStateTagType.CannotCastSkill);
                    }
                    else
                    {
                        _actor.stateTag.ReleaseTag(ActorStateTagType.CannotEnterMove);
                        _actor.stateTag.ReleaseTag(ActorStateTagType.CannotCastSkill);
                        _actor.actorWeak.StopWeak();
                    }
                    break;
            }
        }
    }
}