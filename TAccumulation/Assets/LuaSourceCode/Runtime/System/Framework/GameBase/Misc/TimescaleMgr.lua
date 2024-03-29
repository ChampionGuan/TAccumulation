﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by junjun003.
--- DateTime: 2022/10/27 19:40
---

local CSMGR_INS = CS.PapeGames.X3.TimescaleMgr.Instance

---@class TimescaleMgr
local TimescaleMgr = class("TimescaleMgr")

---@class TimescaleLayer
TimescaleMgr.TimescaleLayer = {
    System = 0, --系统级，最底层
    Dialogue = 10, --剧情用
    DialoguePause = 11, --剧情暂停用
    Business = 100 --业务级
}

---设置系统层的Timescale
---@param key string
---@param value float
function TimescaleMgr.SetSystemTimescale(key, value)
    CSMGR_INS:SetSystemTimescale(key, value)
end

---设置Timescale
---@param layer int
---@param key string
---@param value float
function TimescaleMgr.SetTimescale(layer, key, value)
    CSMGR_INS:SetTimescale(layer, key ,value)
end

---清理Timescale
---@param layer int
---@param key string
function TimescaleMgr.ClearTimescale(layer, key)
    CSMGR_INS:ClearTimescale(layer, key)
end

---Timescale恢复默认值
function TimescaleMgr.SetTimescaleToDefault()
    CSMGR_INS:SetTimescaleToDefault()
end

---获取某一层的Timescale
---@param layer int
---@return float
function TimescaleMgr.GetLayerLocalTimescale(layer)
    return CSMGR_INS:GetLayerLocalTimescale(layer)
end

---获取某一层的Timescale，会乘算Layer更大的所有层的Timescale
---@param layer int
---@return float
function TimescaleMgr.GetLayerGlobalTimescale(layer)
    return CSMGR_INS:GetLayerGlobalTimescale(layer)
end

---获取某个Key的Timescale值
---@param layer int
---@param key string
---@return float
function TimescaleMgr.GetKeyTimescale(layer, key)
    return CSMGR_INS:GetKeyTimescale(layer, key)
end

return TimescaleMgr