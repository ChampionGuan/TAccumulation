--- X3@PapeGames
--- TickleAction
--- Created by doudou
--- Created Date: 2023-11-01

---@class X3Game.TickleAction:FSM.FSMAction
---@field ClickSetting FSM.FSMVar | string
---@field ProgressReductionRate FSM.FSMVar | float
---@field CDTime FSM.FSMVar | float
---@field CrazyHitThresholdTime FSM.FSMVar | float
---@field WaitingTime FSM.FSMVar | float
---@field GameObject FSM.FSMVar | UObject
---@field ClickPartId FSM.FSMVar | int
---@field ClickCollider FSM.FSMVar | UObject
---@field ClickPos FSM.FSMVar | Vector2
---@field NodeId FSM.FSMVar | int
---@field Effector_Hand_L FSM.FSMVar | table
---@field StateId FSM.FSMVar | table
---@field IsCrazyHit FSM.FSMVar | table
---@field IsHit FSM.FSMVar | table
local TickleAction = class("TickleAction", FSMAction)
local CharacterInteractionConst = require("Runtime.System.X3Game.Modules.CharacterInteractionCtrl.CharacterInteractionConst")

---初始化
function TickleAction:OnAwake()
    local jsonTable = JsonUtil.Decode(self.ClickSetting:GetValue())

    self.clickSettingTable = {}
    for k, v in pairs(jsonTable) do
        self.clickSettingTable[tonumber(k)] = v
    end

    self.lastClickTime = -1 -- 上次点击的时间
    self.clickDt = 0 -- 两次点击的时间间隔
    self.lastSendEventTime = -1 -- 上一次生效的点击，并发送事件的时间
    self.sendEventDt = 0 -- 两次生效的点击时间间隔
    self.hasDispatch = false
end

---进入Action
function TickleAction:OnEnter()
    if not self.hasDispatch then
        EventMgr.Dispatch(CharacterInteractionConst.EVENT_UPDATE_REDUCTION_RATE, self.ProgressReductionRate:GetValue())
        EventMgr.Dispatch(CharacterInteractionConst.EVENT_UPDATE_WAIT_TIME, self.WaitingTime:GetValue())
        self.hasDispatch = true
    end

    local partType = self.ClickPartId:GetValue()
    local touchPos = self.ClickPos:GetValue()
    local collider = self.ClickCollider:GetValue()
    local addProgress = 5
    local score = self.clickSettingTable[partType].Score
    if score and #score >= 2 then
        addProgress = math.random(score[1], score[2])
    end
    EventMgr.Dispatch(CharacterInteractionConst.EVENT_PROGRESS_CHANGE, addProgress, touchPos)

    local curTime = TimerMgr.GetRealTimeSeconds()
    if self.lastClickTime > 0 then
        self.clickDt = curTime - self.lastClickTime
    end

    if self.lastSendEventTime > 0 then
        self.sendEventDt = curTime - self.lastSendEventTime
    end

    if self.sendEventDt > 0 and self.sendEventDt < self.CDTime:GetValue() then
        self.fsm:FireEvent("IN_CLICK_CD")
        return
    end

    self.lastClickTime = curTime
    self.lastSendEventTime = curTime

    local isCrazy = self.clickDt > 0 and self.clickDt < self.CrazyHitThresholdTime:GetValue()
    if isCrazy then
        self.crazyTime = curTime
    end
    local newStateId = self:GetStateId(partType, isCrazy)
    local localPos = CommonUtil.GetHitLocalPosition(touchPos, nil, collider, self.GameObject:GetValue().transform)
    self.Effector_Hand_L:SetValue(localPos)
    self.StateId:SetValue(newStateId)
    self.IsCrazyHit:SetValue(isCrazy)
    self.IsHit:SetValue(true)

    local nodeIds = isCrazy and self.clickSettingTable[partType].CrazyNode or self.clickSettingTable[partType].NormalNode
    if nodeIds then
        local index = math.random(1, #nodeIds)
        self.NodeId:SetValue(nodeIds[index])
    else
        Debug.LogError("Invalid Part type:%d", partType)
    end

    self:Finish()
end

function TickleAction:GetStateId(partType, isCrazy)
    local newState = self.StateId:GetValue()
    local curId = self.StateId:GetValue()
    local randomList = {}

    if not isCrazy then
        if self.clickSettingTable[partType].NormalState then
            for _, v in pairs(self.clickSettingTable[partType].NormalState) do
                if v ~= curId then
                    table.insert(randomList, v)
                end
            end
        end
    else
        if self.clickSettingTable[partType].CrazyState then
            for _, v in pairs(self.clickSettingTable[partType].CrazyState) do
                if v ~= curId then
                    table.insert(randomList, v)
                end
            end
        end
    end

    if randomList and #randomList > 0 then
        newState = randomList[math.random(1, #randomList)]
    end

    return newState
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function TickleAction:OnPause(isPaused)
end

--[[如需Action Tick需在Action Csharp类上标识Tickable
function TickleAction:OnUpdate()
end
--]]

---退出Action
function TickleAction:OnExit()
end

---被重置
function TickleAction:OnReset()
end

---被销毁
function TickleAction:OnDestroy()
end

return TickleAction