---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class AT_ReduceMiaoCountReply:PureLogic.ICommand
local AT_ReduceMiaoCountReply = class('ReduceMiaoCountReply',ICommand)

---执行命令
---@param reply pbcmessage.ReduceMiaoCountReply
function AT_ReduceMiaoCountReply:OnCommand(reply)
    
end

return AT_ReduceMiaoCountReply