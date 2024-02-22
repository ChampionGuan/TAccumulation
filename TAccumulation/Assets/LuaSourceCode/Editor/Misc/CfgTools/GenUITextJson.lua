﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2023/5/18 21:13
---
---@class GenUITextJson:BaseCfgHandler
local GenUITextJson = class("GenUITextJson", BaseCfgHandler)
local outFileName = "UITextData"

function GenUITextJson:Execute()

    local localesOutdated = nil
    local cfgExportResPath = os.getenv("CFG_EXPORT_RES_FILE") or string.concat(LUA_BINARY_PATH, "/PostProcess/CfgExportRes.json")
    if io.exists(cfgExportResPath) then
        local cfgExportRes = JsonUtil.Decode(io.readfile(cfgExportResPath))
        localesOutdated = cfgExportRes and cfgExportRes.LocalesOutdated
    end

    if localesOutdated ~= nil and table.isnilorempty(localesOutdated) then
        return
    end

    require("LuaCfg.UITextConst")
    local debugTextMap = require("LuaCfg.UITextData_DEBUG", true, true)
    for _, language in pairs(LanguageTag) do
        if localesOutdated == nil or localesOutdated[language] then
            local res = {}
            local textMap = LuaCfgMgr.GetAllByLanguage(outFileName, nil, language)
            table.merge(textMap,debugTextMap)
            LuaCfgMgr.ResetDirPath()
            for k, v in pairs(textMap) do
                local text = self:ReplaceRoleName(v, textMap)
                text = self:ReplaceLoveLevel(text, textMap)
                table.insert(res, { TextId = k, Text = text, IsEncrypt = false,IsDebug = debugTextMap[k]~=nil })
            end

            table.sort(res, function(a, b)
                return a.TextId < b.TextId
            end)
            local path = string.concat(OUT_JSON_PATH, "/Locale/", language, "/", outFileName, ".json")
            self:Write(path, JsonUtil.Encode({ Datas = res }))
        end
    end
end

---@param textId int
---@param textMap table<int,string>
function GenUITextJson:GetText(textId, textMap)
    local res = textMap[textId] or ""
    return res
end

---@param textId int
---@param textMap table<int,string>
---@return string
function GenUITextJson:GetTextByConstId(textId, textMap)
    return self:GetText(textId - 1000000, textMap)
end

---替换男主标签
---@param text string
---@param uiTextMap table<int,string>
---@return string
function GenUITextJson:ReplaceRoleName(text, uiTextMap)
    if not self.roleTag then
        self.roleTag = {}
        local tag = "{Role%s}"

        for k = 1, 5 do
            local role = LuaCfgMgr.Get("RoleInfo", k)
            local t = string.format(tag, k)
            table.insert(self.roleTag, { tag = t, name = role and role.Name or "" })
        end
    end

    for k, v in pairs(self.roleTag) do
        local key = v.tag
        if string.find(text, key, 1, true) then
            local rep = ""
            if not string.isnilorempty(v.name) then
                rep = self:GetText(v.name, uiTextMap)
            end
            text = string.replace(text, key, rep)
        end
    end
    return text
end

---替换LoveLevel标签
---@param text string
---@param uiTextMap table<int,string>
---@return string
function GenUITextJson:ReplaceLoveLevel(text, uiTextMap)
    if not self.loveLevelTag then
        self.loveLevelTag = {}
        local tag = "{lovepointlevel=%s}"
        for k, v in pairs(LuaCfgMgr.GetAll("LovePointLevel")) do
            local p = LuaCfgMgr.Get("LovePointPeriod", v.PeriodID)
            if p then
                self.loveLevelTag[v.Level] = { tag = string.format(tag, v.Level), name = p.PeriodName }
            end

        end
    end

    for level, v in pairs(self.loveLevelTag) do
        local key = v.tag
        if string.find(text, key, 1, true) then
            local name = self:GetText(v.name, uiTextMap)
            local rep = string.cs_format(self:GetTextByConstId(UITextConst.UI_TEXT_14111, uiTextMap), name, level)
            text = string.replace(text, key, rep)
        end
    end

    return text
end
return GenUITextJson