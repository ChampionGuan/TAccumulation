---Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action/MainHomeCloseDialogue.lua
---Created By 教主
--- Created Time 11:08 2021/7/5
local AIAction = require("Runtime.Plugins.AIDesigner.Base.AITask").AIAction
---关闭剧情
---Category:MainHome
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
---@class CloseDialogue:AIAction
local CloseDialogue = class("CloseDialogue", AIAction)

function CloseDialogue:OnAwake()
    ---@type MainHomeBLL
    self.bll = BllMgr.Get("MainHomeBLL")
end

function CloseDialogue:OnEnter()
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_CLOSE_DIALOGUE)
end

function CloseDialogue:OnUpdate()
    return AITaskState.Success
end


return CloseDialogue