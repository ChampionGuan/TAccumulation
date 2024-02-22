using NodeCanvas.Framework;
using ParadoxNotion;
using ParadoxNotion.Design;

namespace X3Battle
{
    [Category("X3Battle/Action")]
    [Description("WaitFrame")]
    public class WaitFrame : ActionTask
    {
        public uint waitFrame = 1;
        public CompactStatus finishStatus = CompactStatus.Success;

        private int _shouldWaitFrame;
        protected override string info => $"Wait {waitFrame} frame.";


        protected override void OnExecute()
        {
            _shouldWaitFrame = (int)waitFrame;
        }

        protected override void OnUpdate()
        {
            if (_shouldWaitFrame <= 0)
            {
                EndAction(finishStatus == CompactStatus.Success);
            }

            --_shouldWaitFrame;
        }
    }
}
