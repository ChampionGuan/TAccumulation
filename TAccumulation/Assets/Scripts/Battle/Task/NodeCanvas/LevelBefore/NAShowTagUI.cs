using System;

namespace X3Battle
{
    public class NAShowTagUI: NALevelBeforeActionBase
    {
        private Action _closeAction;
        
        public NAShowTagUI()
        {
            _closeAction = _OnCloseAction;
        }
        
        protected override void OnExecute()
        {
            if (!_battle.arg.isShowTips)
            {
                EndAction(true);
                return;
            }

            BattleEnv.LuaBridge.ShowTagTaskUI(_closeAction);
        }

        void _OnCloseAction()
        {
            EndAction(true);
            ForceTick();
        }
    }
}
