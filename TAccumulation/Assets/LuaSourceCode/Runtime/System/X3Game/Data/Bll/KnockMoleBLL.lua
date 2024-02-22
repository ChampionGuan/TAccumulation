﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by muchen.
--- DateTime: 2023/10/24 15:05
---@class KnockMoleBLL
local KnockMoleBLL = class("KnockMoleBLL", BaseBll)

function KnockMoleBLL:OnInit()

end

function KnockMoleBLL:OnClear()

end

---获取当前男主所有难度关卡
---@param roleId int roleId
---@return table<cfg.ActivityGameGroup>
function KnockMoleBLL:GetActivityGameGroupCfgListByRoleId(roleId, activityId)
    local ret = {}
    local activityGamePlayCfg = LuaCfgMgr.Get("ActivityGamePlay", activityId, roleId)
    if activityGamePlayCfg == nil then
        Debug.LogWarning("KnockMoleBLL GetActivityGameGroupCfg activityGamePlayCfg is nil roleId:", roleId, " activityId:", activityId)
        return ret
    end
    local condition = PoolUtil.GetTable()
    condition.GroupID = activityGamePlayCfg.GameGroup
    local activityGameGroupCfgList = LuaCfgMgr.GetListByCondition("ActivityGameGroup", condition)
    PoolUtil.ReleaseTable(condition)
    local firstActivityGameGroupCfg = nil
    local preIDByIdDic = {}
    for k, v in pairs(activityGameGroupCfgList) do
        local condition = PoolUtil.GetTable()
        condition.Group = v.DifficultGroupID
        condition.ManType = roleId
        local knockMoleDifficultyCfg = LuaCfgMgr.GetDataByCondition("KnockMoleDifficulty", condition)
        PoolUtil.ReleaseTable(condition)
        if knockMoleDifficultyCfg and ConditionCheckUtil.CheckConditionByCommonConditionGroupId(knockMoleDifficultyCfg.ShowCondition) then
            if v.PreID == 0 then
                firstActivityGameGroupCfg = v
            else
                preIDByIdDic[v.PreID] = v.ID
            end
        end
    end
    if firstActivityGameGroupCfg == nil then
        Debug.LogWarning("KnockMoleBLL GetActivityGameGroupCfg firstActivityGameGroupCfg is nil roleId:", roleId, " activityId:", activityId)
        return ret
    end
    table.insert(ret, firstActivityGameGroupCfg)
    while (firstActivityGameGroupCfg ~= nil and preIDByIdDic[firstActivityGameGroupCfg.ID] ~= nil) do
        firstActivityGameGroupCfg = LuaCfgMgr.Get("ActivityGameGroup", preIDByIdDic[firstActivityGameGroupCfg.ID])
        table.insert(ret, firstActivityGameGroupCfg)
    end
    return ret
end

---@param activityGameGroupList  table<cfg.ActivityGameGroup>
---@return table<cfg.KnockMoleDifficulty> 打地鼠难度关卡信息
function KnockMoleBLL:GetKnockMoleDifficultyCfgList(activityGameGroupList, roleId)
    local ret = {}
    for i = 1, #activityGameGroupList do
        local condition = PoolUtil.GetTable()
        condition.Group = activityGameGroupList[i].DifficultGroupID
        condition.ManType = roleId
        local tempCfg = LuaCfgMgr.GetDataByCondition("KnockMoleDifficulty", condition)
        table.insert(ret, tempCfg)
    end
    return ret
end

---判断打地鼠关卡是否开启
---@param knockMoleDifficultyId int
---@return boolean
function KnockMoleBLL:CheckKnockMoleDifficultyOpenCondition(knockMoleDifficultyId)
    local knockMoleDifficultyCfg = LuaCfgMgr.Get("KnockMoleDifficulty", knockMoleDifficultyId)
    if knockMoleDifficultyCfg then
        if knockMoleDifficultyCfg.OpenCondition == 0 or ConditionCheckUtil.CheckConditionByCommonConditionGroupId(knockMoleDifficultyCfg.OpenCondition) then
            return true
        end
    end
    return false
end

function KnockMoleBLL:GamePlayPause()
    if GamePlayMgr.GetController() then
        GamePlayMgr.GetController():GamePlayPause(true)
    end
end

function KnockMoleBLL:GamePlayResume()
    if GamePlayMgr.GetController() then
        GamePlayMgr.GetController():GamePlayResume(true)
    end
end

function KnockMoleBLL:GamePlayFinish()
    if GamePlayMgr.GetController() then
        GamePlayMgr.GetController():Finish()
    end
end

function KnockMoleBLL:KnockMoleEnd(isGiveUp)
    if GamePlayMgr.GetController() then
        GamePlayMgr.GetController():End(isGiveUp)
    end
end

---打地鼠结算
---@param isGiveUp bool  是否提前放弃
---@param enterType Define.GamePlayEnterType  进入类型
---@param score int 结果提交
function KnockMoleBLL:SendGetKnockMoleReward(isGiveUp, enterType, score)
    local messageBody = PoolUtil.GetTable()
    messageBody.IsGiveUp = isGiveUp
    messageBody.EnterType = enterType
    messageBody.Score = score
    GrpcMgr.SendRequest(RpcDefines.GetKnockMoleRewardRequest, messageBody, true)
    PoolUtil.ReleaseTable(messageBody)
end

return KnockMoleBLL