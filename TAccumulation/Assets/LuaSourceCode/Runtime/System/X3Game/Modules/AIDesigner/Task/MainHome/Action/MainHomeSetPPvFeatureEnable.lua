---Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action/MainHomeSetPPvFeatureEnable.lua
---Created By 教主
--- Created Time 10:42 2021/7/15

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.MainHomeBaseAIAction")
---控制人物特写
---Category:MainHome
---@class MainHomeSetPPvFeautureEnable:MainHomeBaseAIAction
---@field localFeatureEnabled Boolean
local MainHomeSetPPvFeautureEnable = class("MainHomeSetPPvFeautureEnable", AIAction)

function MainHomeSetPPvFeautureEnable:OnAwake()
    AIAction.OnAwake(self)
   self.localFeatureEnabled = nil
end

function MainHomeSetPPvFeautureEnable:OnPause(paused)
    self.localFeatureEnabled = nil
end

function MainHomeSetPPvFeautureEnable:OnEnter()
    local g_v = self.bll:IsHandlerRunning(MainHomeConst.HandlerType.FeatureEnabled)
    if self.localFeatureEnabled~=g_v then
        self.localFeatureEnabled = g_v
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_PPV_FEATURE_ENABLE,self.localFeatureEnabled)
    end

end

function MainHomeSetPPvFeautureEnable:OnUpdate()
    return AITaskState.Success
end



return MainHomeSetPPvFeautureEnable