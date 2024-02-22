using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine.Playables;
using X3.Character;
using X3Battle;

namespace UnityEngine.Timeline
{
    public class SubSystemControlPlayable : InterruptBehaviour
    {
        private X3.Character.ISubsystem.Type _type;
        private bool _enable;

        private X3.Character.ISubsystem _subSystem;
        private bool _oldEnable;
        
        private bool _usePartType;
        
        private PartType _partType;

        private List<string> _partNames;

        private Dictionary<string, bool> _partOldState;
        
        
        public void SetData(X3.Character.ISubsystem.Type type, bool enable, bool usePartType, PartType partType)
        {
            _type = type;
            _enable = enable;
            _usePartType = usePartType;
            _partType = partType;
        }
        
        protected override void OnStart(Playable playable, FrameData info, object playerData)
        {
            var obj = playerData as GameObject;
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
                            // 物理可以用partyType
                            _partNames = new List<string>();
                            _partOldState = new Dictionary<string, bool>();
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

        protected override void OnStop()
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
                    if (_subSystem != null)
                    {
                        _subSystem.EnabledSelf = _oldEnable;   
                    }
                }
            }
        }
    }
}