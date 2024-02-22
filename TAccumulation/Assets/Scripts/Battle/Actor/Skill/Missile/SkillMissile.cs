using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public class SkillMissile:SkillActive
    {
        private Missile _missile;
        public Missile missile => _missile;
        
        private MissileCfg _missileCfg;  // 子弹配置
        public MissileCfg missileCfg => _missileCfg;
        
        private CreateMissileParam _createParam;  // 创建参数

        private RicochetShareData _ricochetShareData;  // 子弹弹射共享参数

        private RicochetData? _ricochetData;  // 子弹弹射参数

        private TransInfoCache _transInfoCache;
        public int MissileCfgID => _missileCfg.ID;
        
        public SkillMissile(Actor _actor, DamageExporter _masterExporter, SkillCfg _skillConfig, SkillLevelCfg _levelConfig) : base(_actor, _masterExporter, _skillConfig, _levelConfig, _levelConfig.Level, SkillSlotType.Attack)
        {
        }

        public void ResetMissileData(MissileCfg missileCfgParam, CreateMissileParam createParam, RicochetShareData ricochetShareData, RicochetData? ricochetData, TransInfoCache transInfoCache = null)
        {
            _missileCfg = missileCfgParam;
            _createParam = createParam;
            _ricochetShareData = ricochetShareData;
            _ricochetData = ricochetData;
            _transInfoCache = transInfoCache;
        }

        protected override void OnCast()
        {
            base.OnCast();
            // TODO 后面接入对象池
            _missile = new Missile();
            _missile.Init(this, _missileCfg, _createParam, _ricochetShareData, _ricochetData, transInfoCache: _transInfoCache);
            _missile.Start();
        }

        protected override void _OnUpdate()
        {
            // 先更新运动
            var deltaTime = actor.deltaTime;
            
            _missile?.UpdateMotion(deltaTime);
            
            // 更新伤害盒位置
            base._OnUpdate();
            
            // 更新逻辑
            _missile?.UpdateLogic(deltaTime);


        }

        protected override void OnStop(SkillEndType skillEndType)
        {
            base.OnStop(skillEndType);
            _missile.Stop();
            _missile = null;
        }
        
        protected override void _OnHitAny(DamageBox damageBox)
        {
            base._OnHitAny(damageBox);
            _missile.OnHitAny(damageBox);
        }

        public override bool HittingIgnoreActor(Actor actor)
        {
            return _missile.HittingIgnoreActor(actor);
        }
    }
}