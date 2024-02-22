using Framework;
using System.Collections.Generic;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using X3.Character;

namespace UnityEngine.Timeline
{
    public class DBFreezePlayable : InterruptBehaviour
    {
        private string _partName;
        private List<string> _boneNames;
        private X3PhysicsCloth _physicsCloth;

        public void SetData(string partName, List<string> boneNames)
        {
            _partName = partName;
            _boneNames = boneNames;
        }


        protected override void OnStart(Playable playable, FrameData info, object playerData)
        {
            if (!string.IsNullOrEmpty(_partName) && _boneNames != null && _boneNames.Count > 0 && playerData != null && playerData is GameObject actor)
            {
                var character = actor.GetComponent<X3Character>();
                if (character != null)
                {
                    _physicsCloth = character.GetSubsystem(X3.Character.ISubsystem.Type.PhysicsCloth) as X3PhysicsCloth;
                }
            }

            if (_physicsCloth != null)
            {
                foreach (var boneName in _boneNames)
                {
                    _physicsCloth.Freeze(_partName, boneName);
                }
            }
        }

        protected override void OnStop()
        {
            if (_physicsCloth != null)
            {
                foreach (var boneName in _boneNames)
                {
                    _physicsCloth.UnFreeze(_partName, boneName);
                }
            }
        }
    }
}