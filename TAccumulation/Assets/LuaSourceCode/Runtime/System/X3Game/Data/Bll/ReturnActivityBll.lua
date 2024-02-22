﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiantao.
--- DateTime: 2023/10/16 10:45
---
---@class ReturnActivityBll:BaseBll
local ReturnActivityBll = class("ReturnActivityBll", BaseBll)
---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
function ReturnActivityBll:Init(data)
    --if data == nil then
    --    self:SendGetReturnInfoRequest()
    --endF
    SelfProxyFactory.GetReturnActivityProxy():SetData(data)
    ---@type X3Data.ReturnActivityData
    self.returnData = SelfProxyFactory.GetReturnActivityProxy():GetReturnActivityData()
    end
---统一初始化，只会调用一次
function ReturnActivityBll:OnInit(...)
    ---@type DialogueSystem
    self.system = nil
    self.roleIns = nil
    self.isBackMainHome = false
    EventMgr.AddListener("CommonDailyReset", self.OnCommonDailyReset, self)
    EventMgr.AddListener("CustomRecordUpdate", self.CustomRecordUpdate, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_ENTER, self.OnBackMainHome, self)
    EventMgr.AddListener("RETURN_LIGHT_CHANGE", self.OnLightChange, self)
end

---统一清理相关数据状态，只会调用一次
function ReturnActivityBll:OnClear(...)
    TimerMgr.DiscardTimerByTarget(self)
    EventMgr.RemoveListenerByTarget(self)
end

---统一检测条件
---@return boolean,int 是否满足条件，返回满足当前条件的数量
function ReturnActivityBll:CheckCondition(id, datas)
    local result = false
    if id == X3_CFG_CONST.CONDITION_RETURN_IN_RETURN then
        local isInActivity = self:IsInReturnActivity()
        if not isInActivity then
            result = datas[1] == 0
        else
            local curDay = self:GetCurDay()
            if curDay >= datas[2] and (curDay <= datas[3] or datas[3] == -1) then
                result = datas[1] == 1
            else
                result = datas[1] == 0
            end
        end
    elseif id == X3_CFG_CONST.CONDITION_RETURN_LAST_TRIGGER_RETURN then
        local day = BllMgr.GetActivityCenterBLL():GetDaysInterval(TimerMgr.GetCurTimeSeconds(), self.returnData:GetLastStartTime())
        result = day > datas[1]
    end
    return result
end

function ReturnActivityBll:OnCommonDailyReset()
    SelfProxyFactory.GetReturnActivityProxy():OnPassDay()
end

function ReturnActivityBll:CanSign()
    for i = 1, self:GetActivityDuration() do
        if self:GetCurSignDay() >= i and (not self:CheckIsDailySignAward(i)) then
            return true
        end
    end
    return false
end

function ReturnActivityBll:GetCurReturnCfg()
    local id = self.returnData:GetReturnID()
    if id ~= 0 then
        return LuaCfgMgr.Get("ReturnInfo", id)
    end
end

function ReturnActivityBll:GetActivityDuration()
    local id = self.returnData:GetReturnID()
    local returnCfg = LuaCfgMgr.Get("ReturnInfo", id)
    return returnCfg.Duration
end

function ReturnActivityBll:GetTaskGroupID(day)
    if self:IsInReturnActivity() then
        local id = self.returnData:GetReturnID()
        local taskCfg = LuaCfgMgr.Get("ReturnTask", id, day)
        if taskCfg then
            return taskCfg.TaskGroup
        end
    end
end

function ReturnActivityBll:GetCurTaskList(day)
    if self:IsInReturnActivity() then
        local id = self.returnData:GetReturnID()
        local taskCfg = LuaCfgMgr.Get("ReturnTask", id, day)
        if taskCfg then
            local condition = {GroupID = taskCfg.TaskGroup}
            local cfgList = LuaCfgMgr.GetListByCondition("Task", condition)
            local taskDataList = {}
            for k, v in pairs(cfgList) do
                table.insert(taskDataList, BllMgr.GetTaskBLL():GetTaskInfoById(v.ID))
            end
            return taskDataList
        end
    end
end

function ReturnActivityBll:GetSignCfg(day)
    local id = self.returnData:GetReturnID()
    return LuaCfgMgr.Get("ReturnSign", id, day)
