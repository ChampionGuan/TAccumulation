﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by canghai.
--- DateTime: 2022/9/16 15:03
---

---@class X3DataMgr
local X3DataMgr = {}
---@type X3DataSafety
local X3DataSafety = require("Runtime.System.X3Game.Modules.X3Data.X3DataSafety")
---@type X3DataPublisher
local X3DataPublisher = require("Runtime.System.X3Game.Modules.X3Data.X3DataPublisher")
---@type X3DataHistory
local X3DataHistory = require("Runtime.System.X3Game.Modules.X3Data.X3DataHistory")
---@type X3DataPool
local X3DataPool = require("Runtime.System.X3Game.Modules.X3Data.X3DataPool")
---@type X3DataCRUDHelper
local X3DataCRUDHelper = require("Runtime.System.X3Game.Modules.X3Data.X3DataCRUDHelper")
---@type X3DataSerializer
local X3DataSerializer = require("Runtime.System.X3Game.Modules.X3Data.X3DataSerializer")
---@type X3DataPersistence
local X3DataPersistence = require("Runtime.System.X3Game.Modules.X3Data.X3DataPersistence")
---@type X3DataSet
local X3DataSet
local X3DataSetPool
local X3DataSetRequirePath = "Runtime.System.X3Game.Data.X3Data.AutoGenerated.X3DataSet"
---@type X3DataAssociation
local X3DataAssociation = require("Runtime.System.X3Game.Modules.X3Data.X3DataAssociation")
---@type X3DataExternalBridge
local X3DataExternalBridge = require("Runtime.System.X3Game.Modules.X3Data.X3DataExternalBridge")

local Init
local OnLateUpdate
local OnPersistenceTick
local GetX3DataSetCloneFromPool
local ReleaseX3DataSetCloneToPool

--region 数据创建和回收方法
---根据类型创建X3Data
---@param x3DataType string
---@return X3Data.UseArgString1
function X3DataMgr.Create(x3DataType)
    return X3DataPool.Create(x3DataType)
end

---回收 X3DataMgr.Create 的 X3Data
---@param x3Data X3Data.X3DataBase
---@return boolean
function X3DataMgr.Release(x3Data)
    return X3DataPool.Release(x3Data)
end
--endregion 数据创建和回收方法结束

--region 查询方法
---返回符合查询条件的第一条数据
---@param x3DataType string
---@param condition table 查询的条件
---@return X3Data.UseArgString1
function X3DataMgr.GetByCondition(x3DataType, condition)
    return X3DataCRUDHelper.GetByCondition(x3DataType, condition)
end

---返回最后一条数据，如果没有就创建空数据并返回
---@param x3DataType string
---@return X3Data.UseArgString1
function X3DataMgr.GetOrAdd(x3DataType)
    return X3DataCRUDHelper.GetOrAdd(x3DataType)
end

---根据主键进行查询返回符合条件的数据
---如果数据放入了数据库但是没有设置过主键，无法获取
---@param x3DataType string
---@param primaryValue number|string 主键
---@return X3Data.UseArgString1
function X3DataMgr.Get(x3DataType, primaryValue)
    return X3DataCRUDHelper.Get(x3DataType, primaryValue)
end

---根据index查询获取结果
---@param x3DataType string
---@param index number index默认是Last
---@return X3Data.UseArgString1
function X3DataMgr.GetByIndex(x3DataType, index)
    return X3DataCRUDHelper.GetByIndex(x3DataType, index)
end

---对数据进行筛选后返回经过排序的数据
---需要外界提供容器 result
---@param x3DataType string
---@param result table 存放结果的容器
---@param filterFunc fun(x3Data:X3Data.X3DataBase):boolean 数据的筛选方法，为空就是返回所有的数据不筛选
---@param sortFunc fun(a:X3Data.X3DataBase, b:X3Data.X3DataBase):boolean 数据的排序方法，为空就是自然顺序
---@return int
function X3DataMgr.GetAll(x3DataType, result, filterFunc, sortFunc)
    return X3DataCRUDHelper.GetAll(x3DataType, result, filterFunc, sortFunc)
end

---返回该类型的第一条数据
---@param x3DataType string
function X3DataMgr.GetFirst(x3DataType)
    return X3DataCRUDHelper.GetFirst(x3DataType)
end

---返回该类型的前count条数据，结果是正序的1,2,3...Count
---@param x3DataType string
---@param result table
---@param count number count如果是Last就是全部数据
---@return number 实际的结果数量 <= Count
function X3DataMgr.GetFirstByCount(x3DataType, result, count)
    return X3DataCRUDHelper.GetFirstByCount(x3DataType, result, count)
end

