﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiangyu.
--- DateTime: 2023/8/28 15:39
---

LoadLuaCheck = {}
---@type table<string,table> key:文件名 value：{文件名, 加载消耗内存, 加载方式}
local recordMemoryMap = nil

function LoadLuaCheck.Init()
    recordMemoryMap = nil
end

---记录到一个map中
---@param fileName string
---@param memory number
---@param fileType string
local function _recordToMap(fileName, memory, fileType)
    if recordMemoryMap == nil then
        recordMemoryMap = {}
    end
    local num = memory / 1024
    table.insert(recordMemoryMap, #recordMemoryMap + 1, {Cfg = fileName, Memory = Mathf.Abs(num), FileType = fileType})
end


--region 检查lua配置文件

---检查单个lua配置文件
---@param fileName string
---@param loadName string
---@param unloadName string
local function _checkSingleCfgFile(fileName, loadName, unloadName)
    if unloadName then
        LuaCfgMgr.UnLoad(fileName, unloadName)
    else
        LuaCfgMgr.UnLoad(fileName)
    end
    collectgarbage("collect")
    local cnt = collectgarbage("count")
    if loadName then
        LuaCfgMgr.Get(fileName, loadName)
    else
        LuaCfgMgr.GetAll(fileName)
    end
    collectgarbage("collect")
    local memory = collectgarbage("count") - cnt
    local strName = fileName
    if loadName and fileName == "Dialogue" then
        strName = string.format("%s_%s", fileName, loadName)
    end
    _recordToMap(strName, memory, "Cfg")
end

---检查文件夹下的所有lua配置文件
---@param fileName string
---@param folderName string
function LoadLuaCheck.CheckCfg(fileName, folderName)
    if folderName == nil then
        _checkSingleCfgFile(fileName)
        return
    end

    if folderName == "DialogueCfg" then
        local name = string.concat("DialogueCfg.", fileName)
        _checkSingleCfgFile(name, 1)
        return
    end

    if folderName == "Dialogue" then
        local arr = string.split(fileName, "_")
        _checkSingleCfgFile("Dialogue",  arr[2])
    end
end

--endregion


--region 检查require一个lua所耗费的内存大小
function LoadLuaCheck.CheckRequireLua(requirePath, fileName)
    if package.loaded[requirePath] then
        package.loaded[requirePath] = nil
    end
    collectgarbage("collect")
    local cnt = collectgarbage("count")
    require(requirePath)
    collectgarbage("collect")
    local memory = collectgarbage("count") - cnt
    _recordToMap(fileName, memory, "AI")
end
--endregion

---输出文件到csv
---@param outputName string
local function _printLuaToCSV(outputName)
    -- CSV文件路径
    local filepath = outputName

    -- 打开文件以写入数据
    local file = io.open(filepath, "w")

    if recordMemoryMap ~= nil then
        table.sort(recordMemoryMap,function(a,b)
            return a.Memory > b.Memory
        end)
        file:write("CfgName" .. "," .. "Memory(MB)" .. "," .. "FileType" .. "\n")
        file:flush()
        -- 写入数据到文件中
        for _, row in ipairs(recordMemoryMap) do
            if row then
                local num = row.Memory < 0.001 and tostring(row.Memory) or string.format("%.3f", row.Memory)
                file:write(row.Cfg .. "," .. num .. "," .. row.FileType .. "\n")
                file:flush()
            end
        end
    end

    -- 关闭文件
    file:close()
end

---输出文件到csv
---@param fileName string
function LoadLuaCheck.ToPrint(fileName)
    _printLuaToCSV(fileName)
end

return LoadLuaCheck