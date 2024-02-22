using UnityEngine.Playables;
using X3.Character;

namespace UnityEngine.Timeline
{
    public class PhysicsVelocityThresholdPlayable : InterruptBehaviour
    {
        private string _partName;
        private float _velocityThreshold;
        private float _angularVelocityThreshold;
        
        private float _oldVelocityThreshold = 0;
        private float _oldAngularVelocityThreshold = 0;
        
        private X3PhysicsCloth _cloth;

        public void SetData(string partName, float velocityThreshold, float angularVelocityThreshold)
        {
            _partName = partName;
            _velocityThreshold = velocityThreshold;
            _angularVelocityThreshold = angularVelocityThreshold;
        }


        protected override void OnStart(Playable playable, FrameData info, object playerData)
        {
            if (!string.IsNullOrEmpty(_partName) && playerData != null && playerData is GameObject actor)
            {
                var character = actor.GetComponent<X3Character>();
                if (character != null)
                {
                    _cloth = character.GetSubsystem(X3.Character.ISubsystem.Type.PhysicsCloth) as X3PhysicsCloth;
                }
            }

            if (_cloth != null)
            {
                _cloth.GetThreshold(ref _oldVelocityThreshold, ref _oldAngularVelocityThreshold, _partName);
                _cloth.SetThreshold(_velocityThreshold, _angularVelocityThreshold, _partName);
            }
        }

        protected override void OnStop()
        {
            if (_cloth != null)
            {
                _cloth.SetThreshold(_oldVelocityThreshold, _oldAngularVelocityThreshold, _partName);
            }
        }
    }
}