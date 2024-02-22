﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/11/25 10:51
---
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.MainHomeBaseAIAction")
---管理主界面交互
---Category:MainHome
---@class MainHomeSetWndActive:MainHomeBaseAIAction
---@field isActive Boolean
local MainHomeSetWndActive = class("MainHomeSetWndActive", AIAction)


function MainHomeSetWndActive:OnEnter()
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_WND_ACTIVE,self.isActive,true)
end

return MainHomeSetWndActive