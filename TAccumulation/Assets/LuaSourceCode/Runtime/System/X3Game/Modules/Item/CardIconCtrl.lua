﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by canghai.
--- DateTime: 2022/8/31 10:23
---

---@type ItemSubCtrl
local ItemSubCtrl = require(ItemConst.ITEM_SUB_CTRL_PATH)

---@type CardIconData
local CardIconData = require(ItemConst.ITEM_CARD_ICON_DATA_PATH)

---@class CardIconCtrl:ItemSubCtrl
local CardIconCtrl = class("CardIconCtrl", ItemSubCtrl)
function CardIconCtrl:Init()
    ---@type CardIconData
    self.cardIconData = nil
    ---@type GameObject 这个不需要解绑是属于 Common_CardIcon_New 本身的
    self.cardIconFx = nil
end

---@return ItemConst.ItemType
function CardIconCtrl:GetItemType()
    return ItemConst.ItemType.CARD_ICON
end

--- 修改 CardIconData
---@param dataEnum ItemConst.DataEnum
---@param value any
function CardIconCtrl:SetData(dataEnum, value)
    --保证每次取到的数据都是最新的
    ---@type ItemCtrl
    local owner = self.owner
    self.cardIconData = owner.itemData.itemSubDataDic[ItemConst.ItemType.CARD_ICON]

    local cardIconData = self.cardIconData
    local setDataFunc = CardIconData.SetDataFuncDic[dataEnum]
    if setDataFunc then
        setDataFunc(cardIconData, value)
    end
    self:UpdateView()
end

function CardIconCtrl:DecodeShowFlag()
    ---@type Item.ItemData
    local itemData = self.owner.itemData
    self:_ShowIcon()
    self:_ShowBattleTag()
    if itemData.showFlag & ItemConst.ItemShowFlag.CardIcon_Quality ~= 0 then
        self:_ShowQuality()
    else
        self:SetActiveStatus(ItemConst.OCX_CARD_ICON_IMG_QUALITY, false)
    end

    if itemData.showFlag & ItemConst.ItemShowFlag.CardIcon_Star ~= 0 then
        self:_ShowStar()
    else
        self:SetActiveStatus(ItemConst.OCX_CARD_ICON_OBJ_BOTTOM, false)
        self:SetActiveStatus(ItemConst.OCX_CARD_ICON_TRANS_UP_LEVEL, false)
        self:HideEffect()
    end

    if itemData.showFlag & ItemConst.ItemShowFlag.CardIcon_Level ~= 0 then
        self:_ShowLevel()
    else
        self:SetActiveStatus(ItemConst.OCX_CARD_ICON_OBJ_BOTTOM, false)
        self:SetActiveStatus(ItemConst.OCX_CARD_ICON_TXT_LEVEL, false)
    end

    if itemData.showFlag & ItemConst.ItemShowFlag.CardIcon_GoldBorder ~= 0 then
        self:_ShowGoldBorder()
    else
        self:SetActiveStatus(ItemConst.OCX_CARD_ICON_OBJ_GOLD, false)
    end

    if itemData.showFlag & ItemConst.ItemShowFlag.CardIcon_PosInfo ~= 0 then
        self:_ShowPosInfo()
    else
        self:SetActiveStatus(ItemConst.OCX_CARD_ICON_OBJ_POSITION, false)
    end

    if itemData.showFlag & ItemConst.ItemShowFlag.CardIcon_Tag ~= 0 then
        self:_ShowTag()
    else    
        self:SetActiveStatus(ItemConst.OCX_CARD_ICON_TAG_SET, false)
    end
end

function CardIconCtrl:UpdateView()
    --保证每次取到的数据都是最新的
    ---@type ItemCtrl
    local owner = self.owner
    self.cardIconData = owner.itemData.itemSubDataDic[ItemConst.ItemType.CARD_ICON]

    ---@type Item.ItemData
    local itemData = self.owner.itemData
    ---@type CardIconData
    local cardIconData = self.cardIconData
    if not cardIconData.isDirty then
        return
    end

    if itemData.showFlag ~= 0 then
        --特异化流程
        self:DecodeShowFlag()
    else
        -- 标准显示流程(理论上几乎不会用到，这里可能会有问题)
        self:_ShowIcon()
        self:_ShowBattleTag()
        --隐藏ObjGold
        self:SetActiveStatus(ItemConst.OCX_CARD_ICON_OBJ_GOLD, false)
        --隐藏Tag
        self:SetActiveStatus(ItemConst.OCX_CARD_ICON_TAG_SET, false)
    end
    cardIconData.isDirty = false
end

--region Private Field
---@private
function CardIconCtrl:_ShowIcon()
    self:SetActiveStatus(ItemConst.OCX_CARD_ICON_IMG_ICON, true)
    ---@type CardIconData
    local cardIconData = self.cardIconData
    UICommonUtil.TrySetImageWithLocalFile(self:GetComponent(ItemConst.OCX_CARD_ICON_IMG_ICON), cardIconData.cardBaseInfoConfig.CardSmallImage)
end

---@private
function CardIconCtrl:_ShowQuality()
    self:SetActiveStatus(ItemConst.OCX_CARD_ICON_IMG_QUALITY, true)
    ---@type CardIconData
    local cardIconData = self.cardIconData
    local qualityIcon, _ = DevelopHelper.GetCardRarityIconInfo(cardIconData.cardBaseInfoConfig.Quality)
    self:SetImage(ItemConst.OCX_CARD_ICON_IMG_QUALITY, qualityIcon, nil, true)