end

function ReturnActivityBll:GetEndTime()
    if self:IsInReturnActivity() then
        local id = self.returnData:GetReturnID()
        local returnCfg = LuaCfgMgr.Get("ReturnInfo", id)
        return BllMgr.GetActivityCenterBLL():GetEndTimeByDurationDay(self.returnData:GetStartTime(), returnCfg.Duration)
    end
    return 0
end
---获取当前是第几天
function ReturnActivityBll:GetCurDay()
    if self:IsInReturnActivity() then
        return BllMgr.GetActivityCenterBLL():GetDaysInterval(TimerMgr.GetCurTimeSeconds(), self.returnData:GetStartTime())
    end
end

---获取当前已登录几天
function ReturnActivityBll:GetCurSignDay()
    if self:IsInReturnActivity() then
        return self.returnData:GetOpenLoginDay()
    end
end

function ReturnActivityBll:IsCardUnlock()
    if not self:IsInReturnActivity() then
        return
    end
    local signCfgMap = LuaCfgMgr.GetListByCondition("ReturnSign", {ReturnId = self:GetCurReturnID()})
    local day
    for k, v in pairs(signCfgMap) do
        if v.IsUnlockCard == 1 then
            day = v.Day
            break
        end
    end
    return self:GetCurSignDay() >= day
end

---是否处于回流活动期间
function ReturnActivityBll:IsInReturnActivity()
    local id = self.returnData:GetReturnID()
    if id == 0 then
        return false
    end
    local returnCfg = LuaCfgMgr.Get("ReturnInfo", id)
    local curTime = TimerMgr.GetCurTimeSeconds()
    if curTime < TimerMgr.GetUnixTimestamp(GameHelper.GetDateByStr(returnCfg.OpenTime)) or
            ((not string.isnilorempty(returnCfg.CloseTime)) and curTime > TimerMgr.GetUnixTimestamp(GameHelper.GetDateByStr(returnCfg.CloseTime))) then
        return false
    end
    if TimerMgr.GetCurDate().day - TimerMgr.GetDateByUnixTimestamp(self.returnData:GetStartTime()).day + 1 > returnCfg.Duration then
        return false
    end
    return true
end

---查询每天奖励是否已领取
function ReturnActivityBll:CheckIsDailySignAward(day)
    if self:IsInReturnActivity() then
        local signInRewardInfo = self.returnData:GetSignInRewardClaimed()
        if signInRewardInfo == nil or signInRewardInfo[day] == nil then
            return false
        end
        return signInRewardInfo[day]
    end
end
---查询贺卡是否读过
function ReturnActivityBll:IsCardRead(roleID)
    if self:IsInReturnActivity() then
        if roleID == nil then
            roleID = self:GetCurRoleID()
        end
        local cardReadInfo = self.returnData:GetCardRead()
        if cardReadInfo ~= nil then
            return cardReadInfo[roleID]
        else
            return false
        end
    end
end

---监听CustomRecord消息
---@param customType int
function ReturnActivityBll:CustomRecordUpdate(customType, type, ...)
    if customType == DataSaveCustomType.DataSaveCustomTypeReturnStageDoubleDrop then
        local time = SelfProxyFactory.GetCustomRecordProxy():GetCustomRecordValue(DataSaveCustomType.DataSaveCustomTypeReturnStageDoubleDrop, type)
        SelfProxyFactory.GetReturnActivityProxy():SetDoubleTime(type, time)
    end
end
---获取双倍掉落用过的次数
function ReturnActivityBll:GetDoubleTime(type)
    local doubleTimes = self.returnData:GetDoubleTimes()
    return doubleTimes[type] and doubleTimes[type] or 0
end

---获取双倍掉落最大次数
function ReturnActivityBll:GetDoubleMaxTime(type)
    local doubleCfg = LuaCfgMgr.Get("ReturnDropDouble", self.returnData:GetReturnID(), type)
    return doubleCfg and doubleCfg.Max or 0
end
---剧情播放相关

