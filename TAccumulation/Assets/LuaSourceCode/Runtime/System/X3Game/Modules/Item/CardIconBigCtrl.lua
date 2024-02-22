﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by canghai.
--- DateTime: 2023/7/6 11:33
---

---@type ItemSubCtrl
local ItemSubCtrl = require(ItemConst.ITEM_SUB_CTRL_PATH)

---@type CardIconBigData
local CardIconBigData = require(ItemConst.ITEM_CARD_ICON_BIG_DATA_PATH)

---@class CardIconBigCtrl:ItemSubCtrl
local CardIconBigCtrl = class("CardIconBigCtrl", ItemSubCtrl)
function CardIconBigCtrl:Init()
    ---@type CardIconBigData
    self.cardIconBigData = nil
    ---@type GameObject 这个不需要解绑是属于 Common_CardIcon_Big 本身的
    self.cardIconFx = nil
end

---@return ItemConst.ItemType
function CardIconBigCtrl:GetItemType()
    return ItemConst.ItemType.CARD_ICON_BIG
end

--- 修改 cardIconBigData
---@param dataEnum ItemConst.DataEnum
---@param value any
function CardIconBigCtrl:SetData(dataEnum, value)
    --保证每次取到的数据都是最新的
    ---@type ItemCtrl
    local owner = self.owner
    self.cardIconBigData = owner.itemData.itemSubDataDic[ItemConst.ItemType.CARD_ICON_BIG]

    local cardIconBigData = self.cardIconBigData
    local setDataFunc = CardIconBigData.SetDataFuncDic[dataEnum]
    if setDataFunc then
        setDataFunc(cardIconBigData, value)
    end
    self:UpdateView()
end

function CardIconBigCtrl:DecodeShowFlag()
    ---@type Item.ItemData
    local itemData = self.owner.itemData
    self:_ShowIcon()
    self:_ShowBattleTag()
    if itemData.showFlag & ItemConst.ItemShowFlag.CardIcon_Quality ~= 0 then
        self:_ShowQuality()
    else
        self:SetActiveStatus(ItemConst.OCX_CARD_ICON_BIG_IMG_QUALITY, false)
    end

    if itemData.showFlag & ItemConst.ItemShowFlag.CardIcon_Star ~= 0 then
        self:_ShowStar()
    else
        self:SetActiveStatus(ItemConst.OCX_CARD_ICON_BIG_OBJ_BOTTOM, false)
        self:SetActiveStatus(ItemConst.OCX_CARD_ICON_BIG_TRANS_UP_LEVEL, false)
        self:HideEffect()
    end

    if itemData.showFlag & ItemConst.ItemShowFlag.CardIcon_Level ~= 0 then
        self:_ShowLevel()
    else
        self:SetActiveStatus(ItemConst.OCX_CARD_ICON_BIG_OBJ_BOTTOM, false)
        self:SetActiveStatus(ItemConst.OCX_CARD_ICON_BIG_TXT_LEVEL, false)
    end

    if itemData.showFlag & ItemConst.ItemShowFlag.CardIcon_GoldBorder ~= 0 then
        self:_ShowGoldBorder()
    else
        self:SetActiveStatus(ItemConst.OCX_CARD_ICON_BIG_OBJ_GOLD, false)
    end

    if itemData.showFlag & ItemConst.ItemShowFlag.CardIcon_PosInfo ~= 0 then
        self:_ShowPosInfo()
    else
        self:SetActiveStatus(ItemConst.OCX_CARD_ICON_BIG_OBJ_POSITION, false)
    end
end

function CardIconBigCtrl:UpdateView()
    --保证每次取到的数据都是最新的
    ---@type ItemCtrl
    local owner = self.owner
    self.cardIconBigData = owner.itemData.itemSubDataDic[ItemConst.ItemType.CARD_ICON_BIG]

    ---@type Item.ItemData
    local itemData = self.owner.itemData
    ---@type CardIconBigData
    local cardIconBigData = self.cardIconBigData
    if not cardIconBigData.isDirty then
        return
    end

    if itemData.showFlag ~= 0 then
        --特异化流程
        self:DecodeShowFlag()
    else
        -- 标准显示流程
        self:_ShowIcon()
        self:_ShowBattleTag()
    end
    cardIconBigData.isDirty = false
end

--region Private Field
---@private
function CardIconBigCtrl:_ShowIcon()
    self:SetActiveStatus(ItemConst.OCX_CARD_ICON_BIG_IMG_ICON, true)
    ---@type CardIconBigData
    local cardIconBigData = self.cardIconBigData
    --这里是目前Big和普通的区别
    UICommonUtil.TrySetImageWithLocalFile(self:GetComponent(ItemConst.OCX_CARD_ICON_BIG_IMG_ICON), cardIconBigData.cardBaseInfoConfig.CardMiddleImage)
end

---@private
function CardIconBigCtrl:_ShowQuality()
    self:SetActiveStatus(ItemConst.OCX_CARD_ICON_BIG_IMG_QUALITY, true)
    ---@type CardIconBigData
    local cardIconBigData = self.cardIconBigData
    local qualityIcon, _ = DevelopHelper.GetCardRarityIconInfo(cardIconBigData.cardBaseInfoConfig.Quality)
    self:SetImage(ItemConst.OCX_CARD_ICON_BIG_IMG_QUALITY, qualityIcon, nil, true)
