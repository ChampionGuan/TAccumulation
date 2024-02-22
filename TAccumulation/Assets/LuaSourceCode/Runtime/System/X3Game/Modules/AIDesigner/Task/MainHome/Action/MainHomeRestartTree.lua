---Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action/MainHomeRestartTree.lua
---Created By 教主
--- Created Time 19:10 2021/7/16

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.Plugins.AIDesigner.Base.AITask").AIAction
---控制actor显示
---Category:MainHome
---@class MainHomeRestartTree:AIAction
local MainHomeRestartTree = class("MainHomeRestartTree", AIAction)

function MainHomeRestartTree:OnAwake()
    ---@type MainHomeBLL
    self.bll = BllMgr.Get("MainHomeBLL")
end

function MainHomeRestartTree:OnEnter()
    if self.tree:GetVariable("bdState") ~= MainHomeConst.BdState.NONE then
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_PLAY_BD,true,nil,true)
    end
end

function MainHomeRestartTree:OnUpdate()
    return AITaskState.Success
end

return MainHomeRestartTree