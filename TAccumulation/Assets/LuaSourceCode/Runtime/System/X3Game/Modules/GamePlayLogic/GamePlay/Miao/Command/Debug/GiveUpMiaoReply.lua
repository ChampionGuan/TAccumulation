---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class AT_GiveUpMiaoReply:PureLogic.ICommand
local AT_GiveUpMiaoReply = class('GiveUpMiaoReply',ICommand)


function AT_GiveUpMiaoReply:ctor()
    ---@type PureLogic.MiaoLogicEntity
    self.entity = nil
    ICommand.ctor(self)
end

---执行命令
---@param reply pbcmessage.GiveUpMiaoReply
function AT_GiveUpMiaoReply:OnCommand(reply)

end

return AT_GiveUpMiaoReply