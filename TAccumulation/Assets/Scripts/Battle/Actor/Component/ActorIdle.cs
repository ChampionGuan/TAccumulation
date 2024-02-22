using System;
using X3.PlayableAnimator;

namespace X3Battle
{
    public class ActorIdle : ActorComponent
    {
        private Action<int, StateNotifyType, string> _actionAnimStateChange;
        private bool _origState;
        //IdleState 1.battle 2.normal
        private bool? _extState;
        private bool? _animState;
        private int? _animStateSlotID;

        public ActorIdle() : base(ActorComponentType.Idle)
        {
            requiredPhysicalJobRunning = true;
            _actionAnimStateChange = _OnAnimStateChange;
        }

        public override void OnBorn()
        {
            actor.animator.onStateNotify.AddListener(_actionAnimStateChange);
            battle.onPostUpdate.Add(_PostUpdateIdleState, (int)BattlePostUpdateEventLayer.Weapon);
        }

        public override void OnRecycle()
        {
            actor.animator.onStateNotify.RemoveListener(_actionAnimStateChange);
            battle.onPostUpdate.Remove(_PostUpdateIdleState, (int)BattlePostUpdateEventLayer.Weapon);
        }

        public void _OnAnimStateChange(int layerIndex, StateNotifyType notifyType, string stateName)
        {
            if (layerIndex != AnimConst.DefaultLayer)
                return;
            if (notifyType != StateNotifyType.Enter)
                return;

            bool isSkill = actor.mainState.mainStateType == ActorMainStateType.Skill;
            if (isSkill && _animStateSlotID == actor.skillOwner.currentSlot.ID)//同一个技能内 动画切换不再切
                return;
            _animState = isSkill;
            _animStateSlotID = actor.skillOwner.currentSlot?.ID;
        }

        // 设置当前状态武器是否隐藏
        public void SetIdleState(bool? isBattleIdle, bool immediately = false)
        {
            _extState = isBattleIdle;
            if (immediately)
                _PostUpdateIdleState();
        }

        protected void _PostUpdateIdleState()
        {
            if (_extState.HasValue)
            {
                actor.locomotion.SetAnimFSMVariable(FSMVariableName.IdleState, _extState.Value);
                _extState = _animState = null;
            }
            else if (_animState.HasValue)
            {
                actor.locomotion.SetAnimFSMVariable(FSMVariableName.IdleState, _animState.Value);
                _extState = _animState = null;
            }
        }
    }
}