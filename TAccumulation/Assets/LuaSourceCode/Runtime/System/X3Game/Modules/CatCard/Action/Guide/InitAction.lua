﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2020/11/10 16:28
---
---初始化
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
local BaseAction = require(string.concat(CatCardConst.BASE_LUA_ACTION_DIR,"InitAction"))
---@class CatCard.Guide.Action.InitAction:CatCard.Action.InitAction
local InitAction = class("InitAction",BaseAction)
function InitAction:Execute(SPAction)
    self.bll:SetBreakProcedure(X3_CFG_CONST.CARDSTEACH_GAME_START,self.Start,self)
    self.bll:SendMsgToGuide(X3_CFG_CONST.CARDSTEACH_GAME_START,self.bll:GetSubId())
end

return InitAction