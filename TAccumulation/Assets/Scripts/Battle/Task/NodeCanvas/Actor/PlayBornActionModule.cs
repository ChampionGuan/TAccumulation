using NodeCanvas.Framework;
using ParadoxNotion.Design;
using UnityEngine;

namespace X3Battle
{
    [Category("X3Battle/Actor")]
    [Description("判断是否可释放技能")]
    public class PlayBornActionModule : BattleAction
    {
        [Tooltip("动作模组ID")] public BBParameter<int> actionModuleID = new BBParameter<int>();

        [Tooltip("是否等待动作模组结束")] public BBParameter<bool> waitFinish = new BBParameter<bool>();

        private bool _isAddLockIgnore;

        protected override void OnExecute()
        {
            if (null != _actor && _actor.bornCfg.SkipBornActionModule)
            {
                EndAction(true);
                return;
            }
            
            _isAddLockIgnore = false;
            var moduleID = actionModuleID.GetValue();
            if (moduleID <= 0)
            {
                EndAction(true);
                return;
            }

            // bornCfg由外部判断
            bool enableCamera = _actor.bornCfg.ControlBornPerform;
            if (waitFinish.GetValue())
            {
                _AddLockIgnore();
                _actor.sequencePlayer.PlayBornFlowCanvasModule(moduleID, enableCamera, _OnActionModuleEnd);
            }
            else
            {
                _actor.sequencePlayer.PlayBornFlowCanvasModule(moduleID, enableCamera);
                EndAction(true);
            }
        }

        protected override void OnStop(bool interrupted)
        {
            base.OnStop();
            if (!interrupted)
            {
                return;
            }
            var moduleID = actionModuleID.GetValue();            
            if (moduleID <= 0)
            {
                return;
            }

            _RemoveLockIgnore();
            _actor.sequencePlayer.StopBornFlowCanvasModule(moduleID);
        }

        protected void _OnActionModuleEnd()
        {
            _RemoveLockIgnore();
            EndAction(true);
            ForceTick();
        }

        private void _AddLockIgnore()
        {
            if (!_actor.bornCfg.ControlBornPerform)
            {
                return;
            }

            if (_isAddLockIgnore)
            {
                return;
            }

            _isAddLockIgnore = true;
            _actor.stateTag.AcquireTag(ActorStateTagType.LockIgnore);
            
            if (!_actor.IsMonster())
            {
                return;
            }
            
            // DONE: 给男女主添加无敌Buff.
            Battle.Instance.actorMgr.player?.buffOwner?.Add(TbUtil.battleConsts.CharacterInvincibilityBuffID, layer: null, -1, level: 1, caster: null);
            Battle.Instance.actorMgr.boy?.buffOwner?.Add(TbUtil.battleConsts.CharacterInvincibilityBuffID, layer: null, -1, level: 1, caster: null);
        }

        private void _RemoveLockIgnore()
        {
            if (!_isAddLockIgnore)
            {
                return;
            }

            _isAddLockIgnore = false;
            _actor.stateTag.ReleaseTag(ActorStateTagType.LockIgnore);
            
            if (!_actor.IsMonster())
            {
                return;
            }
            
            // DONE: 移除男女主无敌Buff.
            Battle.Instance.actorMgr.player?.buffOwner?.Remove(TbUtil.battleConsts.CharacterInvincibilityBuffID);
            Battle.Instance.actorMgr.boy?.buffOwner?.Remove(TbUtil.battleConsts.CharacterInvincibilityBuffID);
        }
    }
}
