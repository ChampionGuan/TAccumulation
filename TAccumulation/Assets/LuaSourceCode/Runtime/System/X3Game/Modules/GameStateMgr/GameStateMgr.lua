--- X3@PapeGames
--- GameStateMgr
--- Created by Tungway
--- Created Date: 2020/7/24

---@class GameStateMgr
local GameStateMgr = {
    _stateTransitionDict = nil,
    ---@type table<string, BaseGameState>
    _stateDict = {},
    ---@type string[]
    _stateNameList = {},
    _curStateName = nil,
    _nextStateName = nil,
    _stateSwitching = false
}

---代替self
local this = GameStateMgr

local setStateParam, getStateParam
local stateParamMap = {}

---@public
---初始化
function GameStateMgr.Init()
    local define = require("Runtime.System.X3Game.Modules.GameStateMgr.GameStateDefine")
    this._stateTransitionDict = define.StateTransitionDict
    for _, stateName in pairs(GameState) do
        table.insert(this._stateNameList, stateName)
    end
end

---@public
---清理
function GameStateMgr.Clear()
    table.clear(this._stateNameList)
end

---@public
---是否拥有状态
---@param stateName string 状态名
---@return boolean
function GameStateMgr.Has(stateName)
    if string.isnilorempty(stateName) then
        return false
    end

    if not table.indexof(this._stateNameList, stateName) then
        return false
    end
    return true
end

---@public
---切换状态
---@param stateName string 状态名
---@return boolean
---@vararg any 可变参数
function GameStateMgr.Switch(stateName, ...)
    if not this.Has(stateName) then
        return false
    end

    --- temp: 战斗状态-苟
    if stateName == this._curStateName or this._stateSwitching then
        return false
    end

    if not this._CanSwitch(stateName) then
        Debug.LogErrorFormat("不能从状态%s切换至状态%s", this._curStateName, stateName)
        return false
    end

    local state = this._stateDict[stateName]
    if not state then
        state = require(string.concat("Runtime.System.X3Game.Modules.GameStateMgr.", stateName, "State")).new()
        this._stateDict[stateName] = state
    end

    setStateParam(stateName, ...)
    this._nextStateName = stateName
    ---在本帧将交互事件屏蔽
    GameHelper.SetGlobalTouchEnable(false)
    Debug.LogFormat("切换状态：%s -> %s", this._curStateName, stateName)
    return true
end

---@public
---获取当前状态
---@return GameState
function GameStateMgr.GetCurState()
    if not this._curStateName then
        return nil
    end
    local ret = this._stateDict[this._curStateName]
    return ret
end

---@public
---获取当前状态名
---@return string
function GameStateMgr.GetCurStateName()
    return this._curStateName
end

---@public
---执行Tick，由GameMgr驱动
function GameStateMgr.Tick()
    if this._nextStateName ~= nil then
        this._stateSwitching = true
        local prevStateName = this._curStateName
        local nextStateName = this._nextStateName
        local curState = this._stateDict[prevStateName]
        local nextState = this._stateDict[nextStateName]

        local eligible = (curState == nil) or (curState ~= nil and curState:CanExit(nextStateName))

        if eligible then
            if curState ~= nil then
                curState:OnExit(nextStateName)
            end
            this._curStateName = nextStateName
            this._nextStateName = nil
            this._stateSwitching = false
            ---接入CrashSight数据上报
            CrashSightMgr.SetGameState(tostring(this._curStateName))
            CriticalLog.LogFormat("GameState.OnEnter: %s -> %s", prevStateName, nextStateName)
            nextState:OnEnter(prevStateName, getStateParam(this._curStateName))
        else
            -- wait next frame
        end
        this._stateSwitching = false
        ---将交互打开
        GameHelper.SetGlobalTouchEnable(true)
    end
end

---@private
---是否能切换状态
---@param stateName string 状态名
---@return boolean
function GameStateMgr._CanSwitch(stateName)
    if stateName == this._curStateName then
        return false
    end

    if this._curStateName == nil then
        return true
    end

    local transitionList = this._stateTransitionDict[this._curStateName]
    if transitionList == nil then
        return false
    end

    if not table.indexof(transitionList, stateName) then
        Debug.LogErrorFormat("can't switch from state(%s) to state(%s)", this._curStateName, stateName)
        return false
    end

    return true
end

---设置状态参数
---@param stateName string
---@vararg any 可变参数
setStateParam = function(stateName, ...)
    if string.isnilorempty(stateName) then
        return
    end
    if select('#', ...) == 0 then
        return
    end
    stateParamMap[stateName] = { ... }
end

---获取状态参数
---@param stateName string
---@param isClear boolean default true 获取之后是否清除缓存，默认是清除
---@return any ...
getStateParam = function(stateName, isClear)
    if string.isnilorempty(stateName) then
        return
    end
    local p = stateParamMap[stateName]
    if p then
        if isClear or isClear == nil then
            stateParamMap[stateName] = nil
        end
        return table.unpack(p)
    end
    return
end

return GameStateMgr