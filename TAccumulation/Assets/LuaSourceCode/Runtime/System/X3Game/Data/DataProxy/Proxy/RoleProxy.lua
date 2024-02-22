﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2022/5/11 14:49
---@class RoleProxy
local RoleProxy = class("RoleProxy", BaseProxy)

function RoleProxy:InitData(roles)
    if roles.RoleMap == nil then
        self.roleList = {}
    else
        self.roleList = roles.RoleMap
    end
    self.roleLastState = {}
    for k, v in pairs(self.roleList) do
        self.roleLastState[k] = v
    end
    if roles.StorySeriesMap == nil then
        self.storySeriesMap = {}
    else
        self.storySeriesMap = roles.StorySeriesMap
    end
    if roles.AccompanyMap == nil then
        self.AccompanyMap = {}
    else
        self.AccompanyMap = roles.AccompanyMap
    end
end

function RoleProxy:InitOtherData(roles)
    self.roleList = roles or {}
end

function RoleProxy:AddRole(role, callBack)
    if self.roleList[role.Id] ~= nil then
        if (not self.roleLastState[role.Id] or self.roleLastState[role.Id].Status == 0) and role.Status == 1 then
            --新男主解锁
            EventMgr.Dispatch("RoleUnlockEvent", role.Id)
            Debug.LogFormat("RoleUnlockEvent roleId=%s", role.Id)
            self.roleLastState[role.Id] = role
        end
        if self.roleList[role.Id].LoveLevel ~= role.LoveLevel or self.roleList[role.Id].LovePoint ~= role.LovePoint then
            self.roleLastState[role.Id] = self.roleList[role.Id]
            self.roleList[role.Id] = role
            if role.Status == 1 then
                if not self:IsShowTips(role.Id) then
                    return
                end
                local data = { roleID = role.Id, rolePre = self.roleLastState[role.Id], roleCur = self.roleList[role.Id] }
                if callBack then
                    callBack(role.Id, data)
                end
            end
        else
            self.roleList[role.Id] = role
        end
    end
end

function RoleProxy:IsShowTips(role_id)
    if not SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_LOVEPOINT) then
        return false
    end
    if not self:IsUnlocked(role_id) then
        return false
    end
    return true
end

function RoleProxy:ChangeRoleHeardCard(roleId, cardID)
    if self.roleList[roleId] then
        self.roleList[roleId].HeadCardID = cardID
    end
end

function RoleProxy:GetAccompanyMap()
    return self.AccompanyMap
end

function RoleProxy:GetCompanyData(roleID, createIfNoExist)
    local accompanyData = self.AccompanyMap[roleID]
    if not accompanyData and createIfNoExist then
        accompanyData = {  }
        self.AccompanyMap[roleID] = accompanyData
    end
    return accompanyData
end

---获得已解锁男主
function RoleProxy:GetRoleList()
    return self.roleList
end

---获得指定男主数据
function RoleProxy:GetRole(roleID)
    return self.roleList and self.roleList[roleID] or nil
end

---@param roleID int
---@return boolean
function RoleProxy:IsUnlocked(roleID)
    local role = self:GetRole(roleID)
    if role == nil then
        return false
    else
        return role.Status == 1
    end
end

function RoleProxy:SetRole(roleID, roleData)
    self.roleLastState[roleID] = self.roleList[roleID]
    self.roleList[roleID] = roleData
    BllMgr.GetLovePointBLL():GetLoveData():AddRoleData(roleID)
end

---获得男主总亲密度
function RoleProxy:GetTotalLovePoint()
    local point = 0
    for _, v in pairs(self.roleList) do
        if v.Status == 1 then
            point = point + v.LovePoint
        end
    end
    return point
end

return RoleProxy