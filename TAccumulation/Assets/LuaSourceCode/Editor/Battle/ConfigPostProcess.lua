---
---Created by xujie
---Date: 2020/12/2
---Time: 19:48
---
require("Editor.Battle.Common.EditorBattleUtil")
local ConfigPostProcess = {}

---@param actorConfig ActorConfig
function ConfigPostProcess.PrintActorDebugInfo(actorConfig)
    print(string.format("Actor(id=%d) SkillSlots:", actorConfig.ID))
    for k, slot in pairs(actorConfig.SkillSlots) do
        print(string.format("\tslot:ID=%d, SkillID=%d, SkillLevel=%d", slot.ID, slot.SkillID, slot.SkillLevel))
    end
end

---@param femaleConfigs table<Int, FemaleActorConfig>
---@param maleConfigs table<Int, MaleActorConfig>
---@param modelConfigs table<Int, ModelConfig>
---@return table<number, ActorConfig>
function ConfigPostProcess.RoleConfigPostProcess(femaleConfigs, maleConfigs, modelConfigs)
    ---@type table<number, RoleConfig>
    local ActorConfigs = {}
    for _, femaleConfig in pairs(femaleConfigs) do
        ---@type RoleConfig
        local ActorConfig = {}
        ActorConfig.ID = femaleConfig.FemaleBattleFashionID
        ActorConfig.Type = femaleConfig.Type
        ActorConfig.SubType = HeroSubType.Girl
        ActorConfig.Name = femaleConfig.Name
        ActorConfig.IconName = femaleConfig.IconName
        ActorConfig.ModelID = femaleConfig.ModelID
        ActorConfig.EditorVisible = femaleConfig.EditorVisible
        ActorConfig.AnimatorFilename = femaleConfig.AnimatorFilename
        ActorConfig.RMClipFilename = femaleConfig.RMClipFilename
        ActorConfig.TimelineEvent = femaleConfig.TimelineEvent
        ActorConfig.DisableRootMotion = femaleConfig.DisableRootMotion
        ActorConfig.RigidPoint = femaleConfig.RigidPoint
        ActorConfig.TalkAIName = femaleConfig.TalkAIName
        ActorConfig.BattleAIName = femaleConfig.BattleAIName
        ActorConfig.BattleAITriggerIDs = femaleConfig.BattleAITriggerIDs
        ActorConfig.TalkAITriggerIDs = femaleConfig.TalkAITriggerIDs
        ActorConfigs[femaleConfig.FemaleBattleFashionID] = ActorConfig
    end
    for _, maleConfig in pairs(maleConfigs) do
        ---@type RoleConfig
        local ActorConfig = {}
        ActorConfig.ID = maleConfig.BattleFashionID
        ActorConfig.Type = maleConfig.Type
        ActorConfig.SubType = HeroSubType.Boy
        ActorConfig.Name = maleConfig.Name
        ActorConfig.IconName = maleConfig.IconName
        ActorConfig.ModelID = maleConfig.ModelID
        ActorConfig.BattleType = maleConfig.BattleType
        ActorConfig.EditorVisible = maleConfig.EditorVisible
        ActorConfig.AnimatorFilename = maleConfig.AnimatorFilename
        ActorConfig.RMClipFilename = maleConfig.RMClipFilename
        ActorConfig.TimelineEvent = maleConfig.TimelineEvent
        ActorConfig.DisableRootMotion = maleConfig.DisableRootMotion
        ActorConfig.BattleCutScene = maleConfig.BattleCutScene
        ActorConfig.BattlePerform = maleConfig.BattlePerform
        ActorConfig.ComboSkillStarter = maleConfig.ComboSkillStarter
        ActorConfig.AttackIDs = {}
        ConfigPostProcess.CreateIdLevelData(ActorConfig.AttackIDs, maleConfig.AttackIDs)
        ActorConfig.ActiveSkillIDs = {}
        ConfigPostProcess.CreateIdLevelData(ActorConfig.ActiveSkillIDs, maleConfig.ActiveSkillIDs)
        ActorConfig.SpecialSkillIDs = {}
        ConfigPostProcess.CreateIdLevelData(ActorConfig.SpecialSkillIDs, maleConfig.SpecialSkillIDs)
        ActorConfig.PassiveSkillIDs = {}
        ConfigPostProcess.CreateIdLevelData(ActorConfig.PassiveSkillIDs, maleConfig.PassiveSkillIDs)
        ActorConfig.LoveSkillIDs = {}
        ConfigPostProcess.CreateIdLevelData(ActorConfig.LoveSkillIDs, maleConfig.LoveSkillIDs)
        ActorConfig.ComboSkillIDs = {}
        ConfigPostProcess.CreateIdLevelData(ActorConfig.ComboSkillIDs, maleConfig.ComboSkillIDs)
        ActorConfig.FemaleComboSkillIDs = {}
        ConfigPostProcess.CreateIdLevelData(ActorConfig.FemaleComboSkillIDs, maleConfig.FemaleComboSkillIDs)

        ActorConfig.CoopSkillIDs = {}
        ---ConfigPostProcess.CreateIdLevelData(ActorConfig.CoopSkillIDs, maleConfig.CoopSkillIDs)
        ActorConfig.CoopAtkIDs = {}
        local coopAtkIDs
        if maleConfig.CoopAtkIDs and #maleConfig.CoopAtkIDs == 2 then
            coopAtkIDs = { maleConfig.CoopAtkIDs[2] }
        else
            coopAtkIDs = {}
        end
        ConfigPostProcess.CreateIdLevelData(ActorConfig.CoopAtkIDs, coopAtkIDs)
        ActorConfig.UltraSkillIDs = {}
        ---ConfigPostProcess.CreateIdLevelData(ActorConfig.UltraSkillIDs, maleConfig.UltraSkillIDs)
        ActorConfig.DodgeSkillIDs = {}
        ConfigPostProcess.CreateIdLevelData(ActorConfig.DodgeSkillIDs, maleConfig.DodgeSkillIDs)
        ActorConfig.DeadSkillIDs = {}
        ConfigPostProcess.CreateIdLevelData(ActorConfig.DeadSkillIDs, maleConfig.DeadSkillIDs)
        ActorConfig.RigidPoint = maleConfig.RigidPoint
        ActorConfig.BattleAIName = maleConfig.BattleAIName
        ActorConfig.BattleAITriggerIDs = maleConfig.BattleAITriggerIDs
        ActorConfig.TalkAITriggerIDs = maleConfig.TalkAITriggerIDs
        ActorConfig.TalkAIName = maleConfig.TalkAIName
        ActorConfig.EnergyActionIDs = maleConfig.EnergyActionIDs
        ActorConfig.InitEnergy = maleConfig.InitEnergy
        ActorConfig.MaxEnergy = maleConfig.MaxEnergy
        ActorConfig.DynamicCastSlots = maleConfig.DynamicCastSlots
        ActorConfigs[maleConfig.BattleFashionID] = ActorConfig
    end
    for _, config in pairs(ActorConfigs) do
        local modelConfig = modelConfigs[config.ModelID]
        config.PrefabName = modelConfig.PrefabName
        config.Weight = modelConfig.Weight
        config.HurtBoxID = modelConfig.HurtBoxID
        config.ColliderID = modelConfig.ColliderID
        config.FxRadius = modelConfig.FxRadius
        config.FxHeight = modelConfig.FxHeight
        config.DummyCamMargin = modelConfig.DummyCamMargin
        config.TimelinePath = modelConfig.TimelinePath
        config.DummiesID = modelConfig.DummiesID
        config.HurtShakeName = modelConfig.HurtShakeName
        config.DisableHurtScar = modelConfig.DisableHurtScar
        config.FootEffect = modelConfig.FootEffect
        config.FashionID = modelConfig.FashionID
        config.WindFieldAssets = modelConfig.WindFieldAssets

        local turnAccelerationTime = FIntGet(modelConfig.TurnAccelerationTime)
        local maxTurnSpeed = FIntGet(modelConfig.MaxTurnSpeed)
        if turnAccelerationTime ~= 0 then
            config.TurnSpeedAcc = FIntM(1000 * maxTurnSpeed / turnAccelerationTime)
        else
            config.TurnSpeedAcc = FIntM(0)
        end
        config.MaxTurnSpeed = modelConfig.MaxTurnSpeed
        config.TurnAccelerationAngle = modelConfig.TurnAccelerationAngle
    end

    ---每个角色配置后处理
    for k, actorConfig in pairs(ActorConfigs) do
        BattleUtil.CreateSkillSlots(actorConfig, actorConfig)
        actorConfig.AttackIDs = nil
        actorConfig.ActiveSkillIDs = nil
        actorConfig.SpecialSkillIDs = nil
        actorConfig.PassiveSkillIDs = nil
        actorConfig.LoveSkillIDs = nil
        actorConfig.CoopSkillIDs = nil
        actorConfig.CoopAtkIDs = nil
        actorConfig.UltraSkillIDs = nil
        actorConfig.DodgeSkillIDs = nil
        actorConfig.QTEDodgeSkillIDs = nil
        actorConfig.ComboSkillIDs = nil
        actorConfig.DeadSkillIDs = nil
    end

    return ActorConfigs
