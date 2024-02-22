---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2019-12-30 15:05:20
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class MobileCallBLL
local MobileCallBLL = class("MobileCallBLL", BaseBll)

function MobileCallBLL:OnInit()
    EventMgr.AddListener("Mobile_Contact_Add", self.OnCallRpUpdate, self)
    EventMgr.AddListener("ActivePhoneCall", self.OnDialogCall, self)
    EventMgr.AddListener("MobileCallRemind_Open", self.OnFakeMobileCallOpen, self)
    EventMgr.AddListener("MobileCallRemind_Close", self.OnFakeMobileCallClose, self)
    self.CallDictionary = {} --好友对话列表，存储所有对话信息
    ---dialogue相关
    self.virtualCamera = nil
    self.sceneObj = nil
    self.baseDialogueAgr = nil
    ---0205临时处理
    self.tempList = {1401, 2401, 5401, 513}
end

function MobileCallBLL:IsInTempList(callID)
    return table.containsvalue(self.tempList, callID)
end

function MobileCallBLL:GetTempCallIndex(callID)
    for k, v in ipairs(self.tempList) do
        if v == callID then
            return k
        end
    end
end

function MobileCallBLL:SetCallHasShow(callID)
    local index = self:GetTempCallIndex(callID)
    if index == nil then
        return
    end
    BllMgr.GetPlayerServerPrefsBLL():SetBool(GameConst.CustomDataIndex[string.format("TEMP_CALL_HAS_SHOW%d", index)], true)
end

function MobileCallBLL:GetCallHasShow(callID)
    local index = self:GetTempCallIndex(callID)
    if index == nil then
        return
    end
    return BllMgr.GetPlayerServerPrefsBLL():GetBool(GameConst.CustomDataIndex[string.format("TEMP_CALL_HAS_SHOW%d", index)], false)
end

function MobileCallBLL:OnClear()
    --self:ExitCallBack()
    self:ExitDialogue(2)
    EventMgr.RemoveListenerByTarget(self)
    TimerMgr.DiscardTimerByTarget(self)
end

function MobileCallBLL:Init(mData)
    if mData == nil then
        return
    end
    if mData.CallMap == nil then
        return
    end
    for k, v in pairs(mData.CallMap) do
        local callCfg = LuaCfgMgr.Get("PhoneCall", k)
        if callCfg.ShowTime ~= nil and callCfg.ShowTime ~= "" then
            local nowTime = TimerMgr.GetCurTimeSeconds()
            local endTime = TimerMgr.GetUnixTimestamp(GameHelper.GetDateByStr(callCfg.ShowTime))
            if endTime > nowTime then
                TimerMgr.AddTimer(endTime - nowTime, function()
                    self:AddNewPhoneCall(v)
                    EventMgr.Dispatch("Mobile_Call_AddCallCallBack", nil)
                end, self)
            else
                if self:IsInTempList(k) and (not self:GetCallHasShow(k)) then
                    self:AddNewPhoneCall(v)
                    EventMgr.Dispatch("Mobile_Call_AddCallCallBack", nil)
                else
                    self.CallDictionary[k] = v
                end
            end
        else
            self.CallDictionary[k] = v
        end
    end
    self:CheckRed()
end

function MobileCallBLL:GetCallDict()
    return self.CallDictionary
end

function MobileCallBLL:Add(mData)
    if mData == nil then
        return
    end
    if mData.CallList == nil then
        return
    end
    for i = 1, #mData.CallList do
        local getLocalData = self.CallDictionary[mData.CallList[i].ID]
        if getLocalData == nil then
            --新电话
            local PhoneCallData = LuaCfgMgr.Get("PhoneCall", mData.CallList[i].ID)
            if PhoneCallData.ShowDelayTime ~= nil then
                local delayTime = Mathf.Random(PhoneCallData.ShowDelayTime.ID, PhoneCallData.ShowDelayTime.Num)
                TimerMgr.AddTimer(delayTime, function()
                    self:AddNewPhoneCall(mData.CallList[i])
                    EventMgr.Dispatch("Mobile_Call_AddCallCallBack", nil)
                end, self)
            elseif PhoneCallData.ShowTime ~= nil and PhoneCallData.ShowTime ~= "" then
                local nowTime = TimerMgr.GetCurTimeSeconds()
                local endTime = TimerMgr.GetUnixTimestamp(GameHelper.GetDateByStr(PhoneCallData.ShowTime))
                if endTime > nowTime then
                    TimerMgr.AddTimer(endTime - nowTime, function()
                        self:AddNewPhoneCall(mData.CallList[i])
                        EventMgr.Dispatch("Mobile_Call_AddCallCallBack", nil)
                    end, self)
                else
                    self:AddNewPhoneCall(mData.CallList[i])
                end
            else
                self:AddNewPhoneCall(mData.CallList[i])
            end
        else
            self.CallDictionary[mData.CallList[i].ID] = mData.CallList[i]
            self:CheckRed(mData.CallList[i].ID)
        end
    end
    EventMgr.Dispatch("Mobile_Call_AddCallCallBack", nil)
