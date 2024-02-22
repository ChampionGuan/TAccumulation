﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/3/9 14:17
---
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.MainHomeBaseAIAction")
---停止action
---Category:MainHome
---@class MainHomeClearAction:MainHomeBaseAIAction
---@field clearType AIVar | int
local MainHomeClearAction = class("MainHomeClearAction",AIAction)

function MainHomeClearAction:OnEnter()
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_CLEAR_ACTION,self.clearType:GetValue())
end

return MainHomeClearAction