﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2022/11/23 12:19
---
---@class GenUITextConst:BaseCfgHandler
local GenUITextConst = class("GenUITextConst", BaseCfgHandler)
local cfg = "UITextData"
local idStart = 1000000
local uiTextId = 100000
local tag = "UI_TEXT_"
local outFileName = "UITextConst"

function GenUITextConst:Execute()
    local path = string.concat(LUA_CFG_PATH, "/", outFileName, ".lua")
    local temp = {}
    local ids = {}
    for k, v in pairs(LuaCfgMgr.GetAllByLanguage(cfg, LanguageTag.ZH_CN)) do
        if k <= uiTextId then
            temp[k] = v
            table.insert(ids, k)
        end

    end
    table.sort(ids)
    local des = { string.concat(outFileName, "\t=\t{}\n") }
    for k, v in ipairs(ids) do
        local key, value = self:GetTextDes(v)
        table.insert(des, string.concat(outFileName, ".", key, "\t=\t", value, "--", string.replace(temp[v], "\n", ""), "\n"))
    end
    table.insert(des, string.concat("return\t", outFileName))
    self:Write(path, table.concat(des))
end

function GenUITextConst:GetTextDes(id)
    return string.concat(tag, id), idStart + id
end
return GenUITextConst