end
---添加新的电话
function MobileCallBLL:AddNewPhoneCall(callReply)
    local PhoneCallData = LuaCfgMgr.Get("PhoneCall", callReply.ID)
    self.CallDictionary[callReply.ID] = callReply
    self:CheckRed(callReply.ID)
    if PhoneCallData.Principal ~= 0 and PhoneCallData.IsDialogueCall == 0 then
        local phoneSystemIsLock = SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_PHONE)
        local callIsLock = SysUnLock.IsUnLock(X3_CFG_CONST.SYSTEM_UNLOCK_TELEPHONE)
        local contactIsUnlock = BllMgr.GetMobileContactBLL():IsUnlockContact(PhoneCallData.Contact)
        local isShow = callIsLock and phoneSystemIsLock and contactIsUnlock
        if isShow then
            if PhoneCallData.Principal == 1 then
                --重要来电
                ErrandMgr.AddWithCallBack(X3_CFG_CONST.POPUP_PHONE_CALL_TIPS, function()
                    self:ShowCallWnd(callReply.ID, true)
                end)
            elseif PhoneCallData.Principal == 2 then
                ErrandMgr.Add(X3_CFG_CONST.POPUP_PHONE_CALL_TOP_TIPS, { callReply.ID })
            end
        end
    end
end
---剧情触发电话
function MobileCallBLL:OnDialogCall(arg)
    if arg == nil or arg.params == nil or arg.params[1] == nil then
        return
    end
    local callID = tonumber(arg.params[1])
    local PhoneCallData = LuaCfgMgr.Get("PhoneCall", callID)
    if self.CallDictionary[callID] == nil then
        if arg.handler then
            arg.handler()
        end
        return
    end
    self.baseDialogueAgr = arg
    if PhoneCallData.Principal == 1 then
        self:ShowCallWnd(callID, true, arg.handler, true)
    elseif PhoneCallData.Principal == 2 then
        UIMgr.Open(UIConf.MobileCallTipsWnd, { callID, arg.handler, true})
    end
end
---剧情中打开电话界面配合演出，无电话ID
function MobileCallBLL:OnFakeMobileCallOpen(arg)
    local params = arg.params
    UIMgr.Open(UIConf.MobileCallRemind, { PageType = tonumber(params[1]), ContactID = tonumber(params[2]), openByDialogue = true, isFakeCall = true, callType = tonumber(params[3]), acceptCallback = arg.handler})
end
---剧情中关闭电话界面配合演出
function MobileCallBLL:OnFakeMobileCallClose()
    UIMgr.Close(UIConf.MobileCallRemind)
end

function MobileCallBLL:GetCallData(callID)
    return self.CallDictionary[callID]
end

function MobileCallBLL:GetCallDataList(type)
    local retDataTab = {}
    for k, v in pairs(self.CallDictionary) do
        local phoneCallCfg = LuaCfgMgr.Get("PhoneCall", v.ID)
        if phoneCallCfg then
            if type then
                if phoneCallCfg.Type == type then
                    table.insert(retDataTab, v)
                end
            else
                table.insert(retDataTab, v)
            end
        end
    end
    return retDataTab
end

function MobileCallBLL:CTS_GetCallReward(callID, conversationID)
    local messageBody = {}
    messageBody.CallID = callID
    messageBody.ConversationID = conversationID
    GrpcMgr.SendRequest(RpcDefines.GetCallRewardRequest, messageBody, true)
end

function MobileCallBLL:CTS_SendCallBegin(callID)
    local messageBody = {}
    messageBody.CallID = callID
    --发送消息通知新手引导
    if LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PHONEGUIDECALLID) == callID then
        EventMgr.Dispatch(Const.Event.CLIENT_TO_GUIDE, X3_CFG_CONST.PHONE_CALL_GUIDE, callID, 0) --0代表开始
    end

    GrpcMgr.SendRequest(RpcDefines.AcceptRequest, messageBody, true)
end

