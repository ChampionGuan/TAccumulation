﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/6/20 21:04
--- 展示出的牌数据
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.BaseActionData
local BaseActionData = require(CatCardConst.BASE_ACTION_DATA_PATH)
-----@class CatCard.ShowCardActionData:CatCard.BaseActionData
local ShowCardActionData = class("ShowCardActionData", BaseActionData)

function ShowCardActionData:ctor()
    BaseActionData.ctor(self)
    ---@type CatCardData
    self.data = nil
    ---是否展示
    ---@type boolean
    self.isShow = false
    ---是否从卡的位置移动
    ---@type boolean
    self.isFly = false
    ---移动的卡所在位置
    ---@type int
    self.posIdx = 0
    ---移动速度
    ---@type number
    self.speed = 0
    ---移动曲线
    ---@type DG.Tweening.Ease
    self.moveEaseType = nil
    ---旋转曲线
    ---@type DG.Tweening.Ease
    self.rotationEasyType = nil
    ---旋转时长
    ---@type float
    self.rotationDt = 0
    ---缩放时长
    ---@type float
    self.scaleDt = 0
    ---缩放曲线
    ---@type DG.Tweening.Ease
    self.scaleEasyType = nil

    ---要移动到的目标节点
    ---@type GameObject
    self.slot_stack = nil
    
end

--region Get
---@return CatCardData
function ShowCardActionData:GetData()
    return self.data
end

---@return boolean
function ShowCardActionData:IsShow()
    return self.isShow
end

---@return int
function ShowCardActionData:GetPosIdx()
    return self.posIdx
end

---@return boolean
function ShowCardActionData:IsFly()
    return self.isFly
end

---@return number
function ShowCardActionData:GetSpeed()
    return self.speed
end

---@return GameObject
function ShowCardActionData:GetSlotStack()
    return self.slot_stack
end

---@return DG.Tweening.Ease
function ShowCardActionData:GetMoveEasyType()
    return self.moveEaseType
end

---@return DG.Tweening.Ease
function ShowCardActionData:GetRotationEasyType()
    return self.rotationEasyType
end

---@return float
function ShowCardActionData:GetRotationDt()
    return self.rotationDt
end

---@return float
function ShowCardActionData:GetScaleDt()
    return self.scaleDt
end

---@return DG.Tweening.Ease
function ShowCardActionData:GetScaleEasyType()
    return self.scaleEasyType
end

--endregion

--region Set
---@param data CatCardData
function ShowCardActionData:SetData(data)
    self.data = data
end

---@param isShow boolean
function ShowCardActionData:SetIsShow(isShow)
    self.isShow = isShow
end

---@param isFly boolean
function ShowCardActionData:SetIsFly(isFly)
    self.isFly = isFly
end

---@param posIdx int
function ShowCardActionData:SetPosIdx(posIdx)
    self.posIdx = posIdx
end

---@param speed number
function ShowCardActionData:SetSpeed(speed)
    self.speed = speed
end

---@param dt number
function ShowCardActionData:SetRotationDt(dt)
    self.rotationDt = dt
end

---@param scaleDt number
function ShowCardActionData:SetScaleDt(scaleDt)
    self.scaleDt = scaleDt
end

---@param easyType DG.Tweening.Ease
function ShowCardActionData:SetScaleEasyType(easyType)
    self.scaleEasyType = easyType
end

---@param easyType DG.Tweening.Ease
function ShowCardActionData:SetMoveEasyType(easyType)
    self.moveEaseType = easyType
end

---@param easyType DG.Tweening.Ease
function ShowCardActionData:SetRotationEasyType(easyType) 
    self.rotationEasyType = easyType
end

---@param slot_stack GameObject
function ShowCardActionData:SetSlotStack(slot_stack)
    self.slot_stack = slot_stack
end

--endregion

---@param cardId int
---@param isShow boolean
---@param isFly boolean
---@param posIdx int
function ShowCardActionData:Set(cardId,isShow,isFly,posIdx)
    self:SetCardId(cardId)
    self:SetIsShow(isShow)
    self:SetIsFly(isFly)
    self:SetPosIdx(posIdx)
    if self:GetCardId() and self:GetCardId()~=0 then
        self:SetData(self.bll:GenData(CatCardConst.CardType.CARD,self:GetCardId(),0))
    end
end

---设置移动相关参数
---@param speed float
---@param moveEasyType DG.Tweening.Ease
---@param rotationDt float
---@param rotationEasyType DG.Tweening.Ease
---@param scaleDt float
---@param scaleEasyType DG.Tweening.Ease
function ShowCardActionData:SetMove(speed,moveEasyType,rotationDt,rotationEasyType,scaleDt,scaleEasyType)
    if speed then
        self:SetSpeed(speed)
    end
    if moveEasyType then
        self:SetMoveEasyType(moveEasyType)
    end
    if rotationDt then
        self:SetRotationDt(rotationDt)
    end
    if rotationEasyType then
        self:SetRotationEasyType(rotationEasyType)
    end
    if scaleDt then
        self:SetScaleDt(scaleDt)
    end
    if scaleEasyType then
        self:SetScaleEasyType(scaleEasyType)
    end
end

function ShowCardActionData:OnInit()
    self:SetSpeed(CatCardConst.CARD_SPEED)
    self:SetMoveEasyType(CatCardConst.MOVE_EASY_TYPE)
    self:SetRotationDt(CatCardConst.CARD_ROTATION_DT)
    self:SetRotationEasyType(CatCardConst.ROTATION_EASY_TYPE)
    self:SetScaleDt(CatCardConst.CARD_SCALE_DT)
    self:SetScaleEasyType(CatCardConst.SCALE_EASY_TYPE)
end

function ShowCardActionData:OnClear()
    self.bll:ReleaseData(self:GetData())
end

return ShowCardActionData