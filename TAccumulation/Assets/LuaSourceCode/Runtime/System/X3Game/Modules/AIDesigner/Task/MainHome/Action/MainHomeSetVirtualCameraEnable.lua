---Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action/MainHomeSetVirtualCameraEnable.lua
---Created By 教主
--- Created Time 15:10 2021/7/15

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.MainHomeBaseAIAction")
---设置虚拟相机是否可以操作
---true/false
---Category:MainHome
---@class MainHomeSetVirtualCameraEnable:MainHomeBaseAIAction
---@field localCameraEnabled Boolean
local MainHomeSetVirtualCameraEnable = class("MainHomeSetVirtualCameraEnable", AIAction)
local cameraEnabled = false

function MainHomeSetVirtualCameraEnable:OnEnter()
    if cameraEnabled~=self.localCameraEnabled then
        cameraEnabled = self.localCameraEnabled
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_VIRTUAL_CAMERA_ENABLE,self.localCameraEnabled)
    end
end

function MainHomeSetVirtualCameraEnable:OnUpdate()
    return AITaskState.Success
end

function MainHomeSetVirtualCameraEnable:OnDestroy()
    cameraEnabled = false
    EventMgr.RemoveListenerByTarget(self)
end

return MainHomeSetVirtualCameraEnable