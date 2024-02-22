using System;
using System.Collections.Generic;
using PapeGames.X3;
using UnityEngine;
using UnityEngine.Profiling;
using X3Battle.TargetSelect;

namespace X3Battle
{
    public class SkillOwner : ActorComponent
    {
        private Dictionary<int, SkillSlot> _slots;
        public Dictionary<int, SkillSlot> slots => _slots;
        
        private Dictionary<int, List<int>> _skillID2SlotIDs;
        private SkillActive _currentSkill;
        private SkillSlot _currentSlot;
        public SkillSlot currentSlot => _currentSlot;
        
        private Actor _target;
        public SkillLinkData skillLinkData { get; private set; }
        public SkillEnergyController energyController { get; private set; }  // 能量消耗控制
        public SkillDisableController disableController { get; private set; }  // 禁用技能控制
        public SkillChangeBtnSlotData changeBtnSlotData { get; private set; } // 改变Slot数据.
        public SkillInterruptLinkController interruptLinkController { get; private set; } //连招和打断控制器
        public QTEController qteController { get; private set; }  // QTE相关控制
        public TrackController trackController { get; private set; } //track控制器
        public AttachSequencerController attachSequencerController { get; private set; } //技能新增的动作模组控制器
        public Vector3 curCastForward { get; private set;}  // 释放时的目标朝向

        private Action<EventActorEnterStateBase> _actionActorEnterDeadState;

        private bool _isCastingProtect;  // 是否在释放技能过程中
        
        public SkillOwner() : base(ActorComponentType.Skill)
        {
            this._slots = new Dictionary<int, SkillSlot>();
            this._skillID2SlotIDs = new Dictionary<int, List<int>>();
            this._currentSkill = null;
            this._currentSlot = null;
            this._target = null;
            this.skillLinkData = new SkillLinkData();
            this.changeBtnSlotData = new SkillChangeBtnSlotData(this);
            this.interruptLinkController = new SkillInterruptLinkController();
            this._actionActorEnterDeadState = _OnActorEnterDeadState;
            energyController = new SkillEnergyController();
            disableController = new SkillDisableController(this);
            trackController = new TrackController(this);
            attachSequencerController = new AttachSequencerController(this);
        }
 
        protected override void OnDestroy()
        {
            skillLinkData?.Destroy();
            skillLinkData = null;
            foreach (var iter in _slots)
            {
                iter.Value.skill.Destroy();
            }

            trackController = null;
            attachSequencerController = null;
        }

        public override void OnBorn()
        {
            interruptLinkController.Init(actor, _currentSkill);
            _isCastingProtect = false;
            _EvalSkillsOnBorn();
            if (actor.roleBornCfg == null || actor.roleBornCfg.AutoCastPassiveSkill)
            {
                _CastPassiveSkills();
            }

            if (actor.roleBornCfg == null || actor.roleBornCfg.AutoStartSkillCD)
            {
                _SetSkillStartCD();
            }
            
            if (actor.IsBoy() && qteController == null)
            {
                qteController = new QTEController(actor);  // 男主添加QTE控制器
            }
            trackController.SetEnableInfo();
            //创建新加的动作模组
            attachSequencerController.CreateSequencers();
            battle.eventMgr.AddListener<EventActorEnterStateBase>(EventType.OnActorEnterDeadState, _actionActorEnterDeadState, "SkillOwner._OnActorEnterDeadState");
        }

        public override void OnRecycle()
        {
            changeBtnSlotData.Clear();
            energyController.Clear();
            disableController.Clear();
            interruptLinkController.Clear();
            trackController.Clear();
            attachSequencerController.Clear();
            TryEndSkill();
            _StopPassiveSkills();
            battle.eventMgr.RemoveListener<EventActorEnterStateBase>(EventType.OnActorEnterDeadState, _actionActorEnterDeadState);
        }

        // 目标死亡，则置空
        private void _OnActorEnterDeadState(EventActorEnterStateBase arg)
        {
            if (arg.actor == this._target)
            {
                this._target = null;
            }
        }

        // 角色出生时技能列表可能发生变化，这里处理一下增删逻辑
        private void _EvalSkillsOnBorn()
        {
            if (actor.type == ActorType.SkillAgent || actor.type == ActorType.Item)
            {
                // 目前技能代理和道具走的是先出生再动态创建技能的逻辑，不读bornCfg.skillSlots
                // TODO 后续考虑让技能代理和道具和常规Actor走一套逻辑，不特殊处理
                return;
            }
            
            var allSlotCfgs = GetAllSlotConfigs();
            // 筛选出需要删除的技能
            if (_slots != null && _slots.Count > 0)
            {
                var removeList = ObjectPoolUtility.CommonIntList.Get();
                foreach (var iter in _slots)
                {
                    // 在this._slots中，不在allSlotCfgs中，认为需要删除
                    if (allSlotCfgs == null || !allSlotCfgs.ContainsKey(iter.Key))
                    {
                        removeList.Add(iter.Key);
                    }
                }

                _RemoveSkillsOnBorn(removeList);
                ObjectPoolUtility.CommonIntList.Release(removeList);
            }
            
            // 筛选出新增的技能
            if (allSlotCfgs != null && allSlotCfgs.Count > 0)
            {
                var addDict = ObjectPoolUtility.CommonSlotCfgDict.Get();
                foreach (var iter in allSlotCfgs)
                {
                    // 在allSlotCfgs中，不在this._slots中，认为需要新增
                    if (_slots == null || !slots.ContainsKey(iter.Key))
                    {
                        addDict.Add(iter.Key, iter.Value);
                    }
                }

                _CreateSkillsOnBorn(addDict);
                ObjectPoolUtility.CommonSlotCfgDict.Release(addDict);
            }
        }

