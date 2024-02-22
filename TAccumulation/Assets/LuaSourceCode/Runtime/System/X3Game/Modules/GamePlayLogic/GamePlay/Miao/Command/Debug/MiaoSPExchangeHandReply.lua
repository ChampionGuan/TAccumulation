---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class AT_MiaoSPExchangeHandReply:PureLogic.ICommand
local AT_MiaoSPExchangeHandReply = class('MiaoSPExchangeHandReply',ICommand)

function AT_MiaoSPExchangeHandReply:ctor()
    ---@type PureLogic.ClientEntity
    self.entity = nil
    ICommand.ctor(self)
end

---执行命令
---@param reply pbcmessage.MiaoSPExchangeHandReply
function AT_MiaoSPExchangeHandReply:OnCommand(reply)
    print("ReceiveCommand - cmdType : MiaoSPExchangeHandReply")
    local bbComp = self.entity:GetComponent(Miao.Component.Debug.BlackboardComp)
    bbComp:ParseData(reply)
    local trigger = bbComp:SendSPExchangedUndo()
    if not trigger then
        local player = bbComp:GetPlayer(Miao.MiaoPlayerPos.MiaoPlayerPosP1)
        local playerAIComp = self.entity:GetComponent(Miao.Component.Debug.PlayerAIComp)
        playerAIComp:ExecutePlayCardAILogic(player)
        --bbComp:TryToPlayCard()
    end
end

return AT_MiaoSPExchangeHandReply