end

---@param idLevelTb IDLevel[]
---@param idTb Int[]
function ConfigPostProcess.CreateIdLevelData(idLevelTb, idTb)
    for _, v in ipairs(idTb or {}) do
        ---@type IDLevel
        local skillIdLevel = {}
        skillIdLevel.ID = v
        skillIdLevel.Level = 1
        table.insert(idLevelTb, skillIdLevel)
    end
end

---@param configs table<number, ActorConfig>
---@param monsterTemplateConfigs table<number, MonsterTemplateConfig>
---@param monsterSummonConfigs table<number, MonsterSummonConfig>
function ConfigPostProcess.MonsterConfigPostProcess(
        configs,
        monsterTemplateConfigs,
        monsterSummonConfigs)
    configs = table.battleClone(configs)
    monsterTemplateConfigs = table.battleClone(monsterTemplateConfigs)
    monsterSummonConfigs = table.battleClone(monsterSummonConfigs)

    local summonTemplateIDs = {}
    for _, monsterSummonConfig in pairs(monsterSummonConfigs) do
        local monsterTemplateConfig = monsterTemplateConfigs[monsterSummonConfig.MonsterTemplateID]
        table.insert(summonTemplateIDs, monsterSummonConfig.MonsterTemplateID)
        ConfigPostProcess.OnMonsterSummon(configs, monsterSummonConfig, monsterTemplateConfig)
    end

    for _, monsterTemplateConfig in pairs(monsterTemplateConfigs) do
        if not summonTemplateIDs[monsterTemplateConfig.ID] then
            ConfigPostProcess.OnMonster(configs, monsterTemplateConfig)
        end
    end

    return configs
