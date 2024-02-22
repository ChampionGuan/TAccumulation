using System.Collections.Generic;
using X3Sequence;
namespace X3Battle
{
    public class BattleActionTrack : Track
    {
        private List<int> _tags;

        public BattleActionTrack(Sequencer sequencer, bool weakInterrupt = false, bool specialEnd = false,
            string name = "", List<int> tags = null) : base(sequencer, weakInterrupt, specialEnd, name)
        {
            this._tags = tags;
        }

        public void EnableTrack(bool enable, List<int> Tags)
        {
            if (_tags == null)
            {
                return;
            }
            
            foreach (var tag in Tags)
            {
                if (this._tags.Contains(tag))
                {
                    this.enable = enable;
                    return;
                }
            }
        }
    }
}