        // 出生时删除技能
        private void _RemoveSkillsOnBorn(List<int> removeSlotIDs)
        {
            if (removeSlotIDs != null && removeSlotIDs.Count > 0)
            {
                foreach (var slotID in removeSlotIDs)
                {
                    RemoveSkillSlot(slotID);
                }   
            }
        }
        
        // 出生时创建新技能
        private void _CreateSkillsOnBorn(Dictionary<int, SkillSlotConfig> slotCfgs)
        {
            // 优先创建肉鸽技能
            if (slotCfgs != null && slotCfgs.Count > 0)
            {
                foreach (var iter in slotCfgs)
                {
                    var slotCfg = iter.Value;
                    if (slotCfg.SourceType == SkillSourceType.Rogue)
                    {
                        var sloID = iter.Key;
                        _TryCreateSkillSlot(sloID, slotCfg);   
                    }
                }   
            }

            // 立即释放肉鸽被动
            _CastPassiveSkills(prePassive:true);
                
            // 再创建普通技能
            if (slotCfgs != null && slotCfgs.Count > 0)
            {
                foreach (var iter in slotCfgs)
                {
                    var slotCfg = iter.Value;
                    if (slotCfg.SourceType != SkillSourceType.Rogue)
                    {
                        var sloID = iter.Key;
                        _TryCreateSkillSlot(sloID, slotCfg);   
                    }
                }   
            }
        }

        /// <summary>
        /// 随机设置技能开始CD
        /// </summary>
        private void _SetSkillStartCD()
        {
            foreach (var iter in _slots)
            {
                var slot = iter.Value;
                slot?.SetStartCD();
            }
        }
        
        public void SetSkillStartCD()
        {
            _SetSkillStartCD();
        }

        /// <summary>
        /// AI进战时设置一下CD
        /// </summary>
        public void StartAICD()
        {
            foreach (var iter in _slots)
            {
                var slot = iter.Value;
                if (slot.skill.IsPositive())
                {
                    slot.StartAICD();
                }
            }
        }

        /// <summary>
        /// 清楚所有技能CD.
        /// </summary>
        public void ClearAllSkillCD()
        {
            foreach (var iter in _slots)
            {
                var slot = iter.Value;
                if (slot.skill.IsPositive())
                {
                    slot.SetRemainCD(0f);
                }
            }
        }
        
        /// <summary>
        ///  恢复技能使用次数
        /// </summary>
        public void RecoverSkillUseCount(SkillSlotType type)
        {
            foreach (var iter in _slots)
            {
                var slot = iter.Value;
                if (slot.skill.GetSlotType() == type)
                {
                    slot.castCount = slot.maxCastCount;
                }
            }
        }

        public void StopAllSkill()
        {
            TryEndSkill();
            _StopPassiveSkills();
        }
        
        // 是否在吟唱中
        public bool IsSinging()
        {
            if (_currentSkill != null)
            {
                return _currentSkill.IsSinging;
            }

            return false;
        }

        protected override void OnUpdate()
        {
            var actorDeltaTime = actor.deltaTime;
            foreach (var iter in _slots)
            {
                iter.Value.Update(actorDeltaTime);
                
                var skill = iter.Value.skill;
                // 更新被动技
                if (!skill.IsPositive())
                {
                    skill.Update();
                }
            }

            if (_currentSkill != null)
            {
                var deltaTime = _currentSkill.GetPlaySpeed() * actor.deltaTime;
                skillLinkData.Update(deltaTime);
                _currentSkill.Update();
            }

            if (_target != null && _target.isDead)
            {
                _target = null;
            }
            
            // 刷新QTE组件
            qteController?.Update();
        }

        // 冰冻模块需要一个只更新CD的接口
        public void UpdateSlotCD()
        {
            var actorDeltaTime = actor.deltaTime;
            foreach (var iter in _slots)
            {
                iter.Value.UpdateCD(actorDeltaTime);
            }
        }

        /// <summary>
        /// Skill中调用过来, 这里转发一下
        /// </summary>
        /// <param name="playerBtnType">按钮类型</param>
        /// <param name="skillID">技能ID</param>
        /// <param name="duration">持续时长</param>
        /// <param name="btnStateType">按钮状态</param>
        public void OnSkillLinkEvent(PlayerBtnType playerBtnType, int skillID, float duration, PlayerBtnStateType btnStateType)
        {
            var slotID = GetSlotIDBySkillID(skillID);
            if (slotID != null)
            {
                skillLinkData.AddLinkDataItem(playerBtnType, slotID.Value, skillID, duration, btnStateType);
            }
            else
            {
                LogProxy.LogErrorFormat("【卡宝宝&清心】连招事件帧配置异常，skillID={0}, 不在人物技能槽位中, 请策划检查人物技能配置！", skillID);
            }
        }

        // 添加dodgeOffset数据
        public void AddDodgeOffsetData(PlayerBtnType playerBtnType, PlayerBtnStateType stateType, int skillID)
        {
            // 只有普攻技能的非hold普攻连招才会记录
            if (playerBtnType == PlayerBtnType.Attack && stateType != PlayerBtnStateType.Hold)
            {
                if (_currentSkill != null && _currentSkill.config.Type == SkillType.Attack)
                {
                    var slotID = GetSlotIDBySkillID(skillID);
                    if (slotID != null)
                    {
                        skillLinkData.AddDodgeOffsetData(slotID.Value, skillID);
                    }
                }
            }
        }

        // 是否激活DodgeOffset
        public void ActiveDodgeOffset(bool isActive, object owner)
        {
            if (_currentSkill != null)
            {
                // 在开启了DodgeOffset的闪避技中才能开启这个功能
                if (_currentSkill.config.Type == SkillType.Dodge && _currentSkill.config.DodgeOffset)
                {
                    skillLinkData?.ActiveDodgeOffset(isActive, owner);
                }
            }
        }
        