---返回该类型的最后一条数据
---@param x3DataType string
---@return X3Data.UseArgString1
function X3DataMgr.GetLast(x3DataType)
    return X3DataCRUDHelper.GetLast(x3DataType)
end

---返回该类型的后count条数据，结果是倒序的Last,Last-1,Last-2,...
---@param x3DataType string
---@param result table
---@param count number count如果是Last就是全部数据
---@return number 实际的结果数量 <= Count
function X3DataMgr.GetLastByCount(x3DataType, result, count)
    return X3DataCRUDHelper.GetLastByCount(x3DataType, result, count)
end

---判断该类型有没有符合条件的数据
---@param x3DataType string
---@param predictFunc fun(x3Data:X3Data.X3DataBase):boolean
---@return boolean
function X3DataMgr.Contains(x3DataType, predictFunc)
    return X3DataCRUDHelper.Contains(x3DataType, predictFunc)
end
--endregion 查询方法结束

--region 数据添加方法
---向数据库中插入一条记录，如果插入index = 3的位置，原先3号位置的就会向后移动
---如果需要插入到最后请使用 X3DataConst.Last
---@param x3DataType string
---@param source table 可以是nil会创建空数据并存入数据库
---@param index number 默认是Last，超出范围就会返回nil插入失败
---@return X3Data.UseArgString1
function X3DataMgr.Add(x3DataType, source, index)
    return X3DataCRUDHelper.Add(x3DataType, source, index)
end

---向数据库中插入一条记录（末尾），如果主键的值已经有对应的记录则插入失败返回 nil
---@param x3DataType string
---@param source table 可以是nil会创建空数据并存入数据库
---@param primaryValue number|string 必须保证主键非空
---@return X3Data.UseArgString1
function X3DataMgr.AddByPrimary(x3DataType, source, primaryValue)
    return X3DataCRUDHelper.AddByPrimary(x3DataType, source, primaryValue)
end
--endregion 数据添加方法结束

--region 数据删除方法
---根据主键移除数据，如果主键没有设置将移除失败
---@param x3DataType string
---@param primaryValue number|string 主键
---@return boolean
function X3DataMgr.Remove(x3DataType, primaryValue)
    return X3DataCRUDHelper.Remove(x3DataType, primaryValue)
end

---根据index移除数据，超出范围将移除失败
---@param x3DataType string
---@param index number 默认是 Last，超出范围会删除失败
---@return boolean
function X3DataMgr.RemoveByIndex(x3DataType, index)
    return X3DataCRUDHelper.RemoveByIndex(x3DataType, index)
end

---删除所有符合条件的数据
---@param x3DataType string
---@param condition table 查询的条件
---@return boolean
function X3DataMgr.RemoveByCondition(x3DataType, condition)
    return X3DataCRUDHelper.RemoveByCondition(x3DataType, condition)
end

---删除该类型所有数据
---@param x3DataType string
function X3DataMgr.RemoveAll(x3DataType)
    X3DataCRUDHelper.RemoveAll(x3DataType)
end
--endregion 数据删除方法结束

--region 数据更新方法
---只能更新主键已经设置过的数据
---@param x3DataType string
---@param primaryValue number|string
---@param source table
---@return boolean
function X3DataMgr.Update(x3DataType, primaryValue, source)
    return X3DataCRUDHelper.Update(x3DataType, primaryValue, source)
end

---根据index更新数据
---@param x3DataType string
---@param index number 没有默认值，超出范围或者是为空都会失败
---@param source table
---@return boolean
function X3DataMgr.UpdateByIndex(x3DataType, index, source)
    return X3DataCRUDHelper.UpdateByIndex(x3DataType, index, source)
end
--endregion 数据更新方法结束

--region 数据遍历方法
---先筛选出符合条件的数据，依次调用iterationFunc
---@param x3DataType string
---@param iterationFunc fun(x3Data:X3Data.X3DataBase):void 迭代方法如果不允许为空
---@param filterFunc fun(x3Data:X3Data.X3DataBase):boolean 数据的筛选方法，为空就是不筛选
function X3DataMgr.ForEach(x3DataType, iterationFunc, filterFunc)
    return X3DataCRUDHelper.ForEach(x3DataType, iterationFunc, filterFunc)
end
--endregion 数据遍历方法结束

--region 计数统计方法
---返回符合条件的数据的数量
---@param x3DataType string
---@param filterFunc fun(x3Data:X3Data.X3DataBase):boolean 数据的筛选方法，为空就是不筛选
---@return number
function X3DataMgr.Count(x3DataType, filterFunc)
    return X3DataCRUDHelper.Count(x3DataType, filterFunc)
end
--endregion 计数统计方法结束

