﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/6/16 15:14
---
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.BaseActionData
local BaseActionData = require(CatCardConst.BASE_ACTION_DATA_PATH)
---@class CatCard.UseCardConditionActionData:CatCard.BaseActionData
local UseCardConditionActionData = class("UseCardConditionActionData",BaseActionData)

function UseCardConditionActionData:ctor()
    BaseActionData.ctor(self)
    
    ---检测结果
    ---@type boolean
    self.isSuccess = false
    
    ---当前卡数据
    ---@type CatCardData
    self.data = nil
    
    ---@type fun(type:boolean)
    self.resCall = nil
    
    ---条件不满足是否显示tips
    ---@type boolean
    self.isShowTips = false
    
    ---不满足条件的时候tips文本/文本id
    ---@type string | int
    self.tipsText = nil
    
    ---使用卡的类型
    ---@type CatCardConst.UseCardType
    self.useCardType = CatCardConst.UseCardType.None

    ---使用卡时的检测类型
    ---@type CatCardConst.UseCardCheckType
    self.useCardCheckType = CatCardConst.UseCardCheckType.CanUse
end

--region Set
---@param resCall fun(type:boolean)
function UseCardConditionActionData:SetResCall(resCall)
    self.resCall = resCall
end

---@param data CatCardData
function UseCardConditionActionData:SetData(data)
    self.data = data
end

---@param isSuccess boolean
function UseCardConditionActionData:SetIsSuccess(isSuccess)
    self.isSuccess = isSuccess
end

---@param isShowTips boolean
function UseCardConditionActionData:SetIsShowTips(isShowTips)
    self.isShowTips = isShowTips
end

---@param text string | int
function UseCardConditionActionData:SetTipsText(text)
    self.tipsText = text
end

---@param useCardType CatCardConst.UseCardType
function UseCardConditionActionData:SetUseCardType(useCardType)
    self.useCardType = useCardType
end

---@param useCardCheckType CatCardConst.UseCardCheckType
function UseCardConditionActionData:SetUseCardCheckType(useCardCheckType)
    self.useCardCheckType = useCardCheckType
end

--endregion

--region Get
---@return boolean
function UseCardConditionActionData:IsSuccess()
    return self.isSuccess
end

---@return CatCardData
function UseCardConditionActionData:GetData()
    return self.data
end

---@return boolean
function UseCardConditionActionData:IsCanShowTips()
    return self.isShowTips
end

---@return string | int
function UseCardConditionActionData:GetTipsText()
    return self.tipsText
end

---@return CatCardConst.UseCardType
function UseCardConditionActionData:GetUseCardType()
    return self.useCardType
end

---@return CatCardConst.UseCardCheckType
function UseCardConditionActionData:GetUseCardCheckType()
    return self.useCardCheckType
end

--endregion

---@param cardId int
---@param useCardType CatCardConst.UseCardType
---@param resCall fun(type:boolean)
function UseCardConditionActionData:Set(cardId,useCardType,resCall)
    self:SetUseCardType(useCardType)
    self:SetResCall(resCall)
    self:SetCardId(cardId)
    self:SetData(self.bll:GenData(CatCardConst.CardType.CARD,cardId,0))
    self:SetUseCardCheckType(CatCardConst.UseCardCheckType.CanUse)
end

---@param isCanShow boolean
---@param showText string | int
function UseCardConditionActionData:SetTips(isCanShow,showText)
    self:SetIsShowTips(isCanShow)
    self:SetTipsText(showText)
end

function UseCardConditionActionData:Finish()
    if self:IsCanShowTips() and not string.isnilorempty(self:GetTipsText()) then
        UICommonUtil.ShowMessage(self:GetTipsText())
    end
    if self.resCall then
        self.resCall(self:IsSuccess())
    end
    BaseActionData.Finish(self)
end

function UseCardConditionActionData:OnClear()
    self.bll:ReleaseData(self:GetData())
end


return UseCardConditionActionData