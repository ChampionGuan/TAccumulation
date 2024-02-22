﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2021/11/1 10:30
---
---@type UnityEngine.Profiling.Profiler
local s_profiler
local s_isEnable
local lua_profiler = nil
local report_file_path = nil
---@class Profiler
local Profiler = {}

---Debug版本下会在Xlua全局添加两个无GC版本的函数UnityBeginSample、UnityEndSample。作者：阿乐
local _UnityBeginSample = UnityBeginSample
local _UnityEndSample = UnityEndSample

local _UnityBeginCoroutineSample = UnityBeginCoroutineSample
local _UnityEndCoroutineSample = UnityEndCoroutineSample

local s_isDebug = false
local profiler_queue = {}

---开始sample
---@param name string
function Profiler.BeginSample(name)
    if Profiler.IsEnabled() then
        if string.isnilorempty(name) then
            Debug.LogError("Profiler.BeginSample name is nil")
            return
        end
        if s_isDebug then
            table.insert(profiler_queue, 1, name)
        end
        _UnityBeginSample(name)
    end
end

---结束sample
---@param name string
function Profiler.EndSample(name)
    if Profiler.IsEnabled() then
        if s_isDebug then
            local isExistName = false
            for i, v in ipairs(profiler_queue) do
                if v == name then
                    isExistName = true
                    table.remove(profiler_queue , i)
                    break
                end
            end
            if not isExistName then
                Debug.LogError("LuaProfiler BeginFrame and EndFrame not Match : EndFrame Is More")
            end
        end
        _UnityEndSample()
    end
end

---@param name string
function Profiler.BeginCoroutineSample(name)
    if Profiler.IsEnabled() then
        if string.isnilorempty(name) then
            Debug.LogError("Profiler.BeginSample name is nil")
            return
        end
        _UnityBeginCoroutineSample(name)
    end
end

---结束sample
function Profiler.EndCoroutineSample()
    if Profiler.IsEnabled() then
        _UnityEndCoroutineSample()
    end
end

---获取 mono总内存byte
---@return number
function Profiler.GetMonoHeapSize()
    if Profiler.IsEnabled() then
        return s_profiler.GetMonoHeapSizeLong~=nil and s_profiler.GetMonoHeapSizeLong() or 0
    end
end

---獲取当前使用的总内存byte
---@return number
function Profiler.GetMonoUsedSize()
    if Profiler.IsEnabled() then
        return s_profiler.GetMonoUsedSizeLong~=nil and s_profiler.GetMonoUsedSizeLong()
    end
end

---设置引擎profiler
---@param engineProfiler
function Profiler.SetEngineProfiler(engineProfiler)
    s_profiler = engineProfiler
    if s_profiler then
        _UnityBeginSample = UnityBeginSample or s_profiler.BeginSample
        _UnityEndSample = UnityEndSample or s_profiler.EndSample
    end
end

---设置开关
---@param isEnable boolean
function Profiler.SetEnable(isEnable)
    s_isEnable = isEnable
end

---是否开启
---@return boolean
function Profiler.IsEnabled()
    return s_isEnable and s_profiler ~= nil
end

function Profiler.SetDebugEnable(enabled)
    if s_isDebug == enabled then
        return
    end
    s_isDebug = enabled
    if s_isDebug then
        GameMgr.AddUpdateMap(Profiler.Tick)
    else
        GameMgr.RemoveUpdateMap(Profiler.Tick)
    end
end

--region LuaProfiler 相关
---设置luaProfiler 性能分析
---@param luaProfiler table : XLua/Resources/perf/profiler
---@param reportFilePath string 报告存放位置
function Profiler.SetLuaProfiler(luaProfiler,reportFilePath)
    lua_profiler = luaProfiler
    report_file_path = reportFilePath
end

---开始统计
function Profiler.Start()
    if lua_profiler then
        lua_profiler.start()
    end
end

---暂停统计
function Profiler.Pause()
    if lua_profiler then
        lua_profiler.pause()
    end
end

---继续统计
function Profiler.Resume()
    if lua_profiler then
        lua_profiler.pause()
    end
end

---停止统计
function Profiler.Stop()
    if lua_profiler then
        lua_profiler.stop()
    end
end

---获取统计结果
---@class _report
---@field name string 方法名称
---@field total_time number 总时间
---@field average number 平均时间
---@field count number 调用次数
---@field report string 函数调用报告详细信息

---@class _filter_condition
---@field average number 平均耗时
---@field count number 执行次数
---@field total_time number 总时间
---@field name string 方法名称

---@param filer_condition _filter_condition
---@param sort_type string | function 排序方式(TOTAL,AVERAGE,CALLED),根据总耗时，平均耗时，调用次数，或者自定义排序方式,默认TOTAL
---@param is_save_file boolean 是否保存本地文件,默认保存,保存路径：CS.UnityEngine.Application.persistentDataPath+/luaProfilerReport.txt
---@return string,_report[] 返回report字符串信息和report列表数据,表头数据
function Profiler.GetReport(sort_type,is_save_file,filer_condition)
    if lua_profiler and lua_profiler.is_running() then
        if is_save_file~=nil then
            is_save_file = true
        end
        local report_des,report_list = lua_profiler.report(sort_type or "")
        local function check_ok(report)
            local ok = false
            for m,n in pairs(filer_condition) do
                if m == "name" then
                    ok = string.isnilorempty(n) or string.isnilorempty(report[m]) or  string.find(report[m],n,1,true)~=nil
                else
                    ok = report[m]~=nil and report[m]>=n
                end
                if not ok then
                    break
                end
            end
            return ok
        end
        
        if not table.isnilorempty(filer_condition) then
            local res = {Profiler.GetReportTitle()}
            local res_report_list = {}
            for k,v in ipairs(report_list) do
                if check_ok(v) then
                    table.insert(res,v.output)
                    table.insert(res_report_list,v)
                end
            end
            report_des = table.concat(res)
            report_list = res_report_list
        end
        if is_save_file  then
            Profiler.SaveReportToFile(report_des)
        end
        return report_des,report_list
    else
        Debug.LogWarning("profiler 未开启，或者已经被停掉")
    end
end


---获取报告列表
---@return _report[]
function Profiler.GetReportList()
    local report_des,report_list = Profiler.GetReport()
    return report_list
end

---获取报告标题
---@return string
function Profiler.GetReportTitle()
    if lua_profiler then
        return lua_profiler.get_title()
    end
end

---保存报告到文件
---@param report string
---@param file_path string
function Profiler.SaveReportToFile(report,file_path)
    file_path = file_path or report_file_path
    if  not string.isnilorempty(report) then
        return io.writefile(file_path,report)
    end
    return false
end

---Tick函数
function Profiler.Tick()
    if s_isDebug and #profiler_queue > 0 then
        for _, value in ipairs(profiler_queue) do
            Debug.LogErrorFormat("LuaProfiler BeginFrame and EndFrame not Match: %s", value)
        end
        table.clear(profiler_queue)
    end
end

--endregion

return Profiler
