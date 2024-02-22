---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class AT_GetMiaoDataReply:PureLogic.ICommand
local AT_GetMiaoDataReply = class('GetMiaoDataReply',ICommand)

function AT_GetMiaoDataReply:ctor()
    ---@type PureLogic.ClientEntity
    self.entity = nil
    ICommand.ctor(self)
end

---执行命令
---@param reply pbcmessage.GetMiaoDataReply
function AT_GetMiaoDataReply:OnCommand(reply)

end

return AT_GetMiaoDataReply