﻿

---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/3/8 11:57
---

---@class EEEditorDebugger 散装方法集合 用于彩蛋编辑器工具提供支持
local EEEditorDebugger = class("EEEditorDebugger")

---@class EditorEasterEggData
---@field Id string 彩蛋Id
---@field Type string 类型 客户端或服务器彩蛋
---@field EffectStatus string 彩蛋生效状态
---@field ConditionStatus string 彩蛋Condition状态
---@field TriggerNum string 已触发次数/可触发次数
---@field EffectTime string 彩蛋生效时间
---@field EffectEndTime string 彩蛋生效结束时间
---@field ReEffectTime string 彩蛋再次生效时间
---@field AllMsg string 彩蛋全量数据

---@class EditorEasterEggConditionCheckResult
---@field Id string 彩蛋Id
---@field ConditionStatus string 彩蛋Condition状态

---@class EditorEasterEggServerConditionCheckResult
---@field Id string 彩蛋Id
---@field ConditionStatus string 彩蛋Condition状态

---@class EditorEasterEggDebuggerData
---@field EasterEggDataList table<number, EditorEasterEggData> 彩蛋数据列表
---@field CurrentTime string 当前时间
---@field FocusIdList table<number, string> 正在监听的彩蛋Id列表
---@field ConditionResultList table<string, string> 需要每秒检查的Condition结果列表

---@type EditorEasterEggDebuggerData
local debuggerData = {}

local CS_Mgr = CS.PapeGames.X3Editor.EasterEggEditor.EasterEggDebuggerMgr.Instance

-- 获取全量数据
function EEEditorDebugger:CreateSnapshot()
    if EEDebugMgr then
        table.clear(debuggerData)
        
        -- 获取全量彩蛋数据
        debuggerData.EasterEggDataList = self:GetAllEasterEggEditorData()
        
        -- 当前时间
        local curTimeStamp = TimerMgr.GetCurTimeSeconds()
        debuggerData.CurrentTime = string.format("当前时间: [%s | %s]", tostring(curTimeStamp), os.date("%Y.%m.%d-%H:%M:%S", curTimeStamp))
        
        -- 获取正在监听的彩蛋列表
        debuggerData.FocusIdList = self:GetFocusIdList()
        
        -- 获取所有Condition检查结果
        debuggerData.ConditionResultList = self:ConditionCheckOnUpdate()
        
        -- 获取服务器Condition检查结果
        debuggerData.ServerConditionResultList = EEDebugMgr.ServerConditionCheckResultList or {}
        
        CS_Mgr:CreateSnapshot(debuggerData)
    end
end

-- 获取全量数据
function EEEditorDebugger:GetAllEasterEggEditorData()
    local allData = {}
    
    -- 获取所有彩蛋静态配置
    local allEasterEggCfg = LuaCfgMgr.GetAll("EasterEgg")
    
    for _, cfg in pairs(allEasterEggCfg) do
        local easterEggId = cfg.ID
        local isClientType = BllMgr.GetEasterEggBLL():CheckIfClientType(easterEggId)
        local isInEffect = BllMgr.GetEasterEggBLL():CheckIfInEffect(easterEggId)
        local inEffectStr = isInEffect and "True" or "False"
        local eeData = BllMgr.GetEasterEggBLL():GetEasterEggData(easterEggId)
        local eeCfg = LuaCfgMgr.Get("EasterEgg", easterEggId)
        
        -- triggerNum
        local triggerNum = ""
        if eeData and eeData.TriggerNum then
            triggerNum = string.format("%d/%s", eeData.TriggerNum, eeCfg.TriggerCount == -1 and "无限制" or eeCfg.TriggerCount)
        end
        
        -- effectTime
        local effectTime = 0
        if eeData and eeData.EffectTime then
            effectTime = eeData.EffectTime > 0 and string.format("%s | %s", eeData.EffectTime, os.date("%Y.%m.%d-%H:%M:%S", eeData.EffectTime)) or eeData.EffectTime
        end
        
        -- reEffectTime
        local reEffectTime = 0
        if eeData and eeData.ReEffectTime then
            reEffectTime = eeData.ReEffectTime > 0 and string.format("%s | %s", eeData.ReEffectTime, os.date("%Y.%m.%d-%H:%M:%S", eeData.ReEffectTime)) or eeData.ReEffectTime
        end
        
        -- effectEndTime
        local effectEndTime = 0
        if eeData and eeData.ID and eeCfg and eeData.EffectTime > 0 and eeCfg.TimeType ~= 0 then
            effectEndTime = TimeRefreshUtil.GetNextRefreshTime(eeData.EffectTime, eeCfg.TimeType, eeCfg.TimePara)
            effectEndTime = effectEndTime > 0 and string.format("%s | %s", effectEndTime, os.date("%Y.%m.%d-%H:%M:%S", effectEndTime)) or effectEndTime
        end
        
        -- insert data
        table.insert(allData, {
            Id = tostring(easterEggId),
            Type = isClientType and "Condition彩蛋" or "Counter彩蛋",
            EffectStatus = inEffectStr,
            ConditionStatus = isClientType and "..." or "nil",
            TriggerNum = triggerNum,
            EffectTime = tostring(effectTime),
            EffectEndTime = tostring(effectEndTime),
            ReEffectTime = tostring(reEffectTime),
            AllMsg = " -- ",
        })
    end
    
    -- 以Id排序
    table.sort(allData, function(a, b)
        return a.Id < b.Id
    end)
    
    return allData
