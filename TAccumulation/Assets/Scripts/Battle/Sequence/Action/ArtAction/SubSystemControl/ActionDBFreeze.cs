using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Timeline;
using X3.Character;

namespace X3Battle
{
    public class ActionDBFreeze: BSAction
    {
        private string _partName;
        private List<string> _boneNames;
        private X3PhysicsCloth _physicsCloth;

        protected override void _OnInit()
        {
            // 获取playable绑定的clip
            var clip = GetClipAsset<DBFreezeClip>();
            _partName = clip.partName;
            _boneNames = clip.boneNames;

            var bindObj = GetTrackBindObj<GameObject>();
            if (!string.IsNullOrEmpty(_partName) && _boneNames != null && _boneNames.Count > 0 && bindObj != null)
            {
                 var character = bindObj.GetComponent<X3Character>();
                 if (character != null)
                 {
                     _physicsCloth = character.GetSubsystem(X3.Character.ISubsystem.Type.PhysicsCloth) as X3PhysicsCloth;
                 }
            }
        }

        protected override void _OnEnter()
        {
            if (_physicsCloth != null)
            {
                foreach (var boneName in _boneNames)
                {
                    _physicsCloth.Freeze(_partName, boneName);
                }
            }
        }

        protected override void _OnExit()
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