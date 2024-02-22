--- Editor.Misc.CfgTools.GenSundryConfig
--- Created by 教主
--- DateTime:2021/6/16 10:39
--- 本类主要处理SundryConfig配置表相关(纵向-->横向表)
---@class GenSundyConfig:BaseCfgHandler
local GenSundyConfig = class("GenSundyConfig", BaseCfgHandler)
local FileName = "SundryConfig"
local FileNameDst = "SundryConfigData"
local LocalStr = "_Local"
local LocalSoundStr = "_Sound"
local LocalRegionStr = "_Region"

function GenSundyConfig:Execute()
    require("LuaCfg.CfgConst")
    local allSundryConf = {}
    for _, language in pairs(LanguageTag) do
        local src_file_path = GetCfgPathByLanguage(FileName, language)
        local dst_file_path = GetCfgPathByLanguage(FileNameDst, language)
        self:GetConfig(language, FileName, FileNameDst, allSundryConf)
        self:Delete(src_file_path)
        self:Delete(dst_file_path)
    end

    local function Sort(a,b)
        return a.key<b.key
    end
    for k, v in pairs(LuaLocalType) do
        local map = allSundryConf[v]
        if map and #map >= 2 then
            table.sort(map, Sort)
        end
        if not table.isnilorempty(map) then
            if v == LuaLocalType.Base then
                self:GenBase(map)
            elseif v == LuaLocalType.Local then
                self:GenLocal(map)
            elseif v == LuaLocalType.Audio then
                self:GenAudio(map)
            elseif v == LuaLocalType.Region then
                self:GenRegion(map)
            end
        end

    end
end

function GenSundyConfig:GenBase(map)
    local dst_file_path = string.concat(LUA_CFG_PATH, "/", FileName, ".lua")
    local res = {}
    for _, v1 in ipairs(map) do
        res[v1.key] = v1.value
    end
    self:WriteTableToFile(dst_file_path, res)
end

function GenSundyConfig:GenLocal(map)

    local temp = {}
    local res = {}
    local fName = string.concat(FileName,LocalStr)
    for k, v in pairs(LanguageTag) do
        local dst_file_path = GetCfgPathByLanguage(fName, v)
        table.clear(temp)
        table.clear(res)
        for k1, v1 in pairs(map) do
            if v1.lan == v then
                table.insert(temp, k1)
            end
        end
        if #temp > 0 then
            table.sort(temp)
            for _, v1 in ipairs(temp) do
                local t =  map[v1]
                res[t.key] = t.value
            end
            self:WriteTableToFile(dst_file_path, res)
        end

    end

end

function GenSundyConfig:GenAudio(map)

    local fName = string.concat(FileName,LocalSoundStr)
    local temp = {}
    local res = {}
    for k, v in pairs(LanguageTag) do
        local dst_file_path = GetCfgPathBySound(fName, v)
        table.clear(temp)
        table.clear(res)
        for k1, v1 in pairs(map) do
            if v1.lan == v then
                table.insert(temp, k1)
            end
        end
        if #temp > 0 then
            table.sort(temp)
            for _, v1 in ipairs(temp) do
                local t =  map[v1]
                res[t.key] = t.value
            end
            self:WriteTableToFile(dst_file_path, res)
        end

    end

end

function GenSundyConfig:GenRegion(map)

    local fName = string.concat(FileName,LocalRegionStr)
    local temp = {}
    local res = {}
    for k, v in pairs(LuaRegionType) do
        local dst_file_path = GetCfgPathByRegion(fName, v)
        table.clear(temp)
        table.clear(res)
        for k1, v1 in pairs(map) do
            if GetRegionTypeByLanguageType(v1.lan) == v then
                table.insert(temp, k1)
            end
        end
        if #temp > 0 then
            table.sort(temp)
            for _, v1 in ipairs(temp) do
                local t =  map[v1]
                res[t.key] = t.value
            end
            self:WriteTableToFile(dst_file_path, res)
        end

    end

end

function GenSundyConfig:GetConfig(language, src_cfg_name, des_cfg_name, allSundryConf)
    return self:GetConfigByConst(language, src_cfg_name, des_cfg_name, allSundryConf)
end

---根据常量生成的配置表
function GenSundyConfig:GetConfigByConst(language, src_cfg_name, des_cfg_name, allSundryConf)
    local sundry_config_data = LuaCfgMgr.GetByLanguage(des_cfg_name, 1, language)
    local config = table.clone(LuaCfgMgr.GetAllByLanguage(src_cfg_name, nil, language), true)
    for k, v in pairs(sundry_config_data) do
        local upper_key = string.upper(k)
        local idx = X3_CFG_CONST[upper_key]
        if idx and config[idx] then
            local localType = config[idx].LocaleType
            if not allSundryConf[localType] then
                allSundryConf[localType] = {}
            end

            table.insert(allSundryConf[localType], { key = idx, value = table.clone(v, true), lan = language })
        end
    end
    return config
end

return GenSundyConfig