﻿----
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by canghai.
--- DateTime: 2022/10/25 11:43
---

---@class X3DataHistory
local X3DataHistory = {}

---@type X3DataSafety
local X3DataSafety

---是否允许记录，默认是允许记录的
local IsEnableRecord = true
---是否屏蔽所有的操作
local IsBlocked = false
local X3DataHistoryTreeRequirePath = "Runtime.System.X3Game.Modules.X3Data.X3DataHistoryTree"
---@type table<int, X3DataHistoryTree>>
local IdTreeDic = {}
---@type Pool
local TreePool
---缓存了X3Data的Operate在帧尾统一处理
local OperateCache
local OperateTypeAddFuncDic

---@param x3DataSafety X3DataSafety
function X3DataHistory.InjectX3DataSafetyModule(x3DataSafety)
    X3DataSafety = x3DataSafety
end

---修改是否记录所有数据的开关
---@param value boolean
function X3DataHistory.SetIsEnableRecord(value)
    if type(value) ~= 'boolean' then
        return
    end
    IsEnableRecord = value
end

---设置redo和undo的标记
---请在对X3Data进行非Reset/Undo/Redo的数据操作后AddMark，否则无法正确的回到上一次mark的位置
---@param x3Data X3Data.X3DataBase
---@return boolean
function X3DataHistory.AddMark(x3Data)
    ---- 安全检查开始 ----
    if IsBlocked or not IsEnableRecord then
        return false
    end

    if X3DataSafety.GetIsEnableSafetyCheck() then
        if type(x3Data) ~= "table" or x3Data.__X3DataBase == nil then
            Debug.LogErrorWithTag(GameConst.LogTag.X3DataSys, "X3DataHistory.AddMark 失败，请检查 x3Data!!!")
            return false
        end
    end

    if not x3Data.__isEnableHistory then
        return false
    end
    ---- 安全检查结束 ----

    ---@type X3DataHistoryTree
    local tree = IdTreeDic[x3Data.__uniqueId]
    if tree == nil then
        return false
    end

    --AddMark前需要先将已经进行的操作加入树中
    X3DataHistory.ClearOperateCacheById(x3Data.__uniqueId)
    tree:AddMark()
    return true
end

---重置X3Data到历史记录开启的时刻
---@param x3Data X3Data.X3DataBase
---@return boolean
function X3DataHistory.Reset(x3Data)
    ---- 安全检查开始 ----
    if IsBlocked or not IsEnableRecord then
        return false
    end

    if X3DataSafety.GetIsEnableSafetyCheck() then
        if type(x3Data) ~= "table" or x3Data.__X3DataBase == nil then
            Debug.LogErrorWithTag(GameConst.LogTag.X3DataSys, "X3DataHistory.Reset 失败，请检查 x3Data!!!")
            return false
        end
    end

    if not x3Data.__isEnableHistory then
        return false
    end
    ---- 安全检查结束 ----

    ---@type X3DataHistoryTree
    local tree = IdTreeDic[x3Data.__uniqueId]
    if tree == nil then
        return false
    end

    --操纵期间不能记录
    IsBlocked = true
    tree:Reset(x3Data)
    IsBlocked = false
    return true
end

---重置并清理当前版本的历史记录
---@param x3Data X3Data.X3DataBase
---@return boolean
function X3DataHistory.ResetWithHistoryCleared(x3Data)
    ---- 安全检查开始 ----
    if IsBlocked or not IsEnableRecord then
        return false
    end

    if X3DataSafety.GetIsEnableSafetyCheck() then
        if type(x3Data) ~= "table" or x3Data.__X3DataBase == nil then
            Debug.LogErrorWithTag(GameConst.LogTag.X3DataSys, "X3DataHistory.ResetWithHistoryCleared 失败，请检查 x3Data!!!")
            return false
        end
    end

    if not x3Data.__isEnableHistory then
        return false
    end
    ---- 安全检查结束 ----

    ---@type X3DataHistoryTree
    local tree = IdTreeDic[x3Data.__uniqueId]
    if tree == nil then
        return false
    end

    X3DataHistory.ClearOperateCacheById(x3Data.__uniqueId)
    --操纵期间不能记录
    IsBlocked = true
    tree:ResetWithHistoryCleared(x3Data)
    IsBlocked = false
    return true
