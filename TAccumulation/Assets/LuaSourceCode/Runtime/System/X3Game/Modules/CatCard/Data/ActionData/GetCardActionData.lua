﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/6/1 10:58
--- 摸牌action数据
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.BaseActionData
local BaseActionData = require(CatCardConst.BASE_ACTION_DATA_PATH)
---@class CatCard.GetCardActionData:CatCard.BaseActionData
local GetCardActionData = class("GetCardActionData",BaseActionData)

--region 初始化
function GetCardActionData:ctor()
    BaseActionData.ctor(self)
    ---目标位置坐标id
    ---@type int
    self.cardPosIdx = 0
    ---card的初始坐标节点
    ---@type GameObject
    self.stackPosNode = nil
    ---移动速度
    ---@type number
    self.speed = 0
    ---是否旋转z
    ---@type boolean
    self.isRotationZ = false
    ---是否延后旋转Z
    ---@type boolean
    self.isAfterZ = false
    ---移动的目标数据
    ---@type CatCardData
    self.data = nil
    ---@type int[]
    self.cardIds = nil
    ---@type CatCardData[]
    self.cardList = nil
    ---是否刷新model
    ---@type boolean
    self.isAutoRefreshModel = false
    ---移动曲线
    ---@type DG.Tweening.Ease
    self.moveEaseType = nil
    ---@type number
    self.scaleDt = 0
    ---@type DG.Tweening.Ease
    self.scaleEaseType = nil
end
--endregion

--region Set

---@param easeType DG.Tweening.Ease
function GetCardActionData:SetMoveEaseType(easeType)
    self.moveEaseType = easeType
end

---@param idx int
function GetCardActionData:SetPosIdx(idx)
    self.cardPosIdx = idx
end

---@param isAutoRefreshModel boolean
function GetCardActionData:SetIsAutoRefreshModel(isAutoRefreshModel)
    self.isAutoRefreshModel = isAutoRefreshModel
end

---@param speed number
function GetCardActionData:SetSpeed(speed)
    self.speed = speed
end

---@param scaleDt number
function GetCardActionData:SetScaleDt(scaleDt)
    self.scaleDt = scaleDt
end

---@param scaleEasyType DG.Tweening.Ease
function GetCardActionData:SetScaleEasyType(scaleEasyType)
    self.scaleEaseType = scaleEasyType
end

---@param isRotationZ boolean
function GetCardActionData:SetIsRotationZ(isRotationZ)
    self.isRotationZ = isRotationZ
end

---@param isAfterZ boolean
function GetCardActionData:SetIsAfterZ(isAfterZ)
    self.isAfterZ = isAfterZ
end

---@param data CatCardData
function GetCardActionData:SetData(data)
    if self.data then
        self.bll:ReleaseData(self.data)
    end
    self.data = data
end

---@param stackPosNode GameObject
function GetCardActionData:SetStackPosNode(stackPosNode) 
    self.stackPosNode = stackPosNode
end

---设置旋转相关
---@param isRotationZ boolean
---@param isAfterZ boolean
function GetCardActionData:SetRotation(isRotationZ,isAfterZ)
    self:SetIsRotationZ(isRotationZ)
    self:SetIsAfterZ(isAfterZ)
end

---@param cardIds int[]
function GetCardActionData:SetCardIds(cardIds)
    self.cardIds = cardIds
end
--endregion

--region Get
---@return int
function GetCardActionData:GetPosIdx()
    return self.cardPosIdx
end

---@return CatCardData
function GetCardActionData:GetData()
    return self.data
end

---@return number
function GetCardActionData:GetSpeed()
    return self.speed
end

---@return boolean
function GetCardActionData:IsRotationZ()
    return self.isRotationZ
end

---@return boolean
function GetCardActionData:IsAfterZ()
    return self.isAfterZ
end

---@return GameObject
function GetCardActionData:GetStackNode()
    return self.stackPosNode
end

---@return int[]
function GetCardActionData:GetCardIds()
    return self.cardIds
end

---@return boolean
function GetCardActionData:IsAutoRefreshModel()
    return self.isAutoRefreshModel
end

---@return DG.Tweening.Ease
function GetCardActionData:GetMoveEasyType()
    return self.moveEaseType
end

---@return  number
function GetCardActionData:GetScaleDt()
    return self.scaleDt
end

---@return DG.Tweening.Ease
function GetCardActionData:GetScaleEasyType()
    return self.scaleEaseType
end

--endregion


