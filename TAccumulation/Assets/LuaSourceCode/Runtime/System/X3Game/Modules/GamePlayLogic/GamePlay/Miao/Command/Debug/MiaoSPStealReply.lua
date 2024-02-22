---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class AT_MiaoSPStealReply:PureLogic.ICommand
local AT_MiaoSPStealReply = class('MiaoSPStealReply',ICommand)

function AT_MiaoSPStealReply:ctor()
    ---@type PureLogic.MiaoLogicEntity
    self.entity = nil
    ICommand.ctor(self)
end

---执行命令
---@param reply pbcmessage.MiaoSPStealReply
function AT_MiaoSPStealReply:OnCommand(reply)

end

return AT_MiaoSPStealReply