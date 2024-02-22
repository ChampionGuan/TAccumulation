﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by JianXin.
--- DateTime: 2021/3/19 14:21
---

----角色更换日常装 功能脚本
---@class RoleFashionUtil
local RoleFashionUtil = class("RoleFashionUtil")

---@type table 所有皮肤数据
local allFashionData = {}
---@type table 所有默认服装信息
local fashionDefaultDatas = {}
---@type table 默认服装 按照【角色】【部位】来区分
local roleDefaultFashionID = {}
---@type table 所有默认服装  k:fashionID v:true
local allDefaultFashionID = {}

function RoleFashionUtil.Init()
    allFashionData = LuaCfgMgr.GetAll("FashionData")
    fashionDefaultDatas = LuaCfgMgr.GetAll("FashionDefault")
    local roleInfos = LuaCfgMgr.GetAll("RoleInfo")
    for i, v in pairs(roleInfos) do
        RoleFashionUtil.SetDefaultFashionDataWithRoleID(v.ID)
    end
    RoleFashionUtil.SetDefaultFashionDataWithRoleID(0)
end

---@private
function RoleFashionUtil.SetDefaultFashionDataWithRoleID(roleID)
    if not roleDefaultFashionID[roleID] then
        roleDefaultFashionID[roleID] = {}
    end
    for k, v in pairs(fashionDefaultDatas) do
        if v.Role == roleID then
            roleDefaultFashionID[roleID][v.Part] = v.DefaultFashion
        end
        allDefaultFashionID[v.DefaultFashion] = true
    end
end

---@public
function RoleFashionUtil.GetDefaultFashionDataWithRoleID(roleID, partEnum)
    return roleDefaultFashionID[roleID][partEnum]
end

---@private
function RoleFashionUtil.UnfixPart(roleID, curFashionTab, partEnum)
    curFashionTab[partEnum] = RoleFashionUtil.GetDefaultFashionDataWithRoleID(roleID, partEnum)
    return curFashionTab
end

---角色换装通用接口
---@param roleID int 角色ID
---@param curFashionTab table 当前角色装备的fashion列表
---@param equipFashionID int  需要装备的皮肤
---@return  table 已经处理好的fashion列表
function RoleFashionUtil.EquipPartWithFashion(roleID, curFashionTab, equipFashionID)
    local equipFashionData = allFashionData[equipFashionID]
    local equipPartEnum = equipFashionData.PartEnum
    local isHaveUnfixPartTab, unfixPartTab, unfixFashionIDTab = RoleFashionUtil.IsAgainstInEquipTab(curFashionTab, equipFashionID)
    if isHaveUnfixPartTab then
        for i, v in ipairs(unfixPartTab) do
            curFashionTab = RoleFashionUtil.UnfixPart(roleID, curFashionTab, v)
        end
        for i, v in ipairs(unfixFashionIDTab) do
            local partEnum = allFashionData[v].PartEnum
            curFashionTab = RoleFashionUtil.UnfixPart(roleID, curFashionTab, partEnum)
        end
    end
    curFashionTab[equipPartEnum] = equipFashionID
    return curFashionTab
end

---判断时装与 当前时装列表是否互斥 ，并返回互斥列表
---@param curFashionTab table 当前时装列表
---@param equipFashionID int 需要装备时装
---@return  bool  是否互斥
---@return  table 互斥部位列表
---@return  table 互斥fashionID列表
function RoleFashionUtil.IsAgainstInEquipTab(curFashionTab, equipFashionID)
    local unfixPartTab = {}
    local unfixFashionIDTab = {}
    local equipFashionData = allFashionData[equipFashionID]
    local equipPartEnum = equipFashionData.PartEnum
    local isDefault = RoleFashionUtil.IsDefaultWithFashion(equipFashionID)
    if isDefault then
        return #unfixPartTab > 0, unfixPartTab
    end

    ---检查当前装备的部位互斥关系
    if equipFashionData.AgainstPart ~= nil then
        for i, v in ipairs(equipFashionData.AgainstPart) do
            local isDefault = RoleFashionUtil.IsDefaultWithFashion(curFashionTab[v])
            if not isDefault then
                unfixPartTab[#unfixPartTab + 1] = v
            end
        end
    end

    ---检查当前装备的皮肤互斥关系
    if equipFashionData.AgainstFashion ~= nil then
        for i, v in ipairs(equipFashionData.AgainstFashion) do
            local isDefault = RoleFashionUtil.IsDefaultWithFashion(v)
            for k, v1 in pairs(curFashionTab) do
                if v == v1 and not isDefault then
                    unfixFashionIDTab[#unfixFashionIDTab + 1] = v
                end
            end
        end
    end

    ---当前装备列表与需要装备的fashion是否有互斥关系
    for k, id in pairs(curFashionTab) do
        local fashionData = allFashionData[id]
        local isDefault = RoleFashionUtil.IsDefaultWithFashion(curFashionTab[id])
        if not isDefault and fashionData.AgainstPart ~= nil then
            for i, part in ipairs(fashionData.AgainstPart) do
                if part == equipPartEnum then
                    if not table.indexof(unfixPartTab, fashionData.PartEnum) then
                        unfixPartTab[#unfixPartTab + 1] = fashionData.PartEnum
                    end
                end
            end
        end
        if not isDefault and fashionData.AgainstFashion ~= nil then
            for i, v in ipairs(fashionData.AgainstFashion) do
                if v == equipFashionID then
                    if not table.indexof(unfixFashionIDTab, v) then
                        unfixFashionIDTab[#unfixFashionIDTab + 1] = id
                    end
                end
            end
        end
    end
    local isUnfix = #unfixPartTab > 0 or #unfixFashionIDTab > 0
    return isUnfix, unfixPartTab, unfixFashionIDTab
end

---获取当前列表所包含的部件列表
---@param curFashionTab table 当前时装列表
---@return table 部件列表
function RoleFashionUtil.GetPartListWithFashionIDTab(curFashionTab)
    local partList = {}
    for k, id in pairs(curFashionTab) do
        local fashionData = allFashionData[id]
        if fashionData.PartList ~= nil then
            for i, partStr in ipairs(fashionData.PartList) do
                partList[#partList + 1] = partStr
            end
        end
    end
    return partList
end

---判断当前皮肤是否是默认服装
---@param fashionID int 服装id
---@return boolean 是否是默认
function RoleFashionUtil.IsDefaultWithFashion(fashionID)
    return allDefaultFashionID[fashionID] or false
end

RoleFashionUtil.Init()
return RoleFashionUtil