end

---@private
function CardIconBigCtrl:_ShowStar()
    self:SetActiveStatus(ItemConst.OCX_CARD_ICON_BIG_OBJ_BOTTOM, true)
    self:SetActiveStatus(ItemConst.OCX_CARD_ICON_BIG_TRANS_UP_LEVEL, true)
    ---@type CardIconBigData
    local cardIconBigData = self.cardIconBigData
    local upLevel = 0
    if not cardIconBigData.cardIconSpecialData then
        local uid = BllMgr.GetOthersBLL():IsMainPlayer() and SelfProxyFactory.GetPlayerInfoProxy():GetUid() or BllMgr.GetOthersBLL():GetCurrentShowUid()
        local serverData = SelfProxyFactory.GetCardDataProxy():GetData(cardIconBigData.cardBaseInfoConfig.ID, uid)
        if serverData then
            upLevel = serverData:GetPhaseLevel()
        end
    else
        upLevel = cardIconBigData.cardIconSpecialData.phaseLevel
    end
    self:SetValue(ItemConst.OCX_CARD_ICON_BIG_TRANS_UP_LEVEL, upLevel)
    if upLevel == SelfProxyFactory.GetCardDataProxy():GetCardMaxPhaseLv() then
        self:_ShowEffect()
    else
        self:HideEffect()
    end
end

---@private
function CardIconBigCtrl:_ShowLevel()
    self:SetActiveStatus(ItemConst.OCX_CARD_ICON_BIG_OBJ_BOTTOM, true)
    self:SetActiveStatus(ItemConst.OCX_CARD_ICON_BIG_TXT_LEVEL, true)
    ---@type CardIconBigData
    local cardIconBigData = self.cardIconBigData
    local level = 1
    if not cardIconBigData.cardIconSpecialData then
        local uid = BllMgr.GetOthersBLL():IsMainPlayer() and SelfProxyFactory.GetPlayerInfoProxy():GetUid() or BllMgr.GetOthersBLL():GetCurrentShowUid()
        local serverData = SelfProxyFactory.GetCardDataProxy():GetData(cardIconBigData.cardBaseInfoConfig.ID, uid)
        if serverData then
            level = serverData:GetLevel()
        end
    else
        level = cardIconBigData.cardIconSpecialData.level
    end
    self:SetText(ItemConst.OCX_CARD_ICON_BIG_TXT_LEVEL, UITextHelper.GetUIText(UITextConst.UI_TEXT_8617, level))
end

---@private
function CardIconBigCtrl:_ShowGoldBorder()
    local isShowGold = false
    ---@type CardIconBigData
    local cardIconBigData = self.cardIconBigData
    local uid = BllMgr.GetOthersBLL():IsMainPlayer() and SelfProxyFactory.GetPlayerInfoProxy():GetUid() or BllMgr.GetOthersBLL():GetCurrentShowUid()
    local cardData = SelfProxyFactory.GetCardDataProxy():GetData(cardIconBigData.cardBaseInfoConfig.ID, uid)
    if cardData then
        isShowGold = (cardData:GetAwaken() == X3DataConst.AwakenStatus.Awaken)
    end
    self:SetActiveStatus(ItemConst.OCX_CARD_ICON_BIG_OBJ_GOLD, isShowGold)
end

---@private
function CardIconBigCtrl:_ShowPosInfo()
    self:SetActiveStatus(ItemConst.OCX_CARD_ICON_BIG_OBJ_POSITION, true)
    ---@type CardIconBigData
    local cardIconBigData = self.cardIconBigData
    self:SetValue(ItemConst.OCX_CARD_ICON_BIG_OBJ_POSITION, cardIconBigData.cardBaseInfoConfig.PosType - 1)
end

---@private
function CardIconBigCtrl:_ShowBattleTag()
    self:SetActiveStatus(ItemConst.OCX_CARD_CHIP_ICON_BATTLE_TAG_01, true)
    ---@type CardIconBigData
    local cardIconBigData = self.cardIconBigData
    local tagId = cardIconBigData.cardBaseInfoConfig.FormationTag
    local formationTag = LuaCfgMgr.Get("FormationTag", tagId)
    self:SetImage(ItemConst.OCX_CARD_ICON_BIG_BATTLE_TAG_01, formationTag.TagImg)
end

---@private
function CardIconBigCtrl:_ShowEffect()
    local effectName = "fx_ui_CrownActivate_big"
    if string.isnilorempty(effectName) then
        self:HideEffect()
        return
    end

    self:SetActiveStatus(ItemConst.OCX_CARD_ICON_BIG_FX, true, true)
    if self.cardIconFx == nil then
        self.cardIconFx = self:GetComponent(ItemConst.OCX_CARD_ICON_BIG_FX)
    end
    
    if self.activeEffectName ~= effectName then
        self:HideEffect()
    end
    
    self:ShowEffect(effectName, self.cardIconFx)
end

function CardIconBigCtrl:OnClose()
    self.cardIconBigData = nil
    self:HideEffect()
    X3AssetInsProvider.ReleaseIns(self.gameObject)
end
--endregion

return CardIconBigCtrl