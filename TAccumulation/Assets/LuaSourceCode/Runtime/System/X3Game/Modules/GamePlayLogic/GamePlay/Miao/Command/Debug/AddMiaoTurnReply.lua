---@type PureLogic.ICommand
local ICommand = require("PureLogic.Common.Command.ICommand")
---@class AT_AddMiaoTurnReply:PureLogic.ICommand
local AT_AddMiaoTurnReply = class('AddMiaoTurnReply',ICommand)

function AT_AddMiaoTurnReply:ctor()
    ---@type PureLogic.ClientEntity
    self.entity = nil
    ICommand.ctor(self)
end

---执行命令
---@param reply pbcmessage.AddMiaoTurnReply
function AT_AddMiaoTurnReply:OnCommand(reply)
    print("ReceiveCommand - cmdType : AddMiaoTurnReply,state : " .. reply.State)
    local bbComp = self.entity:GetComponent(Miao.Component.Debug.BlackboardComp)
    print("ReceiveCommand - cmdType : AddMiaoTurnReply, 1")
    bbComp:ParseData(reply)
    print("ReceiveCommand - cmdType : AddMiaoTurnReply, 2")
    if reply.State == Miao.MiaoState.MiaoStateEnd then
        local data = bbComp:GetBlackboardData()
        local subTD = bbComp:GetDifficultyCfg()
        if data.roundCount < subTD.Round then
            -- 进入下一轮, 大于三轮说明GameOver
            bbComp:SendToServer(Miao.Command.GM.StartAITestRequest)
        else
            -- 结束了，记录当前跑测的结果    
            self:RecordAITestResult()
        end
        return
    end
    
    local p1 = reply.MiaoPlayers[Miao.MiaoPlayerPos.MiaoPlayerPosP1]
    ---@type pbcmessage.MiaoSPRecord
    local spRecords = reply.SPRecords
    ---@type pbcmessage.MiaoSPAction
    local spAction =  reply.SPAction
    -- 检查是否触发了SP
    local triggerSP = bbComp:CheckSPAction(p1, spRecords,spAction)
    if not triggerSP then
        local player = bbComp:GetPlayer(reply.Seat)
        local playerAIComp = self.entity:GetComponent(Miao.Component.Debug.PlayerAIComp)
        playerAIComp:ExecutePlayCardAILogic(player)
        --bbComp:TryToPlayCard()
    end
end

function AT_AddMiaoTurnReply:RecordAITestResult()
    local bbComp = self.entity:GetComponent(Miao.Component.Debug.BlackboardComp)
    local data = bbComp:GetBlackboardData()
    local winCount = 0
    for k,v in pairs(data.resultList) do
        PURELOGIC_MIAO_TEST_RESULT[v] = PURELOGIC_MIAO_TEST_RESULT[v] + 1
        --if v == Miao.MiaoResultType.MiaoResultTypeWin then
        --    winCount = winCount + 1
        --end
    end
    local subTD = bbComp:GetDifficultyCfg()
    PURELOGIC_MIAO_TEST_RESULT[0] = subTD.Round
    --local winResult = winCount > subTD.Round / 2
    ---- 跑测用的
    --PURELOGIC_MIAO_TEST_RESULT = winResult
end

return AT_AddMiaoTurnReply