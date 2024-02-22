﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by dengzi.
--- DateTime: 2023/9/22 10:53
---

---@class DynamicCardSceneMgr
local DynamicCardSceneMgr = class("DynamicCardSceneMgr")

---@class LoadingSceneTaskItem
---@field ctrlId number 动卡实例ID
---@field sceneAssetPath string 场景资源路径
---@field onComplete function 加载完成回调

---@type table<string, UnityEngine.GameObject> 已加载出来的场景,key:sceneAssetPath,value:场景实例
local loadedSceneObjMap = {}
---@type table<string, number[]>  已加载出来的场景引用的动卡实例ID,key:sceneAssetPath,value:业务实例ID数组，同一个动卡实例只能同时使用一个场景
local loadedSceneRefMap = {}
---@type table<number, LoadingSceneTaskItem> 加载场景Task数据，key：动卡实例ID，value：LoadingSceneTaskData
local loadingTaskMap = {}
---@type table<string, int[]> 正在加载的场景,
local loadingSceneMap = {}

---@param ctrlId number
function DynamicCardSceneMgr.LoadScene(ctrlId, sceneAssetPath, onComplete)
    if not ctrlId or string.isnilorempty(sceneAssetPath) then
        if onComplete then
            onComplete(nil)
        end
        return
    end

    ---如果当前动卡实例有引用其他场景的话，先移除对其他场景的引用
    DynamicCardSceneMgr.RemoveScene(ctrlId, sceneAssetPath)

    local loadedSceneGo = loadedSceneObjMap[sceneAssetPath]
    if loadedSceneGo then
        if not GameObjectUtil.IsNull(loadedSceneGo) then
            ---需要的场景已存在
            local refMap = loadedSceneRefMap[sceneAssetPath]
            if not refMap then
                refMap = {}
            end
            if not table.containsvalue(refMap, ctrlId) then
                table.insert(refMap, ctrlId)
            end
            if onComplete then
                onComplete(loadedSceneGo)
            end
            return
        else
            ---lua引用还在，C#对象没了，当做未加载场景
            loadedSceneObjMap[sceneAssetPath] = nil
            loadedSceneRefMap[sceneAssetPath] = nil
            Debug.LogErrorFormat("动卡加载的场景GameObject被其他业务销毁，请确认！场景资源：%s", tostring(sceneAssetPath))
        end
    end
    if loadingSceneMap[sceneAssetPath] then
        --需要的场景正在加载中
        ---@type LoadingSceneTaskItem
        local taskItem = {}
        taskItem.ctrlId = ctrlId
        taskItem.sceneAssetPath = sceneAssetPath
        taskItem.onComplete = onComplete
        loadingTaskMap[ctrlId] = taskItem
        if not table.containsvalue(loadingSceneMap[sceneAssetPath], ctrlId) then
            table.insert(loadingSceneMap[sceneAssetPath], ctrlId)
        end
        return
    end
    --需要加载场景
    ---@type LoadingSceneTaskItem
    local taskItem = {}
    taskItem.ctrlId = ctrlId
    taskItem.sceneAssetPath = sceneAssetPath
    taskItem.onComplete = onComplete
    loadingTaskMap[ctrlId] = taskItem
    loadingSceneMap[sceneAssetPath] = {ctrlId}
    Res.LoadGameObjectAsync(sceneAssetPath, nil, function(sceneObj)
        DynamicCardSceneMgr.OnSceneLoaded(sceneAssetPath, sceneObj)
    end)
end

---@param sceneAssetPath string
---@param sceneObj UnityEngine.GameObject
function DynamicCardSceneMgr.OnSceneLoaded(sceneAssetPath, sceneObj)
    if table.isnilorempty(loadingSceneMap[sceneAssetPath]) then
        ---场景加载完，但是已经没有动卡实例需要这个场景了，直接回收
        GameObjectUtil.SetActive(sceneObj, false)
        Res.DiscardGameObject(sceneObj)
        loadingSceneMap[sceneAssetPath] = nil
        return
    end
    local sceneRefIdList = {}
    for _, ctrlId in ipairs(loadingSceneMap[sceneAssetPath]) do
        local taskItem = loadingTaskMap[ctrlId]
        if taskItem and taskItem.sceneAssetPath == sceneAssetPath then
            table.insert(sceneRefIdList, ctrlId)
            if taskItem.onComplete then
                 taskItem.onComplete(sceneObj)
            end
            loadingTaskMap[ctrlId] = nil
        end
    end
    loadingSceneMap[sceneAssetPath] = nil
    if #sceneRefIdList == 0 then
        ---场景加载完，但是已经没有动卡实例需要这个场景了，直接回收
        GameObjectUtil.SetActive(sceneObj, false)
        Res.DiscardGameObject(sceneObj)
        return
    end
    loadedSceneRefMap[sceneAssetPath] = sceneRefIdList
    loadedSceneObjMap[sceneAssetPath] = sceneObj
end

---@param ignoreSceneAssetPath string 需要忽略的场景资源
function DynamicCardSceneMgr.RemoveScene(ctrlId, ignoreSceneAssetPath)
    if not ctrlId then
        return
    end
    --移除正在加载的
    local toRemoveLoadingScene = PoolUtil.GetTable()
    for sceneAssetPath, ctrlIdList in pairs(loadingSceneMap) do
        if sceneAssetPath ~= ignoreSceneAssetPath and ctrlIdList and #ctrlIdList > 0 then
            table.removebyvalue(ctrlIdList, ctrlId)
        end
        if table.isnilorempty(ctrlIdList) then
            table.insert(toRemoveLoadingScene, sceneAssetPath)
        end
    end
    if #toRemoveLoadingScene > 0 then
        for i = 1, #toRemoveLoadingScene do
            loadingSceneMap[toRemoveLoadingScene[i]] = nil
        end
    end
    PoolUtil.ReleaseTable(toRemoveLoadingScene)
    if loadingTaskMap[ctrlId] and loadingTaskMap[ctrlId].sceneAssetPath ~= ignoreSceneAssetPath then
        loadingTaskMap[ctrlId] = nil
    end
    --移除加载完的
    local toRemoveScene = PoolUtil.GetTable()
    for sceneAssetPath, ctrlIdList in pairs(loadedSceneRefMap) do
        if sceneAssetPath ~= ignoreSceneAssetPath and ctrlIdList and #ctrlIdList > 0 then
            table.removebyvalue(ctrlIdList, ctrlId)
        end
        if table.isnilorempty(ctrlIdList) then
            table.insert(toRemoveScene, sceneAssetPath)
        end
    end
    if #toRemoveScene > 0 then
        for i = 1, #toRemoveScene do
            local sceneAssetPath = toRemoveScene[i]
            loadedSceneRefMap[sceneAssetPath] = nil
            local sceneObj = loadedSceneObjMap[sceneAssetPath]
            if not GameObjectUtil.IsNull(sceneObj) then
                GameObjectUtil.SetActive(sceneObj)
                Res.DiscardGameObject(sceneObj)
            end
            loadedSceneObjMap[sceneAssetPath] = nil
        end
    end
    PoolUtil.ReleaseTable(toRemoveScene)
end

return DynamicCardSceneMgr