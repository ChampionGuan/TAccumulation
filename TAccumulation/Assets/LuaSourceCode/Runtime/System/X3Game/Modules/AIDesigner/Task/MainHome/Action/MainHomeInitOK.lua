﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/11/21 17:54
---
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.MainHomeBaseAIAction")
---停止action
---Category:MainHome
---@class MainHomeInitOK:MainHomeBaseAIAction
---@field actionId AIVar | int
---@field breakType AIVar | int
local MainHomeInitOK = class("MainHomeInitOK",AIAction)

function MainHomeInitOK:OnEnter()
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_INIT_OK)
end

return MainHomeInitOK