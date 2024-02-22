﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/6/1 18:18
--- 出牌数据
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.BaseActionData
local BaseActionData = require(CatCardConst.BASE_ACTION_DATA_PATH)
---@class CatCard.PopCardActionData:CatCard.BaseActionData
local PopCardActionData = class("PopCardActionData",BaseActionData)

--region 初始化
function PopCardActionData:ctor()
    BaseActionData.ctor(self)
    ---位置坐标
    ---@type int
    self.posIdx = 0
    ---移动速度
    ---@type number
    self.speed = 0
    ---@type CatCardData
    self.data = nil
    ---@type int
    self.slotIdx = 0
end
--endregion

--region Set
---@param idx int
function PopCardActionData:SetPosIdx(idx)
    self.posIdx = idx
end

---@param speed number
function PopCardActionData:SetSpeed(speed)
    self.speed = speed
end

---@param data CatCardData
function PopCardActionData:SetData(data)
    self.data = data
end

---@param idx int
function PopCardActionData:SetSlotIdx(idx)
    self.slotIdx = idx
end

--endregion

--region Get
---@return int
function PopCardActionData:GetPosIdx()
    return self.posIdx
end

---@return CatCardData
function PopCardActionData:GetData()
    if not self.data then
        self.data = self.bll:GenData(CatCardConst.CardType.CARD,self:GetCardId(),self:GetPosIdx())
    end
    return self.data
end

---@return number
function PopCardActionData:GetSpeed()
    return self.speed
end

---@return int
function PopCardActionData:GetSlotIdx()
    return self.slotIdx
end

--endregion
---@param cardId int
---@param posIdx int
---@param slotIdx int
function PopCardActionData:Set(cardId,posIdx,slotIdx)
    self:SetCardId(cardId)
    self:SetPosIdx(posIdx)
    self:SetSlotIdx(slotIdx)
    self:SetData(self.bll:GenData(CatCardConst.CardType.CARD,self:GetCardId(),self:GetPosIdx()))
end

---@param params pbcmessage.MiaoAction
function PopCardActionData:SetParam(params)
    local card_id = self:GetCardId()
    local card_idx = 0
    local slot_idx = 0
    if self:GetPlayerType() == CatCardConst.PlayerType.PLAYER then
        card_idx = self.bll:GetCurSelectIndex(CatCardConst.CardType.CARD)
    else
        local data = self.bll:GenData(CatCardConst.CardType.CARD,card_id)
        if data:IsFuncCard() then
            self:SetCardId(CatCardConst.DEFAULT_FUNC_CARD_ID)
        else
            self:SetCardId(CatCardConst.DEFAULT_CARD_ID)
        end
        self.bll:ReleaseData(data)
        card_idx = self.bll:GetOldCardIndex(self:GetCardId(),self:GetPlayerType())
        --避免新获得卡牌没有加入保存数据造成查找异常的情况
        if card_idx == 0 then
            local data_list = self.bll:GetDataList(CatCardConst.CardType.CARD, CatCardConst.PlayerType.ENEMY)
            for i, v in pairs(data_list) do
                if v:GetRealId() == card_id then
                    card_idx = v:GetIndex()
                    break
                end
            end
        end
    end
    slot_idx = params.Target
    self:Set(card_id,card_idx,slot_idx)
end


---清理数据
function PopCardActionData:OnClear()
    self.bll:ReleaseData(self:GetData())
end

---初始化默认数据
function PopCardActionData:OnInit()
    self:SetSpeed(CatCardConst.CARD_SPEED)
end

return PopCardActionData