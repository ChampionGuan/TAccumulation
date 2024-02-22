---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class Rec_SetDateContentRewardReply:PureLogic.ICommand
---@field entity PureLogic.ClientEntity
local Rec_SetDateContentRewardReply = class('SetDateContentRewardReply',ICommand)

---执行命令
---@param reply pbcmessage.SetDateContentRewardReply
function Rec_SetDateContentRewardReply:OnCommand(reply)
    
end

return Rec_SetDateContentRewardReply