end

---恢复X3Data上下一个Mark
---@param x3Data X3Data.X3DataBase
---@return boolean
function X3DataHistory.Undo(x3Data)
    ---- 安全检查开始 ----
    if IsBlocked or not IsEnableRecord then
        return false
    end

    if X3DataSafety.GetIsEnableSafetyCheck() then
        if type(x3Data) ~= "table" or x3Data.__X3DataBase == nil then
            Debug.LogErrorWithTag(GameConst.LogTag.X3DataSys, "X3DataHistory.Undo 失败，请检查 x3Data!!!")
            return false
        end
    end

    if not x3Data.__isEnableHistory then
        return false
    end
    ---- 安全检查结束 ----

    ---@type X3DataHistoryTree
    local tree = IdTreeDic[x3Data.__uniqueId]
    if tree == nil then
        return false
    end

    --操纵期间不能记录
    IsBlocked = true
    local result = tree:Undo(x3Data)
    IsBlocked = false
    return result
end

---恢复X3Data到下一个Mark
---@param x3Data X3Data.X3DataBase
---@return boolean
function X3DataHistory.Redo(x3Data)
    ---- 安全检查开始 ----
    if IsBlocked or not IsEnableRecord then
        return false
    end

    if X3DataSafety.GetIsEnableSafetyCheck() then
        if type(x3Data) ~= "table" or x3Data.__X3DataBase == nil then
            Debug.LogErrorWithTag(GameConst.LogTag.X3DataSys, "X3DataHistory.Redo 失败，请检查 x3Data!!!")
            return false
        end
    end

    if not x3Data.__isEnableHistory then
        return false
    end
    ---- 安全检查结束 ----

    ---@type X3DataHistoryTree
    local tree = IdTreeDic[x3Data.__uniqueId]
    if tree == nil then
        return false
    end

    --操纵期间不能记录
    IsBlocked = true
    local result = tree:Redo(x3Data)
    IsBlocked = false
    return result
end

---检查是否可以Undo
---@param x3Data X3Data.X3DataBase
---@return boolean
function X3DataHistory.CheckCanUndo(x3Data)
    ---- 安全检查开始 ----
    if IsBlocked or not IsEnableRecord then
        return false
    end

    if X3DataSafety.GetIsEnableSafetyCheck() then
        if type(x3Data) ~= "table" or x3Data.__X3DataBase == nil then
            Debug.LogErrorWithTag(GameConst.LogTag.X3DataSys, "X3DataHistory.CheckCanUndo 失败，请检查 x3Data!!!")
            return false
        end
    end

    if not x3Data.__isEnableHistory then
        return false
    end
    ---- 安全检查结束 ----

    ---@type X3DataHistoryTree
    local tree = IdTreeDic[x3Data.__uniqueId]
    if tree == nil then
        return false
    end

    return tree:CheckCanUndo()
end

---检查是否可以Redo
---@param x3Data X3Data.X3DataBase
---@return boolean
function X3DataHistory.CheckCanRedo(x3Data)
    ---- 安全检查开始 ----
    if IsBlocked or not IsEnableRecord then
        return false
    end

    if X3DataSafety.GetIsEnableSafetyCheck() then
        if type(x3Data) ~= "table" or x3Data.__X3DataBase == nil then
            Debug.LogErrorWithTag(GameConst.LogTag.X3DataSys, "X3DataHistory.CheckCanRedo 失败，请检查 x3Data!!!")
            return false
        end
    end

    if not x3Data.__isEnableHistory then
        return false
    end
    ---- 安全检查结束 ----

    ---@type X3DataHistoryTree
    local tree = IdTreeDic[x3Data.__uniqueId]
    if tree == nil then
        return false
    end

    return tree:CheckCanRedo()
end

