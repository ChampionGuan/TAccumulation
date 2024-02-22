﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2022/8/16 20:01
---@class DebugLogBLL
local DebugLogBLL = class("DebugLogBLL", BaseBll)

function DebugLogBLL:OnInit()
    self.logMap = PoolUtil.GetTable()
    self.csTagList = PoolUtil.GetTable()
    self.page = 102
    Debug.SetGetInt(PlayerPrefs.GetInt)
    Debug.SetFuncInt(PlayerPrefs.SetInt)
    ---按本地存储状态设置Default类型日志开关
    Debug.SetLogEnableWithTag(GameConst.LogTag.Default, GameConst.DebugPlatType.Lua, true)
    Debug.SetLogEnableWithTag(GameConst.LogTag.Default, GameConst.DebugPlatType.CS, true)
end

function DebugLogBLL:SetLogEnable(is_enable)
    Debug.SetLogEnable(is_enable)
    if EventMgr then
        EventMgr.Dispatch("Debug_Level_Change_Event")
    end
end

function DebugLogBLL:SetOpenLogLevel(level)
    Debug.SetLogLevel(level)
    EventMgr.Dispatch("Debug_Level_Change_Event")
end

---统一设置日志tag开关状态
---@param value bool 开启状态
function DebugLogBLL:SetLogTagEnable(value)
    for i, v in pairs(GameConst.LogTag) do
        if v ~= GameConst.LogTag.Default then
            Debug.SetLogEnableWithTag(v, GameConst.DebugPlatType.Lua, value)
        end
    end
    for i, v in pairs(self:GetCSTagList()) do
        if v ~= "Default" then
            Debug.SetLogEnableWithTag(v, GameConst.DebugPlatType.CS, value)
        end
    end
    EventMgr.Dispatch("Debug_Level_Change_Event")
end

function DebugLogBLL:GetPage()
    return self.page
end

function DebugLogBLL:GetDebugLogList()
    if not next(self.logMap) then
        local levelData = self:GetLogLevelData()
        for i, v in pairs(levelData) do
            table.insert(self.logMap, v)
        end
        PoolUtil.ReleaseTable(levelData)
        local titleData = self:GetTitleData()
        for i, v in pairs(titleData) do
            table.insert(self.logMap, v)
        end
        PoolUtil.ReleaseTable(titleData)
        for _, info in pairs(GameConst.LogTag) do
            if info ~= GameConst.LogTag.Default then
                table.insert(self.logMap, self:GenLogData(info, GameConst.DebugPlatType.Lua))
            end
        end
        local tagNames = Debug.GetEngineTagName()
        if tagNames then
            tagNames = GameHelper.ToTable(tagNames)
            self.csTagList = tagNames
            for _, info in pairs(tagNames) do
                if info ~= "Default" then
                    table.insert(self.logMap, self:GenLogData(info, GameConst.DebugPlatType.CS))
                end
            end
        end
        table.sort(self.logMap, function(a, b)
            if a.Flag == b.Flag then
                return a.preChar < b.preChar
            end
            return a.Flag < b.Flag
        end)
    end
    return self.logMap
end

function DebugLogBLL:GetCSTagList()
    return self.csTagList
end

---@param tag GameConst.LogTag
---@param flag GameConst.DebugPlatType
function DebugLogBLL:GenLogData(tag, flag)
    if not tag then
        tag = GameConst.LogTag.Default
    end
    local data = {
        Description = string.format("%s(%s)", tag, flag),
        Type = 1, --勾选项指令
        SendType = 2, --客户端指令
        Command = string.format(Debug.SaveFormat, Debug.LOGPREFIX, tag, flag),
        Page = self.page,
        preChar = string.byte(tag, 1, 1),
        Flag = flag == GameConst.DebugPlatType.Lua and 6 or 7,
        Color = "#8093ef"
    }
    return data
end

function DebugLogBLL:GetTitleData()
    local titleData = {
        [1] = {
            Name = "标记开关设置",
            Command = "set_log_tag_enable",
            Flag = 5,
        }
    }
    local titleList = PoolUtil.GetTable()
    for i, v in pairs(titleData) do
        local data = {
            Description = v.Name,
            Type = 1,
            SendType = 2,
            Command = v.Command,
            Page = self.page,
            preChar = 0,
            Flag = v.Flag,
        }
        table.insert(titleList, data)
    end
    return titleList
end

function DebugLogBLL:GetLogLevelData()
    local levelData = {
        [1] = {
            Name = "普通日志",
            Tag = Debug.DebugLevel.Log,
        },
        [2] = {
            Name = "警告日志",
            Tag = Debug.DebugLevel.Warn,
        },
        [3] = {
            Name = "错误日志",
            Tag = Debug.DebugLevel.Error,
        },
        [4] = {
            Name = "致命日志",
            Tag = Debug.DebugLevel.Fatal,
        },
    }
    local logLevel = PoolUtil.GetTable()
    for i, v in ipairs(levelData) do
        local data = {
            Description = v.Name,
            Type = 1,
            SendType = 2,
            Command = string.format(Debug.LevelFormat, v.Tag),
            Page = self.page,
            preChar = 0,
            Flag = i,
            Color = "#98c988",
        }
        table.insert(logLevel, data)
    end
    return logLevel
end

function DebugLogBLL:OnClear()
    PoolUtil.ReleaseTable(self.logMap)
    PoolUtil.ReleaseTable(self.csTagList)
    self.logMap = nil
    self.csTagList = nil
end

return DebugLogBLL