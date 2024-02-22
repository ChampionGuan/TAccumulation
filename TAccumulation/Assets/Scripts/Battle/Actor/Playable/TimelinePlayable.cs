using UnityEngine.Playables;

namespace X3Battle
{
    public class TimelinePlayable : PlayableNode
    {
        public TimelinePlayable() : base(1, (int) ActorPlayableType.Timeline)
        {
        }

        public override Playable CreatePlayable()
        {
            throw new System.NotImplementedException();
        }
    }
}