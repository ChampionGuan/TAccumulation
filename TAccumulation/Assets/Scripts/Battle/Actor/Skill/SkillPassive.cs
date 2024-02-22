using System.Collections.Generic;
using PapeGames.X3;

namespace X3Battle
{
    public class SkillPassive : ISkill
    {
        private int _triggerInsID;
        private List<int> _buffIds;
        private int _triggerConfigID;
        private TriggerSkillContext _context;
        private bool _isBuffAdded;

        public SkillPassive(Actor _actor, ISkill _masterSkill, SkillCfg _skillConfig, SkillLevelCfg _levelConfig, int level, SkillSlotType skillSlotType) : base(_actor, _masterSkill, _skillConfig, _levelConfig, level, skillSlotType)
        {
            _InitTrigger();
            _InitBuff();
            _context = new TriggerSkillContext(this);
        }

        public override void Destroy()
        {
            _ClearBuff();
            _ClearTrigger();
            _context = null;
            base.Destroy();
        }

        public override bool IsPositive()
        {
            return false;
        }

        protected override void OnCast()
        {
            _AddBuff();
            _AddTrigger();
        }

        protected override void OnStop(SkillEndType skillEndType)
        {
            _ClearBuff();
            _ClearTrigger();
            _DestroyDamageBoxes();
            base.OnStop(skillEndType);
        }

        protected override void _OnEnterCD()
        {
            _ClearBuff();
            if (_triggerInsID > 0)
            {
                actor.battle.triggerMgr.DisableTrigger(_triggerInsID, true);
            }
            LogProxy.LogFormat("【完美闪避】被动技{0}进入CD状态！", config.Name);
        }

        protected override void _OnExitCD()
        {
            _AddBuff();
            if (_triggerInsID > 0)
            {
                actor.battle.triggerMgr.DisableTrigger(_triggerInsID, false);
            }
            LogProxy.LogFormat("【完美闪避】被动技{0}离开CD状态！", config.Name);
        }

        private void _InitTrigger()
        {
            _triggerConfigID = -1;
            if (levelConfig.TriggerID > 0)
            {
                _triggerConfigID = levelConfig.TriggerID;
            }
            else if(config.TriggerID > 0)
            {
                _triggerConfigID = config.TriggerID;
            }
        }

        private void _AddTrigger()
        {
            if (_triggerConfigID > 0)
            {
                _triggerInsID = actor.battle.triggerMgr.AddTrigger(_triggerConfigID, _context);
            }
        }
        
        private void _ClearTrigger()
        {
            if (_triggerInsID > 0)
            {
                actor.battle.triggerMgr.RemoveTrigger(_triggerInsID);
                _triggerInsID = -1;
            }
        }

        private void _InitBuff()
        {
            _buffIds = new List<int>();
            // DONE: 先读取表里的BuffID, 再读取编辑器里配置的BuffID.
            if (levelConfig.BuffIDs != null && levelConfig.BuffIDs.Length > 0)
            {
                foreach (int buffID in levelConfig.BuffIDs)
                {
                    _buffIds.Add(buffID);
                }
            }
            else if (config.BuffIDs != null && config.BuffIDs.Count > 0)
            {
                foreach (int buffID in config.BuffIDs)
                {
                    _buffIds.Add(buffID);
                }
            }
        }

        private void _AddBuff()
        {
            if (_isBuffAdded)
            {
                return;
            }
            _isBuffAdded = true;
            
            foreach (int buffId in _buffIds)
            {
                this.actor.buffOwner.Add(buffId, layer: 1, time: -1, this.level, actor, this);
            }
        }

        private void _ClearBuff()
        {
            if (!_isBuffAdded)
            {
                return;
            }
            _isBuffAdded = false;
            
            foreach (int buffId in _buffIds)
            {
                this.actor.buffOwner.ReduceStack(buffId, 1);
            }
        }

        protected override void _OnUpdate()
        {
            var deltaTime = GetDeltaTime();
            this._UpdateDamageBoxes(deltaTime);
        }
    }
}