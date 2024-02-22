﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2022/12/28 19:41
---换牌动画
---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.BaseActionData
local BaseActionData = require(CatCardConst.BASE_ACTION_DATA_PATH)
-----@class CatCard.ExchangeHandCardActionData:CatCard.BaseActionData
local ExchangeHandCardActionData = class("ExchangeHandCardActionData", BaseActionData)

function ExchangeHandCardActionData:ctor()
    ---@type bool 是否反悔
    self.is_regret = false
end

---@param is_regret bool 
function ExchangeHandCardActionData:Set(is_regret)
    self.is_regret = is_regret
end

function ExchangeHandCardActionData:GetIsRegret()
    return self.is_regret
end

return ExchangeHandCardActionData