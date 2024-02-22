using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Timeline;
using X3.Character;

namespace X3Battle
{
    public class ActionAnimDBMix: BSAction
    {
        private List<string> _partNames;
        private X3Character _character;

        protected override void _OnInit()
        {
            // 获取playable绑定的clip
            var clip = GetClipAsset<AnimDBMixClip>();
            _partNames = clip.partNames;

            var bindObj = GetTrackBindObj<GameObject>();
            if (_partNames != null && _partNames.Count > 0 && bindObj != null)
            {
                _character = bindObj.GetComponent<X3Character>();
            }
        }

        protected override void _OnEnter()
        {
            if (_character != null)
            {
                foreach (var partName in _partNames)
                {
                    _character.PhysicsClothBeginBlendAnimation(partName);
                }
            }
        }

        protected override void _OnExit()
        {
            if (_character != null)
            {
                foreach (var partName in _partNames)
                {
                    _character.PhysicsClothStopBlendAnimation(partName);
                }
            }
        }
    }
}