using FlowCanvas;
using NodeCanvas.Framework;
using NodeCanvas.StateMachines;

namespace X3Battle
{
    public class RogueLevelFlow : LevelFlowBase
    {
        public const string RogueBeforeFsmVariable = "RogueBeforeFSM";
        public const string RogueLevelFlowVariable = "RogueLevelFlow";
        public const string RogueEndFSM = "RogueEndFSM";
        private const string BattleBegin = "BattleBegin";
        private const string BeforeFinish = "BeforeFinish";
        private const string FlowFinish = "FlowFinish";

        private enum FsmType
        {
            Main,
            SubBefore,
            SubEnd,
        }
        
        private NotionGraph<FSMOwner> _fsmOwner;
        private NotionGraph<FlowScriptController> _flow;
        private Variable<FSM> _beforeFsmVariable;
        private Variable<FlowScript> _levelFlowVariable;
        private Variable<FSM> _endFsmVariable;

        protected override void OnAwake()
        {
            
        }

        protected override void OnDestroy()
        {
            _beforeFsmVariable = null;
            _levelFlowVariable = null;
            _endFsmVariable = null;
            
            _flow.OnDestroy();
            _flow = null;
            
            _fsmOwner.OnDestroy();
            _fsmOwner = null;
        }
        
        protected override void OnPreload()
        {
            // DONE: 创建Rogue流程框架图但不启动.
            _fsmOwner = new NotionGraph<FSMOwner>();
            _fsmOwner.Init(new ActorContext(battle.actorMgr.stage), BattleConst.RogueFsmName, BattleResType.Fsm, battle.root, false);
            _fsmOwner.SetVariableValue("cameraActionModuleId", BattleConst.LevelBeforeCameraActionModuleId);
            
            _beforeFsmVariable = _fsmOwner.GetVariable<FSM>(RogueBeforeFsmVariable);
            _levelFlowVariable = _fsmOwner.GetVariable<FlowScript>(RogueLevelFlowVariable);
            _endFsmVariable = _fsmOwner.GetVariable<FSM>(RogueEndFSM);

            // DONE: 创建关卡中流程但不启动.
            _flow = new NotionGraph<FlowScriptController>();
            _flow.Init(new ActorContext(battle.actorMgr.stage), $"Level/{battle.config.LogicFilename}", BattleResType.Flow, null, true);
            _flow.Disable(true);
            
            // DONE: 组装关卡中流程.
            _levelFlowVariable.SetValue(_flow.graph as FlowScript);
        }

        protected override void OnBattleBegin()
        {
            _TriggerFSMEvent(BattleBegin, FsmType.SubBefore);
        }

        protected override void OnBattleEnd()
        {
            
        }

        protected override void OnStartBefore()
        {
            _fsmOwner.Restart();
            _fsmOwner.Update(0f);
        }

        protected override void OnStartMid()
        {
            // DONE: 如果当前层已经游玩到结束阶段了, 则直接判定胜利。
            if (battle.rogue.arg.CurrentLayerData.StageStep == RogueStageStep.End)
            {
                battle.End(true);
                return;
            }

            _TriggerFSMEvent(BeforeFinish, FsmType.Main);
        }

        protected override void OnStartEnd()
        {
            _TriggerFSMEvent(FlowFinish, FsmType.Main);
            _fsmOwner.Update(0f);
        }

        protected override void OnFlowEnd()
        {
            // DONE: 停止战斗
            battle.SetWorldEnable(false, BattleEnabledMask.LevelFlow);
            
            // DONE: 启动战斗结算UI系统（关卡流彻底结束）.
            BattleEnv.LuaBridge.ShowStatisticsUI();
        }

        private void _TriggerFSMEvent(string eventName, FsmType fsmType)
        {
            switch (fsmType)
            {
                case FsmType.Main:
                    _fsmOwner.TriggerFSMEvent(eventName);
                    break;
                case FsmType.SubBefore:
                    _beforeFsmVariable.GetValue().TriggerEvent(eventName);
                    break;
                case FsmType.SubEnd:
                    _endFsmVariable.GetValue().TriggerEvent(eventName);
                    break;
            }
        }
    }
}