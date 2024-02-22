﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by aoliao.
--- DateTime: 2022/12/7 11:37
---DailyConfideMgr
local cs_application = CS.UnityEngine.Application
---网络未连接
local cs_notReachable = CS.UnityEngine.NetworkReachability.NotReachable
---@class DailyConfideMgr
local DailyConfideMgr = class("DailyConfideMgr")
---@type DailyConfideConst
local DailyConfideConst = require("Runtime.System.X3Game.Modules.DailyConfide.Data.DailyConfideConst")

local DailyConfideHelper = CS.X3Game.DailyConfide.DailyConfideHelper

local PFAliyunASRUtility = CS.X3Game.Platform.PFAliyunASRUtility

local PFAudioSessionUtility = CS.X3Game.Platform.PFAudioSessionUtility

local AudioSessionUtil = require("Runtime.System.X3Game.Modules.AudioSession.AudioSessionUtil")

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
---@type AudioSessionConst
local AudioSessionConst = require("Runtime.System.X3Game.Modules.AudioSession.AudioSessionConst")
---做成面向对象吧，需要了才创建对象进行逻辑处理
function DailyConfideMgr:ctor()
    ---@type DailyConfideConst.DailyConfideState 倾诉的阶段
    self.dailyConfideState = DailyConfideConst.DailyConfideState.Opening
end
---DailyConfideMgr初始化
---@param actionData cfg.MainUIAction
function DailyConfideMgr:Init(actionData)
    ---@type bool 游戏开始计时
    self.gameBegin = false
    ---@type cfg.MainUIAction
    self.actionData = actionData
    ---@type int 男主ID
    self.roleID = self.actionData.ActorID
    ---@type table 等待的dialogue conversation
    self.waitConversation = nil
    ---@type table 倾诉主要的配置表 见DailyConfidey
    self.dailyConfideCfg = nil
    ---@type int 倾诉这次可以游玩多久的定时器ID
    self.dailyConfideTimeTickID = nil
    ---@type int 检查权限的时候延迟一帧检查，否则某些android机型不准（真我Q3）
    self.permissionChangeTickID = nil
    ---@type int 倾诉中断后再启动sdk的定时器ID
    self.interruptionTickID = nil
    ---@type int 策划配置的diaglogueID,通过DailyConfideEntry表拿到
    self.dialogueID = self.actionData.ActionDrama
    ---@type string 开场的conversation name ，俗称寒暄
    self.openingConversation = self.actionData.ActionConversation
    ---@type int 连麦可以游玩的倒计时
    self.leaveTime = 0
    ---@type bool voice sdk是否初始化
    self.sdkInit = false
    ---@type int dialogue 空闲一段时间后需要播放一个idle conversation , 这个就是控制倒计时
    self.idleTime = 0
    ---@type int dialogue 空闲一段时间后需要播放一个idle conversation , 这个就是空闲多长时间
    self.dailyConfideWaitingTime = nil
    ---@type string dialogue 空闲一段时间后需要播放一个idle conversation , 这个就是conversation name
    self.dailyConfideWaitingDrama = nil
    local stateData = BllMgr.GetMainHomeBLL():GetData()
    ---@type int Actor的资产ID
    self.assetID = stateData:GetAssetId()
    ---@type GameObject Actor
    self.manObj = BllMgr.GetMainHomeBLL():GetActor()
    ---@type DialogueController
    self.dialogueController = nil
    ---@type table tabble<DailyConfideConst.DailyConfideState> 记录上一次状态，做逻辑判断用的
    self.lastDailyPhoneState = {}
    ---@type number 记录下播放的是哪一个语义组
    self.playSemanticGroupID = nil
    ---@type bool 刚进入倾诉的时候是否有语音特权
    self.entryVoiceEnable = self:GetVoiceEnable(self.roleID)
    ---@type boolean
    self.PLEnd = false ---玩家主动退出，目前没有好滴办法解决退出状态的时候触发DialogueOver，暂时用这个标志位
    ---@type DialogueSystem
    self.dialogueSystem = nil
    ---@type boolean
    self.isPause = false ---是否处在主动暂停状态
    ---@type boolean
    self.hadCheckMute = false ---是否检查过静音（一次游玩只检测一次）
    ---@type number 要恢复的音量
    self.volume = nil;
    ---@type number 延迟多久进入寒暄剧情
    self.entryMeetingStateTickId = nil
    ---一开始是Openning状态，做初始化的一些事情
    self:SetDailyPhoneState(DailyConfideConst.DailyConfideState.Opening)
    self:InitConfig(self.roleID)
    self:InitEvent()
    self:InitMic()
    ---从主界面拿到Actor注入
    self:GetDialogueController():InjectGameObject(self.assetID, self.manObj)
    ---Actor初始化完毕可以进入寒暄状态了
    self:EntryMeetingState()
end

function DailyConfideMgr:OnWhiteScreenOut()
    local lastState = BllMgr.GetDailyConfideBll():GetMicState(self.roleID, self.entryVoiceEnable)
    local isLastOpen = lastState == DailyConfideConst.MicState.Open
    if (isLastOpen or self.lazyInitSDK) and Application.IsIOSMobile() then
        PFAudioSessionUtility.CheckMute(function(isMute)
            if isMute then
                self:PlayDialogue(self.openingConversation)
            else
                if self.entryMeetingStateTickId then
                    TimerMgr.Discard(self.entryMeetingStateTickId)
                end
                local delayTime = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.DAILYCONFIDEWWISEDELAY)
                if not delayTime then
                    delayTime = 2
                end
                self.entryMeetingStateTickId = TimerMgr.AddTimer(delayTime, function()
                    self:PlayDialogue(self.openingConversation)
                end, self)
            end
        end)
    else
        self:PlayDialogue(self.openingConversation)
    end
