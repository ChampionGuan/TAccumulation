---Runtime.System.X3Game.Modules.MainHome.Ctrl/MainHomeActorTouchDataCtrl.lua
---Created By 教主
--- Created Time 17:32 2021/7/7

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local BaseCtrl = require(MainHomeConst.BASE_CTRL)

---@class MainHomeActorTouchDataCtrl:MainHomeBaseCtrl
local MainHomeActorTouchDataCtrl = class("MainHomeActorTouchDataCtrl", BaseCtrl)

function MainHomeActorTouchDataCtrl:ctor()
    BaseCtrl.ctor(self)
    self.isEnable = false
    self.actorId = 0
    self.interactIntervalCount = 0
    self.interactIntervalLimit = 0
    self.interactIntervalCD = 0
    self.interactInterval = 0
    self.ignoreTimeLeft = 0
    self.isInIgnoreState = false
    self.playerId = SelfProxyFactory.GetPlayerInfoProxy():GetUid()
    self.split = MainHomeConst.SPLIT
    self.saveKeyMap = {}
    self.touchLimit = 1000 --LuaCfgMgr.Get("SundryConfig",X3_CFG_CONST.MAINUITOUCHTOUCHLIMT)
    self.interactionList = {}
    self.lastInteractTime = 0
end

function MainHomeActorTouchDataCtrl:Enter()
    BaseCtrl.Enter(self)
    self:OnActorLoadSuccess()
    self:RegisterEvent()
end

function MainHomeActorTouchDataCtrl:Exit()
    self:UnRegisterEvent()
    self:Save()
    self.actorId = 0
    BaseCtrl.Exit(self)
end

function MainHomeActorTouchDataCtrl:OnUpdate()
    if not self.isEnable then
        return
    end

    if self.isInIgnoreState then
        self.ignoreTimeLeft = self.ignoreTimeLeft - TimerMgr.GetCurTickDelta()
        self:SetIsIgnoreState(self.ignoreTimeLeft > 0)
    end
end

function MainHomeActorTouchDataCtrl:SetIsIgnoreState(isInIgnoreState)
    if isInIgnoreState ~= self.isInIgnoreState then
        self.isInIgnoreState = isInIgnoreState
        local state_data = self.bll:GetData()
        state_data:SetActorState(self.isInIgnoreState and MainHomeConst.ActorState.IGNORE or MainHomeConst.ActorState.IDLE)
        if self.isInIgnoreState then
            self.ignoreTimeLeft = self.interactIntervalCD
        end
        self:Save()
        self.isEnable = true
    end
end

function MainHomeActorTouchDataCtrl:GetSaveKey(key, ...)
    local res = self.saveKeyMap[key]
    if not res then
        res = string.concat(key, self.split, self.playerId, self.split, self.actorId, self.split, ...)
        self.saveKeyMap[key] = res
    end
    return res
end

function MainHomeActorTouchDataCtrl:Save()
    if self.actorId == 0 then
        return
    end
    self.isEnable = false
    PlayerPrefs.SetString(self:GetSaveKey(MainHomeConst.SAVE_TIME), TimerMgr.GetCurTimeSeconds())
    PlayerPrefs.SetString(self:GetSaveKey(MainHomeConst.IGNORE_LEFT_TIME), self.ignoreTimeLeft)
    PlayerPrefs.SetString(self:GetSaveKey(MainHomeConst.INTERACT_TIME), self.lastInteractTime)
    for k, v in ipairs(self.interactionList) do
        PlayerPrefs.SetInt(self:GetSaveKey(MainHomeConst.INTERACT_COUNT, k), v)
    end
end

function MainHomeActorTouchDataCtrl:Load()
    if self.actorId == 0 then
        return
    end
    self:ClearIgnoreState()
    local save_time = tonumber(PlayerPrefs.GetString(self:GetSaveKey(MainHomeConst.SAVE_TIME), tostring(0)))
    local ignore_time_left = tonumber(PlayerPrefs.GetString(self:GetSaveKey(MainHomeConst.IGNORE_LEFT_TIME), tostring(0)))
    self.ignoreTimeLeft = math.max(ignore_time_left - (TimerMgr.GetCurTimeSeconds() - save_time), 0)
    self.lastInteractTime = tonumber(PlayerPrefs.GetString(self:GetSaveKey(MainHomeConst.INTERACT_TIME), tostring(0)))
    for k = 1, self.interactIntervalCount do
        local time = PlayerPrefs.GetInt(self:GetSaveKey(MainHomeConst.INTERACT_COUNT, k), 0)
        if time ~= 0 then
            self:SaveInteractCount(self.interactIntervalCount, time)
        end
    end
    self.isEnable = true
    self:CheckActorIgnoreState()
end

function MainHomeActorTouchDataCtrl:OnActorActive(isActive)
    self.isEnable = isActive
end

function MainHomeActorTouchDataCtrl:OnActorLoadSuccess(actor)
    local state_data = self.bll:GetData()
    local actor_id = state_data:GetActorId()
    local actor_conf = state_data:GetActorConf()
    if actor_conf and actor_id ~= self.actorId then
        self:Save()
        self.actorId = actor_id
        self.interactIntervalCount = actor_conf.InteractIntervalCount
        self.interactIntervalLimit = actor_conf.InteractIntervalLimit
        self.interactIntervalCD = actor_conf.InteractIntervalCD
        self:Load()
    end
end

function MainHomeActorTouchDataCtrl:ClearIgnoreState()
    table.clear(self.interactionList)
    self.ignoreTimeLeft = 0
    self.lastInteractTime = TimerMgr.GetCurTimeSeconds()
end

function MainHomeActorTouchDataCtrl:SaveInteractCount(count, time)
    if #self.interactionList >= count then
        table.remove(self.interactionList, 1)
    end
    table.insert(self.interactionList, time)
end

function MainHomeActorTouchDataCtrl:CheckActorIgnoreState()
    if self.ignoreTimeLeft > 0 then
        self:SetIsIgnoreState(true)
    else
        local cur = self.lastInteractTime
        local idx = nil
        for k, v in ipairs(self.interactionList) do
            if cur - v <= self.interactIntervalLimit then
                idx = k - 1
                break
            end
        end
        self:SetIsIgnoreState(idx ~= nil and (#self.interactionList - idx >= self.interactIntervalCount))
    end

end


function MainHomeActorTouchDataCtrl:OnEventStateChanged()
    self:ClearIgnoreState()
    self:CheckActorIgnoreState()
end

function MainHomeActorTouchDataCtrl:OnEventActionShowChanged(actionId, isRunning)
    local actionData = self.bll:GetActionDataProxy():GetActionTypeCfgById(actionId)
    if actionData then
        if actionData.IgnoreStateCount == 1 then
            if not isRunning then
                self:CheckActorIgnoreState()
            else
                self.lastInteractTime = TimerMgr.GetCurTimeSeconds()
                self:SaveInteractCount(self.interactIntervalCount, self.lastInteractTime)
            end
        end
    end
end

function MainHomeActorTouchDataCtrl:RegisterEvent()
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_ACTOR_LOAD_SUCCESS, self.OnActorLoadSuccess, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_STATE_CHANGE_REFRESH, self.OnEventStateChanged, self)
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_SET_ACTION_SHOW_RUNNING, self.OnEventActionShowChanged, self)
end

return MainHomeActorTouchDataCtrl