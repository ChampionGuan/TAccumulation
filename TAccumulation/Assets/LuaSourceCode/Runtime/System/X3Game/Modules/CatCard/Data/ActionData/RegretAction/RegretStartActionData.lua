﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2022/12/30 18:51
---悔牌开始
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.BaseActionData
local BaseActionData = require(CatCardConst.BASE_ACTION_DATA_PATH)
---@class CatCard.RegretStartActionData :CatCard.BaseActionData
local RegretStartActionData = class("RegretStartActionData", BaseActionData)

function RegretStartActionData:ctor()
end

return RegretStartActionData
