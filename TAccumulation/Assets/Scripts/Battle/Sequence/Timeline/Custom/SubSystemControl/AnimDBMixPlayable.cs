using Framework;
using System.Collections.Generic;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using X3.Character;

namespace UnityEngine.Timeline
{
    public class AnimDBMixPlayable : InterruptBehaviour
    {
        private List<string> _partNames;
        private X3Character _character;

        public void SetData(List<string> partNames)
        {
            _partNames = partNames;
        }


        protected override void OnStart(Playable playable, FrameData info, object playerData)
        {
            if (_partNames != null && _partNames.Count > 0 && playerData != null && playerData is GameObject actor)
            {
                _character = actor.GetComponent<X3Character>();
            }

            if (_character != null)
            {
                foreach (var partName in _partNames)
                {
                    _character.PhysicsClothBeginBlendAnimation(partName);
                }
            }
        }

        protected override void OnStop()
        {
            if (_character != null)
            {
                foreach (var partName in _partNames)
                {
                    _character.PhysicsClothStopBlendAnimation(partName);
                }
            }
        }

        protected override void OnProcessFrame(Playable playable, FrameData info, object playerData)
        {
#if UNITY_EDITOR
            PhysicsManager.BlendAnimation = true;
#endif
        }
    }
}