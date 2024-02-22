using System.Collections.Generic;
using PapeGames;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Timeline;
using X3.Character;

namespace X3Battle
{
    public class ActionSubSystemControl: BSAction
    {
        private X3.Character.ISubsystem.Type _type;
        private bool _enable;

        private X3.Character.ISubsystem _subSystem;
        private bool _oldEnable;
        
        private bool _usePartType;
        
        private PartType _partType;

        private List<string> _partNames = new List<string>();

        private Dictionary<string, bool> _partOldState = new Dictionary<string, bool>();

        
        protected override void _OnInit()
        {
            // 获取playable绑定的clip
            var clip = GetClipAsset<SubSystemControlClip>();
            _type = clip.type;
            _enable = clip.enable;
            _usePartType = clip.usePartType;
            _partType = clip.partType;
        }

        protected override void _OnEnter()
        {
            // 获取轨道绑定的对象
            var obj = GetTrackBindObj<GameObject>();
            if (obj != null)
            {
                var x3Character = obj.GetComponent<X3Character>();
                if (x3Character)
                {
                    _subSystem = x3Character.GetSubsystem(_type);
                    if (_subSystem != null)
                    {
                        if (_usePartType && _type == X3.Character.ISubsystem.Type.PhysicsCloth)
                        {
                            _partNames.Clear();
                            _partOldState.Clear();
                            // 物理可以用partyType
                            CharacterMgr.GetPartNamesWithPartType(obj, (int)_partType, _partNames);
                            var physics = _subSystem as X3PhysicsCloth;
                            foreach (var partName in _partNames)
                            {
                                var oldState = physics.GetSimulateState(partName);
                                _partOldState.Add(partName, oldState);
                                physics.SetSimulateState(partName, _enable);   
                            }
                        }
                        else
                        {
                            _oldEnable = _subSystem.EnabledSelf;
                            _subSystem.EnabledSelf = _enable;
                        }   
                    }
                }
            }
        }

        protected override void _OnExit()
        {
            if (_subSystem != null)
            {
                if (_usePartType && _type == X3.Character.ISubsystem.Type.PhysicsCloth)
                {
                    var physics = _subSystem as X3PhysicsCloth;
                    // 物理可以用partyType
                    foreach (var partName in _partNames)
                    {
                        physics.SetSimulateState(partName, _partOldState[partName]);    
                    }
                }
                else
                {
                    _subSystem.EnabledSelf = _oldEnable;   
                }
            }
        }
    }
}