--region 版本管理
---将当前的X3Data进行一个完整的备份
---@param x3Data X3Data.X3DataBase
---@return boolean
function X3DataHistory.SerializeVersion(x3Data)
    ---- 安全检查开始 ----
    if IsBlocked or not IsEnableRecord then
        return false
    end

    if X3DataSafety.GetIsEnableSafetyCheck() then
        if type(x3Data) ~= "table" or x3Data.__X3DataBase == nil then
            Debug.LogErrorWithTag(GameConst.LogTag.X3DataSys, "X3DataHistory.Serialize 失败，请检查 x3Data!!!")
            return false
        end
    end

    if not x3Data.__isEnableHistory then
        return false
    end
    ---- 安全检查结束 ----

    ---@type X3DataHistoryTree
    local tree = IdTreeDic[x3Data.__uniqueId]
    if tree == nil then
        return false
    end
    
    tree:ClearVersionStack()
    tree:_Serialize(x3Data)
    return true
end

---将当前的X3Data进行一个完整的备份
---@param x3Data X3Data.X3DataBase
---@return boolean
function X3DataHistory.RevertToPreVersion(x3Data)
    ---- 安全检查开始 ----
    if IsBlocked or not IsEnableRecord then
        return false
    end

    if X3DataSafety.GetIsEnableSafetyCheck() then
        if type(x3Data) ~= "table" or x3Data.__X3DataBase == nil then
            Debug.LogErrorWithTag(GameConst.LogTag.X3DataSys, "X3DataHistory.Serialize 失败，请检查 x3Data!!!")
            return false
        end
    end

    if not x3Data.__isEnableHistory then
        return false
    end
    ---- 安全检查结束 ----

    ---@type X3DataHistoryTree
    local tree = IdTreeDic[x3Data.__uniqueId]
    if tree == nil then
        return false
    end

    --回退版本前需要先将已经发生的操作清理了，解决异步操作的问题
    X3DataHistory.ClearOperateCacheById(x3Data.__uniqueId)
    IsBlocked = true
    local result = tree:RevertToPreVersion(x3Data)
    IsBlocked = false
    return result
end

---将当前的X3Data进行一个完整的备份
---@param x3Data X3Data.X3DataBase
---@return boolean
function X3DataHistory.RevertToNextVersion(x3Data)
    ---- 安全检查开始 ----
    if IsBlocked or not IsEnableRecord then
        return false
    end

    if X3DataSafety.GetIsEnableSafetyCheck() then
        if type(x3Data) ~= "table" or x3Data.__X3DataBase == nil then
            Debug.LogErrorWithTag(GameConst.LogTag.X3DataSys, "X3DataHistory.Serialize 失败，请检查 x3Data!!!")
            return false
        end
    end

    if not x3Data.__isEnableHistory then
        return false
    end
    ---- 安全检查结束 ----

    ---@type X3DataHistoryTree
    local tree = IdTreeDic[x3Data.__uniqueId]
    if tree == nil then
        return false
    end

    --回退版本前需要先将已经发生的操作清理了，解决异步操作的问题
    X3DataHistory.ClearOperateCacheById(x3Data.__uniqueId)
    IsBlocked = true
    local result = tree:RevertToNextVersion(x3Data)
    IsBlocked = false
    return result
end

---检查是否能回退到前一个历史版本
---@param x3Data X3Data.X3DataBase
---@return boolean
function X3DataHistory.CheckCanRevertToPreVersion(x3Data)
    ---- 安全检查开始 ----
    if IsBlocked or not IsEnableRecord then
        return false
    end

    if X3DataSafety.GetIsEnableSafetyCheck() then
        if type(x3Data) ~= "table" or x3Data.__X3DataBase == nil then
            Debug.LogErrorWithTag(GameConst.LogTag.X3DataSys, "X3DataHistory.CheckCanUndo 失败，请检查 x3Data!!!")
            return false
        end
    end

    if not x3Data.__isEnableHistory then
        return false
    end
    ---- 安全检查结束 ----

    ---@type X3DataHistoryTree
    local tree = IdTreeDic[x3Data.__uniqueId]
    if tree == nil then
        return false
    end

    return tree:CheckCanRevertToPreVersion()
