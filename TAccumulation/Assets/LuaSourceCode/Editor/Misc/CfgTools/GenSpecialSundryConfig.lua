--- Editor.Misc.CfgTools.GenSundryConfig
--- Created by 教主
--- DateTime:2021/6/16 10:39
--- 本类主要处理业务向的SundryConfig配置表相关(纵向-->横向表)
---@class GenSpecialSundryConfig:BaseCfgHandler
local GenSpecialSundryConfig = class("GenSpecialSundryConfig", BaseCfgHandler)
local LocalStr = "_Local"
local LocalSoundStr = "_Sound"
local LocalRegionStr = "_Region"
local Postfix = "Data"
local EXAMINE_INCLUDE_KEY = "ExamineInclude"
local VALUE_KEY = "Value"
local CfgAutoMergeConfigName = "CfgAutoMergeConfig"

function GenSpecialSundryConfig:Execute()
    local jsonPath = string.concat(LUA_BINARY_PATH, "/Tools/settings.json")
    if not io.exists(jsonPath) then
        error(string.format("json not exist!!! [%s]", jsonPath))
        return
    end
    local jsonStr = io.readfile(jsonPath)
    local jsonTable = JsonUtil.Decode(jsonStr)
    ---@class _sundry_config
    ---@field sheet_name string
    ---@field is_need_process boolean
    ---@field is_need_process boolean
    ---@type _sundry_config[]
    local sundry_configList = jsonTable.sundry_config
    if not sundry_configList then
        return
    end
    
    local luaCfgMergePath = string.concat(LUA_CFG_PATH,CfgAutoMergeConfigName,".lua")
    local res = {
        SundryConfig=
        {
            string.concat("SundryConfig",LocalStr),
            string.concat("SundryConfig",LocalSoundStr),
            string.concat("SundryConfig",LocalRegionStr)
        }
    }
    
    for _, v in pairs(sundry_configList) do
        if v.is_need_process then
            ---@type _sundryData[]
            local success = false
            if v.is_locale then
                success = self:GenSundryConfigByLocale(v.sheet_name)
            else
                success = self:GenSundryConfig(v.sheet_name)
            end
            if success then
                if not res[v.sheet_name] then
                    res[v.sheet_name] = {}
                end
                table.insert(res[v.sheet_name],string.concat(v.sheet_name,LocalStr))
                table.insert(res[v.sheet_name],string.concat(v.sheet_name,LocalSoundStr))
                table.insert(res[v.sheet_name],string.concat(v.sheet_name,LocalRegionStr))
            end
        end
    end
    
    self:WriteTableToFile(luaCfgMergePath,res,CfgAutoMergeConfigName)

end

---@param cfgName string
---@return boolean
function GenSpecialSundryConfig:GenSundryConfigByLocale(cfgName)
    local success = false
    local allSundryConfList = {}
    for _, language in pairs(LanguageTag) do
        local dstCfgName = string.concat(cfgName, Postfix)
        local src_file_path = GetCfgPathByLanguage(cfgName, language)
        local dst_file_path = GetCfgPathByLanguage(dstCfgName, language)
        if io.exists(src_file_path) then
            ---@type _sundryData[]
            self:GenSundryConfData(cfgName, allSundryConfList, language, function(name, key1, key2)
                local data = LuaCfgMgr.GetByLanguage(name, key1, language)
                if key2 ~= nil then
                    return data[key2]
                end
                return data
            end)
            self:Delete(src_file_path)
            self:Delete(dst_file_path)
        end
    end
    success = #allSundryConfList>0
    if success then
        self:OutSundryConf(cfgName, allSundryConfList)
    end
    return success
end

---@param cfgName string
function GenSpecialSundryConfig:GenSundryConfig(cfgName)
    local success = false
    local src_file_path = string.concat(LUA_CFG_PATH, cfgName, ".lua")
    if not io.exists(src_file_path) then
        print(string.format("sundryConf[%s] file not exist!!!",src_file_path))
        return
    end
    ---@type _sundryData[]
    local allSundryConfList = {}
    local dstName = string.concat(cfgName, Postfix)
    local dst_file_path = string.concat(LUA_CFG_PATH, dstName, ".lua")
    LuaCfgMgr.ResetDirPath()
    self:GenSundryConfData(cfgName, allSundryConfList, LanguageTag.ZH_CN, LuaCfgMgr.Get)
    self:Delete(src_file_path)
    self:Delete(dst_file_path)
    self:OutSundryConf(cfgName, allSundryConfList)
    success = #allSundryConfList>0
    return success
end

---@param cfgName string
---@param allSundryConfList _sundryData[]
---@param language LanguageTag
---@param getCfgCall fun(name:string,key1:int|string,key2:int|string):table
function GenSpecialSundryConfig:GenSundryConfData(cfgName, allSundryConfList, language, getCfgCall)
    local srcName = cfgName
    local dstName = string.concat(cfgName, Postfix)
    local dstCfgData = getCfgCall(dstName, 1)
    for k, v in pairs(dstCfgData) do
        if string.find(k, "_", 1, true) then
            local temp = string.split(k, "_")
            local key1, key2 = table.unpack(temp, 2)

            local id = tonumber(key1)
            if id ~= nil then
                key1 = id
            end
            id = tonumber(key2)
            if id ~= nil then
                key2 = id
            end
            local data = getCfgCall(srcName, key1, key2)
            table.insert(allSundryConfList, self:GenData(table.clone(v, true), key1, key2, data.LocaleType, language, data.ExamineInclude))
        end
    end
