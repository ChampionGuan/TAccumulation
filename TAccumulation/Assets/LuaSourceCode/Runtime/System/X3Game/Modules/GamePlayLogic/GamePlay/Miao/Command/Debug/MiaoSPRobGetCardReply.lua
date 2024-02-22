---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class AT_MiaoSPRobGetCardReply:PureLogic.ICommand
local AT_MiaoSPRobGetCardReply = class('MiaoSPRobGetCardReply',ICommand)

function AT_MiaoSPRobGetCardReply:ctor()
    ---@type PureLogic.MiaoLogicEntity
    self.entity = nil
    ICommand.ctor(self)
end

---执行命令
---@param reply pbcmessage.MiaoSPRobGetCardReply
function AT_MiaoSPRobGetCardReply:OnCommand(reply)
  
    
end

return AT_MiaoSPRobGetCardReply