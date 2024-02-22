--- Created by fusu.

local globalDeclare = require("GlobalDeclare")
local master = require("Runtime.Common.Master")

---管理注册的Clear
local registerClearMap = {}
local reInitMap = {}

---重启Destroy白名单
local destroyWhiteList =
{
    ["Runtime.System.X3Game.Modules.GameDataBridge.BridgeDataBase"] = true,
    ["Runtime.System.X3Game.Modules.GameDataBridge.GameDataBridge"] = true,
}

---@class GameGlobalHelper
local GameGlobalHelper = {}

function GameGlobalHelper.GetReInitTable()
    if table.isnilorempty(reInitMap) then
        local tempList = globalDeclare.GlobalInfoMap.GameInit
        for _, globalName in ipairs(tempList) do
            reInitMap[globalName] = globalName
        end
    end
    return reInitMap
end

---游戏重启
function GameGlobalHelper.ReInitGlobal()
    ---初始化底层基础数据
    X3DataMgr.Init()

    ---logout 重新初始化
    local _reInitMap = GameGlobalHelper.GetReInitTable()
    GameGlobalHelper.InvokeLuaFunc("Init", _reInitMap)

    for i = #registerClearMap, 1, -1 do
        local clearFuncInfo = registerClearMap[i]
        clearFuncInfo.initFunc()
    end

    ---重新初始化功能
    InitSystem()
end

---GlobalLua的Destroy
function GameGlobalHelper.DestroyAllGlobalLua()
    ---战斗在这里单独引用清理
    CS.X3Battle.BattleEnv.OnGameReboot()
    ---清理C#注册的Delegate
    local delegateHandler = require("Runtime.System.X3Game.Modules.GameMisc.DelegateHandler")
    delegateHandler.OnClear()
    ---热更新重启,调用GlobalLua的Destroy
    GameGlobalHelper.InvokeLuaFunc("Destroy")
    master.UnLoadAllLua(destroyWhiteList)
    GameGlobalHelper.RestoreEngine()
end

---GlobalLua的Destroy
function GameGlobalHelper.ClearAllGlobalLua()
    GameGlobalHelper.InvokeLuaFunc("Clear")

    ---清理白名单
    local whiteList = globalDeclare.GlobalInfoMap.WhiteList
    local result = {}
    for _, tableName in ipairs(whiteList) do
        if globalDeclare.Global[tableName] == nil then
            result[tableName] = tableName
        end
    end
    GameGlobalHelper.InvokeLuaFunc("Clear", result)
    result = nil

    ---清理注册的方法
    for i = #registerClearMap, 1, -1 do
        local clearFuncInfo = registerClearMap[i]
        clearFuncInfo.clearFunc()
    end

    ---清理全局变量, 保证下次调用, 会重新初始化
    local allGlobal = globalDeclare.Global
    local _reInitMap = GameGlobalHelper.GetReInitTable()
    local script_global_map = master.GetCustomGlobal()
    for globalName, _ in pairs(allGlobal) do
        if _reInitMap[globalName] == nil then
            script_global_map[globalName] = nil
        end
    end

    ---清理资源缓存,保底逻辑,放在lua清理之后
    X3AssetInsProvider.CSClear()

    ---卸载GameStart,保证游戏正常进行
    master.UnLoadLua("GameStart")
end

---调用全局
---@param file_path string
function GameGlobalHelper.InvokeLuaFunc(funcName, allGlobalList)
    local allGlobal = allGlobalList or globalDeclare.Global
    local script_global_map = master.GetCustomGlobal()
    for tableKey, _ in pairs(allGlobal) do
        if script_global_map then
            local global = script_global_map[tableKey]
            if global and global[funcName] then
                global[funcName](global)
            end
        end
    end
end

---注册清理
---@param clearFunc function
---@param initFunc function
function GameGlobalHelper.RegisterClear(clearFunc, initFunc)
    local tempTable = {}
    tempTable.clearFunc = clearFunc
    tempTable.initFunc = initFunc
    registerClearMap[#registerClearMap + 1] = tempTable
end

---根据类型初始化全局变量
---@param globalType string
function GameGlobalHelper.InitGlobal(globalType)
    local initTable = globalDeclare.GlobalInfoMap[globalType]
    if initTable == nil then
        return
    end
    for _, globalKey in ipairs(initTable) do
        local global = _G[globalKey]
    end
end

local _debug, _print, _profiler, _vector2, _vector3, _vector4, _quaternion, _color, _mathf
function GameGlobalHelper.InitEngine()
    _print = print
    _debug = CS.UnityEngine.Debug
    _profiler = CS.UnityEngine.Profiling.Profiler
    _vector2 = CS.UnityEngine.Vector2
    _vector3 = CS.UnityEngine.Vector3
    _vector4 = CS.UnityEngine.Vector4
    _quaternion = CS.UnityEngine.Quaternion
    _color = CS.UnityEngine.Color
    _mathf = CS.UnityEngine.Mathf
end

function GameGlobalHelper.RestoreEngine()
    if _debug == nil then return end
    CS.UnityEngine.Debug = _debug
    CS.UnityEngine.Profiling.Profiler = _profiler
    CS.UnityEngine.Vector2 = _vector2
    CS.UnityEngine.Vector3 = _vector3
    CS.UnityEngine.Vector4 = _vector4
    CS.UnityEngine.Quaternion = _quaternion
    CS.UnityEngine.Color = _color
    CS.UnityEngine.Mathf = _mathf
    print = _print
end

return GameGlobalHelper