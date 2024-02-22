---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class AT_MiaoSPRobReply:PureLogic.ICommand
local AT_MiaoSPRobReply = class('MiaoSPRobReply',ICommand)


function AT_MiaoSPRobReply:ctor()
    ---@type PureLogic.MiaoLogicEntity
    self.entity = nil
    ICommand.ctor(self)
end

---执行命令
---@param reply pbcmessage.MiaoSPRobReply
function AT_MiaoSPRobReply:OnCommand(reply)
   
end

return AT_MiaoSPRobReply