--region 数据订阅方法
---订阅字段变更的回调，如果不订阅字段（可变参数为nil）就是订阅类型的回调
---@param x3DataType string X3Data的类型
---@param callback X3DataChangeDelegate
---@param target table 回调的发起者，nil表示回调是非对象方法
---@vararg table<number> 关注的变更字段数组，需要外界自己管理table的回收
---@return boolean
function X3DataMgr.Subscribe(x3DataType, callback, target, ...)
    return X3DataPublisher.Subscribe(x3DataType, callback, target, ...)
end

---订阅数据类型变更的回调
---@param x3DataType string X3Data的类型
---@param callback X3DataChangeDelegate
---@param target table 回调的发起者，nil表示回调是非对象方法
---@param flag X3DataConst.X3DataChangeFlag 关注的变更类型默认是ALL，如果 fieldNameArray非空 将不会生效
---@return boolean
function X3DataMgr.SubscribeWithChangeFlag(x3DataType, callback, target, flag)
    return X3DataPublisher.SubscribeWithChangeFlag(x3DataType, callback, target, flag)
end

---反订阅callback相关的回调
---@param callback X3DataChangeDelegate
---@return boolean
function X3DataMgr.Unsubscribe(callback)
    return X3DataPublisher.Unsubscribe(callback)
end

---反订阅target相关的回调
---@param target table
---@return boolean
function X3DataMgr.UnsubscribeWithTarget(target)
    return X3DataPublisher.UnsubscribeWithTarget(target)
end
--endregion 数据订阅方法结束

--region 持久化
---初始化本地化信息
---@param settings table
function X3DataMgr.InitPersistence(settings)
    --初始化Persistence的时候需要禁用数据回调
    X3DataPublisher.SetIsDisabled(true)
    X3DataPersistence.InitPersistence(settings)
    X3DataPublisher.SetIsDisabled(false)
end
--endregion

--region Private Field
---X3Data主键被修改的时候调用的方法，可以获取本次主键修改是否成功
---@private
---@param x3Data X3Data.X3DataBase
---@param primary string|number
---@return boolean
function X3DataMgr._AddPrimary(x3Data, primary)
    return X3DataSet:AddPrimary(x3Data, primary)
end

---@private
---回收当前帧被 Remove 的 X3Data
function X3DataMgr._ClearReleaseQueue()
    X3DataCRUDHelper.ClearReleaseQueue()
end

---@private
---@param value boolean 是否开启安全检查
function X3DataMgr._SetIsEnableSafetyCheck(value)
    X3DataSafety.SetIsEnableSafetyCheck(value)
end

---@private
---@return boolean 返回是否需要进行安全检查
function X3DataMgr._GetIsEnableSafetyCheck()
    return X3DataSafety.GetIsEnableSafetyCheck()
end

---@private
---@param fileName string 文件名称，默认是 时间+帧号
---@return string 文件名
function X3DataMgr._EncodeX3DataSet(fileName)
    return X3DataSerializer.EncodeX3DataSet(fileName)
end

---@private
---@return string
function X3DataMgr._GetX3DataSetEncodeStr()
    return X3DataSerializer.GetX3DataSetEncodeStr()
end

---@private
---@param fileName string 文件名称，默认是 时间+帧号
---@vararg string
---@return string 文件名
function X3DataMgr._EncodeX3DataSetWithTypeArray(fileName, ...)
    return X3DataSerializer.EncodeX3DataSetWithTypeArray(fileName, ...)
end

---@private
---@vararg string
---@return string
function X3DataMgr._GetX3DataSetEncodeStrWithTypeArray(...)
    return X3DataSerializer.GetX3DataSetEncodeStrWithTypeArray(...)
end

---@private
---@param fileName string 文件名称需保证能找的到
function X3DataMgr._DecodeIntoX3DataSet(fileName)
    X3DataSerializer.DecodeIntoX3DataSet(fileName)
end

---@private
function X3DataMgr._GetOnLateUpdateFunc()
    return OnLateUpdate
end

---@private
function X3DataMgr._GetOnPersistenceTickFunc()
    return OnPersistenceTick
end

---@private
function X3DataMgr._GetX3DataSet()
    return X3DataSet
end
--endregion Private Field 结束

--region Local 方法
OnLateUpdate = function()
    X3DataHistory.ClearOperateCache()
    X3DataPublisher.InvokeX3DataChangeCallback()
    X3DataMgr._ClearReleaseQueue()
end

OnPersistenceTick = function()
    X3DataPersistence.SaveX3DataPersistence()
end