end


function ConfigPostProcess.GetSlotID(slotType, slotIndex)
    return (slotType - 1) * BattleConst.SkillSlotSpace + slotIndex
end

---@param configs table<number, ActorConfig>
---@param templateConfig MonsterTemplateConfig
function ConfigPostProcess.OnMonster(configs, templateConfig)
    if not templateConfig then
        error(string.format("怪物配置（Monster）：怪物（ID=%d）的模板（ID=%d）不存在，找【大侠】", monsterConfig.ID, monsterConfig.TemplateID))
        return
    end

    ---@type RoleConfig
    local actorConfig = {}
    actorConfig.ID = templateConfig.ID
    actorConfig.Type = ActorType.Monster
    actorConfig.SubType = templateConfig.Type
    actorConfig.Name = templateConfig.Name
    actorConfig.CommonName = templateConfig.CommonName
    actorConfig.CloseUpName = templateConfig.CloseUpName
    actorConfig.CloseUpBubble = templateConfig.CloseUpBubble
    actorConfig.DisableWeakUI = templateConfig.DisableWeakUI
    actorConfig.TalkAIMaleName = templateConfig.TalkAIMaleName
    actorConfig.TalkAIFemaleName = templateConfig.TalkAIFemaleName
    actorConfig.EditorVisible = templateConfig.EditorVisible
    actorConfig.HPVisible = templateConfig.HPVisible
    actorConfig.PrefabName = templateConfig.PrefabName
    actorConfig.DummiesID = templateConfig.DummiesID
    actorConfig.DummyCamMargin = templateConfig.DummyCamMargin
    actorConfig.HurtShakeName = templateConfig.HurtShakeName
    actorConfig.DisableHurtScar = templateConfig.DisableHurtScar
    actorConfig.DisableRootMotion = templateConfig.DisableRootMotion
    actorConfig.AnimatorFilename = templateConfig.AnimatorFilename
    actorConfig.RMClipFilename = templateConfig.RMClipFilename
    actorConfig.BattleAIName = templateConfig.BattleAIName
    actorConfig.TalkAIName = templateConfig.TalkAIName
    actorConfig.SkillIDs = {}
    actorConfig.SkillSlots = {}
    actorConfig.SkillLevels = {}
    actorConfig.FxRadius = templateConfig.FxRadius
    actorConfig.FxHeight = templateConfig.FxHeight
    actorConfig.TimelinePath = templateConfig.TimelinePath
    actorConfig.Weight = templateConfig.Weight
    actorConfig.HurtBoxID = templateConfig.HurtBoxID
    actorConfig.ColliderID = templateConfig.ColliderID
    actorConfig.BornTimeline = templateConfig.BornTimeline
    actorConfig.WideBornTimeline = templateConfig.WideBornTimeline
    actorConfig.BornEventTimeline = templateConfig.BornEventTimeline
    actorConfig.BornTime = templateConfig.BornTime
    actorConfig.DeadFreezeTime = templateConfig.DeadFreezeTime
    actorConfig.DeadEffect = templateConfig.DeadEffect
    actorConfig.DeadFXTime = templateConfig.DeadFXTime
    actorConfig.IconName = templateConfig.IconName
    ---actorConfig.RigidPoint = monsterConfig.RigidPoint
    ---actorConfig.ShieldInit = monsterConfig.ShieldInit
    ---actorConfig.ShieldMax = monsterConfig.ShieldMax
    ---actorConfig.ShieldRecoverTime = monsterConfig.ShieldRecoverTime
    ---actorConfig.EquipShield = monsterConfig.EquipShield
    actorConfig.TimelineEvent = templateConfig.TimelineEvent
    actorConfig.WeakRecoverTime = templateConfig.WeakRecoverTime
    actorConfig.TalkAITriggerIDs = templateConfig.TalkAITriggerIDs
    actorConfig.SummonMonsterIDs = templateConfig.SummonMonsterIDs
    actorConfig.TurnSpeedAcc = FIntM(0)
    if FIntGet(templateConfig.TurnAccelerationTime) ~= 0 then
        actorConfig.TurnSpeedAcc = FIntM(1000 * FIntGet(templateConfig.MaxTurnSpeed) / FIntGet(templateConfig.TurnAccelerationTime))
    end
    actorConfig.MaxTurnSpeed = templateConfig.MaxTurnSpeed
    actorConfig.TurnAccelerationAngle = templateConfig.TurnAccelerationAngle

    ConfigPostProcess.AddMonsterSkillSlots(actorConfig, templateConfig)

    actorConfig.DynamicCastSlots = templateConfig.DynamicCastSlots

    configs[actorConfig.ID] = actorConfig
