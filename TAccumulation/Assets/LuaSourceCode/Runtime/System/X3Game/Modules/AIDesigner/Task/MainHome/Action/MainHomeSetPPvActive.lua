---Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action/MainHomeSetPPvActive.lua
---Created By 教主
--- Created Time 14:58 2021/8/18

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.Plugins.AIDesigner.Base.AITask").AIAction
---控制黑屏过渡开关
---Category:MainHome
---@class MainHomeSetPPvActive:AIAction
---@field ppvActive Boolean
local MainHomeSetPPvActive = class("MainHomeSetPPvActive", AIAction)
function MainHomeSetPPvActive:OnAwake()
    ---@type MainHomeBLL
    self.bll = BllMgr.Get("MainHomeBLL")
end

function MainHomeSetPPvActive:OnEnter()
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_POST_PROCESS_ACTIVE,self.ppvActive)
end

function MainHomeSetPPvActive:OnUpdate()
    return AITaskState.Success
end



return MainHomeSetPPvActive