---@param cardId int
---@param posIdx int 可以空缺，空缺的话，会自动找有效位置
function GetCardActionData:Set(cardId,posIdx)
    self:SetCardId(cardId)
    self:SetPosIdx(posIdx)
    self:SetData(self.bll:GenData(CatCardConst.CardType.CARD,cardId,posIdx))
end

--region 内部解析数据

---@param params int[]
function GetCardActionData:SetParam(params)
    if self:GetEffectType() then
        if not table.isnilorempty(params) then
            --第一个元素是数量，后面数cardid列表
            table.remove(params,1)
            if self:GetPlayerType() == CatCardConst.PlayerType.ENEMY then
                local effect_type = self:GetEffectType()
                local is_func = effect_type == CatCardConst.FuncEffectType.DrawFunc
                for k,v in ipairs(params) do
                    if v == 0 then
                        if is_func then
                            v = CatCardConst.DEFAULT_FUNC_CARD_ID
                        else
                            v = CatCardConst.DEFAULT_CARD_ID
                        end
                        params[k] = v
                    end
                end
            end
            self:SetCardIds(params)
        else
            Debug.LogWarningFormat("[喵喵牌] GetCardActionData 数据错误,未找到卡数据")
        end
    else
        if self:GetPlayerType() == CatCardConst.PlayerType.ENEMY then
            local card_id = CatCardConst.DEFAULT_CARD_ID
            if params and params.ActionType == CatCardConst.MiaoActionType.DrawFuncCard then
                card_id = CatCardConst.DEFAULT_FUNC_CARD_ID
            end
            self:SetCardId(card_id)
            self:Set(card_id,self.bll:GetDataIndex(card_id,CatCardConst.CardType.CARD,self:GetPlayerType()))
        else
            self:SetPosIdx(self.bll:GetDataIndex(self:GetCardId(),CatCardConst.CardType.CARD,self:GetPlayerType()))
        end
        
    end
    local cards = self:GetCardIds() 
    self:SetIsAutoRefreshModel(not cards or #cards==0)
    self:SetIsAutoRelease(false)
end

---@param a CatCardData
---@param b CatCardData
---@return boolean
function GetCardActionData.SortCard(a,b)
    return a:GetIndex()<b:GetIndex()
end

---@return boolean
function GetCardActionData:IsFinish()
    return table.isnilorempty(self.cardList)
end

---解析数据
---@return boolean
function GetCardActionData:Parse()
    if self.cardList then
        if #self.cardList>0 then
            local data = table.remove(self.cardList,1)
            self.bll:AddData(data)
            self:Set(data:GetId(),data:GetIndex())
            return true
        end
    else
        self.cardList = PoolUtil.GetTable()
        if not self:GetCardId() or not self:GetPosIdx() or self:GetPosIdx()==0 or self:GetCardId() == 0 then
            local cards = self:GetCardIds()
            if cards then
                if #cards>0 then
                    for k,v in pairs(cards) do
                        local data = self.bll:RemoveDataById(v,CatCardConst.CardType.CARD,self:GetPlayerType())
                        if data then
                            table.insert(self.cardList,data)
                        else
                            Debug.LogErrorFormat("[喵喵牌] GetCardActionData 未找到获取的卡片数据[%s]",v)
                        end
                    end
                    if not self:IsFinish() then
                        if #self.cardList>=2 then
                            table.sort(self.cardList,self.SortCard)
                        end
                        return self:Parse()
                    end

                end
                Debug.LogErrorFormat("[喵喵牌] GetCardActionData 未找到要获取的卡片数据")
            else
                return true
            end
        else
            local idx = self.bll:GetDataIndex(self:GetCardId(),CatCardConst.CardType.CARD,self:GetPlayerType())
            if idx then
                self:Set(self:GetCardId(),idx)
                return true
            else
                Debug.LogErrorFormat("[喵喵牌] GetCardActionData 未找到获取的卡片索引[%s]",self:GetCardId())
            end
        end
    end

    return false
end
--endregion

---清理数据
function GetCardActionData:OnClear()
    self.bll:ReleaseData(self:GetData())
    if self.cardList then
        PoolUtil.ReleaseTable(self.cardList)
    end
end

---初始化默认数据
function GetCardActionData:OnInit()
    self:SetPosIdx(0)
    self:SetSpeed(CatCardConst.CARD_SPEED)
    self:SetRotation(true,self:GetPlayerType() == CatCardConst.PlayerType.PLAYER)
    self:SetIsRotationZ(true)
    self:SetMoveEaseType(CatCardConst.MOVE_EASY_TYPE)
    self:SetScaleDt(CatCardConst.CARD_SCALE_DT)
    self:SetScaleEasyType(CatCardConst.SCALE_EASY_TYPE)
end

return GetCardActionData