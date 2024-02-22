---Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action/MainHomeSetTouchEnable.lua
---Created By 教主
--- Created Time 19:51 2021/7/2
---主界面交互点击开关

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.MainHomeBaseAIAction")
---设置主界面受否可以点击操作
---true/false
---Category:MainHome
---@class MainHomeSetTouchEnable:MainHomeBaseAIAction
---@field touchEnable Boolean
local MainHomeSetTouchEnable = class("MainHomeSetTouchEnable", AIAction)
local isTouchEnable

function MainHomeSetTouchEnable:OnPause(paused)
    isTouchEnable = nil
end

function MainHomeSetTouchEnable:OnEnter()
    if self.touchEnable~= isTouchEnable then
        isTouchEnable = self.touchEnable
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_TOUCH_ENABLE,self.touchEnable)
    end
end

function MainHomeSetTouchEnable:OnUpdate()
    return AITaskState.Success
end


return MainHomeSetTouchEnable