        /// <summary>
        /// 获取playerBtnType对应的SlotID
        /// </summary>
        /// <param name="playerBtnType">按钮类型</param>
        /// <param name="btnStateType">按钮状态判断</param>
        /// <returns>不存在则返回null</returns>
        public int? TryGetLinkSlotID(PlayerBtnType playerBtnType, PlayerBtnStateType btnStateType)
        {
            var slotID = skillLinkData.TryGetLinkSlotID(playerBtnType, btnStateType);
            return slotID;
        }

        /// <summary>
        /// 获取某个按钮上当前SlotID，有连招就用连招，没连招用默认 
        /// </summary>
        /// <param name="playerBtnType">按钮类型</param>
        /// <returns></returns>
        public int? TryGetCurSlotID(PlayerBtnType playerBtnType, PlayerBtnStateType btnStateType)
        {
            // 优先取连招
            var linkSlotId = TryGetLinkSlotID(playerBtnType, btnStateType);
            if (linkSlotId != null)
            {
                return linkSlotId;
            }

            // 取QTE数据
            if (qteController != null && qteController.isActive)
            {
                if (playerBtnType == PlayerBtnType.Active && btnStateType == PlayerBtnStateType.Down)
                {
                    if (qteController.qteSlotID != null)
                    {
                        return qteController.qteSlotID;
                    }
                }
            }
            
            // 取其他模块设置的数据.
            var changeSlotId = changeBtnSlotData?.TryGetSlotID(playerBtnType);
            if (changeSlotId != null)
            {
                return changeSlotId;
            }
            
            // 没有连招就取第0个槽位
            var slot = GetSkillSlot((SkillSlotType) playerBtnType, 0);
            if (slot != null)
            {
                return slot.ID;
            }

            return null;
        }

        /// <summary>
        /// 获取某个按钮上当前SlotID 不获取连招数据
        /// </summary>
        /// <param name="playerBtnType"></param>
        /// <returns></returns>
        public int? TryGetBaseSlotID(PlayerBtnType playerBtnType)
        {
            // 取其他模块设置的数据.
            var changeSlotId = changeBtnSlotData?.TryGetSlotID(playerBtnType);
            if (changeSlotId != null)
            {
                return changeSlotId;
            }
            
            // 没有连招就取第0个槽位
            var slot = GetSkillSlot((SkillSlotType) playerBtnType, 0);
            if (slot != null)
            {
                return slot.ID;
            }

            return null;
        }

        /// <summary>
        /// 激活中的技能连招是否有此技能
        /// </summary>
        /// <param name="slotID"></param>
        /// <param name="btnStateType">按钮状态判断，如果null则所有状态都能过</param>
        /// <returns></returns>
        public bool IsActiveSkillLink(int slotID, PlayerBtnStateType? btnStateType = null)
        {
            var result = skillLinkData.IsActiveSkillLink(slotID, btnStateType);
            return result;
        }

        public void CastAllPassiveSkills()
        {
            _CastPassiveSkills();
            actor.energyOwner?.EvalEnergyAfterBorn();
        }
        
        public void CastPassiveSkill(int passiveSkillID)
        {
            var slot = GetSkillSlot(SkillSlotType.SkillID, passiveSkillID);
            if (slot != null)
            {
                if (!slot.skill.IsPositive())
                {
                    slot.skill.Cast();
                }
            }
        }
        
        private void _CastPassiveSkills(bool prePassive = false)
        {
            foreach (var iter in _slots)
            {
                var skill = iter.Value.skill;
                if (!skill.IsPositive())
                {
                    if (!prePassive || iter.Value.config.SourceType == SkillSourceType.Rogue)
                    {
                        skill.Cast();   
                    }
                }
            }
        }

        private void _StopPassiveSkills()
        {
            foreach (var iter in _slots)
            {
                var skill = iter.Value.skill;
                if (!skill.IsPositive())
                {
                    skill.Stop(SkillEndType.Interrupt);
                }
            }
        }

        // 通过slotConfig创建技能
        private bool _TryCreateSkillSlot(int slotID, SkillSlotConfig skillSlotConfig)
        {
            if (skillSlotConfig == null)
            {
                return false;
            }
            
            if (slotID != skillSlotConfig.ID)
            {
                LogProxy.LogErrorFormat("【技能】bornCfg.skillSlots配置异常，slotID={0}, slotCfg.ID={1}，两个ID不一致，请联系程序！", slotID, skillSlotConfig.ID);
                return false;
            }
            
            if (_slots.ContainsKey(slotID))
            {
                LogProxy.LogErrorFormat("【卡宝宝&清心】创建技能失败，已存在slotID={0}的技能，请检查配置！", skillSlotConfig.SkillID);
                return false;
            }

            if (skillSlotConfig.ID != slotID)
            {
                LogProxy.LogWarningFormat("CreateSkill({0}): actor({1})'s slotID({2}) is not same with array index, please check ActorConfig table!", skillSlotConfig.SkillID, actor.config.ID, skillSlotConfig.ID);
            }

            var skillConfig = TbUtil.GetCfg<SkillCfg>(skillSlotConfig.SkillID);
            if (skillConfig == null)
            {
                LogProxy.LogErrorFormat("【卡宝宝&清心】技能(id={0})配置不存在: 所属角色 {1}", skillSlotConfig.SkillID, actor.name);
                return false;
            }

            if (!_CheckCreateUniqueValid(skillSlotConfig.SkillID))
            {
                if (skillSlotConfig.SourceType == SkillSourceType.Rogue)
                {
                    // 肉鸽来源不报错
                    LogProxy.LogFormat("【卡宝宝&楚门】创建技能失败，已存在相同ID={0}技能，并且这个技能是不可重复的，但技能来源是肉鸽，不报错！", skillSlotConfig.SkillID);
                    return false;
                }
                else
                {
                    // 常规来源直接报错
                    LogProxy.LogErrorFormat("【卡宝宝&清心】创建技能失败，已存在相同ID={0}技能，并且这个技能是不可重复的！", skillSlotConfig.SkillID);
                    return false;   
                }
            }
            
            var skill = _CreateSkillByID(skillSlotConfig.SkillID, skillSlotConfig.SkillLevel, skillSlotConfig.SlotType);
            if (skill == null)
            {
                LogProxy.LogErrorFormat("【卡宝宝&清心】技能槽位创建失败：技能(id={0}) 没有找到，或者没有等级配置，导致槽位({1})创建失败！", skillSlotConfig.SkillID, BattleUtil.GetSlotDebugInfo(slotID));
                return false;
            }

            var skillSlot = new SkillSlot(skillSlotConfig, skill, slotID);
            skill.SetSlotID(skillSlotConfig.ID);

            _slots[slotID] = skillSlot;
            _AddSkillSlotMapInfo(skillSlotConfig.SkillID, slotID);
            return true;
        }

