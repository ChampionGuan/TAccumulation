---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class AT_PlayMiaoCardReply:PureLogic.ICommand
local AT_PlayMiaoCardReply = class('PlayMiaoCardReply',ICommand)

function AT_PlayMiaoCardReply:ctor()
    ---@type PureLogic.ClientEntity
    self.entity = nil
    ICommand.ctor(self)
end

---执行命令
---@param reply pbcmessage.PlayMiaoCardReply
function AT_PlayMiaoCardReply:OnCommand(reply)
    print("ReceiveCommand - cmdType : PlayMiaoCardReply")
    local bbComp = self.entity:GetComponent(Miao.Component.Debug.BlackboardComp)
    bbComp:ParseData(reply)

    local data = bbComp:GetBlackboardData()
    if data.subState == Miao.MiaoSubState.MiaoSubStateNumPlus then
        if bbComp:HasBuff(Miao.MiaoPlayerPos.MiaoPlayerPosP1,Miao.MiaoBuffType.MiaoBuffTypeNumPlus) then
            local player = bbComp:GetPlayer(Miao.MiaoPlayerPos.MiaoPlayerPosP1)
            local playerAIComp = self.entity:GetComponent(Miao.Component.Debug.PlayerAIComp)
            playerAIComp:ExecutePlayCardAILogic(player)
            return
        end
    end

    -- 没有额外出牌阶段，出完数字牌直接进入下一回合
    bbComp:SendToServer(Miao.Command.AddMiaoTurnRequest)
end

return AT_PlayMiaoCardReply