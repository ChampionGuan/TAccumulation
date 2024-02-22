﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2022/6/6 19:13
---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.BaseActionData
local BaseActionData = require(CatCardConst.BASE_ACTION_DATA_PATH)
-----@class CatCard.CardSelectData:CatCard.BaseActionData
local CardSelectData = class("CardSelectData", BaseActionData)

function CardSelectData:ctor()
    self.model = nil --
    ---@type string
    self.effectName = nil  --特效名称
    ---@type string CatCardConst.Sound
    self.soundName = nil --音效名称
    ---@type int
    self.posIndex = 1   --卡牌索引
    ---@type bool
    self.is_select = nil  --是否已选中
end

function CardSelectData:Set(model, effectName, soundName,is_select)
    self:SetCardModel(model)
    self:SetEffectName(effectName)
    self:SetSoundName(soundName)
    self:SetIsSelect(is_select)
end

---@param model GameObject:卡牌对象
function CardSelectData:SetCardModel(model)
    self.model = model
end

---@param effectName :特效名称
function CardSelectData:SetEffectName(effectName)
    self.effectName = effectName
end

---@param soundName:音效名
function CardSelectData:SetSoundName(soundName)
    self.soundName = soundName
end

---@return GameObject:卡牌对象
function CardSelectData:GetCardModel()
    return self.model
end

---@return string:特效名称
function CardSelectData:GetEffectName()
    if not self.effectName then
        self.effectName = CatCardConst.Effect.CARD_SELECTED
    end
    return self.effectName
end

---@return int:卡牌位置索引
function CardSelectData:GetPosIndex()
    return self.posIndex
end

function CardSelectData:SetPosIndex(index)
    self.posIndex = index
end

---@return string:音效名称
function CardSelectData:GetSoundName()
    return self.soundName
end

function CardSelectData:SetIsSelect(is_select)
    self.is_select = is_select
end

---@return bool
function CardSelectData:GetIsSelect()
    return self.is_select
end

---@param is_select bool 是否选中
function CardSelectData:SetSelect(is_select)
    self:DoSelect(is_select)
end

function CardSelectData:DoSelect(is_active)
    local effect_state = is_active and CatCardConst.EffectState.SHOW or CatCardConst.EffectState.HIDE
    self.bll:CheckEffect(CatCardConst.EffectType.DEFAULT, effect_state, self:GetEffectParam())
    if is_active then
        if self.soundName then
            self.bll:CheckSound(CatCardConst.SoundType.DEFAULT, self.soundName)
        else
            self.bll:CheckSound(CatCardConst.SoundType.DEFAULT, CatCardConst.Sound.SYSTEM_MIAO_PUTDOWN)
        end
    end
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_MODEL_SELECT_EVENT,self)
end

function CardSelectData:GetEffectParam()
    return self:GetEffectName(), self:GetEffectParent()
end

function CardSelectData:GetEffectParent()
    return self.model.transform.parent
end

return CardSelectData