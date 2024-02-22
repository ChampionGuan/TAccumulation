#if UNITY_EDITOR

using UnityEngine;

namespace X3Battle
{
    public class ActorMono : MonoBehaviour
    {
        public Actor actor { get; private set; }

        public void TryInit(Actor actor)
        {
            this.actor = actor;
        }

        public void TryUninit()
        {
            this.actor = null;
        }
    }
}

#endif