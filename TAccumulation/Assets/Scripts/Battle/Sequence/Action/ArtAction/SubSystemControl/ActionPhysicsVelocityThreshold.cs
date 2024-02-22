using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Timeline;
using X3.Character;

namespace X3Battle
{
    public class ActionPhysicsVelocityThreshold: BSAction
    {
        private string _partName;
        private float _velocityThreshold;
        private float _angularVelocityThreshold;
        
        private float _oldVelocityThreshold = 0;
        private float _oldAngularVelocityThreshold = 0;
        
        private X3PhysicsCloth _cloth;

        protected override void _OnInit()
        {
            // 获取playable绑定的clip
            var clip = GetClipAsset<PhysicsVelocityThresholdClip>();
            _partName = clip.partName;
            _velocityThreshold = clip.velocityThreshold;
            _angularVelocityThreshold = clip.angularVelocityThreshold;
            
            var bindObj = GetTrackBindObj<GameObject>();
            var character = bindObj.GetComponent<X3Character>();
            if (character != null)
            {
                _cloth = character.GetSubsystem(X3.Character.ISubsystem.Type.PhysicsCloth) as X3PhysicsCloth;
            }
        }

        protected override void _OnEnter()
        {
            if (_cloth != null)
            {
                _cloth.GetThreshold(ref _oldVelocityThreshold, ref _oldAngularVelocityThreshold, _partName);
                _cloth.SetThreshold(_velocityThreshold, _angularVelocityThreshold, _partName);
            }
        }

        protected override void _OnExit()
        {
            if (_cloth != null)
            {
                _cloth.SetThreshold(_oldVelocityThreshold, _oldAngularVelocityThreshold, _partName);
            }
        }
    }
}