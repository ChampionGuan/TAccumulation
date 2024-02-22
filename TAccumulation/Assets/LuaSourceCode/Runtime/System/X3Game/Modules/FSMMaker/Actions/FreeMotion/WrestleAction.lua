--- X3@PapeGames
--- WrestleAction
--- Created by xiangyu
--- Created Date: 2023-12-11

---@class X3Game.WrestleAction:FSM.FSMAction
---@field InitPower FSM.FSMVar | int 力量初始值
---@field PowerSubNumMin FSM.FSMVar | float 力量每秒衰减最小值
---@field PowerSubNumMax FSM.FSMVar | float 力量每秒衰减最大值
---@field PowerAddNumMax FSM.FSMVar | float 力量增加值最大值
---@field PowerAddNumMin FSM.FSMVar | float 力量增加值最小值
local WrestleAction = class("WrestleAction", FSMAction)
local updateFrameTime = 0.03
---初始化
function WrestleAction:OnAwake()
end

---进入Action
function WrestleAction:OnEnter()
    ---if need to complete action, call Finish()
    ---self:Finish()
    self.start = false
    self.wrestleEnd = false
    
    self.currentPower = self.InitPower:GetValue()
    self.resultPower = self.currentPower
    self.subPowerFrameMin = self.PowerSubNumMin:GetValue() * updateFrameTime
    self.subPowerFrameMax = self.PowerSubNumMax:GetValue() * updateFrameTime
    
    self.successLimit = updateFrameTime
    self.failedLimit = 1 - updateFrameTime
    
    UIMgr.Open(UIConf.FreeMotionWrestleWnd, self.currentPower)
    
    EventMgr.AddListener("WrestleStart", self.StartEvent, self)
    EventMgr.AddListener("WrestleClick", self.AddPowerEvent, self)
end

---玩法开始
function WrestleAction:StartEvent()
    self.start = true
end

---点击增加力量
function WrestleAction:AddPowerEvent()
    local addNum = Mathf.RandomFloat(self.PowerAddNumMin:GetValue(), self.PowerAddNumMax:GetValue())
    local result = self.resultPower + addNum
    self.resultPower = result >= 1 and 1 or result
end

---每帧减少随机的power
function WrestleAction:UpdateSubPower()
    local subPowerRange = Mathf.RandomFloat(self.subPowerFrameMin, self.subPowerFrameMax)
    local result = self.resultPower - subPowerRange
    self.resultPower = result <= 0 and 0 or result
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function WrestleAction:OnPause(isPaused)
    
end

---Tick
function WrestleAction:OnUpdate()
    if not self.start then
        self:SendEventToCTS(0)
        return
    end

    if self.wrestleEnd then
        return
    end

    self:UpdateSubPower()
    self:UpdateCheckResult()
    
    local lerpValue = updateFrameTime
    self.currentPower = Mathf.Lerp(self.currentPower, self.resultPower, lerpValue)
    local cutSceneParam = 1 - self.currentPower * 2
    self:SendEventToCTS(cutSceneParam)
    EventMgr.Dispatch("WrestleSliderUpdate", self.currentPower)
end

function WrestleAction:SendEventToCTS(value)
    CutSceneMgr.SendEventWithFloat("Input", value)
    CutSceneMgr.SendEventWithParam("Role", "Input", value)
end

---检查结果并做好结束的标记
function WrestleAction:UpdateCheckResult()
    local isEnd = false
    local changeState
    if self.currentPower <= self.successLimit then
        ---成功了
        isEnd = true
        changeState = "Success"
    elseif self.currentPower >= self.failedLimit then
        --失败了
        isEnd = true
        changeState = "Failed"
    end

    self.wrestleEnd = isEnd
    if isEnd then
        EventMgr.Dispatch("WrestleSliderUpdate", self.currentPower)
        EventMgr.Dispatch("WrestleEnd")
        FSMMgr.ChangeState(self.fsm.id, changeState)
        self:Finish()
    end
end

---退出Action
function WrestleAction:OnExit()
    EventMgr.RemoveListener("WrestleStart", self.StartEvent, self)
    EventMgr.RemoveListener("WrestleClick", self.AddPowerEvent, self)
end

---被重置
function WrestleAction:OnReset()
end

---被销毁
function WrestleAction:OnDestroy()
end

return WrestleAction