        private bool _CheckCreateUniqueValid(int skillID)
        {
            var skillCfg = TbUtil.GetCfg<SkillCfg>(skillID);
            var hasSkill = false;
            _skillID2SlotIDs.TryGetValue(skillID, out var slotIDs);
            if (slotIDs != null && slotIDs.Count > 0)
            {
                hasSkill = true;
            }

            var isValid = true;
            if (skillCfg.ReleaseType == SkillReleaseType.Active)
            {
                if (hasSkill)
                {
                    isValid = false;
                }
            }
            else if(skillCfg.ReleaseType == SkillReleaseType.Passive)
            {
                var levelCfg = TbUtil.GetSkillLevelCfg(skillID, 1);  // 数值策划用1级的配置来定义整个技能
                if (levelCfg != null && levelCfg.IsUnique && hasSkill)
                {
                    isValid = false;
                }
            }
            return isValid;
        }

        // 添加技能ID -? SlotID的映射信息
        private void _AddSkillSlotMapInfo(int skillID, int slotID)
        {
            _skillID2SlotIDs.TryGetValue(skillID, out var slotIDs);
            if (slotIDs == null)
            {
                slotIDs = new List<int>();
                _skillID2SlotIDs[skillID] = slotIDs;
            }
            slotIDs.Add(slotID);
        }
        
        // 通过技能ID获取SlotID，获取不到返回null
        public int? GetSlotIDBySkillID(int skillID, bool safeCheck = true)
        {
            _skillID2SlotIDs.TryGetValue(skillID, out var slotIDs);
            if (slotIDs != null && slotIDs.Count > 0)
            {
                if (slotIDs.Count > 1 && safeCheck)
                {
                    LogProxy.LogErrorFormat("【卡宝宝&清心】存在多个技能id={0}的技能，将默认返回第一个，策划需要检查配置！", skillID);
                }
                return slotIDs[0];
            }
            else if (safeCheck)
            {
                LogProxy.LogErrorFormat("【卡宝宝&清心】获取槽位ID失败，技能id={0}，对应的槽位不存在，策划需要检查配置！", skillID);
            }

            return null;
        }

        // 通过SlotType 和 SlotID获取对应技能ID，运行时接口， slotIDType是skill的时候，index表示技能ID
        // 如果类型为SkillSlotType.Skill, 如果找不到返回null
        public int? GetSlotID(SkillSlotType slotType, int slotIndex)
        {
            int? slotID = null;
            if (slotType == SkillSlotType.SkillID)
            {
                slotID = GetSlotIDBySkillID(slotIndex, false);
            }
            else
            {
                slotID = BattleUtil.GetSlotID(slotType, slotIndex);
            }

            return slotID;
        }

        // 这个接口是给战斗调试器使用的，正常逻辑不要调用
        public void CreateSkillSlotByDebugEditor(int slotID, int skillID, int skillLevel = 1)
        {
            // 如果运行时过程中调用，要确保技能停止，否则可能会有特效或者Timeline泄露
            TryEndSkill();

            var slotConfig = new SkillSlotConfig();
            slotConfig.ID = slotID;
            slotConfig.SkillID = skillID;
            slotConfig.SkillLevel = skillLevel;
            var isSuccessfully = _TryCreateSkillSlot(slotID, slotConfig);
            // 被动技能创建时直接释放
            if (isSuccessfully)
            {
                var newSlot = GetSkillSlot(slotID);
                var newSkill = newSlot?.skill;
                if (newSkill != null && !newSkill.IsPositive())
                {
                    newSkill.Cast();
                }    
            }
        }

        // TODO 给战斗调试器提供的接口，正常逻辑不要调用
        public ISkill GetSkillByDebugEditor(int skillID)
        {
            var slot = GetSkillSlot(SkillSlotType.SkillID, skillID);
            return slot?.skill;
        }


        // TODO 给技能编辑器用的，正常逻辑不要调用，当技能配置修改时更新SkillSlot
        public void RecreateSkillSlotByDebugEditor(int skillID)
        {
            _skillID2SlotIDs.TryGetValue(skillID, out var curSlotIDs);
            if (curSlotIDs != null)
            {
                var slotIDs = curSlotIDs.ToArray();
                foreach (var slotID in slotIDs)
                {
                    var slotCfg = GetSkillSlot(slotID).config;
                    RemoveSkillSlot(slotID);
                    var isSuccessfully = _TryCreateSkillSlot(slotID, slotCfg);
                    if (isSuccessfully)
                    {
                        // 被动技能直接释放
                        var newSlot = GetSkillSlot(slotID);
                        var newSkill = newSlot.skill;
                        if (!newSkill.IsPositive())
                        {
                            newSkill.Cast();
                        }
                    }
                }
            }
        }