end

---@param configs table<number, ActorConfig>
---@param monsterSummonConfig MonsterSummonConfig
---@param templateConfig MonsterTemplateConfig
function ConfigPostProcess.OnMonsterSummon(configs, monsterSummonConfig, templateConfig)
    if not monsterSummonConfig then
        error(string.format("召唤怪配置（MonsterSummon）：召唤怪（ID=%d）的模板（ID=%d）不存在，找【咸梨】", monsterSummonConfig.ID, monsterSummonConfig.MonsterTemplateID))
        return
    end

    if not templateConfig then
        error(string.format("怪物配置（Monster）：模板（ID=%d）不存在，找【咸梨】", templateConfig.ID))
        return
    end

    ---@type RoleConfig
    local actorConfig = {}
    actorConfig.ID = monsterSummonConfig.ID
    actorConfig.Type = ActorType.Monster
    actorConfig.SubType = templateConfig.Type
    actorConfig.Name = monsterSummonConfig.Name
    actorConfig.CommonName = templateConfig.CommonName
    actorConfig.CloseUpName = templateConfig.CloseUpName
    actorConfig.CloseUpBubble = templateConfig.CloseUpBubble
    actorConfig.DisableWeakUI = templateConfig.DisableWeakUI
    actorConfig.TalkAIMaleName = templateConfig.TalkAIMaleName
    actorConfig.TalkAIFemaleName = templateConfig.TalkAIFemaleName
    actorConfig.PrefabName = templateConfig.PrefabName
    ---actorConfig.RigidPoint = monsterConfig.RigidPoint
    actorConfig.BattleAIName = templateConfig.BattleAIName
    actorConfig.AnimatorFilename = templateConfig.AnimatorFilename
    actorConfig.SkillIDs = {}
    actorConfig.SkillSlots = {}
    actorConfig.SkillLevels = {}
    actorConfig.DummiesID = templateConfig.DummiesID
    actorConfig.FxRadius = templateConfig.FxRadius
    actorConfig.FxHeight = templateConfig.FxHeight
    actorConfig.Weight = templateConfig.Weight
    actorConfig.HurtBoxID = templateConfig.HurtBoxID
    actorConfig.ColliderID = templateConfig.ColliderID
    actorConfig.IconName = templateConfig.IconName
    actorConfig.HurtShakeName = templateConfig.HurtShakeName
    actorConfig.DisableHurtScar = templateConfig.DisableHurtScar
    actorConfig.DisableRootMotion = templateConfig.DisableRootMotion
    actorConfig.TimelineEvent = templateConfig.TimelineEvent
    actorConfig.BornTimeline = templateConfig.BornTimeline
    actorConfig.WideBornTimeline = templateConfig.WideBornTimeline
    actorConfig.BornEventTimeline = templateConfig.BornEventTimeline
    actorConfig.BornTime = templateConfig.BornTime
    actorConfig.DeadFreezeTime = templateConfig.DeadFreezeTime
    actorConfig.DeadEffect = templateConfig.DeadEffect
    actorConfig.DeadFXTime = templateConfig.DeadFXTime
    actorConfig.TalkAITriggerIDs = templateConfig.TalkAITriggerIDs
    actorConfig.EditorVisible = templateConfig.EditorVisible
    actorConfig.HPVisible = templateConfig.HPVisible
    actorConfig.TurnSpeedAcc = FIntM(0)
    if FIntGet(templateConfig.TurnAccelerationTime) ~= 0 then
        actorConfig.TurnSpeedAcc = FIntM(1000 * FIntGet(templateConfig.MaxTurnSpeed) / FIntGet(templateConfig.TurnAccelerationTime))
    end
    actorConfig.MaxTurnSpeed = templateConfig.MaxTurnSpeed
    actorConfig.TurnAccelerationAngle = templateConfig.TurnAccelerationAngle
    ConfigPostProcess.AddMonsterSkillSlots(actorConfig, templateConfig)

    actorConfig.LifeTime = monsterSummonConfig.LifeTime
    actorConfig.DeadWithMaster = monsterSummonConfig.DeadWithMaster
    actorConfig.MaxNum = monsterSummonConfig.MaxNum
    ---actorConfig.MonsterID = monsterSummonConfig.MonsterID
    actorConfig.DynamicCastSlots = templateConfig.DynamicCastSlots

    ---actorConfig.Source = monsterSummonConfig.Source
    ---actorConfig.HPScale = monsterSummonConfig.HPScale
    ---actorConfig.PhyAttackScale = monsterSummonConfig.PhyAttackScale
    ---actorConfig.PhyDefenceScale = monsterSummonConfig.PhyDefenceScale
    ---actorConfig.CritValScale = monsterSummonConfig.CritValScale
    ---actorConfig.ElementScale = monsterSummonConfig.ElementScale

    configs[actorConfig.ID] = actorConfig
