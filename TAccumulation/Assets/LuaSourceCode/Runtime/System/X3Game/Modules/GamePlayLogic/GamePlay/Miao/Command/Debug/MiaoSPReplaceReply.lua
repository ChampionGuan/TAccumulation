---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class AT_MiaoSPReplaceReply:PureLogic.ICommand
local AT_MiaoSPReplaceReply = class('MiaoSPReplaceReply',ICommand)

function AT_MiaoSPReplaceReply:ctor()
    ---@type PureLogic.MiaoLogicEntity
    self.entity = nil
    ICommand.ctor(self)
end

---执行命令
---@param reply pbcmessage.MiaoSPReplaceReply
function AT_MiaoSPReplaceReply:OnCommand(reply)
    print("ReceiveCommand - cmdType : MiaoSPReplaceReply")
    local bbComp = self.entity:GetComponent(Miao.Component.Debug.BlackboardComp)
    bbComp:ParseData(reply)
    
    local player = bbComp:GetPlayer(Miao.MiaoPlayerPos.MiaoPlayerPosP1)
    local playerAIComp = self.entity:GetComponent(Miao.Component.Debug.PlayerAIComp)
    playerAIComp:ExecutePlayCardAILogic(player)
    
    --bbComp:TryToPlayCard()
end

return AT_MiaoSPReplaceReply