---@return table x3DataSet
GetX3DataSetCloneFromPool = function()
    local pool = X3DataSetPool
    if pool == nil then
        pool = PoolUtil.Get(function()
            ---@type X3DataSet
            local x3DataSetClone = require(X3DataSetRequirePath).new()
            local result = PoolUtil.GetTable()
            x3DataSetClone:Clear(result)
            for _, x3Data in pairs(result) do
                X3DataMgr.Release(x3Data)
            end
            
            PoolUtil.ReleaseTable(result)
            x3DataSetClone.InjectX3DataPoolModule(X3DataPool)
            return x3DataSetClone
        end, function(x3DataSetClone)
            local result = PoolUtil.GetTable()
            x3DataSetClone:Clear(result)
            for _, x3Data in pairs(result) do
                X3DataMgr.Release(x3Data)
            end
            
            PoolUtil.ReleaseTable(result)
        end)
        X3DataSetPool = pool
    end

    return pool:Get()
end

---@param x3DataSetClone X3DataSet
ReleaseX3DataSetCloneToPool = function(x3DataSetClone)
    if x3DataSetClone == nil then
        return
    end

    ---@type Pool
    local pool = X3DataSetPool
    if not pool then
        return
    end

    pool:Release(x3DataSetClone)
end

Init = function ()
    -- X3DataExternalBridge Init
    X3DataExternalBridge.Init()
    
    -- X3DataPool Init
    X3DataPool.InjectX3DataSafetyModule(X3DataSafety)
    X3DataPool.InjectX3DataAssociationModule(X3DataAssociation)

    -- X3DataHistory Init
    X3DataHistory.InjectX3DataSafetyModule(X3DataSafety)

    -- X3DataPublisher Init
    X3DataPublisher.InjectX3DataSafetyModule(X3DataSafety)
    X3DataPublisher.InjectX3DataPoolModule(X3DataPool)
    
    -- X3DataSet Init
    if not X3DataSet then
        X3DataSet = GetX3DataSetCloneFromPool()
        X3DataSet.InjectX3DataPoolModule(X3DataPool)
    end
    
    -- X3DataCRUDHelper Init
    X3DataCRUDHelper.InjectX3DataSafetyModule(X3DataSafety)
    X3DataCRUDHelper.InjectX3DataPoolModule(X3DataPool)
    X3DataCRUDHelper.InjectX3DataSetModule(X3DataSet)
    X3DataCRUDHelper.InjectX3DataPublisherModule(X3DataPublisher)
    
    -- X3DataPersistence Init
    X3DataPersistence.InjectX3DataSetModule(X3DataSet)
    X3DataPersistence.InjectX3DataPoolModule(X3DataPool)
    X3DataPersistence.InjectX3DataPublisherModule(X3DataPublisher)

    -- X3DataSerializer Init
    X3DataSerializer.InjectX3DataSetModule(X3DataSet)
    X3DataSerializer.InjectX3DataPoolModule(X3DataPool)
    
    -- X3DataBase Init
    X3DataBase.InjectX3DataHistoryModule(X3DataHistory)
    X3DataBase.InjectX3DataSafetyModule(X3DataSafety)
    X3DataBase.InjectX3DataPublisherModule(X3DataPublisher)
    X3DataBase.InjectX3DataPoolModule(X3DataPool)
    X3DataBase.InjectX3DataAssociationModule(X3DataAssociation)
    X3DataBase.InjectX3DataExternalBridgeModule(X3DataExternalBridge)
    X3DataBase.InjectX3DataPersistenceModule(X3DataPersistence)
    
    TimerMgr.AddTimerByFrame(1, OnLateUpdate, X3DataMgr, true, TimerMgr.UpdateType.LATE_UPDATE)
    --本地数据持久化改为1s存储一次
    TimerMgr.AddTimer(1, OnPersistenceTick, X3DataMgr, true, TimerMgr.UpdateType.LATE_UPDATE)
    EventMgr.AddListener("Game_Quit", OnPersistenceTick, X3DataMgr)
    --默认设置成false
    Debug.SetLogEnableWithTag(GameConst.LogTag.X3DataSysDebug, GameConst.DebugPlatType.Lua, false)
    X3DataMgr.InitPersistence(CS.X3Game.X3GameSettings.Instance.X3DataSettings)
end
--endregion Local 方法结束

function X3DataMgr.Clear()
    TimerMgr.DiscardTimerByTarget(X3DataMgr)
    EventMgr.RemoveListenerByTarget(X3DataMgr)
    OnLateUpdate()
    OnPersistenceTick()
    
    X3DataSet = nil
    X3DataSetPool = nil
    X3DataExternalBridge.Clear()
    X3DataPool.Clear()
    X3DataHistory.Clear()
    X3DataPublisher.Clear()
    X3DataCRUDHelper.Clear()
    X3DataPersistence.Clear()
    X3DataSerializer.Clear()
    X3DataAssociation.Clear()
end

function X3DataMgr.Init()
    Init()
end

return X3DataMgr