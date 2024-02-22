using System.Collections.Generic;

namespace X3Battle
{
    public class RicochetShareData : IReset
    {
        // 根子弹配置
        private MissileCfg _rootMissileCfg;
        public MissileCfg rootMissileCfg => _rootMissileCfg;  
        
        // 当前弹射次数
        private int _curRicochetNum;

        // 子弹群
        private HashSet<Actor> _missileActors = new HashSet<Actor>();

        // 命中的单位
        private HashSet<Actor> _hitActors = new HashSet<Actor>();

        public RicochetShareData()
        {
        }

        public void Init(Actor rootMissile, MissileCfg rootCfg)
        {
            _rootMissileCfg = rootCfg;
            _curRicochetNum = 0;
            _missileActors.Add(rootMissile);
        }
        
        public void Reset()
        {
            _rootMissileCfg = null;
            _curRicochetNum = 0;
            _missileActors.Clear();
            _hitActors.Clear();
        }

        // 是否为空
        public bool IsMissileEmpty()
        {
            return _missileActors.Count == 0;
        }
        
        // 是否能弹射
        public bool CanRicochet()
        {
            // 根节点激活弹射
            if (rootMissileCfg.ricochetActive)
            {
                if (_curRicochetNum < rootMissileCfg.ricochetMaxNum)
                {
                    if (_missileActors.Count <= rootMissileCfg.ricochetMaxMissilesNum)
                    {
                        return true;
                    }
                }
            }
            return false;
        }

        // 弹射新子弹
        public void AddChildMissile(Actor missile)
        {
            _curRicochetNum++;  // 已经弹射的次数+1
            _missileActors.Add(missile);
        }

        // 移除子弹时调用
        public void RemoveMissile(Actor missile)
        {
            _missileActors.Remove(missile);
        }
        
        // 添加一个命中的actor
        public void AddHittingActor(Actor actor)
        {
            _hitActors.Add(actor);
        }

        // 是否命中过了某个actor
        public bool HasHitActor(Actor actor)
        {
            var result = _hitActors.Contains(actor);
            return result;
        }
    }
}