end

---@param actorConfig RoleConfig
---@param templateConfig MonsterTemplateConfig
function ConfigPostProcess.AddMonsterSkillSlots(actorConfig, templateConfig)
    for i, skillID in ipairs(templateConfig.AttackIDs or {}) do
        ---@type IDLevel
        local skillIdLevel = {}
        skillIdLevel.ID = skillID
        skillIdLevel.Level = 1
        BattleUtil.AddSkillSlot(actorConfig, SkillSlotType.Attack, i, skillIdLevel)
    end

    for i, skillID in ipairs(templateConfig.ActiveSkillIDs or {}) do
        ---@type IDLevel
        local skillIdLevel = {}
        skillIdLevel.ID = skillID
        skillIdLevel.Level = 1
        BattleUtil.AddSkillSlot(actorConfig, SkillSlotType.Active, i, skillIdLevel)
    end

    for i, skillID in ipairs(templateConfig.DeadSkillIDs or {}) do
        ---@type IDLevel
        local skillIdLevel = {}
        skillIdLevel.ID = skillID
        skillIdLevel.Level = 1
        BattleUtil.AddSkillSlot(actorConfig, SkillSlotType.Dead, i, skillIdLevel)
    end
end

---@param skillConfigs table<Int, SkillConfig>
---@param skillLevelConfigs table<Int, SkillLevelConfig[]>
---@param skillPassiveConfigs table<Int, SkillPassiveConfig[]>
function ConfigPostProcess.SkillConfigPostProcess(skillConfigs, skillLevelConfigs, skillPassiveConfigs)
    skillConfigs = table.battleClone(skillConfigs)
    skillLevelConfigs = table.battleClone(skillLevelConfigs)
    skillPassiveConfigs = table.battleClone(skillPassiveConfigs)
    for k, skillConfig in pairs(skillConfigs) do
        if skillConfig.AimOnCast == 0 then
            skillConfig.AimOnCast = nil
        end

        if not skillConfig.Time and skillConfig.Frame then
            skillConfig.Time = math.floor(skillConfig.Frame * 0.333333)
        end

        skillConfig.levelConfigs = skillLevelConfigs[skillConfig.ID]
        if not skillConfig.levelConfigs then
            error(string.format("技能配置（SkillConfig)：技能(id=%d)的等级配置，在技能等级配置（SkillLevelConfig）中没有找到！请找策划！", skillConfig.ID))
        end
    end

    for k, passiveConfigs in pairs(skillPassiveConfigs) do
        for i, passiveConfig in ipairs(passiveConfigs) do
            ConfigPostProcess.OnSkillPassiveConfig(skillConfigs, passiveConfig)
        end
    end
    return skillConfigs
