﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by muchen.
--- DateTime: 2021/7/9 15:28
---@class StageMonsterUtil
local StageMonsterUtil = class("StageMonsterUtil")
---@param stageId number
---@return Battle.Config.MonsterTemplate
function StageMonsterUtil.GetStageMonsterCfg(stageId)
    local retMonsterTemplateCfg = nil
    local retMonsterCfg=nil
    local stageCfg = LuaCfgMgr.Get("CommonStageEntry", stageId)
    if stageCfg == nil then
        return retMonsterCfg
    end
    local monsterIds = BattleForSystem.GetBattleLevelMonsterIDs(stageId)
    if #monsterIds > 0 then
        for i = 1, #monsterIds do
            local tempData = BattleForSystem.GetMonsterTemplate(monsterIds[i])
            if tempData ~= nil then
                local tempInfo = BattleForSystem.GetMonsterTemplate(tempData.ID)
                if retMonsterTemplateCfg == nil or retMonsterTemplateCfg.Rate < tempInfo.Rate then
                    retMonsterTemplateCfg = tempInfo
                    retMonsterCfg=tempData
                end
            end
        end
    end
    return retMonsterTemplateCfg,retMonsterCfg
end
---@param Cfg_CommonStageEntry stageCfg
---@return Define.StageLimitType
function StageMonsterUtil.GetCommonStageEntryLimitType(Cfg_CommonStageEntry)
    if Cfg_CommonStageEntry.TeamAllLimit then
        return Define.StageLimitType.All
    end
    if Cfg_CommonStageEntry.TeamLimit and #Cfg_CommonStageEntry.TeamLimit > 0 then
        return Define.StageLimitType.SCore
    end
    if Cfg_CommonStageEntry.TeamCardLimit and #Cfg_CommonStageEntry.TeamCardLimit > 0 then
        return Define.StageLimitType.Card
    end
    if Cfg_CommonStageEntry.TeamWeaponLimit and #Cfg_CommonStageEntry.TeamWeaponLimit > 0 then
        return Define.StageLimitType.Weapon
    end
    return Define.StageLimitType.None
end
return StageMonsterUtil