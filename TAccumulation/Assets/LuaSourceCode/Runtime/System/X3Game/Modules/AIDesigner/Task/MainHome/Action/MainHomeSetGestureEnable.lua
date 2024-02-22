---Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action/MainHomeSetGestureEnable.lua
---Created By 教主
--- Created Time 15:54 2021/7/19

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.MainHomeBaseAIAction")
---设置主界面受否可以点击操作
---true/false
---Category:MainHome
---@class MainHomeSetGestureEnable:MainHomeBaseAIAction
---@field touchEnable Boolean
local MainHomeSetGestureEnable = class("MainHomeSetGestureEnable", AIAction)

local isTouchEnable = nil


function MainHomeSetGestureEnable:OnPause(paused)
    if paused then
        isTouchEnable = nil
    end
end

function MainHomeSetGestureEnable:OnEnter()
    if isTouchEnable ~=self.touchEnable then
        isTouchEnable = self.touchEnable
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_GESTURE_ENABLE,self.touchEnable)
    end

end

function MainHomeSetGestureEnable:OnUpdate()
    return AITaskState.Success
end


return MainHomeSetGestureEnable