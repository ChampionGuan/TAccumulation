﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2022/12/30 18:55
---悔牌选择
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.BaseActionData
local BaseActionData = require(CatCardConst.BASE_ACTION_DATA_PATH)
---@class CatCard.RegretSelectActionData :CatCard.BaseActionData
local RegretSelectActionData = class("RegretSelectActionData", BaseActionData)

function RegretSelectActionData:ctor()
    
end

return RegretSelectActionData