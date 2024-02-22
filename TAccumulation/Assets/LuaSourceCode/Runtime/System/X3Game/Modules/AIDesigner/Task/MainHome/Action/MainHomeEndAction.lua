﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/3/1 17:11
---
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.MainHomeBaseAIAction")
---停止action
---Category:MainHome
---@class MainHomeEndAction:MainHomeBaseAIAction
---@field actionId AIVar | int
---@field breakType AIVar | int
local MainHomeEndAction = class("MainHomeEndAction",AIAction)

function MainHomeEndAction:OnEnter()
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_END_INTERACT,self.actionId:GetValue(),self.breakType:GetValue())
end

return MainHomeEndAction