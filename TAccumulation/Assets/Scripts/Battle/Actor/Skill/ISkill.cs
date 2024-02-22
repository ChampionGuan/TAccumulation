using System.Collections.Generic;
using UnityEngine;

namespace X3Battle
{
    public class ISkill: DamageExporter
    {
        private SkillCfg _config;
        public SkillCfg config => _config;
        private SkillLevelCfg _levelConfig;
        public SkillLevelCfg levelConfig => _levelConfig;
        private int _slotID = -1;
        public int slotID => _slotID;
        public int level { get; private set; }
        public string skillIcon => _levelConfig?.SkillIcon;
        
        /// <summary> 统计技能是否命中过Actor, 技能释放时重置为false  </summary>
        public bool isHitAnyActor { get; private set; }
        
        public SkillSlotType slotType { get; private set; }

        private string _strInfo;

        private bool _isRunning;

        public ISkill(Actor _actor, DamageExporter _masterExporter, SkillCfg _skillConfig, SkillLevelCfg levelConfigParam, int level, SkillSlotType skillSlotType): base(DamageExporterType.Skill)
        {
            this.Init(_skillConfig.ID, _actor, _masterExporter);
            this.level = level;
            this.slotType = skillSlotType;
            _config = _skillConfig;
            _levelConfig = levelConfigParam;
            this.isHitAnyActor = false;
            this._strInfo = _skillConfig.Name + " " + _skillConfig.ID;
            _isRunning = false;
        }
        
        public  bool IsRunning()
        {
            return _isRunning;
        }
        
        public ISkill GetRootSkill()
        {
            ISkill result = this;
            while (result.masterExporter is ISkill masterSkill)
            {
                result = masterSkill;
            }

            return result;
        }

        public override int GetLevel()
        {
            return level;
        }
        
        /// <summary>
        /// 比较是否完全有这个Tag
        /// </summary>
        /// <param name="tagValue"> etc. SkillTag.Attack | SkillTag.Resonance </param>
        /// <returns> 是否包含这个Tag, 有一个没有就返回false </returns>
        public bool CompareSkillTag(int tagValue)
        {
            if (config.Tags != null && config.Tags.Count == 1)
            {
                return config.Tags[0] == tagValue;
            }
            return false;
        }

        // TODO 目前是用List.Contains判断, 待优化 by 长空
        /// <summary>
        /// 判断技能是否有这个Tag.
        /// </summary>
        /// <param name="skillTag"> 最好是一个Tag, 尽量不要是复合状态. </param>
        /// <returns> 是否有这个Tag, 有一个有就返回true </returns>
        public bool HasSkillTag(int tagValue)
        {
            if (config.Tags != null)
            {
                return config.Tags.Contains(tagValue);
            }
            return false;
        }

        /// <summary>
        /// 判断技能类型是否是这个
        /// </summary>
        /// <param name="skillType"> 目标类型 </param>
        /// <returns></returns>
        public bool CompareSkillType(SkillType skillType)
        {
            return this.config.Type == skillType;
        }
        
        // 获取技能配置ID
        public override int GetID()
        {
            return config.ID;
        }
        public override int GetCfgID()
        {
            return config.ID;
        }
        
        
        // 获取技能配置CD
        public float GetCD()
        {
            return levelConfig.CD;  
        }
        
        
        // 获取技能CDLimit
        public float GetCDMaxLimit()
        {
            return levelConfig.CDMax;  
        }
        
        //获取技能开始随机CD
        public float GetStartMaxCDLimit()
        {
            return levelConfig.StartCDMax;  
        }
        
        // 获取技能配置开始CD
        public float GetStartCD()
        {
            return levelConfig.StartCD;
        }

        // 获取deltaTime
        public virtual float GetDeltaTime()
        {
            return actor.deltaTime;
        }
        
        //设置技能所属的槽位ID
        //@param slotID Int
        public void SetSlotID(int slotID)
        {
            this._slotID = slotID;
        }
        
        //获取技能配置速度 (兼容一下不配的情况)
        protected float GetConfigPlaySpeed()
        {
            return config.PlaySpeed == 0? 1f : config.PlaySpeed;
        }

        //@return SkillSlotType
        public SkillSlotType GetSlotType()
        {
            if (_slotID >= 0)
            {
                return BattleUtil.GetSlotTypeAndIndex(_slotID, out var _);
            }

            // DONE: 如果技能的主人是技能则, 槽位类型为主人的槽位类型, 例如:子弹的主人是
            if (masterExporter is ISkill mSkill)
            {
                return mSkill.GetSlotType();
            }

            PapeGames.X3.LogProxy.LogErrorFormat("错误！不能对没有SlotID的技能取SlotType {0}", config.ID);
            return SkillSlotType.Attack;
        }

        //获取技能使用次数
        public int GetCastCount()
        {
            return config.CastCount;
        }
        
        /// <summary>
        /// 获取公共CD组ID
        /// </summary>
        /// <returns></returns>
        public int GetGroupID()
        {
            return _levelConfig.CDGroupID;
        }
        
        //TODO 移除技能计时器
        protected void DiscardTimer()
        {
            // this.actor.battle.timer:Discard(this)
        }

        //是否是主动技能，默认是主动技能
        //@return boolean
        public virtual bool IsPositive()
        {
            return true;
        }
        
        //技能运行过程中，Actor执行Command的回调，关心则处理，否则忽略
        //@param command Command
        // public void OnCommand(command) }

        //释放技能（接口类不要加实现）
        public void Cast()
        {
            if (_isRunning)
            {
                return;
            }
            _isRunning = true;
            
            isHitAnyActor = false;
            OnCast();
        }
        //更新技能（接口类不要加实现）
        public void Update()
        {
            if (_isRunning)
            {
                _OnUpdate();
            }
        }

        //中止技能（接口类不要加实现）
        //@param skill}Type Skill}Type 结束方式
        public void Stop(SkillEndType skillEndType)
        {
            if (!_isRunning)
            {
                return;
            }
            _isRunning = false;

            OnStop(skillEndType);
        }

        public virtual float GetLength() { return 0; }

        public virtual void SetLength(float length) { }

        public override void Destroy()
        {
            _config = null;
            _levelConfig = null;
            base.Destroy();
        }

        protected virtual void OnCast() { }
        protected virtual void OnStop(SkillEndType skillEndType) { }

        protected override void _OnHitAny(DamageBox damageBox)
        {
            base._OnHitAny(damageBox);

            if (damageBox.lastHitTargets.Count > 0)
            {
                isHitAnyActor = true;
            }
        }

        public override string ToString()
        {
            if (!string.IsNullOrEmpty(_strInfo))
            {
                return _strInfo;
            }

            return base.ToString();
        }

        public void EnterCD()
        {
            _OnEnterCD();
        }

        protected virtual void _OnEnterCD() { }

        public void ExitCD()
        {
            _OnExitCD();
        }

        protected virtual void _OnExitCD() { }

        protected virtual void _OnUpdate() { }
    }
}