        public ISkill GetSkillBySlot(int slotID)
        {
            _slots.TryGetValue(slotID, out var slot);
            if (slot != null)
            {
                return slot.skill;
            }

            return null;
        }

        public SkillSlot GetSkillSlot(SkillSlotType slotType, int slotIndex)
        {
            var slotId = GetSlotID(slotType, slotIndex);
            if (slotId == null)
                return null;
            return GetSkillSlot(slotId.Value);
        }

        public SkillSlot GetSkillSlot(int slotID)
        {
            _slots.TryGetValue(slotID, out var slot);
            return slot;
        }

        public bool HasSkillSlot(int slotID)
        {
            return GetSkillSlot(slotID) != null;
        }

        //  skillType Int skillConfig里的SkillType
        public List<SkillSlot> GetSkillSlotsByType(SkillSlotType skillType)
        {
            var result = new List<SkillSlot>();
            foreach (var iter in _slots)
            {
                if (iter.Value.slotType == skillType)
                {
                    result.Add(iter.Value);
                }
            }

            return result;
        }

        public bool IsSkillRunning()
        {
            return _currentSkill != null;
        }

        private ISkill _CreateSkillByID(int skillConfigID, int skillLevel, SkillSlotType skillSlotType)
        {
            if (skillConfigID == 0)
            {
                return null;
            }

            var skillConfig = TbUtil.GetCfg<SkillCfg>(skillConfigID);
            if (skillConfig == null)
            {
                PapeGames.X3.LogProxy.LogErrorFormat("【卡宝宝&清心】技能(id={0})配置不存在: 所属角色(id={1})", skillConfigID, actor.config.ID);
                return null;
            }

            if (skillConfig.ID != skillConfigID)
            {
                PapeGames.X3.LogProxy.LogErrorFormat("【卡宝宝&清心】技能(id={0})配置错误: Key和技能ID不一致，导表错误！", skillConfigID);
                skillConfig.ID = skillConfigID;
            }

            var skillLevelConfig = TbUtil.GetSkillLevelCfg(skillConfigID, skillLevel);
            if (skillLevelConfig == null)
            {
                PapeGames.X3.LogProxy.LogErrorFormat("【卡宝宝&清心】技能(id={0})配置错误: SkillLevelConfig没有对应的配置，每个技能都需要一个等级配置！", skillConfigID);
                return null;
            }

            var skill = _CreateSkill(null, skillConfig, skillLevelConfig, skillLevel, skillSlotType);
            return skill;
        }


        private ISkill _CreateSkill(ISkill masterSkill, SkillCfg skillConfig, SkillLevelCfg skillLevelConfig, int level, SkillSlotType skillSlotType)
        {
            ISkill skill = null;

            var isPassitiveSkill = skillConfig.ReleaseType == SkillReleaseType.Passive;
            if (isPassitiveSkill)
            {
                // DONE: 创建被动技能.
                skill = CreateSkillPassive(skillConfig, skillLevelConfig, level, skillSlotType);
            }
            else
            {
                // 剩下的都是timeline技能
                skill = new SkillTimeline(actor, masterSkill, skillConfig, skillLevelConfig, level, skillSlotType);
            }
            
            // 创建技能
            disableController?.OnCreateSkill(skill);
            return skill;
        }

        // 创建新子弹
        public int CreateMissileSkill(DamageExporter master, SkillCfg skillConfig, SkillLevelCfg skillLevelConfig, MissileCfg missileCfg, CreateMissileParam createParam, RicochetShareData ricochetShareData = null, RicochetData? ricochetData = null, TransInfoCache transInfoCache = null)
        {
            var slotID = BattleUtil.GetSlotID(SkillSlotType.Attack, 0);
            SkillMissile missileSkill = null;
            if (GetSkillSlot(slotID) != null)
            {
                missileSkill = GetSkillBySlot(slotID) as SkillMissile;
            }
            else
            {
                missileSkill = new SkillMissile(actor, master, skillConfig, skillLevelConfig);
                _AddToAgentSkillSlot(missileSkill);
            }

            if (missileSkill != null)
            {
                missileSkill.ResetMissileData(missileCfg, createParam, ricochetShareData, ricochetData, transInfoCache: transInfoCache);  
                missileSkill.SetMasterExporter(master);
            }
            
            return slotID;
        }

        // 动态创建法术场的技能，返回slotID
        public int CreateMagicFieldSkill(DamageExporter damageExporter, SkillCfg skillConfig, SkillLevelCfg skillLevelConfig, int level, MagicFieldCfg magicFieldCfg, CreateMagicFieldParam createParam)
        {
            var slotID = BattleUtil.GetSlotID(SkillSlotType.Attack, 0);
            SkillMagicField skill = null;
            if (GetSkillSlot(slotID) != null)
            {
                skill = GetSkillBySlot(slotID) as SkillMagicField;
            }
            else
            {
                skill = new SkillMagicField(actor, damageExporter, skillConfig, skillLevelConfig, level, magicFieldCfg);
                _AddToAgentSkillSlot(skill);
            }

            if (skill != null)
            {
                skill.SetMasterExporter(damageExporter);
                skill.SetCreateParam(createParam);
            }

            return slotID;
        }