end

---@param dailyConfideState DailyConfideConst.DailyConfideState 设置当前倾诉状态
---@param isResume bool 是否是恢复设置，如果是不需要设置上次的状态
function DailyConfideMgr:SetDailyPhoneState(dailyConfideState, isResume)
    if not isResume or dailyConfideState == DailyConfideConst.DailyConfideState.Over then
        table.insert(self.lastDailyPhoneState, self.dailyConfideState)
    end
    if self.lastDailyPhoneState[#self.lastDailyPhoneState] ~= DailyConfideConst.DailyConfideState.Over then
        self.dailyConfideState = dailyConfideState
    end
    EventMgr.Dispatch(DailyConfideConst.StateChange, self.dailyConfideState)
end
---@return DailyConfideConst.DailyConfideState 上一次状态，做逻辑判断用的
function DailyConfideMgr:GetLastDailyPhoneState()
    return table.remove(self.lastDailyPhoneState)
end
---@return DailyConfideConst.DailyConfideState
function DailyConfideMgr:getDailyPhoneState()
    return self.dailyConfideState
end
---@return bool isSuc 初始化静态向量表
function DailyConfideMgr:InitStaticVector(role)
    DailyConfideHelper.CleanData()
    return DailyConfideHelper.InitStaticVector(role)
end
---进入倾诉，开始计算冷却CD
function DailyConfideMgr:EntryInnerDailyConfideGamePlay()
    self.gameBegin = true
    ---上报服务器倾诉开始
    BllMgr.GetDailyConfideBll():RequestStart(self.roleID)
    ---主界面计数
    ---local count = 1
    local actionTypeConf = BllMgr.GetMainHomeBLL():GetActionDataProxy():GetActionTypeCfgById(self.actionData.ID)
    local taskCountId = actionTypeConf.TaskCountID
    local needSave = actionTypeConf.DailyMaxRecord == 1
    if taskCountId ~= 0 then
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SEND_REQUEST, MainHomeConst.NetworkType.ADD_ROLE_INTERACT_NUM, self.roleID, actionTypeConf.Key, 1, needSave)
    end
    ---记录condition数据
    local curEmotion, curMatterType, curMatterSubType = self:GetDialogueVariable()
    BllMgr.GetDailyConfideBll():RecordConditionData(self.roleID, curEmotion, curMatterType, curMatterSubType)
end
---绑定事件
function DailyConfideMgr:InitEvent()
    EventMgr.AddListener(DailyConfideConst.VIPChange, self.onPermissionChange, self)
    EventMgr.AddListener(DailyConfideConst.DailyConfideTokenUpdate, self.onTokenUpdate, self)
    EventMgr.AddListener(DailyConfideConst.DailyConfideTalkReply, self.onDailyConfideTalkReply, self)
    EventMgr.AddListener(DailyConfideConst.GameFocus, self.OnGameFocus, self)
end

---初始化麦克风
function DailyConfideMgr:InitMic()
    if self:getMicEnable(self.roleID) and self:GetUserOpenMic() then
        self:InitVoice(self.roleID)
        self:InnerStartASR()
    end
end
---@return bool 设备是否有权打开mic
function DailyConfideMgr:GetDriveIsOpenMic()
    return BllMgr.GetDailyConfideBll():GetDriveIsOpenMic()
end
---@param Open bool 玩家选择是否打开mic
function DailyConfideMgr:SetUserOpenMic(Open)
    Debug.Log("【连麦】玩家选择是否打开:", Open)
    BllMgr.GetDailyConfideBll():SetUserOpenMic(Open)
end
---@param dontCheckVIP bool 不检查vip（收费的权限，是否可以使用语音）
---@return bool 是否是VIP可以用ASR
function DailyConfideMgr:GetVoiceEnable(roleID, dontCheckVIP)
    return BllMgr.GetDailyConfideBll():GetVoiceEnable(roleID, dontCheckVIP)
end
---@param Open bool 选择是否是VIP可以用ASR
function DailyConfideMgr:SetIsVoiceVIP(value)
    BllMgr.GetDailyConfideBll():SetIsVoiceVIP(value)
end
---@param sucCallBack function
---@param failCallBack function
---开始mic检测
function DailyConfideMgr:StartMicCheck(sucCallBack, failCallBack)
    BllMgr.GetDailyConfideBll():StartMicCheck(sucCallBack, failCallBack)
end
---设备mic权限改变的时候的回调
function DailyConfideMgr:OnPermissionChangeMicCheckCallBack()
    if self:getMicEnable(self.roleID) and (not self:GetIsSDKInit()) then
        ---因为这里状态改边了，所以不check用户是否自己选择打开
        self:InitVoice(self.roleID)
    end
    self:changeASRState(self:GetMicState(self.roleID))
end

