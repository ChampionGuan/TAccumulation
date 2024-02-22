using UnityEngine;

namespace X3Battle
{
// Actor适配器
    public class ActorAdapter: IReset
    {
        private TransInfo _info;
        private Actor _actor;

        public Actor actor
        {
            get => _actor;
            set => _actor = value;
        }

        // 世界空间坐标
        public Vector3 position
        {
            get
            {
                if (_info != null)
                {
                    return _info.position;
                }
                else if (_actor != null)
                {
                    return _actor.transform.position;
                }
                return Vector3.zero;
            }
        }
        
        // 世界空间朝向
        public Vector3 forward
        {
            get
            {
                if (_info != null)
                {
                    return _info.forward;
                }
                else if (_actor != null)
                {
                    return _actor.transform.forward;
                }
                return Vector3.zero;
            }
        }

        public void Reset()
        {
            _info = null;
            _actor = null;
        }
            
        public void SetData(TransInfo info)
        {
            Reset();
            _info = info;
        }
        
        public void SetData(Actor actor)
        {
            Reset();
            _actor = actor;
        }
        
        public static bool operator==(ActorAdapter t1, ActorAdapter t2)
        {
            bool result;
            if (t1 is null || t2 is null)
            {
                if (t1 is null && t2 is null)
                {
                    result = true;
                }
                else
                {
                    result = false;
                }
            }
            else
            {
                result = t1._info == t2._info && t1._actor == t2._actor;
            }
            return result;
        }
        
        public static bool operator!=(ActorAdapter t1, ActorAdapter t2)
        {
            return !(t1 == t2);
        }
    }
}