function ReturnActivityBll:GetSceneName(isFirst)
    if isFirst then
        local sceneID = BllMgr.GetMainHomeBLL():GetData():GetSceneId()
        local sceneName = BllMgr.GetMainHomeBLL():GetData():GetSceneResourceName()
        BllMgr.GetPlayerServerPrefsBLL():SetInt(GameConst.CustomDataIndex.RETURN_SCENE_NAME, sceneID)
        return sceneName
    else
        local sceneID = BllMgr.GetPlayerServerPrefsBLL():GetInt(GameConst.CustomDataIndex.RETURN_SCENE_NAME)
        local sceneName = LuaCfgMgr.Get("MainUIScene", sceneID).Resource
        return sceneName
    end
end

function ReturnActivityBll:GetSceneID(isFirst)
    if isFirst then
        local sceneID = BllMgr.GetMainHomeBLL():GetData():GetSceneId()
        return sceneID
    else
        local sceneID = BllMgr.GetPlayerServerPrefsBLL():GetInt(GameConst.CustomDataIndex.RETURN_SCENE_NAME)
        return sceneID
    end
end

function ReturnActivityBll:IsReturnActiveFirstEnter()
    if not self:IsInReturnActivity() then
        return false
    end
    local id = self.returnData:GetReturnID()
    local roleId = self.returnData:GetRoleID()
    if id ~= 0 and roleId == 0 then
        return true
    end
    return false
end

function ReturnActivityBll:StartFirstDialogue()
    local returnCfg = self:GetCurReturnCfg()
    self.dialogueController = DialogueManager.InitByName("ReturnActivity")
    self.system = self.dialogueController:InitDialogue(returnCfg.Dialogue, Mathf.Random(1, 10000), nil, function()
        self.dialogueController:StartDialogueById(returnCfg.Dialogue, returnCfg.Conversation, nil, nil, function()
            local roleID = self.dialogueController:GetVariableState(1)
            self:SetRole(roleID)
            DialogueManager.ClearByName("ReturnActivity")
            UICommonUtil.WhiteScreenIn(function()
                self:LoadRole(roleID, function()
                    self:StartRoleDialogue(roleID, true)
                    UICommonUtil.ClearScreen()
                end)
            end)
        end)
    end)
    self.system:GetSettingData():SetShowExitButton(false)
    self.system:GetSettingData():SetShowClickBg(true)
end

---播放男主剧情
function ReturnActivityBll:StartRoleDialogue(roleID, isFirst)
    local returnRoleCfg = LuaCfgMgr.Get("ReturnRole", self.returnData:GetReturnID(), roleID)
    self.dialogueController = DialogueManager.InitByName("ReturnActivity")
    local assetID = LuaCfgMgr.Get("RoleInfo", roleID).DefaultAssetID
    self.dialogueController:InjectGameObject(assetID, self.roleIns)
    self.system = self.dialogueController:InitDialogue(returnRoleCfg.Dialogue, Mathf.Random(1, 10000), nil, function()
        self.dialogueController:StartDialogueByName(returnRoleCfg.Dialogue, returnRoleCfg.ConversationDetail, nil, nil, function()
            self:BackToMainHome()
        end)
    end)
    self.system:GetSettingData():SetShowExitButton(true)
    self.system:GetSettingData():SetShowClickBg(true)
    self.system:RegisterExitClickHandler(function()
        if isFirst then
            UICommonUtil.ShowMessageBox(UITextConst.UI_TEXT_33506, {
                { btn_type = GameConst.MessageBoxBtnType.CONFIRM, btn_text = UITextConst.UI_TEXT_5701, btn_call = function()
                    self:BackToMainHome()
                end },
                { btn_type = GameConst.MessageBoxBtnType.CANCEL, btn_text = UITextConst.UI_TEXT_5702, btn_call = function()
                    --DialogueManager.GetDefaultDialogueSystem():ResumeTime()
                    DialogueManager.GetUIController():ResumeTime()
                end }
            })
        else
            self:BackToMainHome()
        end
    end)
end

function ReturnActivityBll:BackToMainHome()
    UICommonUtil.WhiteScreenIn(function()
        DialogueManager.ClearByName("ReturnActivity")
        self.isBackMainHome = true
        UIMgr.Close(UIConf.SpecialDatePlayWnd)
        GameStateMgr.Switch(GameState.MainHome, false, false)
    end)
end

