﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by kan.
--- DateTime: 2022/5/12 14:38
---

local GachaPerformPreLoad = {}

---table<key, value> key:int scoreID，value:GameObject 男主表现信息
local scorePerformDic = {}
---table<key, value> key:string sceneName，value:GameObject 男主表现信息
local scenePerformDic = {}
---table<key, value> key:int scoreID，value:Func(GameObject,GameObject) 缓存获取男主表现信息CallBack
local waitCallBack = {}

local isLoading = false

local preloadScoreList = {}
local curPreloadIndex = 1

function GachaPerformPreLoad.PreLoadScore(rewards, finishedCallBack)
    isLoading = true
    for k, v in ipairs(rewards) do
        table.insert(preloadScoreList, v)
    end
    local num = #preloadScoreList
    if (num > 0) and (curPreloadIndex <= num) then
        local doNextCB = function(cb)
            curPreloadIndex = curPreloadIndex + 1
            if curPreloadIndex > #preloadScoreList then
                if finishedCallBack then
                    finishedCallBack(preloadScoreList)
                end
                preloadScoreList = {}
                curPreloadIndex = 1
                isLoading = false
                return
            end
            GachaPerformPreLoad:PreLoadScoreInner(cb)
        end
        GachaPerformPreLoad:PreLoadScoreInner(doNextCB)
    end
end

function GachaPerformPreLoad:PreLoadScoreInner(callback)
    local itemData = preloadScoreList[curPreloadIndex].Item
    if itemData.Type ~= 50 and preloadScoreList[curPreloadIndex].DecomFrom ~= nil then
        itemData = preloadScoreList[curPreloadIndex].DecomFrom
    end
    if itemData.Type ~= 50 then
        if callback then
            callback(callback)
        end
        return
    end
    local itemInfo = LuaCfgMgr.Get("Item", itemData.Id)
    local mSCoreInfo = LuaCfgMgr.Get("SCoreBaseInfo", itemInfo.ID)
    local roleIns = scorePerformDic[mSCoreInfo.ID]
    local formationSuitID = mSCoreInfo.DefaultSkin
    if roleIns == nil then
        local test = BllMgr.GetFashionBLL():GetScoreModelByFormationSuitNoAnimatorState(mSCoreInfo.ID, formationSuitID, function(ins, id)
            roleIns = ins
            local showScene = scenePerformDic[mSCoreInfo.GetShowScene]
            if showScene == nil then
                showScene = UIMgr.LoadDynamicUIPrefab(mSCoreInfo.GetShowScene)
                GameObjectUtil.SetActive(showScene, false)
            end
            --X3AnimatorUtil.SetLocalPosition(roleIns,0,100000,0)
            GachaPerformPreLoad.AddSCoreInfo(mSCoreInfo.ID, roleIns, mSCoreInfo.GetShowScene, showScene)

            if callback then
                callback(callback)
            end
        end)
    else
        local showScene = scenePerformDic[mSCoreInfo.GetShowScene]
        if showScene == nil then
            showScene = UIMgr.LoadDynamicUIPrefab(mSCoreInfo.GetShowScene)
            GameObjectUtil.SetActive(showScene, false)
        end
        GachaPerformPreLoad.AddSCoreInfo(mSCoreInfo.ID, roleIns, mSCoreInfo.GetShowScene, showScene)
        if callback then
            callback(callback)
        end
    end
end

function GachaPerformPreLoad.PreLoad(rewards, callBack)
    isLoading = true
    local doNextCB = function(curIndex, cb)
        if curIndex == 1 and callBack then
            callBack()
        end
        curIndex = curIndex + 1
        GachaPerformPreLoad.LoadGachaAsset(curIndex, rewards, cb)
    end

    GachaPerformPreLoad.LoadGachaAsset(1, rewards, doNextCB)
end

function GachaPerformPreLoad.LoadGachaAsset(curIndex, rewards, doNextCB)
    if curIndex > #rewards then
        isLoading = false
        return
    end

    local itemData = rewards[curIndex].Item
    if itemData.Type ~= 50 and rewards[curIndex].DecomFrom ~= nil then
        itemData = rewards[curIndex].DecomFrom
    end

    if itemData.Type ~= 50 then
        if doNextCB then
            doNextCB(curIndex, doNextCB)
        end
        return
    end

    local itemInfo = LuaCfgMgr.Get("Item", itemData.Id)
    local mSCoreInfo = LuaCfgMgr.Get("SCoreBaseInfo", itemInfo.ID)
    local roleIns = scorePerformDic[mSCoreInfo.ID]
    local formationSuitID = mSCoreInfo.DefaultSkin
    if roleIns == nil then
        local test = BllMgr.GetFashionBLL():GetScoreModelByFormationSuitNoAnimatorState(mSCoreInfo.ID, formationSuitID, function(ins, id)
            roleIns = ins
            local showScene = scenePerformDic[mSCoreInfo.GetShowScene]
            if showScene == nil then
                showScene = UIMgr.LoadDynamicUIPrefab(mSCoreInfo.GetShowScene)
                GameObjectUtil.SetActive(showScene, false)
            end
            GameObjectUtil.SetActive(roleIns, false)
            GachaPerformPreLoad.AddSCoreInfo(mSCoreInfo.ID, roleIns, mSCoreInfo.GetShowScene, showScene)
            if doNextCB then
                doNextCB(curIndex, doNextCB)
            end
        end)
    else
        local showScene = scenePerformDic[mSCoreInfo.GetShowScene]
        if showScene == nil then
            showScene = UIMgr.LoadDynamicUIPrefab(mSCoreInfo.GetShowScene)
            GameObjectUtil.SetActive(showScene, false)
        end
        GachaPerformPreLoad.AddSCoreInfo(mSCoreInfo.ID, roleIns, mSCoreInfo.GetShowScene, showScene)
        if doNextCB then
            doNextCB(curIndex, doNextCB)
        end
    end
end

function GachaPerformPreLoad.AddSCoreInfo(scoreID, roleIns, sceneName, scene)
    scorePerformDic[scoreID] = roleIns
    scenePerformDic[sceneName] = scene
    if waitCallBack[scoreID] then
        waitCallBack[scoreID](scoreID, scene, roleIns)
        waitCallBack[scoreID] = nil
    end
end

function GachaPerformPreLoad.GetPerformScene(scoreID, sceneName, callBack)
    local sceneGO = scenePerformDic[sceneName]
    local roleIns = scorePerformDic[scoreID]
    if sceneGO then
        if callBack then
            callBack(scoreID, sceneGO, roleIns)
        end
    else
        waitCallBack[scoreID] = callBack
    end
end

function GachaPerformPreLoad.ClearPerformScene()
    if scorePerformDic then
        for k, v in pairs(scorePerformDic) do
            CharacterMgr.ReleaseIns(v)
            CS.UnityEngine.GameObject.DestroyImmediate(v, true)
        end
        scorePerformDic = {}
    end

    if scenePerformDic then
        for k, v in pairs(scenePerformDic) do
            CS.UnityEngine.GameObject.DestroyImmediate(v, true)
        end
        scenePerformDic = {}
    end
end

function GachaPerformPreLoad.GetState()
    return isLoading
end

return GachaPerformPreLoad