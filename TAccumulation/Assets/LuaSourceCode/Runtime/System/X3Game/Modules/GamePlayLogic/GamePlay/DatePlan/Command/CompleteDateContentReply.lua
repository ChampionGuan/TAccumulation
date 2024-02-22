---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Rec_CompleteDateContentReply:PureLogic.ICommand
---@field entity PureLogic.ClientEntity
local Rec_CompleteDateContentReply = class('CompleteDateContentReply',ICommand)

---执行命令
---@param reply pbcmessage.CompleteDateContentReply
function Rec_CompleteDateContentReply:OnCommand(reply)
    local DatePlanConst = require("Runtime.System.X3Game.Modules.DatePlan.DatePlanConst")
    EventMgr.Dispatch(DatePlanConst.LogicEventType.DatePlanOnEndContent, reply)
end

return Rec_CompleteDateContentReply