end

-- 获取正在监听的彩蛋列表
function EEEditorDebugger:GetFocusIdList()
    local idMap = EEDebugMgr:GetFocusMap() or {}
    local idList = {}
    for id, flag in pairs(idMap) do
        if flag then
            table.insert(idList, tostring(id))
        end
    end
    return idList
end

-- 获取指定彩蛋 指定行为的历史记录
local function __getTargetEasterEggHistory(easterEggId, eventName)
    local historyDataList = EEDebugMgr:GetHistoryById(easterEggId)
    if table.isnilorempty(historyDataList) then return {} end
    
    local targetEventList = {}
    for _, v in pairs(historyDataList) do
        if v.eventName == eventName then table.insert(targetEventList, v) end
    end
    
    return targetEventList
end

--Description
--1. 用户发起彩蛋调试请求。
--2. 系统开始检查当前彩蛋是否已经生效。
--        - 如果彩蛋已经生效，系统会通知用户"彩蛋已经生效"，流程结束。
--3. 如果彩蛋未生效，系统会检查当前彩蛋的触发条件是否已经满足。
--        - 如果触发条件未满足，系统会通知用户"触发条件未满足或客户端逻辑问题"，流程结束。
--4. 如果触发条件满足，系统会查看彩蛋的历史记录，检查是否有"尝试生效"的记录。
--5. 系统会查看彩蛋的历史记录，检查是否有"生效返回"的记录。
--        - 如果没有"尝试生效"的历史记录，系统会通知用户"触发条件未覆盖或服务器端逻辑问题"。
--        - 如果有"尝试生效"的历史记录，但没有"生效返回"的记录，系统会通知用户"服务器端触发条件逻辑问题"。
--        - 如果既有"尝试生效"的历史记录，又有"生效返回"的记录，系统会通知用户"异常结果，需要进一步调查"。