end

---@private
function CardIconCtrl:_ShowStar()
    self:SetActiveStatus(ItemConst.OCX_CARD_ICON_OBJ_BOTTOM, true)
    self:SetActiveStatus(ItemConst.OCX_CARD_ICON_TRANS_UP_LEVEL, true)
    ---@type CardIconData
    local cardIconData = self.cardIconData
    local upLevel = 0
    if not cardIconData.cardIconSpecialData then
        local uid = BllMgr.GetOthersBLL():IsMainPlayer() and SelfProxyFactory.GetPlayerInfoProxy():GetUid() or BllMgr.GetOthersBLL():GetCurrentShowUid()
        local serverData = SelfProxyFactory.GetCardDataProxy():GetData(cardIconData.cardBaseInfoConfig.ID, uid)
        if serverData then
            upLevel = serverData:GetPhaseLevel()
        end
    else
        upLevel = cardIconData.cardIconSpecialData.phaseLevel
    end
    self:SetValue(ItemConst.OCX_CARD_ICON_TRANS_UP_LEVEL, upLevel)
    if upLevel == SelfProxyFactory.GetCardDataProxy():GetCardMaxPhaseLv() then
        self:_ShowEffect()
    else
        self:HideEffect()
    end
end

---@private
function CardIconCtrl:_ShowLevel()
    self:SetActiveStatus(ItemConst.OCX_CARD_ICON_OBJ_BOTTOM, true)
    self:SetActiveStatus(ItemConst.OCX_CARD_ICON_TXT_LEVEL, true)
    ---@type CardIconData
    local cardIconData = self.cardIconData
    local level = 1
    if not cardIconData.cardIconSpecialData then
        local uid = BllMgr.GetOthersBLL():IsMainPlayer() and SelfProxyFactory.GetPlayerInfoProxy():GetUid() or BllMgr.GetOthersBLL():GetCurrentShowUid()
        local serverData = SelfProxyFactory.GetCardDataProxy():GetData(cardIconData.cardBaseInfoConfig.ID, uid)
        if serverData then
            level = serverData:GetLevel()
        end
    else
        level = cardIconData.cardIconSpecialData.level
    end
    self:SetText(ItemConst.OCX_CARD_ICON_TXT_LEVEL, UITextHelper.GetUIText(UITextConst.UI_TEXT_8617, level))
end

---@private
function CardIconCtrl:_ShowGoldBorder()
    local isShowGold = false
    ---@type CardIconData
    local cardIconData = self.cardIconData
    local uid = BllMgr.GetOthersBLL():IsMainPlayer() and SelfProxyFactory.GetPlayerInfoProxy():GetUid() or BllMgr.GetOthersBLL():GetCurrentShowUid()
    local cardData = SelfProxyFactory.GetCardDataProxy():GetData(cardIconData.cardBaseInfoConfig.ID, uid)
    if cardData then
        isShowGold = (cardData:GetAwaken() == X3DataConst.AwakenStatus.Awaken)
    end
    self:SetActiveStatus(ItemConst.OCX_CARD_ICON_OBJ_GOLD, isShowGold)
end

---@private
function CardIconCtrl:_ShowPosInfo()
    self:SetActiveStatus(ItemConst.OCX_CARD_ICON_OBJ_POSITION, true)
    ---@type CardIconData
    local cardIconData = self.cardIconData
    self:SetValue(ItemConst.OCX_CARD_ICON_OBJ_POSITION, cardIconData.cardBaseInfoConfig.PosType - 1)
end

function CardIconCtrl:_ShowTag()
    ---@type CardIconData
    local cardIconData = self.cardIconData
    --key2 读取0号默认的CardSuit
    local cardSuit = LuaCfgMgr.Get("CardSuit", cardIconData.cardBaseInfoConfig.SuitID, 0)
    --这里会存在CardSuit尚未配置的情况
    if cardSuit then
        self:SetActiveStatus(ItemConst.OCX_CARD_ICON_TAG_SET, true)
        self:SetText(ItemConst.OCX_CARD_ICON_SET_NAME, cardSuit.SuitName)
    else
        self:SetActiveStatus(ItemConst.OCX_CARD_ICON_TAG_SET, false)
    end
end

---@private
function CardIconCtrl:_ShowBattleTag()
    self:SetActiveStatus(ItemConst.OCX_CARD_CHIP_ICON_BATTLE_TAG_01, true)
    ---@type CardIconData
    local cardIconData = self.cardIconData
    local tagId = cardIconData.cardBaseInfoConfig.FormationTag
    local formationTag = LuaCfgMgr.Get("FormationTag", tagId)
    self:SetImage(ItemConst.OCX_CARD_ICON_ICON_BATTLE_TAG_01, formationTag.TagImg)
end

---@private
function CardIconCtrl:_ShowEffect()
    local effectName = "fx_effect_DevelopCard_Full_small"
    if string.isnilorempty(effectName) then
        self:HideEffect()
        return
    end

    self:SetActiveStatus(ItemConst.OCX_CARD_ICON_FX, true, true)
    if self.cardIconFx == nil then
        self.cardIconFx = self:GetComponent(ItemConst.OCX_CARD_ICON_FX)
    end

    if self.activeEffectName ~= effectName then
        self:HideEffect()
    end
    
    self:ShowEffect(effectName, self.cardIconFx)
end

function CardIconCtrl:OnClose()
    self.cardIconData = nil
    self:HideEffect()
    X3AssetInsProvider.ReleaseIns(self.gameObject)
end
--endregion

return CardIconCtrl