end

---检查是否能回退到后一个历史版本
---@param x3Data X3Data.X3DataBase
---@return boolean
function X3DataHistory.CheckCanRevertToNextVersion(x3Data)
    ---- 安全检查开始 ----
    if IsBlocked or not IsEnableRecord then
        return false
    end

    if X3DataSafety.GetIsEnableSafetyCheck() then
        if type(x3Data) ~= "table" or x3Data.__X3DataBase == nil then
            Debug.LogErrorWithTag(GameConst.LogTag.X3DataSys, "X3DataHistory.CheckCanUndo 失败，请检查 x3Data!!!")
            return false
        end
    end

    if not x3Data.__isEnableHistory then
        return false
    end
    ---- 安全检查结束 ----

    ---@type X3DataHistoryTree
    local tree = IdTreeDic[x3Data.__uniqueId]
    if tree == nil then
        return false
    end

    return tree:CheckCanRevertToNextVersion()
end

---将当前的X3Data进行一个完整的备份
---@param x3Data X3Data.X3DataBase
function X3DataHistory.ClearSerializedVersion(x3Data)
    ---- 安全检查开始 ----
    if IsBlocked or not IsEnableRecord then
        return false
    end

    if X3DataSafety.GetIsEnableSafetyCheck() then
        if type(x3Data) ~= "table" or x3Data.__X3DataBase == nil then
            Debug.LogErrorWithTag(GameConst.LogTag.X3DataSys, "X3DataHistory.Serialize 失败，请检查 x3Data!!!")
            return false
        end
    end

    if not x3Data.__isEnableHistory then
        return false
    end
    ---- 安全检查结束 ----

    ---@type X3DataHistoryTree
    local tree = IdTreeDic[x3Data.__uniqueId]
    if tree == nil then
        return false
    end

    --回退版本前需要先将已经发生的操作清理了，解决异步操作的问题
    X3DataHistory.ClearOperateCacheById(x3Data.__uniqueId)
    IsBlocked = true
    tree:ClearSerializedVersion(x3Data)
    IsBlocked = false
    return true
end
--endregion 版本管理结束

---每次开启历史记录的时候都会清理该节点旧的记录
---@private
---@param x3Data X3Data.X3DataBase
function X3DataHistory._EnableHistory(x3Data)
    X3DataHistory.ClearHistory(x3Data)

    ---@type X3DataHistoryTree
    local tree = IdTreeDic[x3Data.__uniqueId]
    if tree == nil then
        tree = X3DataHistory._GetTreeFromPool(x3Data)
        IdTreeDic[x3Data.__uniqueId] = tree
    end
end

---向树中插入节点
---@private
---@param operate X3DataHistoryOperate
function X3DataHistory._RecordHistory(operate)
    --减少内存占用 相当于operate.x3Data = nil
    local x3Data = table.remove(operate)
    ---@type X3DataHistoryTree
    local tree = IdTreeDic[x3Data.__uniqueId]
    tree:CreateTreeNode(tree.curNode, operate, false)
end

---每次开启历史记录的时候都会清理该节点旧的记录
---@param x3Data X3Data.X3DataBase
function X3DataHistory.ClearHistory(x3Data)
    local tree = IdTreeDic[x3Data.__uniqueId]
    if tree == nil then
        return
    end

    IdTreeDic[x3Data.__uniqueId] = nil
    X3DataHistory._ReleaseTreeToPool(tree)

    --清理operateCache
    local operateDic = OperateCache[x3Data.__uniqueId]
    if operateDic ~= nil then
        for _, operate in pairs(operateDic) do
            --array copy有用到的新array
            PoolUtil.ReleaseTable(operate[3])
            PoolUtil.ReleaseTable(operate)
        end

        PoolUtil.ReleaseTable(operateDic)
        OperateCache[x3Data.__uniqueId] = nil
    end
end