function MobileCallBLL:CTS_SendCallEnd(callID)
    local messageBody = {}
    messageBody.CallID = callID
    GrpcMgr.SendRequest(RpcDefines.CallEndRequest, messageBody, true)
    --发送消息通知新手引导
    if LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PHONEGUIDECALLID) == callID then
        EventMgr.Dispatch(Const.Event.CLIENT_TO_GUIDE, X3_CFG_CONST.PHONE_CALL_GUIDE, callID, 1) --1代表结束
    end
end
--拒接某男主的电话
function MobileCallBLL:CTS_SendPhoneRefuse(roleID, callType)
    BllMgr.GetCounterBLL():SetCounterUpdateData(X3_CFG_CONST.COUNTER_TYPE_PHONEREFUSENUM,1,{ roleID, callType })
end

function MobileCallBLL:CheackAllMessage()
    for k, v in pairs(self.CallDictionary) do
        if v.Status == Define.MobileCallStatus.newStatus then
            return true
        end
    end
    return false
end

function MobileCallBLL:HasNotReadMessage(callID)
    local mCall = self.CallDictionary[callID]
    local phoneCallCfg = LuaCfgMgr.Get("PhoneCall", callID)
    if mCall == nil or phoneCallCfg == nil then
        return false
    end
    if not BllMgr.GetMobileContactBLL():IsUnlockContact(phoneCallCfg.Contact) then
        return false
    end
    if phoneCallCfg.IsDialogueCall == 1 then
        return false
    end
    return mCall.Status == Define.MobileCallStatus.newStatus
end

function MobileCallBLL:UpdateCallStatus(callID, status)
    local mCall = self.CallDictionary[callID]
    if mCall ~= nil then
        mCall.Status = status
    end
    self:CheckRed(callID)
end

--给个人信息用的收集度接口
function MobileCallBLL:GetCollectionProgress(manType)
    local allPhoneCall = LuaCfgMgr.GetAll("PhoneCall")
    local allCallNum = 0
    local curHaveCallNum = 0
    for k, v in pairs(allPhoneCall) do
        if v.Contact == manType and (v.IsShow == 1 or self:GetCallData(v.ID) ~= nil) then
            allCallNum = allCallNum + 1
            if self:GetCallData(v.ID) ~= nil then
                curHaveCallNum = curHaveCallNum + 1
            end
        end
    end
    return curHaveCallNum, allCallNum
end

-------------------手机电话红点相关--------------------
function MobileCallBLL:CheckRed(call_id)
    if call_id then
        local is_un_read = self:HasNotReadMessage(call_id)
        local callCfg = LuaCfgMgr.Get("PhoneCall", call_id)
        if callCfg.Type == 1 then
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_CALL_CALLLIST, is_un_read and 1 or 0, call_id)
        else
            RedPointMgr.UpdateCount(X3_CFG_CONST.RED_PHONE_CALL_VIDEOLIST, is_un_read and 1 or 0, call_id)
        end
    else
        RedPointMgr.CLearRedCountMapByID(X3_CFG_CONST.RED_PHONE_CALL_CALLLIST)
        RedPointMgr.CLearRedCountMapByID(X3_CFG_CONST.RED_PHONE_CALL_VIDEOLIST)
        for k, v in pairs(self.CallDictionary) do
            self:CheckRed(k)
        end
    end
end
---新增联系人时刷新红点
function MobileCallBLL:OnCallRpUpdate(contentData)
    for k, v in pairs(self.CallDictionary) do
        local redPointNum = RedPointMgr.GetCount(X3_CFG_CONST.RED_PHONE_CALL_CALLLIST, v.ID) + RedPointMgr.GetCount(X3_CFG_CONST.RED_PHONE_CALL_VIDEOLIST, v.ID)
        if redPointNum <= 0 then
            local phoneCallCfg = LuaCfgMgr.Get("PhoneCall", v.ID)
            if contentData.ID == phoneCallCfg.Contact then
                self:CheckRed(v.ID)
            end
        end
    end
end

--region 功能跳转
function MobileCallBLL:JumpToCallList(manID, panelIndex)
    UIMgr.Open(UIConf.MobileMainWnd, Define.MobileTab.Call, manID, nil, panelIndex)
end

function MobileCallBLL:JumpToCall(callID)
    if self.CallDictionary[callID] == nil then
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_5782)
        return
    end
    self:ShowCallWnd(callID)
end

function MobileCallBLL:ShowCallWnd(callId, isRemind, overCallBack, isOpenByDialogue)
    local type = 2
    if isRemind then
        type = 1
    end
    local callCfg = LuaCfgMgr.Get("PhoneCall", callId)
    if callCfg then
        if callCfg.Type == 2 and (not isRemind) then
            UICommonUtil.WhiteScreenIn(function() UIMgr.Open(UIConf.MobileCallRemind, { PageType = type, CallID = callId, callBack = overCallBack , openByDialogue = isOpenByDialogue}) end)
        else
            UIMgr.Open(UIConf.MobileCallRemind, { PageType = type, CallID = callId, callBack = overCallBack, openByDialogue = isOpenByDialogue})
        end
    end
