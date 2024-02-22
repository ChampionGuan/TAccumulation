﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/3/9 17:04
---
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.MainHomeBaseAIAction")
---管理主界面交互
---Category:MainHome
---@class MainHomeCloseLoading:MainHomeBaseAIAction
local MainHomeCloseLoading = class("MainHomeCloseLoading", AIAction)

function MainHomeCloseLoading:OnEnter()
    UICommonUtil.SetLoadingProgress(1,true)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_LOADING_FINISH)
end

return MainHomeCloseLoading