﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by canghai.
--- DateTime: 2022/11/16 17:54
---

---@class X3DataPool
local X3DataPool = {}

---@type X3DataSafety
local X3DataSafety
---@type X3DataAssociation
local X3DataAssociation

---X3DataSet 以及 X3Data的分类对象池
local X3DataMgrPoolMap = {}
---CreateX3Data的时候赋予的唯一Id
local X3DataCurMaxId = 0

---@param x3DataSafety X3DataSafety
function X3DataPool.InjectX3DataSafetyModule(x3DataSafety)
    X3DataSafety = x3DataSafety
end

---@param x3DataAssociation X3DataAssociation
function X3DataPool.InjectX3DataAssociationModule(x3DataAssociation)
    X3DataAssociation = x3DataAssociation
end

---根据类型创建X3Data
---@param x3DataType string
---@return X3Data.X3DataBase
function X3DataPool.Create(x3DataType)
    if X3DataSafety.GetIsEnableSafetyCheck() then
        if not X3DataSafety.X3DataTypeCheck(x3DataType, "Create") then
            return nil
        end
    end

    local x3Data = X3DataPool.GetDataFromPool(x3DataType)
    if x3Data == nil then
        Debug.LogFatalFormatWithTag(GameConst.LogTag.X3DataSysDebug, "X3DataMgr.Create %s 失败，类型尚未定义或者require失败，请检查P4上的资源！！！", x3DataType)
        return nil
    end

    --取出的数据需要重新启动回调以及修改记录的功能
    rawset(x3Data, "__isDisableFieldRecord", false)
    rawset(x3Data, "__isDisableModifyRecord", false)
    
    -- 每次重新出来的时候 uniqueId 都会变
    X3DataCurMaxId = X3DataCurMaxId + 1
    rawset(x3Data, "__uniqueId", X3DataCurMaxId)
    rawset(x3Data, "__isInX3DataSet", false)
    rawset(x3Data, "__isPrimarySet", false)
    rawset(x3Data, "__isReleased", false)
    Debug.LogFormatWithTag(GameConst.LogTag.X3DataSysDebug, "X3DataMgr.Create %s 成功！！！", x3DataType)
    return x3Data
end

---回收 X3DataMgr.Create 的 X3Data
---@param x3Data X3Data.X3DataBase
---@return boolean
function X3DataPool.Release(x3Data)
    ---提高容错，nil 不处理
    if x3Data == nil then
        return true
    end
    
    if X3DataSafety.GetIsEnableSafetyCheck() then
        if x3Data ~= nil and type(x3Data) ~= "table" or x3Data.__X3DataBase == nil then
            Debug.LogErrorWithTag(GameConst.LogTag.X3DataSys, "X3DataMgr.Release 失败，请检查 x3Data！！！")
            return false
        end
    end

    --已经被释放的数据无需再次处理
    if x3Data.__isReleased then
        return true
    end
    
    if x3Data.__isInX3DataSet then
        Debug.LogFormatWithTag(GameConst.LogTag.X3DataSysDebug, "X3DataMgr.Release 失败, 请在 X3DataMgr.Release【%s】类型的数据之前调用 Remove 接口删除数据！！！", x3Data.__cname)
        return false
    end

    --Release后（即使被业务Cache）也无法再触发任何回调
    --如果在数据库中的数据被调用Release需要从数据库中移除
    rawset(x3Data, "__isDirty", false)
    rawset(x3Data, "__isInX3DataSet", false)
    rawset(x3Data, "__isPrimarySet", false)
    rawset(x3Data, "__isEnableHistory", false)
    X3DataPool.ReleaseDataToPool(x3Data)
    --释放后的数据不能被使用（Clear在Release Func 中下面的值会被设置成 false）
    rawset(x3Data, "__isDisableFieldRecord", true)
    rawset(x3Data, "__isDisableModifyRecord", true)
    rawset(x3Data, "__isReleased", true)
    x3Data:ClearHistory()
    X3DataAssociation.ReleaseNode(x3Data)
    Debug.LogFormatWithTag(GameConst.LogTag.X3DataSysDebug, "X3DataMgr.Release %s 成功！！！", x3Data.__cname)
    return true
end

---动态创建X3Data的对象池并且获取X3Data对象
---@param x3DataType string
---@return X3Data.X3DataBase
function X3DataPool.GetDataFromPool(x3DataType)
    ---@type Pool
    local pool = X3DataMgrPoolMap[x3DataType]
    if pool == nil then
        pool = PoolUtil.Get(function()
            --这里可能会因为P4更新导致拿不到（文件名大小写改过）
            local x3DataRequire = require(X3DataConst.X3DataRequire[x3DataType])
            if x3DataRequire == nil then
                return nil
            end
            
            local x3Data = x3DataRequire.new()
            x3Data:Clear()
            return x3Data
        end, function(x3Data)
            x3Data:Clear()
        end)
        X3DataMgrPoolMap[x3DataType] = pool
    end

    return pool:Get()
end

---@param x3Data X3Data.X3DataBase
function X3DataPool.ReleaseDataToPool(x3Data)
    ---@type Pool
    local pool = X3DataMgrPoolMap[x3Data.__cname]
    if not pool then
        return
    end

    pool:Release(x3Data)
end

function X3DataPool.Clear()
    for _, pool in pairs(X3DataMgrPoolMap) do
        PoolUtil.Release(pool)
    end
    X3DataMgrPoolMap = {}
    X3DataCurMaxId = 0
end

return X3DataPool