        /// <summary>
        /// 创建或获取空技能
        /// </summary>
        /// <param name="master">哪个技能或buff创建该技能，没有填null</param>
        /// <param name="skillConfig">技能cfg</param>
        /// <param name="skillLevelConfig">技能等级cfg</param>
        /// <returns></returns>
        public int GetOrCreateEmptySkill(DamageExporter master, SkillCfg skillConfig, SkillLevelCfg skillLevelConfig)
        {
            var slotID = BattleUtil.GetSlotID(SkillSlotType.Attack, 0);
            SkillActive emptySkill = null;
            if (GetSkillSlot(slotID) != null)
            {
                emptySkill = GetSkillBySlot(slotID) as SkillActive;
            }
            else
            {
                emptySkill = new SkillActive(actor, master, skillConfig, skillLevelConfig, skillLevelConfig.Level, SkillSlotType.Attack);
                _AddToAgentSkillSlot(emptySkill);
            }

            if (emptySkill != null)
            {
                emptySkill.SetMasterExporter(master);
            }
            
            return slotID;
        }

        // AgentActor需要动态创建技能时会调用，agent使用普攻槽位
        private int _AddToAgentSkillSlot(ISkill skill)
        {
            var slotID = BattleUtil.GetSlotID(SkillSlotType.Attack, 0);
            var skillId = skill.config.ID;
            var slotCfg = new SkillSlotConfig()
            {
                ID = slotID,
                SkillID = skillId,
                SkillLevel = skill.level,
            };
            var skillSlot = new SkillSlot(slotCfg, skill, slotID);
            skill.SetSlotID(slotID);

            _slots[slotID] = skillSlot;
            _AddSkillSlotMapInfo(skillId, slotID);
            return slotID;
        }

        // 创建被动技能
        private SkillPassive CreateSkillPassive(SkillCfg skillConfig, SkillLevelCfg skillLevelConfig, int level, SkillSlotType skillSlotType)
        {
            var skill = new SkillPassive(actor, null, skillConfig, skillLevelConfig, level, skillSlotType);
            return skill;
        }

        // 死亡、销毁状态，视为技能无效
        public bool _CheckMainStateIsValid(Actor actor)
        {
            if (actor == null || actor.mainState == null || actor.isDead || actor.mainState.IsState(ActorMainStateType.Num))
            {
                return false;
            }

            return true;
        }


        /// <summary>
        /// 重要接口：某个SlotID能否释放技能
        /// </summary>
        /// <param name="targetSlotID"></param>
        /// <param name="reportError">不报错</param>
        /// <param name="notCheckPriority">不检查优先级</param>
        /// <param name="stateType">连招按钮状态判断，如果null则所有状态都可以</param>
        /// <returns></returns>
        public bool CanCastSkillBySlot(int targetSlotID, bool reportError = false, bool notCheckPriority = false, PlayerBtnStateType? stateType = null)
        {
            _slots.TryGetValue(targetSlotID, out var skillSlot);
            if (skillSlot == null)
            {
                if (reportError)
                {
                    PapeGames.X3.LogProxy.LogErrorFormat("{0} 不能释放槽位{1}对应的技能：技能不存在！", this.actor.name, targetSlotID);
                }
                else
                {
                    PapeGames.X3.LogProxy.LogFormat("{0} 不能释放槽位{1}对应的技能：技能不存在！", this.actor.name, targetSlotID);
                }

                return false;
            }

            if (_isCastingProtect)
            {
                PapeGames.X3.LogProxy.LogFormat("{0} 不能释放槽位{1}对应的技能：已经有技能在释放过程中了！", this.actor.name, targetSlotID);
                return false;
            }

            var targetSkill = skillSlot.skill;
            if (!targetSkill.IsPositive())
            {
                if (reportError)
                {
                    PapeGames.X3.LogProxy.LogErrorFormat("{0} 不能释放槽位{1}对应的技能：这是个被动技能！", this.actor.name, targetSlotID);
                }
                else
                {
                    PapeGames.X3.LogProxy.LogFormat("{0} 不能释放槽位{1}对应的技能：这是个被动技能！", this.actor.name, targetSlotID);
                }

                return false;
            }

            using (ProfilerDefine.SkillEnergyJudgePMarker.Auto())
            {
                if (!skillSlot.IsEnergyFull())
                {
                    PapeGames.X3.LogProxy.LogFormat("{0} 不能释放槽位{1}对应的技能：能量不够！", this.actor.name, targetSlotID);
                    return false;
                }
            }

            if (skillSlot.HasMultiSegmentSkill() && skillSlot.GetCanCastCount() <= 0)
            {
                PapeGames.X3.LogProxy.LogFormat("{0} 不能释放槽位{1}对应的技能：释放次数不够", this.actor.name, targetSlotID);
                return false;
            }

            if (!skillSlot.HasMultiSegmentSkill() && skillSlot.IsCD())
            {
                PapeGames.X3.LogProxy.LogFormat("{0} 不能释放槽位{1}对应的技能：释放CD不够！", this.actor.name, targetSlotID);
                return false;
            }

            // 人物状态判断
            using (ProfilerDefine.SkillStateTagJudgePMarker.Auto())
            {
                if (actor.stateTag != null && actor.stateTag.IsActive(ActorStateTagType.CannotCastSkill))
                {
                    PapeGames.X3.LogProxy.LogFormat("{0} 不能释放槽位{1}对应的技能：角色处于不能放技能状态！", this.actor.name, targetSlotID);
                    return false;
                }
            }

            // 技能禁用状态判断
            using (ProfilerDefine.SkillDisableControllerJudgePMarker.Auto())
            {
                if (disableController.IsDisableSkill(targetSkill))
                {
                    PapeGames.X3.LogProxy.LogFormat("{0} 不能释放槽位{1}对应的技能：此技能类型已被buff标记为不可释放！", this.actor.name, targetSlotID);
                    return false;
                }
            }

            // 受击能否释放技能 
            using (ProfilerDefine.SkillDisableControllerJudgePMarker.Auto())
            {
                if (actor.hurt != null && actor.hurt.isHurt && !actor.hurt.hurtInterruptController.HurtInterruptBySkill(skillSlot.skill.config.Type))
                {
                    PapeGames.X3.LogProxy.LogFormat("{0} 不能释放槽位{1}对应的技能：处于受击不可打断区间！", this.actor.name, targetSlotID);
                    return false;
                }
            }

            // 移动能否释放技能 
            using (ProfilerDefine.SkillLocomotionJudgePMarker.Auto())
            {
                if (actor.locomotion != null && !actor.locomotion.CanSkillInterrupt(skillSlot.skill.config.Type))
                {
                    PapeGames.X3.LogProxy.LogFormat("{0} 不能释放槽位{1}对应的技能：处于locomotion不可打断区间！", this.actor.name, targetSlotID);
                    return false;
                }
            }

            // 优先级和连招判断，如果满足连招则跳过优先级
            using (ProfilerDefine.SkillLinkPriorityJudgePMarker.Auto())
            {
                if (IsActiveSkillLink(targetSlotID, stateType))
                {
                    // 有连招就不进行优先级判断了   
                }
                else
                {
                    // 没有连招就优先级判断：如果当前有技能存在（即在运行），则判定优先级，如果优先级不够，则判定是否可以被打断
                    if (!notCheckPriority && this._currentSkill != null &&
                        skillSlot.skill.config.Priority <= this._currentSkill.config.Priority &&
                        !this.interruptLinkController.SkillCanInterrupt(skillSlot.skill.config.Type))
                    {
                        PapeGames.X3.LogProxy.LogFormat("{0} 不能释放槽位{1}对应的技能：优先级不够，不能打断当前技能！", this.actor.name, targetSlotID);
                        return false;
                    }
                }
            }

            return true;
        }

