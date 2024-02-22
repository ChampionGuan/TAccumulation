using NodeCanvas.Framework;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/通用/Action")]
    [Name("播放气泡对话\nPlayDialogBubble")]
    public class FAPlayBubble : FlowAction
    {
        [Name("InsID")]
        public BBParameter<int> actorId = new BBParameter<int>();
        public BBParameter<string> bubbleId = new BBParameter<string>();
        
        protected override void _Invoke()
        {
            _battle.dialogue.Play(bubbleId.value);
        }
    }
}
