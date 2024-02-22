using FlowCanvas;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("暂停战斗沟通\nPauseDialogue")]
    public class FAPauseDialogue : FlowAction
    {
        private ValueInput<bool> _viPaused;
        
        protected override void _OnRegisterPorts()
        {
            base._OnRegisterPorts();
            _viPaused = AddValueInput<bool>("IsStop");
        }

        protected override void _Invoke()
        {
            bool paused = _viPaused.GetValue();
            _battle.dialogue.Pause(paused);
        }
    }
}