---@public 一键检查彩蛋未生效原因
---@param easterEggId
function EEEditorDebugger:CheckDebugEasterEgg(easterEggId)
    easterEggId = tonumber(easterEggId)
    local function __internalLog(logContent)
        Debug.LogError(string.format("[彩蛋一键Debug] [彩蛋Id: %s] [当前时间: %s] %s", easterEggId, TimerMgr.GetCurTimeSeconds(), logContent))
    end

    __internalLog("发起检查 --------------------- ")

    -- 检查确保当前彩蛋是失效状态
    local isInEffect = BllMgr.GetEasterEggBLL():CheckIfInEffect(easterEggId)
    __internalLog("检查当前彩蛋生效状态: " .. tostring(isInEffect))

    -- 如果是生效状态抛出错误原因       当前彩蛋已经是生效状态了
    if isInEffect then
        CS_Mgr:ShowCheckResult("失败！！", string.format("检查结果: 检查失败 彩蛋当前已经是生效状态\n\n\n(详细可见控制台日志)"))
        return
    end

    -- 检查当前Condition是否通过
    local isConditionPass = BllMgr.GetEasterEggBLL():CheckIfEasterEggConditionPass(easterEggId)
    __internalLog("检查当前Condition状态: " .. tostring(isConditionPass))

    -- 如果当前Condition没通过(客户端逻辑) 则表示可能  1.测试者没有完成预期的Condition. 或 2. 客户端Condition逻辑实现有问题.
    if not isConditionPass then
        CS_Mgr:ShowCheckResult("成功！！", string.format("检查结果: 请向 [%s] 寻求帮助\n\n\n\n可能发生的原因/需要排查的问题是 \n[%s]\n\n\n(详细可见控制台日志)"
        , "Condition开发(客户端)"
        , " 1.测试者没有完成预期的Condition. \n或\n 2. 客户端Condition的逻辑实现."
        ))
        return
    end

    -- 查找彩蛋行为历史记录 "尝试生效"
    local tryEffectRequestHistory = __getTargetEasterEggHistory(easterEggId, EasterEggEnum.DebugEventMap.EasterEggTryEffect)
    __internalLog("查找彩蛋行为历史记录 [尝试生效]: " .. table.dump(tryEffectRequestHistory))
    
    -- 查找彩蛋行为历史记录 "生效返回"
    local effectReplyHistory = __getTargetEasterEggHistory(easterEggId, EasterEggEnum.DebugEventMap.EasterEggEffect)
    __internalLog("查找彩蛋行为历史记录 [生效返回]: " .. table.dump(effectReplyHistory))

    -- 如果没有 "尝试生效" 的历史记录, 可能的走向是客户端Condition没有埋点
    if #tryEffectRequestHistory == 0 then
        -- 此时尝试客户端 主动生效 查看服务器返回是否正常
        EEDebugMgr:CheckEffectById(easterEggId)
        __internalLog("彩蛋客户端尝试主动生效, 请等待... ... ")

        TimerMgr.AddTimer(2, function()
            local _isInEffect = BllMgr.GetEasterEggBLL():CheckIfInEffect(easterEggId)
            __internalLog("检查当前彩蛋生效状态: " .. tostring(_isInEffect))

            -- 查找彩蛋行为历史记录 "尝试生效"
            local newTryEffectRequestHistory = __getTargetEasterEggHistory(easterEggId, EasterEggEnum.DebugEventMap.EasterEggTryEffect)
            __internalLog("查找彩蛋行为历史记录 [尝试生效]: " .. table.dump(newTryEffectRequestHistory))

            -- 如果TryEffect记录多了一条 说明应该没有埋点
            if #newTryEffectRequestHistory == #tryEffectRequestHistory + 1 then
                if _isInEffect then
                    CS_Mgr:ShowCheckResult("成功！！", string.format("检查结果: 请向 [%s] 寻求帮助\n\n\n\n可能发生的原因/需要排查的问题是 \n[%s]\n\n\n(详细可见控制台日志)"
                    , "Condition开发(客户端)"
                    , "Condition埋点没有覆盖到(客户端)"
                    ))
                    return
                else
                    -- 这里触发TryEffect了仍然没有生效 可能是服务器逻辑也有问题 - 
                    CS_Mgr:ShowCheckResult("成功！！", string.format("检查结果: 请向 [%s] 寻求帮助\n\n\n\n可能发生的原因/需要排查的问题是 \n[%s]\n\n\n(详细可见控制台日志)"
                    , "Condition开发(客户端) & Condition开发(服务器)"
                    , "Condition埋点没有覆盖到(客户端) & Condition逻辑(服务器)"
                    ))
                    return
                end
            else
                -- Condition完成了 尝试触发没有出现 应该是被框架层逻辑拦下来了 大多是受制于彩蛋的生命周期限制
                -- 这里可能受彩蛋生命周期影响 如果出现 找彩蛋框架开发(客户端)排查下
                CS_Mgr:ShowCheckResult("检查失败", string.format("检查结果: 可能受彩蛋配置生命周期影响 Condition完成后未正常生效. \n如果确认测试流程无误, 请向 [%s] 寻求帮助\n\n\n\n可能发生的原因/需要排查的问题是 \n[%s]\n\n\n(详细可见控制台日志)"
                , "彩蛋框架开发 (客户端)"
                , "测试者环境有误或彩蛋自身生命周期受限导致的未正常生效"
                ))
                return
            end
        end)
    else
        -- 如果有尝试生效 但没有生效逻辑 应该是客户端Condition逻辑通过后 服务器逻辑没通过 
        if #effectReplyHistory == 0 then
            CS_Mgr:ShowCheckResult("成功！！", string.format("检查结果: 请向 [%s] 寻求帮助\n\n\n\n可能发生的原因/需要排查的问题是 \n[%s]\n\n\n(详细可见控制台日志)"
            , "Condition开发(服务器)"
            , "Condition逻辑(服务器)"
            ))
            return
        else
            CS_Mgr:ShowCheckResult("检查失败！！", string.format("检查结果: 走向了异常的结果, 请向 [%s] 寻求帮助\n\n\n\n可能发生的原因/需要排查的问题是 \n[%s]\n\n\n(详细可见控制台日志)"
            , "彩蛋框架开发 (客户端)"
            , "待排查"
            ))
            return
        end
    end
