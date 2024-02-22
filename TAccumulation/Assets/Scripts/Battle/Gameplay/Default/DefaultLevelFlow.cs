using System;
using FlowCanvas;
using NodeCanvas.StateMachines;

namespace X3Battle
{
    public class DefaultLevelFlow : LevelFlowBase
    {
        private NotionGraph<FlowScriptController> _flow; // 关卡中流程图.
        private NotionGraph<FSMOwner> _beforeFsmOwner; // 关卡前流程图.
        private Action _endLevelCallback;

        public Battle battle => Battle.Instance;

        public DefaultLevelFlow()
        {
            _endLevelCallback = _OnEndLevelCallback;
        }
        
        protected override void OnAwake()
        {
            
        }

        protected override void OnDestroy()
        {
            _beforeFsmOwner?.OnDestroy();
            _beforeFsmOwner = null;
            
            _flow.OnDestroy();
            _flow = null;
        }

        protected override void OnPreload()
        {
            // DONE: 创建关卡前流程但不启动.
            _beforeFsmOwner = new NotionGraph<FSMOwner>();
            _beforeFsmOwner.Init(new ActorContext(battle.actorMgr.stage), BattleConst.LevelBeforeFsmName, BattleResType.Fsm, null, false);
            _beforeFsmOwner.SetVariableValue("cameraActionModuleId", BattleConst.LevelBeforeCameraActionModuleId, true);
            
            // DONE: 创建关卡中流程但不启动.
            _flow = new NotionGraph<FlowScriptController>();
            _flow.Init(new ActorContext(battle.actorMgr.stage), $"Level/{battle.config.LogicFilename}", BattleResType.Flow, battle.root, true);
            _flow.Disable(true);
        }
        
        protected override void OnBattleBegin()
        {
            _beforeFsmOwner.TriggerFSMEvent("BattleBegin");
        }

        protected override void OnBattleEnd()
        {
            
        }

        protected override void OnStartBefore()
        {
            // DONE: 启动关卡前流程.
            _beforeFsmOwner.Restart();
            _beforeFsmOwner.Update(0f);
        }

        protected override void OnStartMid()
        {
            // DONE: 卸载关卡前流程图资源.
            _beforeFsmOwner?.OnDestroy();
            _beforeFsmOwner = null;
            
            // DONE: 启动关卡中流程图.
            _flow.Restart();
        }

        protected override void OnStartEnd()
        {
            
        }

        protected override void OnFlowEnd()
        {
            bool isWin = battle.status == BattleRunStatus.Success;
            BattleEnv.LuaBridge.ShowBattleEndUI(isWin, _endLevelCallback);
        }

        protected override void OnUpdate()
        {
            _CheckLevelEndByFail();
        }

        private void _OnEndLevelCallback()
        {
            // DONE: 停止战斗
            battle.SetWorldEnable(false, BattleEnabledMask.LevelFlow);
            
            // DONE: 启动战斗结算UI系统（关卡流彻底结束）.
            BattleEnv.LuaBridge.ShowStatisticsUI();
        }
    }
}