﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhanbo.
--- DateTime: 2022/3/26 17:38
---
---@class SystemSettingProxy:BaseProxy
local SystemSettingProxy = class("SystemSettingProxy", BaseProxy)

function SystemSettingProxy:OnInit()
    self.data = require("Runtime.System.X3Game.Data.DataProxy.Data.SystemSettingData").new()
end

function SystemSettingProxy:OnClear()
    self.data = nil
end

---@param gameSettingData pbcmessage.GameSettingData
function SystemSettingProxy:OnEnterGameReply(gameSettingData)
    
end

---获取推送主题
---@return int
function SystemSettingProxy:GetPushTheme()
    return BllMgr.GetSystemSettingBLL():GetLocalSysTheme()
end

return SystemSettingProxy