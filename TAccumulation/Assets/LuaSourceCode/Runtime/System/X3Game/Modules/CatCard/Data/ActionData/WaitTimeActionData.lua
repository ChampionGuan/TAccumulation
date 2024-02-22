﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2022/12/21 15:03
---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.BaseActionData
local BaseActionData = require(CatCardConst.BASE_ACTION_DATA_PATH)
---@class CatCard.WaitTimeActionData:CatCard.BaseActionData
local WaitTimeActionData = class("WaitTimeActionData", BaseActionData)

function WaitTimeActionData:ctor()
    ---@type int
    self.waitTime = 0
end

---@param params any
function WaitTimeActionData:SetParam(params)
    self.waitTime = params[1]
end

---@param waitTime float
function WaitTimeActionData:Set(waitTime)
    self.waitTime = waitTime
end

function WaitTimeActionData:GetWaitTime()
    return self.waitTime
end

return WaitTimeActionData