---@param focus bool
function DailyConfideMgr:OnGameFocus(focus)
    if focus then
        if not UNITY_EDITOR then
            local lastState = BllMgr.GetDailyConfideBll():GetMicState(self.roleID, self.entryVoiceEnable)
            local isLastOpen = lastState == DailyConfideConst.MicState.Open
            if isLastOpen then
                self:StartASR(self.entryVoiceEnable)
            end
        end
    else
        if not UNITY_EDITOR then
            self:StopASR()
        end
    end
end

---设备mic权限改变的时候用的
function DailyConfideMgr:onPermissionChange()
    if not self.permissionChangeTickID then
        self.permissionChangeTickID = TimerMgr.AddTimerByFrame(1, handler(self, self.timeTick), self)
    end
end
---开始计时，超过一定时间要结束连麦或者播放待机动画
function DailyConfideMgr:timeTick()
    if self:GetVoiceEnable(self.roleID) then
        self:StartMicCheck(handler(self, self.OnPermissionChangeMicCheckCallBack), handler(self, self.OnPermissionChangeMicCheckCallBack))
    else
        self:OnPermissionChangeMicCheckCallBack()
    end
    TimerMgr.Discard(self.permissionChangeTickID)
    self.permissionChangeTickID = nil
end
---@param dontCheckVIP bool 不检查vip（收费的权限，是否可以使用语音）
---@return bool 两个都是true才说明mic可以使用
function DailyConfideMgr:GetMicReady(roleID, dontCheckVIP)
    return self:GetIsSDKInit() and self:getMicEnable(roleID, dontCheckVIP)
end

---@return bool voice sdk 是否初始化成功
function DailyConfideMgr:GetIsSDKInit()
    return self.sdkInit
end
---@param isSuc bool sdk 是否初始化成功
function DailyConfideMgr:SetIsSDKInit(isSuc)
    self.sdkInit = isSuc
end
---释放sdk
function DailyConfideMgr:DisposeSDK()
    self:StopASR()
    self:SetIsSDKInit(false)
    PFAliyunASRUtility.Release()
    AudioSessionUtil.ExitRecordMode()
    if self.volume then
        WwiseMgr.SetVolume(self.volume)
    end
    self:SetDelegate(nil)
end
---调用sdk的开始语音转文本接口
function DailyConfideMgr:InnerStartASR()
    if self:GetIsSDKInit() then
        if not self.lazyStartASR then
            local internetReachability = cs_application.internetReachability
            if internetReachability == cs_notReachable then
                UICommonUtil.ShowMessage(UITextConst.UI_TEXT_5110)--网络异常
                BllMgr.GetDailyConfideBll():SetUserOpenMic(false)
                BllMgr.GetDailyConfideBll():RequestToken()
            else
                self:InitializeAudioSessionSettings()
                local ret = PFAliyunASRUtility.StartDialogue()
                self.lazyStartASR = true
            end
        end
        EventMgr.Dispatch(DailyConfideConst.MicChange)
        if UNITY_EDITOR then
            ---编辑器手动触发回调
            self:OnOperateResult(DailyConfideConst.AliyunASRSubBuzyType.StartDialogue, DailyConfideConst.AliyunASROperateResult.Success)
        end
    end
end

---开始asr检查麦克风之后的回调
function DailyConfideMgr:startASRCheckMicCallBack()
    if self:GetDriveIsOpenMic() then
        ---调用StartASRCheckMicCallBack之前会SetDriveIsOpenMic这边检查一下权限
        self:InitVoice(self.roleID)
        self:InnerStartASR()
    end
end
---开始ASR 外部函数
---@param dontCheckVIP bool 不检查vip（收费的权限，是否可以使用语音）
function DailyConfideMgr:StartASR(dontCheckVIP)
    if self:GetVoiceEnable(self.roleID, dontCheckVIP) then
        if self:GetIsSDKInit() then
            self:InnerStartASR()
        else
            self:StartMicCheck(handler(self, self.startASRCheckMicCallBack), handler(self, self.startASRCheckMicCallBack))
        end
    else
        BllMgr.GetDailyConfideBll():OpenQuickShop(self.roleID)
    end

end
---关闭ASR
function DailyConfideMgr:StopASR()
    if self:GetIsSDKInit() and not self.lazyStartASR then
        PFAliyunASRUtility.CancelDialogue();
        AudioSessionUtil.ResetAudioSessionCategory();
    end
    EventMgr.Dispatch(DailyConfideConst.MicChange)
end
---@param Open bool 是否打开ASR
function DailyConfideMgr:changeASRState(Open)
    if self:GetIsSDKInit() then
        if Open then
            self:InnerStartASR()
        else
            self:StopASR()
        end
    end
end
---@param dontCheckVIP bool 不检查vip（收费的权限，是否可以使用语音）
---@return bool 获取mic是否打开，需要1.vip,2.sdk 初始化 3.设备有权限 4.用户默认打开
function DailyConfideMgr:GetMicState(roleID, dontCheckVIP)
    return self:GetMicReady(roleID, dontCheckVIP) and self:GetUserOpenMic()
end
---@return bool 用户是否选择打开mic
function DailyConfideMgr:GetUserOpenMic()
    return BllMgr.GetDailyConfideBll():GetUserOpenMic()
end
---@param dontCheckVIP bool 不检查vip（收费的权限，是否可以使用语音）
---@return bool 是否可以使用Mic vip用户and手机打开Mic权限，不包括sdk状态
function DailyConfideMgr:getMicEnable(roleID, dontCheckVIP)
    return BllMgr.GetDailyConfideBll():GetMicEnable(roleID, dontCheckVIP)
