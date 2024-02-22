---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class AT_MiaoSPUndoReply:PureLogic.ICommand
local AT_MiaoSPUndoReply = class('MiaoSPUndoReply',ICommand)

function AT_MiaoSPUndoReply:ctor()
    ---@type PureLogic.ClientEntity
    self.entity = nil
    ICommand.ctor(self)
end


---执行命令
---@param reply pbcmessage.MiaoSPUndoReply
function AT_MiaoSPUndoReply:OnCommand(reply)
    print("ReceiveCommand - cmdType : MiaoSPUndoReply")
    local bbComp = self.entity:GetComponent(Miao.Component.Debug.BlackboardComp)
    bbComp:ParseData(reply)

    local player = bbComp:GetPlayer(Miao.MiaoPlayerPos.MiaoPlayerPosP1)
    local playerAIComp = self.entity:GetComponent(Miao.Component.Debug.PlayerAIComp)
    playerAIComp:ExecutePlayCardAILogic(player)
    
    --bbComp:TryToPlayCard()
end

return AT_MiaoSPUndoReply