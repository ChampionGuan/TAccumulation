---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class AT_MiaoSPExchangeHandUndoReply:PureLogic.ICommand
local AT_MiaoSPExchangeHandUndoReply = class('MiaoSPExchangeHandUndoReply',ICommand)

function AT_MiaoSPExchangeHandUndoReply:ctor()
    ---@type PureLogic.ClientEntity
    self.entity = nil
    ICommand.ctor(self)
end

---执行命令
---@param reply pbcmessage.MiaoSPExchangeHandUndoReply
function AT_MiaoSPExchangeHandUndoReply:OnCommand(reply)
    print("ReceiveCommand - cmdType : MiaoSPExchangeHandUndoReply")
    local bbComp = self.entity:GetComponent(Miao.Component.Debug.BlackboardComp)
    bbComp:ParseData(reply)
    bbComp:SendToServer(Miao.Command.AddMiaoTurnRequest)
end

return AT_MiaoSPExchangeHandUndoReply