end

---@param role int 男主ID 初始化语音 ，取决于静态向量是否初始化完成和sdk是否初始化完成
function DailyConfideMgr:InitVoice(role)
    if not BllMgr.GetDailyConfideBll():CheckToken() then
        Debug.Log("【连麦】Token未获取，发送请求")
        BllMgr.GetDailyConfideBll():RequestToken()
        return
    end
    if self:GetIsSDKInit() then
        return
    end
    local initStaticVectorResult = self:InitStaticVector(role)

    if initStaticVectorResult then
        self:InitVoiceSDK()
        self.lazyInitSDK = true
        if UNITY_EDITOR then
            ---编辑器手动触发回调
            self:OnOperateResult(DailyConfideConst.AliyunASRSubBuzyType.Initialize,
                    DailyConfideConst.AliyunASROperateResult.Success)
        end
    else
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_11618)--检测到必要文件损坏，可尝试重启游戏进行修复（静态表问题）
        Debug.Log("【连麦】没有找到静态向量表。男主：", role)
        self:SetIsSDKInit(false)
        if UNITY_EDITOR then
            ---编辑器手动触发回调
            self:OnOperateResult(DailyConfideConst.AliyunASRSubBuzyType.Initialize,
                    DailyConfideConst.AliyunASROperateResult.UnknownError)
        end
    end
end

function DailyConfideMgr:InitVoiceSDK()
    self:InitializeAudioSessionSettings()
    self:SetDelegate(self)
    PFAliyunASRUtility.Initialize(DailyConfideConst.AliyunLogLevel.Error, self:GetSDKInitParam())
end

---初始化AudioSession的设置
function DailyConfideMgr:InitializeAudioSessionSettings()
    if self.hadCheckMute then
        AudioSessionUtil.SetCategoryWithOptionsAndMode(AudioSessionConst.Category.PlayAndRecord, (AudioSessionConst.CategoryOptions.AllowBluetooth | AudioSessionConst.CategoryOptions.DefaultToSpeaker), AudioSessionConst.Mode.VoiceChat);
    else
        self.hadCheckMute = true
        AudioSessionUtil.EnterRecordMode((AudioSessionConst.CategoryOptions.AllowBluetooth | AudioSessionConst.CategoryOptions.DefaultToSpeaker), AudioSessionConst.Mode.VoiceChat,
                function(isMute)
                    ---如果有声音，静音
                    if isMute then
                        self.volume = WwiseMgr.GetVolume()
                        WwiseMgr.SetVolume(0)
                    end
                end)
    end

end

---@param del X3Game.Platform.IPFAliyunASRDelegate
function DailyConfideMgr:SetDelegate(del)
    PFAliyunASRUtility.SetDelegate(del)
end

---@return string 获取sdk初始化json string
function DailyConfideMgr:GetSDKInitParam()
    local param = ""
    DailyConfideConst.AliyunInitParam.token = BllMgr.GetDailyConfideBll():GetToken()
    DailyConfideConst.AliyunInitParam.vocabulary = BllMgr.GetDailyConfideBll():GetKeyWord()
    param = JsonUtil.Encode(DailyConfideConst.AliyunInitParam)
    return param
end

---开始计时，超过一定时间要结束连麦或者播放待机动画
function DailyConfideMgr:InitDailyConfideTimeTick()
    if not self.dailyConfideTimeTickID then
        self.dailyConfideTimeTickID = TimerMgr.AddTimer(1, handler(self, self.dailyConfideTimeTick), self, true)
    end
    self.leaveTime = BllMgr.GetDailyConfideBll():GetBufferTime() --可以游玩的时间，单位是秒
    self:dailyConfideTimeTick()
end

---@param roleID int 男主ID 配置表和杂项配置初始化 目前所有男主共同用一套向量表
function DailyConfideMgr:InitConfig(roleID)
    local dailyConfideCfg = BllMgr.GetDailyConfideBll():GetDailyConfideRawCfg()
    self.dailyConfideCfg = {}
    ---这个表可能是乱序，所以用pairs
    for k, v in pairs(dailyConfideCfg) do
        self.dailyConfideCfg[v.SemanticGroupID] = v
    end

    self.dailyConfideWaitingTime = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.DAILYCONFIDEWAITINGTIME)
    self.dailyConfideWaitingDrama = LuaCfgMgr.Get("SundryConfig", X3_CFG_CONST.DAILYCONFIDEWAITINGDRAMA)
end

---开始计时，超过一定时间要结束连麦或者播放待机动画
function DailyConfideMgr:dailyConfideTimeTick()
    if self:getDailyPhoneState() == DailyConfideConst.DailyConfideState.Pause then
        ---暂停不计时
        return
    end
    self.leaveTime = self.leaveTime - 1
    --Debug.LogError("➥",self.leaveTime)
    if self.leaveTime <= 0 then
        TimerMgr.Discard(self.dailyConfideTimeTickID)
        self.dailyConfideTimeTickID = nil
        if BllMgr.GetMainHomeBLL():IsWndFocus() then
            ---结束连麦
            self:timeOut()
        end
        return
    end

    if self:getDailyPhoneState() ~= DailyConfideConst.DailyConfideState.Normal then
        return
    end

    self.idleTime = self.idleTime + 1 --超过30如果没有播放dialogue则播放一个idle
    if self.idleTime > self.dailyConfideWaitingTime then
        if self:getDailyPhoneState() == DailyConfideConst.DailyConfideState.Normal and (not self:GetDialogueIsPlaying()) then
            self:PlayDialogue(self.dailyConfideWaitingDrama)
        end
    end

