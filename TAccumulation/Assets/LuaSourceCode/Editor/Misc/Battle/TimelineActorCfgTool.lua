﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by PC.
--- DateTime: 19/5/2021 下午2:48
---
require("Editor.Battle.Common.EditorBattleEnum")
require("Editor.Battle.Common.EditorBattleUtil")
--require("Runtime.System.Framework.GameBase.Runtime.System.X3Game.UI.UIUtil")
require("Runtime.System.X3Game.Modules.GameMisc.GameMgr")
require("Runtime.System.Framework.GameBase.LuaComp.CSTypeConst")
local RoleActorType = {
    Female = 1,
    Male = 2,
    Monster = 3,
}

local TimelineActorCfgTool = {}

-- 获取所有的技能列表
TimelineActorCfgTool.GetSkillEditorDatas = function()
    local skillConfigs = LuaCfgMgr.GetAll("Battle.Config.SkillConfig")
    local skillIDs = {}
    for _, skillConfig in pairs(skillConfigs) do
        table.insert(skillIDs, skillConfig.ID)
    end
    return CS.BattleTimelineEditor.LuaDataUtil.GeneraSkillEditorDatas({
        excelSkillIDs = skillIDs,
    })
end

-- 生成C#用的数据
TimelineActorCfgTool.GenerateTimelineActorConfigs = function()
    local cfgs = TimelineActorCfgTool.GetTimelineActorConfigs()
    local sceneList = TimelineActorCfgTool.GetSceneConfigs()
    return CS.BattleTimelineEditor.LuaDataUtil.GeneraTimelineActorCallByLua({
        list = cfgs,
        sceneList = sceneList,
    })
end

function TimelineActorCfgTool.GetSceneConfigs()
    local sceneCfgs = LuaCfgMgr.GetAll("BattleEditorScene")
    if not sceneCfgs then
        sceneCfgs = LuaCfgMgr.GetAll("Battle.Config.BattleEditorScene")
    end
    local returnData = {}
    for _, v in pairs(sceneCfgs) do
        table.insert(returnData, {
            name = v.SceneName,
            path = v.ScenePath,
        })
    end
    return returnData
end

---@return TimelineActorConfig[]
function TimelineActorCfgTool.GetTimelineActorConfigs()
    local tiemlineActorCfgs = {}
    local editorCfgs = LuaCfgMgr.GetAll("BattleEditorConfig")
    if not editorCfgs then
        editorCfgs = LuaCfgMgr.GetAll("Battle.Config.BattleEditorConfig")
    end
    for _, v in pairs(editorCfgs) do
        local timelineActorCfg = TimelineActorCfgTool.GenerateTimelineActorCfg(v)
        if timelineActorCfg and next(timelineActorCfg) then
            table.insert(tiemlineActorCfgs, timelineActorCfg)
        end
    end
    table.sort(tiemlineActorCfgs, function(a, b)
        return a.id < b.id
    end)
    return tiemlineActorCfgs
end

---@return CS.TimelineActorConfig
function TimelineActorCfgTool.GenerateTimelineActorCfg(editorCfg)
    -- 基础信息
    local actorCfg = {}
    actorCfg.type = editorCfg.RoleType
    actorCfg.id = editorCfg.ID
    actorCfg.isSuitModel = editorCfg.IsSuitModel  -- 是suit，没modelName
    actorCfg.modelName = editorCfg.ModelName
    actorCfg.suitKey = editorCfg.SuitKey
    actorCfg.dummiesID = editorCfg.DummiesID
    actorCfg.description = string.format("%d %s", actorCfg.id, editorCfg.RoleName)
    -- 处理timeline配置
    actorCfg.timelineDirectory = BattleClientUtil.GetTimelineDirectory(editorCfg.TimelinePath)
    actorCfg.timelineAssetDirectory = "Assets/Build/Art/Timeline/PlayableAssets/" .. editorCfg.TimelinePath
    -- 处理技能信息
    if editorCfg.RoleType == RoleActorType.Female then
        TimelineActorCfgTool.EvalFemaleTimelineActorCfg(editorCfg, actorCfg)
    elseif editorCfg.RoleType == RoleActorType.Male then
        TimelineActorCfgTool.EvalMaleTimelineActorCfg(editorCfg, actorCfg)
    elseif editorCfg.RoleType == RoleActorType.Monster then
        TimelineActorCfgTool.EvalMonsterTimelineActorCfg(editorCfg, actorCfg)
    end
    return actorCfg