        /// <summary>
        /// 尝试通过SkillSlot释放技能, 技能有CD和能量效果
        /// </summary>
        /// <param name="slotID"></param>
        /// <param name="target">会影响到目标选择系统，null则由索敌系统重新筛选目标</param>
        /// <param name="safeCheck">是否进行安全检查，默认进行安全检查</param>
        /// <param name="stateType">连招按钮状态判断，如果null则所有状态都可以</param>
        /// <returns></returns>
        public bool TryCastSkillBySlot(int slotID, Actor target = null, bool safeCheck = true, PlayerBtnStateType? stateType = null, bool forceSetTarget = false, bool notCheckPriority = false)
        {
            if (safeCheck && !CanCastSkillBySlot(slotID, true, notCheckPriority, stateType))
            {
                return false;
            }

            _isCastingProtect = true;
            
            var skillSlot = _slots[slotID];
            // 普通技能逻辑分支
            var targetSkill = skillSlot.skill as SkillActive;
            
            // 从当前技能到下个技能过渡事件
            if (_currentSkill != null && targetSkill != null)
            {
                var eventData = actor.battle.eventMgr.GetEvent<EventSwitchRunningSkill>();
                eventData.Init(_currentSkill, targetSkill);
                actor.battle.eventMgr.Dispatch(EventType.SwitchRunningSkill, eventData);
            }

            TryEndSkill(nextSkill:targetSkill);
            this._currentSlot = skillSlot;
            //是否由动作模组控制CD
            skillSlot.StartCastCD();
            
            if (_currentSlot != null)
            {
                _currentSlot.SubCastCount();
                // 尝试消耗能量
                _currentSlot.TryCostEnergy();
            }
            
            _isCastingProtect = false;
            
            _TryCastSkill(targetSkill, target, forceSetTarget);
            return true;
        }

        
        /// <summary>
        /// 直接通过Skill释放，技能没有CD和能量效果
        /// </summary>
        /// <param name="skill"></param>
        /// <param name="target"></param>
        private void _TryCastSkill(SkillActive skill, Actor target, bool forceSetTarget)
        {
            // 释放技能的之前，需要把之前的技能停止，否则多个技能一起运行，抢占人物控制权
            if (this._currentSkill != null)
            {
                return;
            }

            // 释放技能的之前,将受击停止
            if (actor.hurt != null && actor.hurt.isHurt)
                actor.hurt.StopHurt();

            _SelectSkillTarget(skill, target, forceSetTarget);
            
            // 触发QTEController内部逻辑
            qteController?.OnCastSkill(skill);  

            // 设置位置
            curCastForward = actor.transform.forward;
            Vector3? newForward = null;
            
            if (skill.config.IsRotateToExpectation)
            {
                // 面向摇杆 (不直接从摇杆取，而是从主状态机取期望方向)
                var expectDir = actor.GetDestDir();
                newForward = expectDir;
            }
            // 面向目标, 优先级比摇杆高
            if (_target != null && _target != actor && skill.config.IsRotateToTarget)
            {
                var dir = _target.transform.position - actor.transform.position;
                dir.y = 0;
                var forward = dir.normalized;
                newForward = forward;
            }

            if (newForward != null)
            {
                curCastForward = newForward.Value;
                // 非爆发技立即设置，爆发技需要在播起来后暗中设置
                if (skill.config.Type != SkillType.Ultra)
                {
                    actor.transform.SetForward(newForward.Value);
                }
            }
            _currentSkill = skill;
            // 如果技能运行中，则设置人物状态机到技能状态
            // 注意：很多技能代理是瞬间结束的，为了避免动画状态切换，这里专门做的优化
            if (actor.mainState != null)
            {
                actor.mainState.TryToState(ActorMainStateType.Skill);
            }
            //切换技能的时候换一下技能
            interruptLinkController.Init(actor, _currentSkill);
            skill.Cast();
        }