end

-- 对彩蛋每秒检查其Condition逻辑
---@param easterEggId string 彩蛋Id
function EEEditorDebugger:AddConditionCheckOnUpdate(easterEggId)
    EEDebugMgr.ConditionCheckOnUpdateIdMap = EEDebugMgr.ConditionCheckOnUpdateIdMap or {}
    EEDebugMgr.ConditionCheckOnUpdateIdMap[easterEggId] = true
end

-- 解除彩蛋每秒检查的Condition逻辑
---@param easterEggId string 彩蛋Id
function EEEditorDebugger:RemoveConditionCheckOnUpdate(easterEggId)
    EEDebugMgr.ConditionCheckOnUpdateIdMap = EEDebugMgr.ConditionCheckOnUpdateIdMap or {}
    EEDebugMgr.ConditionCheckOnUpdateIdMap[easterEggId] = false
end

-- 发起对已设置的彩蛋的每秒检查逻辑
---@return table<number, EditorEasterEggConditionCheckResult> 彩蛋Condition检查结果
function EEEditorDebugger:ConditionCheckOnUpdate()
    if not EEDebugMgr or not EEDebugMgr.ConditionCheckOnUpdateIdMap then return {} end
    
    EEDebugMgr.ConditionCheckResultList = {}
    for id, flag in pairs(EEDebugMgr.ConditionCheckOnUpdateIdMap) do
        if flag then
            local checkResult = BllMgr.GetEasterEggBLL():CheckIfEasterEggConditionPass(tonumber(id))
            table.insert(EEDebugMgr.ConditionCheckResultList, {Id = tostring(id), Result = tostring(checkResult)})
        end
    end
    
    return EEDebugMgr.ConditionCheckResultList
end

-- call GM func
function EEEditorDebugger:CallGMFunc(gmCommand)
    if string.isnilorempty(gmCommand) then Debug.LogError("handle gm func failed") return end
    
    BllMgr.GetGMCommandBLL():SendCommand(gmCommand)
end

-- call GM func check condition status by server 
function EEEditorDebugger:CheckServerConditionStatus(easterEggId)
    local eeCfg = LuaCfgMgr.Get("EasterEgg", tonumber(easterEggId))
    local conditionId = eeCfg.ConditionType
    local messageBody = {}
    messageBody.Params = {
        "condition",
        "params",
        tostring(conditionId),
        eeCfg.Param1 and tostring(eeCfg.Param1),
        eeCfg.Param2 and tostring(eeCfg.Param2),
        eeCfg.Param3 and tostring(eeCfg.Param3),
        eeCfg.Param4 and tostring(eeCfg.Param4),
        eeCfg.Param5 and tostring(eeCfg.Param5),
    }
    
    EEDebugMgr.lastServerConditionCheckEasterEggId = tostring(easterEggId)
    
    GrpcMgr.SendRequest(RpcDefines.GmSendRequest, messageBody, true)
end

return EEEditorDebugger