end

-- 生成女主信息
---@return CS.TimelineActorConfig
function TimelineActorCfgTool.EvalFemaleTimelineActorCfg(editorCfg, actorCfg)
    local weaponSkinCfg = LuaCfgMgr.Get("Battle.Config.WeaponSkinConfig", editorCfg.WeaponID)
    local skillIds = {}
    for _, id in ipairs(weaponSkinCfg and weaponSkinCfg.ActiveSkillIDs or {}) do
        table.insert(skillIds, id)
    end
    for _, id in ipairs(weaponSkinCfg and weaponSkinCfg.AttackIDs or {}) do
        table.insert(skillIds, id)
    end
    for _, id in ipairs(weaponSkinCfg and weaponSkinCfg.ComboSkillIDs or {}) do
        table.insert(skillIds, id)
    end
    for _, id in ipairs(weaponSkinCfg and weaponSkinCfg.DodgeSkillIDs or {}) do
        table.insert(skillIds, id)
    end
    for _, id in ipairs(weaponSkinCfg and weaponSkinCfg.SpecialSkillIDs or {}) do
        table.insert(skillIds, id)
    end
    -- 技能信息
    local skills = TimelineActorCfgTool.GenerateSkillCfgs(skillIds, true)
    actorCfg.skills = skills
end

-- 生成男主信息
---@return CS.TimelineActorConfig
function TimelineActorCfgTool.EvalMaleTimelineActorCfg(editorCfg, actorCfg)
    local manCfg = LuaCfgMgr.Get("Battle.Config.ActorConfig", editorCfg.RoleID)
    if manCfg == nil then
        Debug.Log(string.format("RoleID（ID=%d）对应的角色不存在，请联系策划！", editorCfg.RoleID))
        actorCfg.skills = {}
        return
    end
    local skills = TimelineActorCfgTool.GenerateSkillCfgs(manCfg.SkillIDs)
    actorCfg.skills = skills
end

-- 生成Monster信息
---@return CS.TimelineActorConfig
function TimelineActorCfgTool.EvalMonsterTimelineActorCfg(editorCfg, actorCfg)
    TimelineActorCfgTool.EvalMaleTimelineActorCfg(editorCfg, actorCfg)
end

-- 生成skill信息
---@return CS.SkillConfig[]
function TimelineActorCfgTool.GenerateSkillCfgs(skillIds, containsLink)
    skillIds = skillIds or {}
    if containsLink then
        local newSkillIds = {}
        -- 先补全连接技能
        for _, id in ipairs(skillIds) do
            table.insert(newSkillIds, id)
            local skillCfg = LuaCfgMgr.Get("Battle.Config.SkillConfig", id)
            while skillCfg and skillCfg.LinkSkillID and skillCfg.LinkSkillID ~= 0 do
                table.insert(newSkillIds, skillCfg.LinkSkillID)
                skillCfg = LuaCfgMgr.Get("Battle.Config.SkillConfig", skillCfg.LinkSkillID)
            end
        end
        skillIds = newSkillIds
    end
    local idSet = {}
    local skillCfgs = {}
    for _, id in ipairs(skillIds) do
        if not idSet[id] then
            -- 这一步是为了去重
            idSet[id] = true
            local cfg = LuaCfgMgr.Get("Battle.Config.SkillConfig", id)
            if not cfg then
                Debug.LogError(string.format("Skill（ID=%d）对应的技能不存在，请联系策划！", id))
                return skillCfgs
            end
            if cfg.Timeline and cfg.Timeline ~= "" then
                table.insert(skillCfgs, {
                    id = cfg.ID,
                    description = string.format("%d %s", cfg.ID, cfg.Name),
                    timelinePath = BattleClientUtil.GetTimelinePath(cfg.Timeline),
                })
            end
        end
    end
    return skillCfgs
end

return TimelineActorCfgTool