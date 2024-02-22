using System;

namespace X3Battle
{
    public class NAShowMultiLevel: NALevelBeforeActionBase
    {
        private Action _closeAction;

        public NAShowMultiLevel()
        {
            _closeAction = _OnCloseAction;
        }
        
        protected override void OnExecute()
        {
            BattleEnv.LuaBridge.ShowMultiLevelUI(_closeAction);
        }

        private void _OnCloseAction()
        {
            EndAction(true);
            ForceTick();
        }
    }
}
