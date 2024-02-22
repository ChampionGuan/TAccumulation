---
--- PlayerPrefs
--- Created by zhanbo.
--- DateTime: 2020/7/20 14:56
---

---@class PlayerPrefs
PlayerPrefs = {}

local CLS = CS.UnityEngine.PlayerPrefs
local prefs_Pool
local isDirty = false

function PlayerPrefs.Init()
    isDirty = false
    prefs_Pool = {}
end

---注销的时候做一次保存
function PlayerPrefs.Clear()
    PlayerPrefs.Save()
    --prefs_Pool = nil
    --CLS = nil
end

---@param key string
---@return any
local function PoolGet(key)
    if prefs_Pool and prefs_Pool[key] then
        return prefs_Pool[key]
    end
    return nil
end

---@param key string
---@param value any
local function PoolSet(key, value)
    local pre = prefs_Pool[key]
    if value~=pre then
        prefs_Pool[key] = value
        isDirty = true
        return true
    end
    return false
end

function PlayerPrefs.DeleteAll()
    prefs_Pool = nil
    CLS.DeleteAll()
end

---@param key string
function PlayerPrefs.DeleteKey(key)
    if prefs_Pool then
        prefs_Pool[key] = nil
    end
    CLS.DeleteKey(key)
end

---@param  key string float defaultValue
---@param defaultValue float
---@return float
function PlayerPrefs.GetFloat(key, defaultValue)
    if defaultValue == nil then
        defaultValue = 0
    end

    local value = PoolGet(key)
    if value ~= nil then
        return value
    end

    value = CLS.GetFloat(key, defaultValue)
    prefs_Pool[key] = value
    return value
end

---@param  key string  int defaultValue
---@param defaultValue int
---@return int
function PlayerPrefs.GetInt(key, defaultValue)
    if defaultValue == nil then
        defaultValue = 0
    end

    local value = PoolGet(key)
    if value ~= nil then
        return value
    end

    value = CLS.GetInt(key, defaultValue)
    prefs_Pool[key] = value
    return value
end

---@param  key string  string defaultValue
---@param defaultValue string
---@return string
function PlayerPrefs.GetString(key, defaultValue)
    if defaultValue == nil then
        defaultValue = ""
    end

    local value = PoolGet(key)
    if value ~= nil then
        return value
    end

    value = CLS.GetString(key, defaultValue)
    prefs_Pool[key] = value
    return value
end

---@param key string
---@return boolean
function PlayerPrefs.HasKey(key)
    local value = PoolGet(key)
    if value ~= nil then
        return true
    end
    return CLS.HasKey(key)
end

---@param key string
---@param value float
function PlayerPrefs.SetFloat(key, value)
    if PoolSet(key, value) then
        CLS.SetFloat(key, value)
    end
end

---@param key string
---@param value int
function PlayerPrefs.SetInt(key, value)
    if PoolSet(key, value) then
        CLS.SetInt(key, value)
    end
end
---@param key string
---@param value boolean
function PlayerPrefs.SetBool(key, value)
    PlayerPrefs.SetInt(key, value and 1 or 0)
    return value
end
---@param key string
---@param value boolean
---@return boolean
function PlayerPrefs.GetBool(key, value)
    return PlayerPrefs.GetInt(key, value and 1 or 0) == 1 and true or false
end
---@param key string
---@param value string
function PlayerPrefs.SetString(key, value)
    if PoolSet(key, value) then
        CLS.SetString(key, value)
    end
end

function PlayerPrefs.Save()
    if isDirty then
        isDirty = false
        CLS.Save()
    end
    
end

PlayerPrefs.Init()

return PlayerPrefs