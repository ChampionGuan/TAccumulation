﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by dengzi.
--- DateTime: 2023/10/24 11:30
---

---@class CrashSightMgr
local CrashSightMgr = {}

local cs_CrashSightMgr = CS.CrashSightManager
local isInitialized = cs_CrashSightMgr.IsInitialized()

local KeyDefine = {
    Region = "Region",
    GameState = "GameState",
    UID = "UID",
    ResVersion = "ResVersion",
    SceneName = "SceneName",
    IsLoading = "IsLoading",
    BattleLevelID = "BattleLevelID",
    BuildNum = "BuildNum",
}

function CrashSightMgr.Init()
end

function CrashSightMgr.Clear()
end

---设置用户ID
---@param userId string
function CrashSightMgr.SetUserId(userId)
    if not isInitialized then
        return
    end
    cs_CrashSightMgr.SetUserId(userId)
end

---标记场景
---@param sceneId int 场景ID
function CrashSightMgr.SetScene(sceneId)
    if not isInitialized then
        return
    end
    cs_CrashSightMgr.SetScene(sceneId)
end

---添加自定义数据 此消息会随错误、崩溃一起上报，可在 崩溃详情页->跟踪数据->valueMapOthers.txt 查看
---@param key string
---@param value string
function CrashSightMgr.UploadCustomInfo(key, value)
    if not isInitialized then
        return
    end
    cs_CrashSightMgr.UploadCustomInfo(key, value)
end

---设置地区
---@param region string
function CrashSightMgr.SetRegion(region)
    CrashSightMgr.UploadCustomInfo(KeyDefine.Region, region)
end

---设置UID
---@param uid string
function CrashSightMgr.SetUID(uid)
    CrashSightMgr.UploadCustomInfo(KeyDefine.UID, uid)
end

---设置当前游戏状态
---@param gameState string
function CrashSightMgr.SetGameState(gameState)
    CrashSightMgr.UploadCustomInfo(KeyDefine.GameState, gameState)
end

---设置资源版本号
---@param resVersion string
function CrashSightMgr.SetResVersion(resVersion)
    CrashSightMgr.UploadCustomInfo(KeyDefine.ResVersion, resVersion)
end

---设置当前场景名
function CrashSightMgr.SetCurSceneName(sceneName)
    CrashSightMgr.UploadCustomInfo(KeyDefine.SceneName, sceneName)
end

---设置是否Loading
function CrashSightMgr.SetIsLoading(isLoading)
    CrashSightMgr.UploadCustomInfo(KeyDefine.IsLoading, tostring(isLoading))
end

function CrashSightMgr.SetBattleLevelID(levelID)
    CrashSightMgr.UploadCustomInfo(KeyDefine.BattleLevelID, tostring(levelID))
end

---@param buildNum
function CrashSightMgr.SetBuildNum(buildNum)
    CrashSightMgr.UploadCustomInfo(KeyDefine.BuildNum, tostring(buildNum))
end

return CrashSightMgr