---从池中取出X3DataHistoryTree并初始化
---@private
---@param x3Data X3Data.X3DataBase
---@return X3DataHistoryTree
function X3DataHistory._GetTreeFromPool(x3Data)
    if TreePool == nil then
        TreePool = PoolUtil.Get(function()
            return require(X3DataHistoryTreeRequirePath).new()
        end, function(tree)
            tree:Clear()
        end)
    end
    ---@type X3DataHistoryTree
    local tree = TreePool:Get()
    tree:Init(x3Data)
    return tree
end

---@private
---@param tree X3DataHistoryTree
function X3DataHistory._ReleaseTreeToPool(tree)
    if TreePool == nil then
        return
    end
    TreePool:Release(tree)
end

---避免单帧内反复的修改只算一次历史记录
---@param operateType X3DataConst.X3DataOperateType
---@param x3Data X3Data.X3DataBase
---@param fieldName string
---@param newValue any
---@param key any
function X3DataHistory.AddOrModifyOperateCache(operateType, x3Data, fieldName, newValue, key)
    -- 可以自定义的关闭记录
    if IsBlocked or not IsEnableRecord or not x3Data.__isEnableHistory then
        return false
    end

    if OperateCache[x3Data.__uniqueId] == nil then
        OperateCache[x3Data.__uniqueId] = PoolUtil.GetTable()
    end

    local operateTable = OperateCache[x3Data.__uniqueId][fieldName]
    if operateTable == nil then
        operateTable = PoolUtil.GetTable()
        OperateCache[x3Data.__uniqueId][fieldName] = operateTable
    end

    OperateTypeAddFuncDic[operateType](operateTable, fieldName, newValue, key, x3Data)
end

---在帧尾清理OperateCache
function X3DataHistory.ClearOperateCache()
    for _, fieldNameOperateArrayDic in pairs(OperateCache) do
        for _, operateTable in pairs(fieldNameOperateArrayDic) do
            for _, operate in pairs(operateTable) do
                X3DataHistory._RecordHistory(operate)
            end
            PoolUtil.ReleaseTable(operateTable)
        end
        PoolUtil.ReleaseTable(fieldNameOperateArrayDic)
    end

    table.clear(OperateCache)
end

---通过Id提前清理OperateCache
function X3DataHistory.ClearOperateCacheById(id)
    local fieldNameOperateArrayDic = OperateCache[id]
    if not fieldNameOperateArrayDic then
        return
    end
    for _, operateTable in pairs(fieldNameOperateArrayDic) do
        for _, operate in pairs(operateTable) do
            X3DataHistory._RecordHistory(operate)
        end
        PoolUtil.ReleaseTable(operateTable)
    end
    
    PoolUtil.ReleaseTable(fieldNameOperateArrayDic)
    OperateCache[id] = nil
end

---@param x3Data X3Data.X3DataBase
---@param value boolean
function X3DataHistory.SetIsEnableHistory(x3Data, value)
    ---- 安全检查开始 ----
    if X3DataSafety.GetIsEnableSafetyCheck() then
        if type(value) ~= "boolean" then
            return
        end
    end
    ---- 安全检查结束 ----

    if x3Data.__isEnableHistory == value then
        return
    end

    rawset(x3Data, "__isEnableHistory", value)
    X3DataHistory._EnableHistory(x3Data);
end

---@param x3Data X3Data.X3DataBase
---@return number
function X3DataHistory.GetHistoryRecordMaxIndex(x3Data)
    ---@type X3DataHistoryTree
    local tree = IdTreeDic[x3Data.__uniqueId]
    if tree == nil then
        return 0
    end
    return tree.curMaxIndex
end

---@param x3Data X3Data.X3DataBase
---@return number
function X3DataHistory.GetCurHistoryRecordIndex(x3Data)
    ---@type X3DataHistoryTree
    local tree = IdTreeDic[x3Data.__uniqueId]
    if tree == nil then
        return 0
    end
    return tree.curNode.index
end

