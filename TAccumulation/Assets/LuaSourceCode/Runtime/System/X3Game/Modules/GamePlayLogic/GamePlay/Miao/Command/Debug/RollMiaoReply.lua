---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class AT_RollMiaoReply:PureLogic.ICommand
local AT_RollMiaoReply = class('RollMiaoReply',ICommand)

---执行命令
---@param reply pbcmessage.RollMiaoReply
function AT_RollMiaoReply:OnCommand(reply)

end

return AT_RollMiaoReply