end
---@return bool
function DailyConfideMgr:GetEntryVoiceEnable()
    return self.entryVoiceEnable
end

function DailyConfideMgr:OnLogicPause()
    local lastState = BllMgr.GetDailyConfideBll():GetMicState(self.roleID, self.entryVoiceEnable)
    local isLastOpen = lastState == DailyConfideConst.MicState.Open
    if isLastOpen then
        self.isPause = true
        self:StopASR()--上次是打开的，这次关闭
    end
    if self.dialogueSystem then
        self.dialogueSystem:PauseDialogue(DailyConfideConst.DialoguePiperLineKey)
        self:GetDialogueController():ShowOrHideDialogueUI(false)
    end

    self:SetDailyPhoneState(DailyConfideConst.DailyConfideState.Pause)
end

function DailyConfideMgr:OnLogicResume()
    self:CheckTimeOut()
    local lastState = BllMgr.GetDailyConfideBll():GetMicState(self.roleID, self.entryVoiceEnable)
    local isLastOpen = lastState == DailyConfideConst.MicState.Open
    if isLastOpen and self.isPause then
        self:InnerStartASR(self.entryVoiceEnable)
    end
    if self.dialogueSystem then
        self.dialogueSystem:ResumeDialogue(DailyConfideConst.DialoguePiperLineKey)
        self:GetDialogueController():ShowOrHideDialogueUI(true)
    end
    self:SetDailyPhoneState(self:GetLastDailyPhoneState(), true)
end

function DailyConfideMgr:CheckTimeOut()
    if self.leaveTime <= 0 then
        if BllMgr.GetMainHomeBLL():IsWndFocus() then
            ---结束连麦
            self:timeOut()
        end
    else
        if self:getDailyPhoneState() == DailyConfideConst.DailyConfideState.Over then
            if not self:GetDialogueIsPlaying() then
                self:ExitDailyPhone()
            end
        end
    end
end
---超时了弹出去
function DailyConfideMgr:timeOut()
    UICommonUtil.ShowMessage(UITextConst.UI_TEXT_11616)--就跟他聊到这里吧~（时长上限
    self:ExitDailyPhone()
    ErrandMgr.SetDelay(true)
end
---剧情初始化完成
---@param conversationName string 要播放的动画名字
---@param feedbackType DailyConfideConst.FeedbackType|nil
---@param semanticGroupID number|nil 语义组ID
function DailyConfideMgr:PlayDialogue(conversationName, feedbackType, semanticGroupID)
    if not feedbackType then
        self:playDialogue(conversationName, semanticGroupID)
        return
    end
    if self:GetDialogueIsPlaying() then
        local data = {
            name = conversationName,
            type = feedbackType,
            semanticGroupID = semanticGroupID
        }
        if self.waitConversation then
            --local waitType = self.waitConversation.type
            if feedbackType == DailyConfideConst.FeedbackType.Continue
                    or feedbackType == DailyConfideConst.FeedbackType.Over
                    or feedbackType == DailyConfideConst.FeedbackType.Bonus
            then
                self.waitConversation = data
            end
        else
            if feedbackType == DailyConfideConst.FeedbackType.Bonus then
                if self.playSemanticGroupID ~= semanticGroupID then
                    self.waitConversation = data
                end
            elseif feedbackType ~= DailyConfideConst.FeedbackType.FeedBack then
                self.waitConversation = data
            end
        end
    else
        --local state = self:getDailyPhoneState()
        --TODO check state
        self:playDialogue(conversationName, semanticGroupID)

    end
end
---@return bool 是否在播放中
function DailyConfideMgr:GetDialogueIsPlaying()
    return self:GetDialogueController():IsPlayingConversation()
end

---Dialogue播放结束的回调
function DailyConfideMgr:onDialoguePlayOver()
    self:matchCountRequest(self.roleID, self.playSemanticGroupID)
    self.playSemanticGroupID = nil
    local curState = self:getDailyPhoneState()
    if curState == DailyConfideConst.DailyConfideState.Meeting then
        --第一次进入倾诉
        self:SetDailyPhoneState(DailyConfideConst.DailyConfideState.Normal)
        self:EntryInnerDailyConfideGamePlay()
    elseif curState == DailyConfideConst.DailyConfideState.waitToOver or curState == DailyConfideConst.DailyConfideState.Pause then
        local lastState = self:GetLastDailyPhoneState()
        if lastState == DailyConfideConst.DailyConfideState.Meeting then
            table.insert(self.lastDailyPhoneState, DailyConfideConst.DailyConfideState.Normal)
            if not self.PLEnd then
                self:EntryInnerDailyConfideGamePlay()
                self.PLEnd = false
            end
        else
            table.insert(self.lastDailyPhoneState, lastState)
        end
    end
    if self.waitConversation then
        local name = self.waitConversation.name
        local type = self.waitConversation.type
        local semanticGroupID = self.waitConversation.semanticGroupID
        self.waitConversation = nil
        self:PlayDialogue(name, type, semanticGroupID)
    else
        if self:getDailyPhoneState() == DailyConfideConst.DailyConfideState.Over then
            self:ExitDailyPhone() --说完告别
        else
            EventMgr.Dispatch(DailyConfideConst.DialogueShowOver)
        end
    end
    self.idleTime = 0
