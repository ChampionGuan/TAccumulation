---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class AT_InitMiaoHandReply:PureLogic.ICommand
local AT_InitMiaoHandReply = class('InitMiaoHandReply',ICommand)




---执行命令
---@param reply pbcmessage.InitMiaoHandReply
function AT_InitMiaoHandReply:OnCommand(reply)

end

return AT_InitMiaoHandReply