end

---@param cfgName string
---@param allSundryConfList _sundryData[]
function GenSpecialSundryConfig:OutSundryConf(cfgName, allSundryConfList)
    local function Sort(a, b)
        if b.key2 == nil or a.key2 == nil or a.key1 ~= b.key1 then
            return a.key1 < b.key1
        end
        return a.key2 < b.key2
    end

    local map = {}
    for _, v in ipairs(allSundryConfList) do
        if not map[v.localeType] then
            map[v.localeType] = {}
        end
        table.insert(map[v.localeType], v)
    end

    for k, v in pairs(map) do
        local list = v
        if #list >= 2 then
            table.sort(list, Sort)
        end
        if #list > 0 then
            if k == LuaLocalType.Base then
                self:GenBase(cfgName, list)
            elseif k == LuaLocalType.Local then
                self:GenLocal(cfgName, list)
            elseif k == LuaLocalType.Audio then
                self:GenAudio(cfgName, list)
            elseif k == LuaLocalType.Region then
                self:GenRegion(cfgName, list)
            end
        end
    end

end

---@param cfgName string
---@param list _sundryData[]
function GenSpecialSundryConfig:GenBase(cfgName, list)
    local dst_file_path = string.concat(LUA_CFG_PATH, cfgName, ".lua")
    self:GenFile(dst_file_path,list)
end

---@param cfgName string
---@param list _sundryData[]
function GenSpecialSundryConfig:GenLocal(cfgName, list)
    local temp = {}
    local res = {}
    local fName = string.concat(cfgName, LocalStr)
    for k, v in pairs(LanguageTag) do
        local dst_file_path = GetCfgPathByLanguage(fName, v)
        table.clear(temp)
        table.clear(res)
        for _, v1 in ipairs(list) do
            if v1.language == v then
                table.insert(temp, v1)
            end
        end
        if #temp > 0 then
            self:GenFile(dst_file_path,temp)
        end

    end

end

---@param cfgName string
---@param list _sundryData[]
function GenSpecialSundryConfig:GenAudio(cfgName, list)
    local temp = {}
    local res = {}
    local fName = string.concat(cfgName, LocalSoundStr)
    for k, v in pairs(LanguageTag) do
        local dst_file_path = GetCfgPathBySound(fName, v)
        table.clear(temp)
        table.clear(res)
        for _, v1 in ipairs(list) do
            if v1.language == v then
                table.insert(temp, v1)
            end
        end
        if #temp > 0 then
            self:GenFile(dst_file_path,temp)
        end
    end
end

---@param cfgName string
---@param list _sundryData[]
function GenSpecialSundryConfig:GenRegion(cfgName, list)

    local temp = {}
    local res = {}
    local fName = string.concat(cfgName, LocalRegionStr)
    for _, v in pairs(LanguageTag) do
        local dst_file_path = GetCfgPathByRegion(fName, GetRegionTypeByLanguageType(v))
        table.clear(temp)
        table.clear(res)
        for _, v1 in ipairs(list) do
            if v1.language == v then
                table.insert(temp, v1)
            end
        end
        if #temp > 0 then
            self:GenFile(dst_file_path,temp)
        end

    end

end

---@param filePath string
---@param list _sundryData[]
function GenSpecialSundryConfig:GenFile(filePath,list)
    local is_multi = false
    local res = {}
    for _, v1 in ipairs(list) do
        local value = { [VALUE_KEY] = type(v1.value) == "table" and LuaStr(self:GetFileContents1(v1.value)) or v1.value, [EXAMINE_INCLUDE_KEY] = v1.examineInclude }
        if v1.key2 ~= nil then
            local t = res[v1.key1]
            if not t then
                t = {}
                res[v1.key1] = t
            end
            t[v1.key2] = value
            is_multi = true
        else
            res[v1.key1] = value
        end
    end
    self:WriteFile(filePath, res,is_multi)
end

---@class _sundryData
---@field key1 int | string
---@field key2 int | string
---@field value any
---@field localeType LuaLocalType
---@field language LanguageTag
---@field examineInclude int
---@param key1 string | int
---@param key1 string | int
---@param language LanguageTag
---@param localeType LuaLocalType
---@param examineInclude int
---@param value any
---@return _sundryData
function GenSpecialSundryConfig:GenData(value, key1, key2, localeType, language, examineInclude)
    local data = {}
    data.key1 = key1
    data.key2 = key2
    data.value = value
    data.language = language
    data.examineInclude = examineInclude
    data.localeType = localeType or LuaLocalType.Base
    return data
end

return GenSpecialSundryConfig