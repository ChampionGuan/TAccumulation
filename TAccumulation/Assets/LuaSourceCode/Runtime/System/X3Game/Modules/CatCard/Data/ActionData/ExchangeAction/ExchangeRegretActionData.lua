﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2022/12/28 20:10
---换牌反悔action
---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.BaseActionData
local BaseActionData = require(CatCardConst.BASE_ACTION_DATA_PATH)
-----@class CatCard.ExchangeRegretActionData:CatCard.BaseActionData
local ExchangeRegretActionData = class("ExchangeRegretActionData", BaseActionData)

function ExchangeRegretActionData:ctor()
    
end

return ExchangeRegretActionData