function ReturnActivityBll:OnBackMainHome()
    if self.isBackMainHome then
        UICommonUtil.ClearScreen()
        self.isBackMainHome = false
    end
end

function ReturnActivityBll:OnLightChange(arg)
    local params = arg.params
    local stateId = tonumber(params[2])
    local lightSolution = BllMgr.GetMainHomeBLL():GetData():GetLightSolutionByRoleState(self:GetCurRoleID(), stateId, self:GetSceneID())
    if not string.isnilorempty(lightSolution) then
        local obj = Res.Load(lightSolution, ResType.T_CharacterLighting, AutoReleaseMode.Scene)
        if obj then
            local characterLightingManager = CS.PapeGames.Rendering.CharacterLightingProvider.Current
            characterLightingManager:ChangeCharacterLight(obj)
        end
    end
end
function ReturnActivityBll:LoadRole(roleID, finishCall)
    if roleID == 0 then
        roleID = 1
    end
    local fashionMap = {}
    local rolePartKeys = BllMgr.GetPlayerServerPrefsBLL():GetIntList(GameConst.CustomDataIndex[string.format("RETURN_CLOTHE%d", roleID)])
    if table.isnilorempty(rolePartKeys)  then
        fashionMap = BllMgr.GetFashionBLL():GetEveryDayFashionList(roleID)
        for k ,v in pairs(fashionMap) do
            table.insert(rolePartKeys, v)
        end
        BllMgr.GetPlayerServerPrefsBLL():SetIntList(GameConst.CustomDataIndex[string.format("RETURN_CLOTHE%d", roleID)], rolePartKeys)
    end
    local partList = BllMgr.GetFashionBLL():GetPartKeysWithFashionIDs(rolePartKeys, roleID, false)
    local baseKey = BllMgr.GetFashionBLL():GetRoleModelBaseKey(roleID)
    CharacterMgr.GetIns(baseKey, partList, nil, function(ins)
        self.roleIns = ins
        local assetID = LuaCfgMgr.Get("RoleInfo", roleID).DefaultAssetID
        CutSceneMgr.InjectAssetIns(assetID, self.roleIns)
        if finishCall then
            finishCall(ins)
        end
    end)
end


function ReturnActivityBll:DesRole()
    if self.roleIns ~= nil then
        CharacterMgr.ReleaseIns(self.roleIns)
        self.roleIns = nil
    end
end

function ReturnActivityBll:SetRole(roleID)
    self:SendReturnSetRoleRequest(roleID)
end

function ReturnActivityBll:GetCurRoleID()
    if self:IsInReturnActivity() then
        local roleID = self.returnData:GetRoleID()
        return (roleID ~= 0 and roleID ~= nil) and roleID or 1
    end
end

function ReturnActivityBll:GetCurReturnID()
    if self:IsInReturnActivity() then
        return self.returnData:GetReturnID()
    end
end

---发送服务器协议
function ReturnActivityBll:SendGetReturnInfoRequest()
    local msg = {}
    GrpcMgr.SendRequest(RpcDefines.GetReturnInfoRequest, msg)
end

function ReturnActivityBll:SendReturnSignInRequest(day)
    local msg = {
        RewardDay = day
    }
    GrpcMgr.SendRequest(RpcDefines.ReturnSignInRequest, msg, true)
end

function ReturnActivityBll:SendReturnQuestRewardClaimRequest(questIDs)
    local msg = {
        QuestIDs = questIDs
    }
    GrpcMgr.SendRequest(RpcDefines.ReturnQuestRewardClaimRequest, msg)
end

function ReturnActivityBll:SendReturnSetRoleRequest(roleID)
    local msg = {
        RoleID = roleID
    }
    GrpcMgr.SendRequest(RpcDefines.ReturnSetRoleRequest, msg, true)
end

function ReturnActivityBll:SendReturnCardReadRequest(roleID)
    local msg = {
        RoleID = roleID
    }
    GrpcMgr.SendRequest(RpcDefines.ReturnCardReadRequest, msg, true)
end

---断线重连
function ReturnActivityBll:OnReconnect()

end

---红点刷新检测
---@param redId number 红点配置id
function ReturnActivityBll:OnRedPointCheck(redId)

end

return ReturnActivityBll