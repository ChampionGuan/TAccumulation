---Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action/MainHomeSetWndTouchEnable.lua
---Created By 教主
--- Created Time 15:54 2021/7/19

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.MainHomeBaseAIAction")
---设置主界面受否可以点击操作
---true/false
---Category:MainHome
---@class MainHomeSetWndTouchEnable:MainHomeBaseAIAction
---@field touchEnable Boolean
local MainHomeSetWndTouchEnable = class("MainHomeSetWndTouchEnable", AIAction)
local isTouchEnable = nil

function MainHomeSetWndTouchEnable:OnPause(paused)
    if paused then
        isTouchEnable = nil
    end
end

function MainHomeSetWndTouchEnable:OnEnter()
    if isTouchEnable~=self.touchEnable then
        isTouchEnable = self.touchEnable
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_WND_TOUCH_ENABLE,self.touchEnable)
    end
end

function MainHomeSetWndTouchEnable:OnUpdate()
    return AITaskState.Success
end


return MainHomeSetWndTouchEnable