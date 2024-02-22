---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Rec_StartDateContentReply:PureLogic.ICommand
---@field entity PureLogic.ClientEntity
local Rec_StartDateContentReply = class('StartDateContentReply',ICommand)

---执行命令
---@param reply pbcmessage.StartDateContentReply
function Rec_StartDateContentReply:OnCommand(reply)
    ---@type DatePlanConst
    local DatePlanConst = require("Runtime.System.X3Game.Modules.DatePlan.DatePlanConst")
    EventMgr.Dispatch(DatePlanConst.LogicEventType.DatePlanOnStartContent, reply)
end

return Rec_StartDateContentReply