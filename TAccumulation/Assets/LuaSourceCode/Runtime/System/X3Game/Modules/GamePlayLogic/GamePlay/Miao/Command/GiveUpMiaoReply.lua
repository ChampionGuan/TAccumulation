---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Rec_GiveUpMiaoReply:PureLogic.ICommand
local Rec_GiveUpMiaoReply = class('GiveUpMiaoReply',ICommand)

---执行命令
---@param reply pbcmessage.GiveUpMiaoReply
function Rec_GiveUpMiaoReply:OnCommand(reply)

end

return Rec_GiveUpMiaoReply