end
---@param conversationName string 内部函数，播放dialogue conversation
---@param semanticGroupID number 语义组ID
function DailyConfideMgr:playDialogue(conversationName, semanticGroupID)
    local dialogueController = self:GetDialogueController()
    if dialogueController:DialogueInited(self.dialogueID) == false then
        ---@type DialogueSystem
        self.dialogueSystem = dialogueController:InitDialogue(self.dialogueID)
    end
    if conversationName == "PLEnd" then
        self.PLEnd = true  ---玩家主动退出
    end
    local playID = self:GetDialogueController():StartDialogueByName(self.dialogueID, conversationName,
            nil, DailyConfideConst.DialoguePiperLineKey, handler(self, self.onDialoguePlayOver))
    if semanticGroupID then
        self.playSemanticGroupID = semanticGroupID --记录下播放的是哪一个语义组
    end
end

---进入寒暄
function DailyConfideMgr:EntryMeetingState()
    self:InitDailyConfideTimeTick()
    self:SetDailyPhoneState(DailyConfideConst.DailyConfideState.Meeting)
end

---@param text string 文本
---倾诉反馈设置到剧情
function DailyConfideMgr:onFeedBackInteractionStart(text)
    ---点击倾诉
    if text == "" or text == nil then
        self:Match(0)
    else
        BllMgr.GetDailyConfideBll():RequestWordVector(text, self.roleID)
    end
end

function DailyConfideMgr:GetDialogueVariable()
    local curEmotion = self:GetVariableState(DailyConfideConst.DialogVariables.Emotion)
    local curMatterType = self:GetVariableState(DailyConfideConst.DialogVariables.MatterType)
    local curMatterSubType = self:GetVariableState(DailyConfideConst.DialogVariables.MatterSubType)
    return curEmotion, curMatterType, curMatterSubType
end

---释放
function DailyConfideMgr:Dispose()
    if self.entryMeetingStateTickId then
        TimerMgr.Discard(self.entryMeetingStateTickId)
    end
    self.entryMeetingStateTickId = nil
    TimerMgr.Discard(self.dailyConfideTimeTickID)
    self.dailyConfideTimeTickID = nil
    if self.dailyConfideTimeTickID then
        TimerMgr.Discard(self.permissionChangeTickID)
    end
    self.permissionChangeTickID = nil
    if self.interruptionTickID then
        TimerMgr.Discard(self.interruptionTickID)
    end
    self.interruptionTickID = nil
    BllMgr.GetDailyConfideBll():StartCloseWhiteScreen()
    self:DisposeSDK()
    local curEmotion, curMatterType, curMatterSubType = self:GetDialogueVariable()
    EventMgr.Dispatch(DailyConfideConst.DialogVariablesUpdate, curEmotion, curMatterType, curMatterSubType)
    self:GetDialogueController():RemoveGameObject(self.assetID, self.manObj)
    DialogueManager.ClearByName(DailyConfideConst.DialogControllerName)
    self:DisposeField()
    EventMgr.RemoveListenerByTarget(self)
end
---释放字段
function DailyConfideMgr:DisposeField()
    self.gameBegin = nil
    self.roleID = nil
    self.waitConversation = nil
    self.dailyConfideState = nil
    self.entryVoiceEnable = nil
    self.dailyConfideCfg = nil
    self.dailyConfideTimeTickID = nil
    self.dialogueID = nil
    self.openingConversation = nil
    self.leaveTime = nil
    self.sdkInit = false
    self.idleTime = nil
    self.dailyConfideWaitingTime = nil
    self.dailyConfideWaitingDrama = nil
    self.assetID = nil
    self.manObj = nil
    self.dialogueController = nil
    self.lastDailyPhoneState = nil
    self.playSemanticGroupID = nil
    self.PLEnd = nil
    self.dialogueSystem = nil
    self.hadCheckMute = nil
    self.volume = nil
end
---退出连麦
function DailyConfideMgr:ExitDailyPhone()
    if BllMgr.GetMainHomeBLL():IsWndFocus() then
        BllMgr.GetDailyConfideBll():OnDailyPhoneExit()
    end
end
---点击触发结束
function DailyConfideMgr:TriggerOver()
    local state = self:getDailyPhoneState()
    for k, v in pairs(self.dailyConfideCfg) do
        if v.FeedbackType == DailyConfideConst.FeedbackType.Over then
            self:EntryOverState(state, nil, v.ConversationName)
            return
        end
    end
end
---@param state DailyConfideConst.DailyConfideState
---@param feedBackType  DailyConfideConst.FeedbackType 没有值的话会立即播放并且情况队列里的待播放对话
---@param conversationName  string
---@param semanticGroupID number 语义组ID
function DailyConfideMgr:EntryOverState(state, feedBackType, conversationName, semanticGroupID)
    if state == DailyConfideConst.DailyConfideState.Normal then
        self:PlayDialogue(conversationName, feedBackType, semanticGroupID)
    else
        self.waitConversation = nil
        self:PlayDialogue(conversationName, self.gameBegin and feedBackType or nil, semanticGroupID)
    end
    self:SetDailyPhoneState(DailyConfideConst.DailyConfideState.Over)