---@param x3Data X3Data.X3DataBase
---@param index number
---@return boolean
function X3DataHistory.RevertByRecordIndex(x3Data, index)
    if IsBlocked or not IsEnableRecord then
        return false
    end
    
    X3DataHistory.ClearOperateCacheById(x3Data.__uniqueId)
    ---@type X3DataHistoryTree
    local tree = IdTreeDic[x3Data.__uniqueId]
    if tree == nil then
        return false
    end

    if index > tree.curMaxIndex or index < 1 then
        return false
    end

    --操纵期间不能记录
    IsBlocked = true
    tree:_RevertByIndex(x3Data, index)
    IsBlocked = false
    return true
end
---缓存了X3Data的Operate在帧尾统一处理
---两级key x3Data的id x3Data的fieldName
---针对字段类型做如下处理
---基础类型 最后只有一个值，每次都替换
---array 拷贝
---map 最后是key,operate 对于map来说可以全部当成update处理
OperateCache = {}
OperateTypeAddFuncDic = {
    [X3DataConst.X3DataOperateType.MapUpdate] = function(operateTable, fieldName, value, key, x3Data)
        --MapUpdate与MapClear互斥
        if operateTable.__MapClear ~= nil then
            PoolUtil.ReleaseTable(operateTable.__MapClear)
            operateTable.__MapClear = nil
        end
        
        ---@type X3DataHistoryOperate
        local operate = operateTable[key]
        if operate == nil then
            operate = PoolUtil.GetTable()
            operateTable[key] = operate
            table.insert(operate, X3DataConst.X3DataOperateType.MapUpdate)
            table.insert(operate, fieldName)
            table.insert(operate, value)
            table.insert(operate, key)
            table.insert(operate, x3Data)
        else
            --只改value
            operate[3] = value
        end
    end,
    [X3DataConst.X3DataOperateType.ArrayCopy] = function(operateTable, fieldName, value, key, x3Data)
        ---@type X3DataHistoryOperate
        local operate = operateTable[1]
        if operate == nil then
            operate = PoolUtil.GetTable()
            table.insert(operateTable, operate)
            table.insert(operate, X3DataConst.X3DataOperateType.ArrayCopy)
            table.insert(operate, fieldName)
            table.insert(operate, PoolUtil.GetTable())
            table.insert(operate, key)
            table.insert(operate, x3Data)
        end
        --先清理后增加
        table.clear(operate[3])
        if value ~= nil then
            for _, v in ipairs(value) do
                table.insert(operate[3], v)
            end
        end
    end,
    ---@return boolean 返回是否增加元素
    [X3DataConst.X3DataOperateType.BasicSet] = function(operateTable, fieldName, value, key, x3Data)
        ---@type X3DataHistoryOperate
        local operate = operateTable[1]
        if operate == nil then
            operate = PoolUtil.GetTable()
            table.insert(operateTable, operate)
            table.insert(operate, X3DataConst.X3DataOperateType.BasicSet)
            table.insert(operate, fieldName)
            table.insert(operate, value)
            table.insert(operate, key)
            table.insert(operate, x3Data)
        else
            --只改value
            operate[3] = value
        end
    end,
    [X3DataConst.X3DataOperateType.MapClear] = function(operateTable, fieldName, value, key, x3Data)
        if operateTable.__MapClear ~= nil then
            --已经clear了
            return
        end

        --MapUpdate与MapClear互斥
        if not table.isnilorempty(operateTable) then
            for _, operate in pairs(operateTable)do
                PoolUtil.ReleaseTable(operate)
            end
            table.clear(operateTable)
        end

        local operate = PoolUtil.GetTable()
        operateTable.__MapClear = operate
        table.insert(operate, X3DataConst.X3DataOperateType.MapClear)
        table.insert(operate, fieldName)
        table.insert(operate, value)
        table.insert(operate, key)
        table.insert(operate, x3Data)
    end,
}

function X3DataHistory.Clear()
    IsEnableRecord = true
    IsBlocked = false
    IdTreeDic = {}
    TreePool = nil
    OperateCache = {}
end

return X3DataHistory