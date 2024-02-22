using System;
using PapeGames.X3;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Rogue")]
    public class NAShowBattleEndUI : BattleAction
    {
        private const string Event_Success = "Success";
        private const string Event_Fail = "Fail";
        
        private Action _closeAction;

        public NAShowBattleEndUI()
        {
            _closeAction = _OnCloseAction;
        }

        protected override void OnExecute()
        {
            if (!_battle.isEnd)
            {
                LogProxy.LogError("【战斗】【Rogue】战斗尚未结束！请不要调用战斗结束UI接口！");
                EndAction(true);
                return;
            }
            
            bool isWin = _battle.status == BattleRunStatus.Success;
            BattleEnv.LuaBridge.ShowBattleEndUI(isWin, _closeAction);
        }

        private void _OnCloseAction()
        {
            bool isWin = _battle.status == BattleRunStatus.Success;
            bool isReceiveReward = isWin && !_battle.rogue.IsLastLayer();
            string eventName = isReceiveReward ? Event_Success : Event_Fail;
            _fsm?.TriggerEvent(eventName);
        } 
    }
}