end
---@param semanticGroupID int 语义组ID
---@param isSuc bool 是否命中静态向量
---拿到命中的语义组ID来处理逻辑
function DailyConfideMgr:Match(semanticGroupID, isSuc)
    local state = self:getDailyPhoneState()
    Debug.Log("【连麦】Match:", semanticGroupID, " isSuc: ", (isSuc and 1 or 0), "state: ", state)
    if state == DailyConfideConst.DailyConfideState.Opening or state == DailyConfideConst.DailyConfideState.Over then
        ---开场和结束阶段不响应
        return
    end
    if not isSuc then
        self:playNormalFeedBack()
        return
    end
    local matchCfg = self.dailyConfideCfg[semanticGroupID]
    if matchCfg then
        Debug.Log("【连麦】MatchCfg,ManLimit:", matchCfg.ManLimit, " ; feedBackType: ", matchCfg.FeedbackType, " 。")
        if matchCfg.ManLimit == -1 or matchCfg.ManLimit == self.roleID then

            local feedBackType = matchCfg.FeedbackType
            if feedBackType == DailyConfideConst.FeedbackType.Over then
                if state ~= DailyConfideConst.DailyConfideState.Meeting then
                    self:EntryOverState(state, feedBackType, matchCfg.ConversationName, semanticGroupID)
                end
            elseif feedBackType == DailyConfideConst.FeedbackType.Continue then
                if state == DailyConfideConst.DailyConfideState.waitToOver then
                    self:SetDailyPhoneState(DailyConfideConst.DailyConfideState.Normal)
                    self:PlayDialogue(matchCfg.ConversationName, feedBackType, semanticGroupID)
                else
                    self:playNormalFeedBack(semanticGroupID)
                end
            else
                if state == DailyConfideConst.DailyConfideState.Normal then
                    --self:SetDailyPhoneState(DailyConfideConst.DailyConfideState.Normal)
                    self:PlayDialogue(matchCfg.ConversationName, feedBackType, semanticGroupID)
                end
            end
        else
            self:playNormalFeedBack()
        end
    else
        if state == DailyConfideConst.DailyConfideState.Meeting then
            self:matchDialogue(state, semanticGroupID)
        else
            self:playNormalFeedBack()
        end
    end
end
---@param state DailyConfideConst.DailyConfideState
---@param semanticGroupID int
---寒暄阶段match到语义组后，需要告诉dialogue模拟玩家选了哪个选项
function DailyConfideMgr:matchDialogue(state, semanticGroupID)
    if state == DailyConfideConst.DailyConfideState.Meeting then
        --寒暄阶段Match Dialogue语义组
        local dialogueMatchGroup = self:GetDialogueController():GetSemanticGroupIDList()
        for k, v in pairs(dialogueMatchGroup) do
            if k == semanticGroupID then
                self:GetDialogueController():HitSemanticGroupID(semanticGroupID)
                break
            end
        end
    end
end
---match中普通反馈
---@param semanticGroupID number|nil 语义组ID
function DailyConfideMgr:playNormalFeedBack(semanticGroupID)
    if self:getDailyPhoneState() ~= DailyConfideConst.DailyConfideState.Normal then
        return
    end
    local normalFeedBack = self.dailyConfideCfg[0]
    self:PlayDialogue(normalFeedBack.ConversationName, DailyConfideConst.FeedbackType.FeedBack, semanticGroupID)
end

---@return DialogueController
function DailyConfideMgr:GetDialogueController()
    if self.dialogueController == nil then
        self.dialogueController = DialogueManager.InitByName(DailyConfideConst.DialogControllerName)
        self.dialogueController:SetDialogueUseDefaultSetting(true)
        self.dialogueController:GetSettingData():SetShowReviewButton(false)
        self.dialogueController:GetSettingData():SetShowAutoButton(false)
    end
    return self.dialogueController
end
---@param show bool 是否显示dialogueUI
function DailyConfideMgr:ShowOrHideChoiceUI(show)
    self:GetDialogueController():ShowOrHideChoiceUI(show)
end
---获取变量值
---@param variableKey int
---@return int
function DailyConfideMgr:GetVariableState(variableKey)
    return self:GetDialogueController():GetVariableState(variableKey)
end

---@param roleID number 男主ID
---@param matchID number|nil 玩家命中的语义组ID
---每次有触发语义组ID，并且播完了剧情的时候，把下述两个参数的值发给服务器，服务器记着，成就这边做判断是否满足配置要求，满足了就加计数值
function DailyConfideMgr:matchCountRequest(roleID, matchID)
    BllMgr.GetDailyConfideBll():RequestMatchCount(roleID, matchID)
end
---Token刷新咯
function DailyConfideMgr:onTokenUpdate()
    if BllMgr.GetDailyConfideBll():CheckToken() then
        self:InitMic()
    else
        Debug.LogError("刷新的Token时间不足")
    end
