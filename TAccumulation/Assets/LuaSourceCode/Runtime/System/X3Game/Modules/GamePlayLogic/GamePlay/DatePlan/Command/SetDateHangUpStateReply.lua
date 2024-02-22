---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Rec_SetDateHangUpStateReply:PureLogic.ICommand
---@field entity PureLogic.ClientEntity
local Rec_SetDateHangUpStateReply = class('SetDateHangUpStateReply',ICommand)

---执行命令
---@param reply pbcmessage.SetDateHangUpStateReply
function Rec_SetDateHangUpStateReply:OnCommand(reply)
    
end

return Rec_SetDateHangUpStateReply