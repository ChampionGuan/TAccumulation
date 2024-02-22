---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class AT_GetMiaoRewardReply:PureLogic.ICommand
local AT_GetMiaoRewardReply = class('GetMiaoRewardReply',ICommand)


function AT_GetMiaoRewardReply:ctor()
    ---@type PureLogic.ClientEntity
    self.entity = nil
    ICommand.ctor(self)
end

---执行命令
---@param reply pbcmessage.GetMiaoRewardReply
function AT_GetMiaoRewardReply:OnCommand(reply)

end

return AT_GetMiaoRewardReply