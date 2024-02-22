﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhanbo.
--- DateTime: 2022/6/17 19:22
---
---@class SensitiveWordHelper
local SensitiveWordHelper = {}
local m_IsInit = false
---@type DBFilter
local m_DBFilter = nil
---@type CMSCtrl
local m_CMSCtrl = nil

local function Init()
    if m_IsInit then
        return
    end
    m_DBFilter = require("Runtime.System.X3Game.Modules.SensitiveWord.DBFilter").new()
    m_CMSCtrl = require("Runtime.System.X3Game.Modules.SensitiveWord.CMSCtrl").new()
    m_IsInit = true
end

---是否包含敏感字
---@param word string
---@return bool
function SensitiveWordHelper.ContainSensitiveWord(word)
    if string.isnilorempty(word) then
        return false
    end
    Init()
    ---特殊替换
    local DirtyWordsChangeDatas_cfg = LuaCfgMgr.GetAll("DirtyWordsChange")
    if m_DBFilter:ContainSensitiveWord(word) then
        for k, v in pairs(DirtyWordsChangeDatas_cfg) do
            word = string.replace(word, UITextHelper.GetUIText(v.OriginalText), UITextHelper.GetUIText(v.NewText))
            if not m_DBFilter:ContainSensitiveWord(word) then
                ---只要替换后的字如果不被匹配就通过
                return false
            end
        end
        return true
    else
        return false
    end
end

---获取填充了filterString的文字(filterString默认为"*")
---@param word string
---@param filterString string
---@return string
function SensitiveWordHelper.FilterSensitiveWord(word, filterString)
    if string.isnilorempty(word) then
        return word
    end
    Init()
    if SensitiveWordHelper.ContainSensitiveWord(word) then
        return m_DBFilter:FilterSensitiveWord(word, filterString)
    else
        return word
    end

end

---根据CMS的敏感词版本号更新敏感词的DB文件
function SensitiveWordHelper.UpdateDBCfgByCMS()
    Init()
    m_CMSCtrl:CheckVersion(m_DBFilter)
end

return SensitiveWordHelper