end

--endregion

--region Dialogue管理

---初始化对话
function MobileCallBLL:InitDialogue(phoneCallId, callBack, gameObject, closeCallBack, isOpenByDialogue)
    local phoneCallCfg = LuaCfgMgr.Get("PhoneCall", phoneCallId)
    if phoneCallCfg then
        if phoneCallCfg.Type == 2 then
            local sceneName = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.PHONEVIDEOCALLSCENE)
            local sceneCfg = LuaCfgMgr.Get("SceneInfo", sceneName)
            self.sceneObj = Res.LoadGameObject(sceneCfg.ScenePath)
            if self.sceneObj ~= nil then
                GameObjectUtil.SetPosition(self.sceneObj, 0 ,0, 0)
                GameObjectUtil.SetActive(self.sceneObj, true)
                SceneMgr.SetBGObject(sceneCfg.BackgroundNodePath)
            end
            self.virtualCamera = GlobalCameraMgr.CreateVirtualCamera(CameraModePath.AutoSyncMode)
            CutSceneMgr.SetCachePPVMode(true)
        end
        self.dialogueController = DialogueManager.InitByName("MobileVideoCall")
        self.system = self.dialogueController:InitDialogue(phoneCallCfg.Dialogue, Mathf.Random(1, 10000), nil, function()
            self.dialogueController:StartDialogueByName(phoneCallCfg.Dialogue, phoneCallCfg.ConversationDetail, nil, nil, function()
                if callBack then
                    callBack()
                end
            end)
            EventMgr.Dispatch("OnPhoneCallDialogStart")
        end)
        self.system:GetSettingData():SetShowAllBaseButton(true)
        self.system:GetSettingData():SetShowReviewButton(true)
        --self.system:GetSettingData():SetShowReviewButton(BllMgr.GetRoleBLL():IsUnlocked(phoneCallCfg.Contact))
        self.system:GetSettingData():SetSpeedUpBGM(false)
        if phoneCallCfg.Type == 2 then
            self.system:GetSettingData():SetShowAutoButton(false)
            self.system:GetSettingData():SetShowClickBg(false)
        else
            self.system:GetSettingData():SetShowAutoButton(true)
            self.system:GetSettingData():SetShowClickBg(true)
        end
        local callData = self:GetCallData(phoneCallId)
        if callData.Status == Define.MobileCallStatus.doneStatus and callData.Type == 2 then
            self.system:GetSettingData():SetShowPlaySpeedButton(true)
        else
            self.system:GetSettingData():SetShowPlaySpeedButton(false)
        end
        self.system:AddOuterUIObject(gameObject, closeCallBack)
        if isOpenByDialogue then
            if self.baseDialogueAgr.exitClickHandler ~= nil then
                self.system:RegisterExitClickHandler(handler(self, self.ExitCallBack))
            elseif self.baseDialogueAgr.exitHandler ~= nil then
                self.system:RegisterExitHandler(handler(self, self.ExitCallBack), self.baseDialogueAgr.exitString)
            end
        end
    end
end

---点击退出回调
function MobileCallBLL:ExitCallBack()
    if self.baseDialogueAgr == nil then
        return
    end
    if self.baseDialogueAgr.exitClickHandler ~= nil then
        self.baseDialogueAgr.exitClickHandler()
    elseif self.baseDialogueAgr.exitHandler ~= nil then
        self.baseDialogueAgr.exitHandler()
    end
end

---离开对话
function MobileCallBLL:ExitDialogue(type)
    if self.dialogueController == nil then
        return
    end
    if type == 2 then
        SceneMgr.ClearBGObject()
        ---没有切换场景，需手动清理场景中特效
        SceneMgr.ClearScene2DEffect()
        CutSceneMgr.SetCachePPVMode(false)
        CutSceneMgr.DestroyCachedPPV()
    end
    DialogueManager.ClearByName("MobileVideoCall")
    if self.virtualCamera ~= nil then
        GlobalCameraMgr.DestroyVirtualCamera(self.virtualCamera)
        self.virtualCamera = nil
    end
    if self.sceneObj then
        Res.DiscardGameObject(self.sceneObj)
        self.sceneObj = nil
    end
    self.dialogueController = nil
    self.baseDialogueAgr = nil
end
--endregion

return MobileCallBLL


