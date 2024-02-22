﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by deling.
--- DateTime: 2022/7/10 16:58
---

local PurikuraProcessDecorate = class("PurikuraProcessDecorate")
local PurikuraConstNew = require "Runtime.System.X3Game.Modules.PurikuraNew.PurikuraConstNew"

function PurikuraProcessDecorate:ctor()
    self.decorate = {} --1~4为男性饰品，5~8为女性饰品
    self:_InitDecorate()
end

function PurikuraProcessDecorate:GetList()
    return self.decorate
end

function PurikuraProcessDecorate:GetListByMode(mode)
    --Female = 0,  --女单
    --Male = 1,    --男单
    --Double = 2,  --双人模式
    local result = {}
    for i = 1, #self.decorate do
        if self.decorate[i].Value then
            if mode == PurikuraConstNew.StickerMode.Double then
                table.insert(result, self.decorate[i].Value)
            elseif i > 4 and mode == PurikuraConstNew.StickerMode.Female then
                table.insert(result, self.decorate[i].Value)
            elseif i < 5 and mode == PurikuraConstNew.StickerMode.Male then
                table.insert(result, self.decorate[i].Value)
            end
        end
    end

    return result
end

function PurikuraProcessDecorate:GetDecorate(index)
    return self.decorate[index]
end

---新增配饰
function PurikuraProcessDecorate:AddDecorate(value, sex)
    if sex == Define.Sex.Male then
        for i = 1, 4 do
            if self.decorate[i].Value == nil then
                self.decorate[i].Value = value
                EventMgr.Dispatch(PurikuraConstNew.Event.DecorateInfoChange, i)
                break
            end
        end
    else
        for i = 5, 8 do
            if self.decorate[i].Value == nil then
                self.decorate[i].Value = value
                EventMgr.Dispatch(PurikuraConstNew.Event.DecorateInfoChange, i)
                break
            end
        end
    end
end

---判断当前配饰是否加满了
function PurikuraProcessDecorate:IsFull(sex)
    local count = 0
    if sex == Define.Sex.Male then
        for i = 1, 4 do
            local v = self.decorate[i].Value
            if v then
                count = count + 1
            end
        end
    else
        for i = 5, 8 do
            local v = self.decorate[i].Value
            if v then
                count = count + 1
            end
        end
    end
    return count >= 4
end

function PurikuraProcessDecorate:RemoveDecorate(index)
    self.decorate[index].Value = nil
    EventMgr.Dispatch(PurikuraConstNew.Event.DecorateInfoChange, index)
end

function PurikuraProcessDecorate:RemoveAllDecorate()
    for i = 1, #self.decorate do
        self:RemoveDecorate(i)
    end
end

function PurikuraProcessDecorate:DecorateExist(id, sex)
    if sex == Define.Sex.Male then
        for i = 1, 4 do
            if self.decorate[i].Value and self.decorate[i].Value.ID == id then
                return true
            end
        end
    elseif sex == Define.Sex.Female then
        for i = 5, 8 do
            if self.decorate[i].Value and self.decorate[i].Value.ID == id then
                return true
            end
        end
    end
    return false
end

function PurikuraProcessDecorate:_InitDecorate()
    for i = 1, 8 do
        table.insert(self.decorate,{ID = i})
    end
end

----检测配饰冲突
function PurikuraProcessDecorate:CheckIsMutex()
    --local chooseList = PhotoMgr.controller.decorate:GetList()
    local chooseList = self:GetList()

    local hasMutex = false
    for i = 1, #chooseList do
        if chooseList[i].Value ~= nil and self:IsMutexWithEquip(chooseList[i].Value) then
            self:RemoveDecorate(chooseList[i].ID)
            if not hasMutex then hasMutex = true end
        end
    end

    if hasMutex then
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_7294 )
    end
end

function PurikuraProcessDecorate:IsMutexWithEquip(info)
    local character = PhotoMgr.controller.femaleCharacter
    if info.RoleID == -1 or info.RoleID ~= 0 then
        character = PhotoMgr.controller.maleCharacter
    end

    return character:JewelryIsMutexWithFashion(info.ID)
end


function PurikuraProcessDecorate:Clear()
    self:_InitDecorate()
end

return PurikuraProcessDecorate