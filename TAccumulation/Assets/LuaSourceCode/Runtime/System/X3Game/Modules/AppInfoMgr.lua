﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2023/5/6 18:23
---

---@class AppInfoMgr
local AppInfoMgr = {}

local cs_AppInfoMgr = CS.X3Game.AppInfoMgr.Instance
---@type boolean
local IsAudit = nil
---@type GameConst.GameSubVersion
local GameSubVersion = nil

function AppInfoMgr.Init()
    GameSubVersion = require("LuaCfg.revision", true, true)
    CrashSightMgr.SetBuildNum(cs_AppInfoMgr.AppInfo.BuildNum)
end

function AppInfoMgr.Clear()
end

function AppInfoMgr.InitSkipEnable()
    AppInfoMgr.SetIsAudit(cs_AppInfoMgr.AppInfo.IsAudit)
    LuaCfgMgr.ParseMerger()
end

---是否是审核模式
---@return boolean
function AppInfoMgr.IsAudit()
    return cs_AppInfoMgr.AppInfo.IsAudit
end

---@param enable boolean
function AppInfoMgr.SetIsAudit(enable, force)
    if enable ~= IsAudit or force then
        IsAudit = enable
        LuaCfgMgr.Clear()
        LuaCfgMgr.SetSkipEnable(enable, Const.SKIP_TAG)
    end

end

function AppInfoMgr.GetServerRegion()
    return cs_AppInfoMgr.AppInfo.ServerRegionId
end

function AppInfoMgr.GetRegion()
    return cs_AppInfoMgr.AppInfo.Region
end

function AppInfoMgr.GetCmsUrl()
    return cs_AppInfoMgr.AppInfo.CmsUrl
end

function AppInfoMgr.GetTcVersion()
    return cs_AppInfoMgr.AppInfo.TcVersion
end

--region 自定义 & 分享 屏蔽开关
---@class AppInfoMgr.CustomDisableType 自定义功能枚举
AppInfoMgr.CustomDisableType = {
    System = X3_CFG_CONST.SYSTEM_DISABLE_DIY, ---系统
    Share = X3_CFG_CONST.SYSTEM_DISABLE_SHARE, ---分享
}

local customDisableData = { }

---@param disableTab int[]
function AppInfoMgr.SetCustomDisableData(disableTab)
    disableTab = disableTab or {}
    customDisableData = disableTab
end

---@param customDisableType AppInfoMgr.CustomDisableType
---@return bool  是否屏蔽
function AppInfoMgr.CheckCustomDisable(customDisableType)
    local value = AppInfoMgr.GetIsCustomDisable(customDisableType)
    if value then
        UICommonUtil.ShowMessage(UITextConst.UI_TEXT_5818)
    end
    return value
end

---@param customDisableType AppInfoMgr.CustomDisableType
---@return bool
function AppInfoMgr.GetIsCustomDisable(customDisableType)
    return table.containsvalue(customDisableData, customDisableType)
end

---@return string,int
function AppInfoMgr.GetAppVersionAndBuildNum()
    return cs_AppInfoMgr.AppInfo.AppVer, cs_AppInfoMgr.AppInfo.BuildNum
end

---检测是否是某个版本
---@param gameSubVersion GameConst.GameSubVersion
---@return boolean
function AppInfoMgr.IsEqualGameSubVersion(gameSubVersion)
    return gameSubVersion == GameSubVersion
end

---获取当前版本
---@return GameConst.GameSubVersion
function AppInfoMgr.GetGameSubVersion()
    return GameSubVersion
end

--region
return AppInfoMgr