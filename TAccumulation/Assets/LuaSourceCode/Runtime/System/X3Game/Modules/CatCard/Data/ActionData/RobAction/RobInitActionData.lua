﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2023/1/8 12:44
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.BaseActionData
local BaseActionData = require(CatCardConst.BASE_ACTION_DATA_PATH)
---@class CatCard.RobInitActionData:CatCard.BaseActionData
local RobInitActionData = class("RobInitActionData",BaseActionData)

function RobInitActionData:ctor()
    
end

return RobInitActionData