        // TODO 临时让策划录像处理
        public void TempSetSkillTarget(Actor target)
        {
            _SelectSkillTarget(null, target, true);
        }
        
        // 释放技能时设置目标朝向
        private void _SelectSkillTarget(SkillActive skill, Actor target, bool forceSetTarget)
        {
            if (forceSetTarget)
            {
                _target = target;
                return;
            }
            
            if (target == null)
            {
                // 技能没有指定目标，发事件通知锁敌系统更新目标
                var selectData = ObjectPoolUtility.SkillSelectData.Get();
                selectData.Init(skill);
                actor.targetSelector?.TryUpdateTarget(TargetSelectorUpdateType.SkillSelectTarget, selectData);
                ObjectPoolUtility.SkillSelectData.Release(selectData);
                qteController?.RefreshLockTarget(skill.config);

                var targetSelectType = skill.config.TargetSelectType;
                Actor selectActor = null;
                if (targetSelectType == TargetSelectType.Self)
                {
                    selectActor = actor;
                }
                else if (targetSelectType == TargetSelectType.Boy)
                {
                    selectActor = battle.actorMgr.boy;
                }
                else if (targetSelectType == TargetSelectType.Girl)
                {
                    selectActor = battle.actorMgr.girl;
                }
                else if (targetSelectType == TargetSelectType.Lock)
                {
                    selectActor = actor.targetSelector?.GetTarget();
                }
                else if (targetSelectType == TargetSelectType.NearestEnemy)
                {
                    selectActor = BattleUtil.GetNearestEnemy(actor, skill.config.NearestEnemySelectRange, considerLockIgnore: true);
                }

                _target = selectActor;
            }
            else
            {
                // 技能有指定目标直接使用
                _target = target;
            }
        }

        public Actor GetTarget()
        {
            return _target;
        }

        /// <summary>
        /// 尝试终止当前技能
        /// </summary>
        /// <param name="skillEndType"></param>
        public void TryEndSkill(SkillEndType skillEndType = SkillEndType.Interrupt, SkillActive nextSkill = null)
        {
            if (this._currentSkill == null)
            {
                return;
            }
            
            // 先清除currentSkill，避免下面的逻辑反复进入该接口
            var currentSkill = this._currentSkill;
            this._currentSkill = null;
            this._currentSlot = null;
            
            // 清理连招数据
            if (skillLinkData != null)
            {
                bool openDodgeOffset = currentSkill != null && nextSkill != null && currentSkill.config.Type == SkillType.Attack && nextSkill.config.Type == SkillType.Dodge && nextSkill.config.DodgeOffset;
                if (openDodgeOffset)
                {
                    skillLinkData.EvalDodgeOffset();
                }
                else
                {
                    skillLinkData.Clear();
                }
            }
            //清除打断连招数据
            interruptLinkController.Clear();
            
            currentSkill.Stop(skillEndType);
            // 如果Stop接了另一个技能，这边不调用
            if (_currentSkill == null)
            {
                // 如果单位死亡了，技能结束不切换状态
                // 否则，单位技能状态结束，默认进入idle状态，动画就不正确了
                // TODO  老艾，这里帮状态机模块判断了状态，考虑挪入actor.mainState
                if (nextSkill == null && actor.mainState != null && !actor.isDead)
                {
                    PapeGames.X3.LogProxy.LogFormat("技能结束，动画状态机进入StopSkill");
                    actor.mainState.StopSkill();
                }
                else
                {
                    PapeGames.X3.LogProxy.LogFormat("技能结束");
                }
            }
        }

        // 清理掉技能的残留特效
        public void ClearSkillRemainFX()
        {
            foreach (var iter in _slots)
            {
                if (iter.Value.skill is SkillActive skillActive)
                {
                    skillActive.ClearRemainFX();
                }
            }
        }

        public void RemoveSkillSlot(int slotID)
        {
            _slots.TryGetValue(slotID, out var slot);
            if (slot == null)
            {
                LogProxy.LogErrorFormat("(slot id={0}) is not exist!", slotID);
                return;
            }

            // 主动技能走结束流程
            if (slot == _currentSlot)
            {
                TryEndSkill();
            }
            
            _slots.Remove(slotID);
            
            // 处理skillID2SlotID映射
            _skillID2SlotIDs.TryGetValue(slot.skill.config.ID, out var _slotIDs);
            if (_slotIDs != null)
            {
                _slotIDs.Remove(slotID);
            }
                
            // 销毁技能
            slot.skill.Destroy();
        }

        /// <summary>
        /// 技能状态能否被移动打断
        /// </summary>
        /// <returns></returns>
        public bool SkillCanMove()
        {
            if (_currentSkill == null)
            {
                return true;
            }

            return interruptLinkController.skillCanInterruptByMove;
        }

        // 获取技能槽位配置
        public Dictionary<int, SkillSlotConfig> GetAllSlotConfigs()
        {
            Dictionary<int, SkillSlotConfig> slotCfgs = null;
            if (actor.roleBornCfg != null)
            {
                slotCfgs = actor.roleBornCfg.SkillSlots;
            }

            if (slotCfgs == null)
            {
                slotCfgs = actor.config.SkillSlots;
            }

            return slotCfgs;
        }

        /// <summary>
        /// 通过技能ID去取SkillID 如果失败返回skillslotType.num
        /// </summary>
        /// <param name="skillID"></param>
        /// <returns></returns>
        public SkillSlotType GetTypeBySkillID(int skillID)
        {
            var slotId = GetSlotIDBySkillID(skillID);
            if (slotId == null)
            {
                return SkillSlotType.Num;
            }

            var slot = GetSkillSlot(slotId.Value);
            if (slot == null)
            {
                return SkillSlotType.Num;
            }
            return slot.slotType;
        }
    }
}