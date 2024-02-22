﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2020/8/27 11:39
---
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@class CatCardData
local CatCardData = class("CatCardData")

function CatCardData:ctor()
    self.is_valid = true
    ---@type CatCardBLL
    self.bll = nil
    ---@type cfg.MiaoCardFuncEffect
    self.effect_conf = nil
    ---@type number
    self.rotationZ = 0
    ---@type boolean
    self.is_new = false
    ---@type number
    self.realId = 0
end

function CatCardData:SetIsNew(is_new)
    self.is_new = is_new
end

function CatCardData:IsNew()
    return self.is_new
end

function CatCardData:IsFuncCard()
    return self:GetType() == CatCardConst.CardType.CARD and self:GetSubType() == CatCardConst.SubType.FUNCCARD
end

function CatCardData:SetBll(bll)
    self.bll = bll
end

function CatCardData:GetIndex()
    return self.index
end

function CatCardData:SetIndex(index)
    self.index = index
end

function CatCardData:SetIsValid(is_valid)
    self.is_valid = is_valid
end

function CatCardData:IsValid()
    return self.is_valid
end

function CatCardData:GetId()
    return self.id
end

function CatCardData:SetId(id)
    self:GenConf(id)
    self.id = id
    self.card_model = nil
end

---@param realId int 真实cardId
function CatCardData:SetRealId(realId)
    self.realId = realId or 0
end

function CatCardData:GetRealId()
    return self.realId
end

---如果是暗牌的话，就是本地数据，明牌的话就是服务器数据，针对npc
function CatCardData:IsLocal()
    return self.is_local
end

function CatCardData:SetLocal(is_local)
    self.is_local = is_local
end

--- 1:底牌，2:手牌
---@return CatCardConst.CardType
function CatCardData:GetType()
    return self.conf.Class
end

--- 底盘
--1：普通格
--2：翻倍格
--- 手牌：
--1：数字牌
--2：功能牌
function CatCardData:GetSubType()
    return self.conf.SubClass
end

---获取花色
---0：无
--翻倍底盘&数字牌：
--1：白猫
--2：黑猫
--3：三花猫
--4：橘猫
function CatCardData:GetColor()
    return self.conf.Type
end

function CatCardData:GetColorName(color)
    if color == 1 then
        return "狸花猫"
    elseif color == 2 then
        return "蓝猫"
    elseif color == 3 then
        return "薄荷猫"
    else
        return "橘猫"
    end
end

--数字牌：
--1~6：数字
--功能牌：
--1：招财喵
--2：共享喵
--3：强盗喵
--4：拆迁喵
--5：重建喵
function CatCardData:GetNum()
    return self.conf.Num
end

---@return string 卡牌名称
function CatCardData:GetBrandCardName()
    if self.player_type == CatCardConst.PlayerType.ENEMY then
        local conf = LuaCfgMgr.Get("MiaoCardInfo", self:GetRealId())
        if conf then
            if conf.SubClass == CatCardConst.SubType.FUNCCARD then
                return string.format("%s:%s", self:GetIndex(), UITextHelper.GetUIText(self:GetFuncCardName(self:GetRealId())))
            else
                return string.format("%s:%s(%s)", self:GetIndex(), self:GetColorName(conf.Type), conf.Num)
            end
        end
    end
    return ""
end

---获得功能牌名称
function CatCardData:GetFuncCardName(cardId)
    local conf = self:GetConf(cardId)
    if not conf then
        Debug.LogError("MiaoCardInfo找不到卡片数据:", cardId or self:GetId())
        return
    end
    local cardInfo = LuaCfgMgr.Get("MiaoCardFuncEffect", conf.Num)
    return cardInfo and cardInfo.HandCardName
end


---效果id
--PASSCARD = 1,    --跳过喵
--FROZENCARD = 2,  --冰冻喵
--VETOCARD = 3,    --否决喵
--RICHCARD = 4,    --发财喵
--GREEDYCARD = 5,  --贪心喵
--SHOWCARD = 6,    --给喵看看
--STEALCARD = 7,   --顺手牵喵
--DISCOLORCARD = 8,--变色喵
--BANKRUPTCYCARD = 9, --破产喵
--SMALLCARD = 10,  --变小喵
--REMOVECARD = 11, --拆迁喵
--EXICITEDCARD = 12,--兴奋喵
---@return CatCardConst.FuncCardType
function CatCardData:GetEffectId()
    return self:IsFuncCard() and self:GetNum() or -1
end

---@return cfg.MiaoCardFuncEffect
function CatCardData:GetEffectConf()
    if not self.effect_conf then
        self.effect_conf = LuaCfgMgr.Get("MiaoCardFuncEffect", self:GetEffectId())
    end
    return self.effect_conf
end

---@return CatCardConst.PlayerType
function CatCardData:GetEffectTarget()
    local effect = self:GetEffectConf()
    return effect and effect.Target or -1
