---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Rec_StartLetterReply:PureLogic.ICommand
---@field entity PureLogic.ClientEntity
local Rec_StartLetterReply = class('StartLetterReply',ICommand)

---执行命令
---@param reply pbcmessage.StartLetterReply
function Rec_StartLetterReply:OnCommand(reply)
    local DatePlanConst = require("Runtime.System.X3Game.Modules.DatePlan.DatePlanConst")
    EventMgr.Dispatch(DatePlanConst.LogicEventType.DatePlanOnStartLetter, reply)
end

return Rec_StartLetterReply