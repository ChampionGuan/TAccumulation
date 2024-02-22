---Runtime.System.X3Game.Modules.MainHome.Ctrl/MainHomeNetworkCtrl.lua
---Created By 教主
--- Created Time 16:43 2021/7/8

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local BaseCtrl = require(MainHomeConst.BASE_CTRL)
---@class MainHomeNetworkCtrl:MainHomeBaseCtrl
local MainHomeNetworkCtrl = class("MainHomeNetworkCtrl",BaseCtrl)

function MainHomeNetworkCtrl:ctor()
    BaseCtrl.ctor(self)
    self.runningMap = PoolUtil.GetTable()
end

function MainHomeNetworkCtrl:Enter()
    BaseCtrl.Enter(self)
    self:RegisterEvent()
end

function MainHomeNetworkCtrl:Exit()
    self:UnRegisterEvent()
    BaseCtrl.Exit(self)
end

--region 网络协议收发相关

---网络协议参数
function MainHomeNetworkCtrl:GetParam(networkType,...)
    local req = PoolUtil.GetTable()
    if networkType == MainHomeConst.NetworkType.EVENT_FINISH then
        local eventId,dialogueId,checkList,actionId = select(1,...)
        req.EventID = eventId
        req.DialogueId = dialogueId
        req.CheckList = checkList
        req.ActionID = actionId or 0
    elseif networkType == MainHomeConst.NetworkType.GET_BOX_LOVE_TOKEN then
        local tokenId = select(1,...)
        if tokenId then
            req.LoveTokenID = tokenId
        end
    elseif networkType == MainHomeConst.NetworkType.SET_EVENT then
        req.EventID = select(1,...)
    elseif networkType == MainHomeConst.NetworkType.ADD_ROLE_INTERACTIVE_NUM then
        local roleId,count, stateId = select(1,...)
        req.CounterType = X3_CFG_CONST.COUNTER_TYPE_MAINUI_TOUCHTOUCH
        req.AddNum = count
        req.Params = {roleId, stateId}
    elseif networkType == MainHomeConst.NetworkType.ADD_ROLE_INTERACT_NUM then
        local roleId,actionType,count,needSave = select(1,...)
        req.RoleID = roleId
        req.ActionType = actionType
        req.AddNum = count
        req.TaskCountHist = needSave or false
    elseif networkType == MainHomeConst.NetworkType.SET_INTERACTIVE_ENABLE then
        local isEnable = select(1,...)
        req.InterActive = isEnable or false
    elseif networkType == MainHomeConst.NetworkType.ADD_ROLE_INTERACTIVE_BODY_TYPE_NUM then
        local roleId,count, bodyPartType, taskCountID = select(1,...)
        req.CounterType = X3_CFG_CONST.COUNTER_TYPE_MAINUI_BODYPARTNUM
        req.AddNum = count
        req.Params = {roleId, bodyPartType}
        req.Param6 = taskCountID
    end
    return req
end

---@param msg pbcmessage.MainUIRefreshReply
function MainHomeNetworkCtrl:MainUIRefreshReply(msg)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_STATE_REFRESH_REPLAY,msg.IsRefresh)
end

---特殊事件完成
function MainHomeNetworkCtrl:MainUIEventFinishReply(msg)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_CHECK_EVENT_END)
    if  msg then
        UICommonUtil.ShowRewardPopTips(msg.RewardList, 2)
    end
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_STATE_CHANGED)
    self.bll:SendMsgToGuide(MainHomeConst.CHECK_GUIDE)
end

---点击宝箱奖励
function MainHomeNetworkCtrl:GetBoxRewardReply(msg)
    if  msg then
        UICommonUtil.ShowRewardPopTips(msg.RewardList, 2)
    end
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_STATE_CHANGED)
end

---点击gift奖励
function MainHomeNetworkCtrl:GetBoxLoveTokenReply(msg)
    if not msg then
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_STATE_CHANGED)
        return
    end
    local item = LuaCfgMgr.Get("Item",msg.LoveTokenID)
    if not item then
        return
    end

    UIMgr.Open(UIConf.LoveTokenShow,item, msg.RewardList)
    EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_AI_STATE_CHANGED)
end

function MainHomeNetworkCtrl:MainUIEventSetReply(msg)

end

---@param msg pbcmessage.AddSpecialNumReply
function MainHomeNetworkCtrl:AddSpecialNumReply(msg)

end

---@param msg pbcmessage.AddRoleInteractiveNumReply
function MainHomeNetworkCtrl:AddRoleInteractiveNumReply(msg)
end

---@param msg pbcmessage.AddSpInteractiveNumReply
function MainHomeNetworkCtrl:AddSpInteractiveNumReply(msg)
end

---@param msg pbcmessage.MainUISetActiveReply
function MainHomeNetworkCtrl:MainUISetActiveReply(msg)
    --local data = self.bll:GetData()
    --data:SetMode(msg.InterActive and MainHomeConst.ModeType.INTERACT or MainHomeConst.ModeType.NORMAL,true) 
end

---@param msg pbcmessage.MainUICheckActiveReply
function MainHomeNetworkCtrl:MainUICheckActiveReply(msg)
    
end

--endregion

function MainHomeNetworkCtrl:SetIsRunning(networkType,isRunning)
    if not isRunning then
        isRunning = nil
    end
    self.runningMap[networkType] = isRunning
    BaseCtrl.SetIsRunning(self,not table.isnilorempty(self.runningMap))
end

function MainHomeNetworkCtrl:GetSender(networkType,...)
    local conf = MainHomeConst.NetworkConf[networkType]
    if conf then
        return conf[1],conf[3]
    end
    Debug.LogErrorFormat("[MainHome]GetSender[%s]--failed",networkType)
    return nil
end

function MainHomeNetworkCtrl:GetReceiver(networkType)
    local conf = MainHomeConst.NetworkConf[networkType]
    if conf then
        return self[conf[2]],self
    end
    return nil
end

function MainHomeNetworkCtrl:OnEventSendRequest(networkType,...)
    if networkType == MainHomeConst.NetworkType.EVENT_FINISH  then
        --设置/完成特殊事件需要判断是否锁定刷新状态
        if self.bll:GetData():IsLockState() then
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_9280)
            return
        end
    end
    local sender,isRunning = self:GetSender(networkType)
    if sender then
        self:SetIsRunning(networkType,isRunning)
        local param = self:GetParam(networkType,...)
        if isRunning then
            GrpcMgr.SendRequest(sender,param)
        else
            if sender == RpcDefines.CounterUpdateRequest then
                BllMgr.GetCounterBLL():SetCounterUpdateData(param.CounterType, param.AddNum, param.Params, param.Param6 , param.Param7)
            else
                GrpcMgr.SendRequestAsync(sender,param)
            end
        end
        PoolUtil.ReleaseTable(param)
    end
end

function MainHomeNetworkCtrl:OnEventReceiveMsg(networkType,msg)
    local receiver,target = self:GetReceiver(networkType)
    if receiver then
        receiver(target,msg)
        self:SetIsRunning(networkType)
    end
end


function MainHomeNetworkCtrl:RegisterEvent()
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_SEND_REQUEST,self.OnEventSendRequest,self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_RECEIVE_MSG,self.OnEventReceiveMsg,self)
end


return MainHomeNetworkCtrl