end

---@param skillConfigs table<Int, SkillConfig>
---@param passiveConfig SkillPassiveConfig
function ConfigPostProcess.OnSkillPassiveConfig(skillConfigs, passiveConfig)

    local skillConfig = skillConfigs[passiveConfig.SkillID]
    if not skillConfig then
        ---@type SkillConfig
        skillConfig = {}
        skillConfig.ID = passiveConfig.SkillID
        skillConfig.Name = passiveConfig.Name
        skillConfig.SkillIcon = passiveConfig.SkillIcon
        skillConfig.SkillType = passiveConfig.SkillType
        skillConfig.levelConfigs = {}
        skillConfigs[skillConfig.ID] = skillConfig
    end

    local levelConfig = skillConfig.levelConfigs[passiveConfig.Level]
    if not levelConfig then
        ---@type SkillLevelConfig
        levelConfig = {}
        levelConfig.Level = passiveConfig.Level
        levelConfig.Desc = passiveConfig.Desc
        skillConfig.levelConfigs[levelConfig.Level] = levelConfig
    end

    levelConfig.BuffIDs = passiveConfig.AddBuff
    levelConfig.BuffLevels = passiveConfig.AddBuffLevel
    levelConfig.BuffMountTypes = passiveConfig.MountType
end

---@param battleLevelConfigs table<Int, BattleLevelConfig>
---@param battleLevelEXLConfigs table<Int, BattleLevelEXLConfig>
function ConfigPostProcess.BattleLevelPostProcess(battleLevelConfigs, battleLevelEXLConfigs)
    battleLevelEXLConfigs = table.battleClone(battleLevelEXLConfigs)

    for k, config in pairs(battleLevelEXLConfigs) do
        ---@type BattleLevelConfig
        local battleLevelConfig = {}
        battleLevelConfig.ID = config.ID
        battleLevelConfig.Name = config.Name
        battleLevelConfig.SceneName = config.SceneName
        battleLevelConfig.WwiseIDs = config.WwiseIDs
        battleLevelConfig.BackgroundMusic = config.BackgroundMusic
        battleLevelConfig.LogicFilename = config.LogicFilename
        battleLevelConfig.Visible = config.Visible
        battleLevelConfig.TimeLimit = config.TimeLimit
        battleLevelConfig.TimeLimitType = config.TimeLimitType
        battleLevelConfig.PlayerIndex = config.PlayerIndex
        battleLevelConfig.ElementType = config.ElementType
        battleLevelConfig.ElementRatio = config.ElementRatio
        battleLevelConfig.FinalDmgAddRate = config.FinalDmgAddRate
        battleLevelConfig.AirWallID = config.AirWallID or 1
        battleLevelConfig.CloseCut = config.CloseCut or false
        battleLevelConfig.SceneGroundHeight = config.SceneGroundHeight

        battleLevelConfig.StageID = config.StageID
        battleLevelConfigs[battleLevelConfig.ID] = battleLevelConfig
    end

    return battleLevelConfigs
end

---返回table的克隆
---@param object table
---@return table
function table.battleClone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return new_table
    end
    return _copy(object)
end

return ConfigPostProcess