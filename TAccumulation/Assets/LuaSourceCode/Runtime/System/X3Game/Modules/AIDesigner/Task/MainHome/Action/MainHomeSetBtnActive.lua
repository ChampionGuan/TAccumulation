﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/3/28 15:47
---
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.MainHomeBaseAIAction")
---主界面左右按钮显隐逻辑
---Category:MainHome
---@class MainHomeSetBtnActive:MainHomeBaseAIAction
local MainHomeSetBtnActive = class("MainHomeSetBtnActive", AIAction)
function MainHomeSetBtnActive:OnAwake()
    AIAction.OnAwake(self)
    self.btnActive = nil
end

function MainHomeSetBtnActive:OnEnter()
    local g_v = self.bll:IsHandlerRunning(MainHomeConst.HandlerType.BtnActive)
    if g_v~=self.btnActive then
        self.btnActive = g_v
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_REFRESH_BTN,self.btnActive)
    end
end

return MainHomeSetBtnActive