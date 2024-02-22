﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiantao.
--- DateTime: 2023/6/12 17:05
---
---@class CardDevelopConst
local CardDevelopConst = {}

---卡牌升级反馈提示
CardDevelopConst.UpgradeType = {
    CARD_BREAK = 1,
    CARD_AWAKE = 2,
    CARD_ADVANCE = 3,
}

--- 卡牌升级相关事件
CardDevelopConst.Event = {
    LEVEL_UP_TIP = "DevelopCardLevelUp",
}

---排序优先级
---@class CardDevelopConst.SortPriority
CardDevelopConst.SortPriority = {
    Level = 1,
    Quality = 2,
    Suit = 3,
    RedPoint = 4,
    Tag = 5,
}

return CardDevelopConst