﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/6/10 1:04
---场上目标过滤
---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.CatCardBaseAction
local BaseAction = require(CatCardConst.BASE_ACTION_PATH_NEW)
---@class CatCard.TargetFilterAction:CatCard.CatCardBaseAction
local TargetFilterAction = class("TargetFilterAction", BaseAction)
function TargetFilterAction:ctor()
    BaseAction.ctor(self)
    self.isGenerated = false
end
---@param action_data CatCard.TargetFilterActionData
function TargetFilterAction:Begin(action_data)
    self.isGenerated = false
    self:GenTargetMap(action_data)
    self.isGenerated = true
end

---@param func fun(type:CatCardConst.CardType,type:int,type:CatCardConst.PlayerType)
function TargetFilterAction:Foreach(func)
    return self:GetData():Foreach(func)
end

---@param action_data CatCard.TargetFilterActionData
function TargetFilterAction:GenTargetMap(action_data)
    local target_owner = action_data:GetTargetOwner()
    if target_owner == CatCardConst.SelectTargetOwner.All then
        target_owner = nil
    end
    local target_map = action_data:GetTargetMap()
    if target_map then
        PoolUtil.ReleaseTable(target_map)
    end
    action_data:SetTargetMap(nil)
    local target_map = PoolUtil.GetTable()
    for card_type, _ in pairs(action_data:GetCardTypeMap()) do
        local data_list = self.bll:GetDataList(card_type, card_type == CatCardConst.CardType.CARD and target_owner or nil)
        for k, v in pairs(data_list) do
            if self:IsTargetValid(card_type, v:GetIndex(), v:GetPlayerType()) then
                if not target_map[card_type] then
                    target_map[card_type] = PoolUtil.GetTable()
                end
                target_map[card_type][v:GetIndex()] = true
            end
        end
        PoolUtil.ReleaseTable(data_list)
    end
    action_data:SetTargetMap(target_map)
end

---@param card_type CatCardConst.CardType
---@param index int
---@param player_type CatCardConst.PlayerType
---@return boolean
function TargetFilterAction:IsTargetValid(card_type, index, player_type)
    ---@type CatCard.TargetFilterActionData
    local action_data = self:GetData()
    if self.isGenerated then
        return action_data:IsTargetValid(card_type, index, player_type)
    end
    ---筛选类型
    if not action_data:IsTargetTypeEnable(card_type) then
        return false
    end
    ---检测filter
    ---检测归属
    if action_data:IsFilterEnable(CatCardConst.SelectTargetFilterType.FilterByOwner) then
        local owner = action_data:GetTargetOwner()
        if card_type == CatCardConst.CardType.CARD then
            if owner == CatCardConst.SelectTargetOwner.Player then
                if player_type ~= CatCardConst.PlayerType.PLAYER then
                    return false
                end
            elseif owner == CatCardConst.SelectTargetOwner.Enemy then
                if player_type ~= CatCardConst.PlayerType.ENEMY then
                    return false
                end
            end
        else
            if player_type ~= nil and player_type~=-1 then
                if owner == CatCardConst.SelectTargetOwner.Player then
                    if player_type ~= CatCardConst.PlayerType.PLAYER then
                        return false
                    end
                elseif owner == CatCardConst.SelectTargetOwner.Enemy then
                    if player_type ~= CatCardConst.PlayerType.ENEMY then
                        return false
                    end
                end
            end
            
        end

    end

    ---检测属性相关
    if card_type == CatCardConst.CardType.SLOT then
        ---检测格子属性
        ---@type SlotData
        local data = self.bll:GetData(card_type, index)
        if action_data:IsFilterEnable(CatCardConst.SelectTargetFilterType.OccupySlot) and action_data:IsFilterEnable(CatCardConst.SelectTargetFilterType.EmptySlot) then
        elseif action_data:IsFilterEnable(CatCardConst.SelectTargetFilterType.OccupySlot) then
            if not data:IsOccupied() then
                return false
            end
        elseif action_data:IsFilterEnable(CatCardConst.SelectTargetFilterType.EmptySlot) then
            if data:IsOccupied() then
                return false
            end
        end
    elseif card_type == CatCardConst.CardType.CARD then
        ---检测卡
        ---@type CatCardData
        local data = self.bll:GetData(card_type, index, player_type)
        if not data then
            return false
        end
        if action_data:IsFilterEnable(CatCardConst.SelectTargetFilterType.NumCard) and action_data:IsFilterEnable(CatCardConst.SelectTargetFilterType.FuncCard) then
        elseif action_data:IsFilterEnable(CatCardConst.SelectTargetFilterType.NumCard) then
            if data:IsFuncCard() then
                return false
            end
        elseif action_data:IsFilterEnable(CatCardConst.SelectTargetFilterType.FuncCard) then
            if not data:IsFuncCard() then
                return false
            end

            ---判断是否出功能牌阶段有冰冻喵buff
            local pop_st = self.bll:GetStateData():GetPopState()
            if pop_st == CatCardConst.PopCardState.PopFuc and self.bll:HasBuff(CatCardConst.BuffType.FrozenCard,CatCardConst.PlayerType.PLAYER) then
                return false
            end

        end
    end
    return true
end
return TargetFilterAction