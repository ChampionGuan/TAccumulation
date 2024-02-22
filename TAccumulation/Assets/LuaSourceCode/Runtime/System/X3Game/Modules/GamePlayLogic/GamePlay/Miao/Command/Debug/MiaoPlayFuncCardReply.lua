---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class AT_MiaoPlayFuncCardReply:PureLogic.ICommand
local AT_MiaoPlayFuncCardReply = class('MiaoPlayFuncCardReply',ICommand)

---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.GamePlayLogic.GamePlay.Miao.Const.MiaoConst")


function AT_MiaoPlayFuncCardReply:ctor()
    ---@type PureLogic.ClientEntity
    self.entity = nil
    ICommand.ctor(self)
end

---执行命令
---@param reply pbcmessage.MiaoPlayFuncCardReply
function AT_MiaoPlayFuncCardReply:OnCommand(reply)
    print("ReceiveCommand - cmdType : MiaoPlayFuncCardReply")
    local bbComp = self.entity:GetComponent(Miao.Component.Debug.BlackboardComp)
    bbComp:ParseData(reply)
    
    local playerAIComp = self.entity:GetComponent(Miao.Component.Debug.PlayerAIComp)
    
    local player = bbComp:GetPlayer(reply.Seat)
    for k, effect in pairs(reply.Effects) do
        local result, actType, target ,cardID = playerAIComp:HandleQueryEffect(player,effect)--  bbComp:CheckFuncQuery(effect)
        if result then
            local request = {
                ActionType = actType,
                Target = target,
                CardId = cardID
            }
            bbComp:SendToServer(Miao.Command.MiaoPlayFuncCardRequest,request)
            return
        end
    end
    
    local data = bbComp:GetBlackboardData()
    -- 表示女主结束
    if (data.seat == Miao.MiaoPlayerPos.MiaoPlayerPosP1 and data.state ==  CatCardConst.State.P1_ACT) or
            (data.seat == Miao.MiaoPlayerPos.MiaoPlayerPosP2 and data.state ==  CatCardConst.State.P2_ACT) then
        bbComp:SendToServer(Miao.Command.AddMiaoTurnRequest)
    else
        playerAIComp:ExecutePlayCardAILogic(player)
        -- playerAIComp:TryToPlayCard()
    end
end

return AT_MiaoPlayFuncCardReply