end
---@param vector table 语义匹配向量
function DailyConfideMgr:onDailyConfideTalkReply(vector, cacheRequest)
    local result = DailyConfideHelper.MatchVector(vector)
    local value = DailyConfideHelper.GetValue()
    self:Match(result, value >= DailyConfideConst.VoiceMatchWeight)
    --TODO Delete it 目前QA需要
    if value >= DailyConfideConst.VoiceMatchWeight then
        Debug.Log("【连麦】命中语义组: ", result, "，输入文本：", cacheRequest.Talk, ",权重值为：", value)
    else
        Debug.Log("【连麦】【未命中语义组，输入文本：", cacheRequest.Talk, "最接近语义组为：", result, ",权重值为：", value)
    end
end

function DailyConfideMgr:ResetLazyFlag()
    self.lazyInitSDK = false
    self.lazyStartASR = false
    self.isPause = false
end

--region Aliyun Delegate
---@param operateType DailyConfideConst.AliyunASRSubBuzyType
---@param result DailyConfideConst.AliyunASROperateResult
---@param originalErrorCode int 阿里云文档的原生错误码
function DailyConfideMgr:OnOperateResult(operateType, result, originalErrorCode)
    if result ~= DailyConfideConst.AliyunASROperateResult.Success then
        if operateType == DailyConfideConst.AliyunASRSubBuzyType.Initialize then
            UICommonUtil.ShowMessage(UITextConst.UI_TEXT_5196)-- SDK初始化失败，请稍后重试！
            self:ResetLazyFlag()
            self:SetUserOpenMic(false)
            self:DisposeSDK()
        else
            self:OnError(originalErrorCode)
        end
    else
        if operateType == DailyConfideConst.AliyunASRSubBuzyType.Initialize then
            self:SetIsSDKInit(true)
            if self.lazyInitSDK then
                self.lazyInitSDK = false
                self.isPause = false
                self:InnerStartASR()
            end
        else
            if operateType == DailyConfideConst.AliyunASRSubBuzyType.StartDialogue then
                self.lazyStartASR = false
                local lastState = BllMgr.GetDailyConfideBll():GetMicState(self.roleID, self.entryVoiceEnable)
                local isLastOpen = lastState == DailyConfideConst.MicState.Open
                if not isLastOpen then
                    self:StopASR()
                end
            end
        end
    end
end

function DailyConfideMgr:OnOpen()
    ---暂时不需要处理
end
---@param proactively bool 主动暂停还是被动暂停
function DailyConfideMgr:OnPause(proactively)
    if not proactively then
        ---proactively为 true,主动暂停忽略
        local platform = Application.GetPlatform()
        if platform == CS.UnityEngine.RuntimePlatform.Android then
            ---如果是Android平台延迟一帧释放，否则会卡死
            TimerMgr.AddTimerByFrame(1, function()
                self:OnError(DailyConfideConst.LogicErrorCode.UnNormalPause)
            end, self)
        else
            self:OnError(DailyConfideConst.LogicErrorCode.UnNormalPause)
        end
    end
end
---不需要处理
function DailyConfideMgr:OnClose()
    AudioSessionUtil.ResetAudioSessionCategory()
end
---@param reason DailyConfideConst.AliyunASRInterruptionReason 打断的原因，暂时没有需要处理的业务逻辑
function DailyConfideMgr:OnInterrupt(reason)
    Debug.Log("Aliyun SDK OnInterrupt => ", reason)
end

---@param errorCode int|DailyConfideConst.LogicErrorCode -1开头的是客户端主动触发的错误码，其余为阿里云原生错误码，目前和策划约定除了可以忽略的，其他都直接关闭语音识别并飘字提示
---错误码参考 https://help.aliyun.com/document_detail/183573.html?spm=a2c4g.84424.0.0.3d514f39WIWuRC
function DailyConfideMgr:OnError(errorCode)
    if Application.IsIOSMobile() then
        if errorCode == DailyConfideConst.IgnoreErrorCode.MIC_ERROR then
            return
        end
    end
    ---todo:需要根据实际ErrorCode进行处理
    local content = tostring(errorCode)
    if errorCode ~= DailyConfideConst.LogicErrorCode.DefaultErrorCode and string.startswith(content, "0") then
        --- 0 开头的忽略
        return
    end

    Debug.LogErrorFormat("【连麦】VoiceSDKError,CODE：%s", content)
    self:ResetLazyFlag()
    self:DisposeSDK()
    UICommonUtil.ShowMessage(UITextConst.UI_TEXT_11615)--语音识别超时，请重试
    EventMgr.Dispatch(DailyConfideConst.MicASRStateChange, DailyConfideConst.MicASRState.NoTalking)
    EventMgr.Dispatch(DailyConfideConst.MicChange)
end

---@param result string ASR转换的文本
function DailyConfideMgr:OnResult(result)
    local curState = self:getDailyPhoneState()
    if curState ~= DailyConfideConst.DailyConfideState.Opening and curState ~= DailyConfideConst.DailyConfideState.Pause then
        EventMgr.Dispatch(DailyConfideConst.MicASRStateChange, DailyConfideConst.MicASRState.NoTalking)
        if result then
            result = string.cutoverflow(result, DailyConfideConst.DailyPhoneASRResultChatLimit)
        else
            result = ""
        end
        self:onFeedBackInteractionStart(result)
    end
end
---持续转文本，主要用来触发UI动效
function DailyConfideMgr:OnPartialResult()
    EventMgr.Dispatch(DailyConfideConst.MicASRStateChange, DailyConfideConst.MicASRState.Talking)
end

--endregion
return DailyConfideMgr