end

---获取预加载的模型列表
function CatCardData:GetPreLoadModels()
    return self.conf.NormalModel
end

---杯子模型
function CatCardData:GetCupModel()
    if not self.cup_model then
        self.cup_model = self.conf.NormalModel[1]
    end
    return self.cup_model
end

---盘子模型
function CatCardData:GetCupPlateModel()
    if not self.cup_plate_model then
        self.cup_plate_model = self.conf.NormalModel[2]
    end
    return self.cup_plate_model
end

---垫子模型
function CatCardData:GetCupMatModel(tag, ...)
    return self.bll:GetCupMatModel(tag, ...)
end

---获取卡片模型
---@return string
function CatCardData:GetCardModel()
    if not self.card_model then
        self.card_model = self.conf.NormalModel[1]
    end
    return self.card_model
end

---获取男主实际卡片模型
---@return string
function CatCardData:GetRealCardModel()
    if self.realId > 0 then
        local conf = self:GetConf(self.realId)
        return conf and conf.NormalModel[1]
    end
    return self.card_model
end

---@return number
function CatCardData:GetRotationZ()
    return self.rotationZ
end

---@param rotationZ number
function CatCardData:SetRotationZ(rotationZ)
    self.rotationZ = rotationZ
end

---获取猫的模型
function CatCardData:GetCatModel()
    if not self.cat_model then
        self.cat_model = self.conf.NormalModel[2]
    end
    return self.cat_model
end

---获取卡片数量模型
function CatCardData:GetNumModel(idx)
    idx = idx and idx or 1
    if not self.card_num_model then
        local index = 3
        self.card_num_model = PoolUtil.GetTable()
        for k = index, #self.conf.NormalModel do
            table.insert(self.card_num_model, self.conf.NormalModel[k])
        end
    end
    return self.card_num_model[idx]
end

---根据杯子和卡的匹配
function CatCardData:GetMatchIdx(cup_color)
    if self.conf and self.conf.CupNumConnect then
        for k, v in pairs(self.conf.CupNumConnect) do
            if v.ID == cup_color then
                return v.Num
            end
        end
    end
    return nil
end

---获取旗子模型
function CatCardData:GetFlagModel()
    return self.conf.CardTypeMatch and self.conf.CardTypeMatch[1] or ""
end

function CatCardData:GetPlayerType()
    return self.player_type
end

---遮罩显示状态
function CatCardData:GetMaskState()
    if self.player_type == CatCardConst.PlayerType.ENEMY then
        return false
    end
    self.stateData = self.bll:GetStateData()
    if self.stateData:GetState() < CatCardConst.State.P1_PRE then
        --初始发牌阶段不需要遮罩
        return false
    end
    if self.stateData:GetSeat() == CatCardConst.SeatType.ENEMY then
        return false
    end
    if self.stateData:GetMode() == CatCardConst.ModeType.Func then
        if self.stateData:GetPopState() == CatCardConst.PopCardState.PopFuc then
            return not self:IsFuncCard()
        elseif self.stateData:GetPopState() == CatCardConst.PopCardState.PopNum or self.stateData:GetPopState() == CatCardConst.PopCardState.PopNumPlus then
            return self:IsFuncCard()
        else
            if self.bll:GetCurSelectIndex(CatCardConst.CardType.SLOT) then
                --出完数字牌表演没结束时移位操作按卡牌类型处理
                return self:IsFuncCard()
            else
                return true
            end
        end
    end
    return false
end

function CatCardData:SetPlayerType(player_type)
    self.player_type = player_type
    self:SetIsTouchEnable(player_type == CatCardConst.PlayerType.PLAYER)
end

function CatCardData:SetIsTouchEnable(is_enable)
    self.is_touch_enable = is_enable
end

function CatCardData:IsTouchEnable()
    return self.is_touch_enable
end

function CatCardData:Refresh(server_data)
    self:SetLocal(server_data.IsLocal)
    if server_data.Id then
        self:SetId(server_data.Id)
    end
    if server_data.PlayerType then
        self:SetPlayerType(server_data.PlayerType)
    end
    if server_data.PosIndex then
        self:SetIndex(server_data.PosIndex)
    end
end

function CatCardData:GenConf(id)
    if self.id == id then
        return
    end
    self.id = id
    self.conf = self:GetConf(self:GetId())
    if not self.conf then
        Debug.LogError("MiaoCardInfo找不到卡片数据:", self:GetId())
    end
end

function CatCardData:GetConf(id)
    if id then
        if id > 0 then
            return LuaCfgMgr.Get("MiaoCardInfo", id)
        end
    else
        return self.conf
    end
    return nil
end

function CatCardData:Clear()
    PoolUtil.ReleaseTable(self.card_num_model)
    table.clear(self)
    self.is_valid = true
    self:SetRotationZ(0)
end

return CatCardData