using UnityEngine;

namespace X3Battle
{
    public class BSAActorAnimOffset: X3Sequence.Action
    {
        private Actor _actor;
        private Vector3 _offsetPos;
        private Vector3 _offsetEuler;
        
        public void SetData(Actor actor, Vector3 offsetPos, Vector3 offsetEuler)
        {
            _actor = actor;
            _offsetPos = offsetPos;
            _offsetEuler = offsetEuler;
        }

        protected override void _OnEnter()
        {
            if (_actor != null)
            {
                if (_offsetPos != Vector3.zero)
                {
                    var offset = _offsetPos.x * _actor.transform.right + _offsetPos.y * _actor.transform.up + _offsetPos.z * _actor.transform.forward;
                    var pos = _actor.transform.position;
                    pos += offset;
                    _actor.transform.SetPosition(pos, isForce:true, checkAirWall: true);
                }

                if (_offsetPos != Vector3.zero)
                {
                    var forward = _actor.transform.forward;
                    forward = Quaternion.Euler(_offsetEuler) * forward;
                    _actor.transform.SetForward(forward);
                }   
            }
        }
    }
}