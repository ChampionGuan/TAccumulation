--- X3@PapeGames
--- ResBatchLoader
--- Created by zhanbo
--- Created Date: 2020/12/01
--- Updated by Tungway
--- Update Date: 2020/12/01

---@class ResBatchLoader
local ResBatchLoader = {}
local this = ResBatchLoader

local CS_CLS = CS.X3Game.ResBatchLoader

---是否在运行中
function ResBatchLoader.GetIsRunning()
    return CS_CLS.IsRunning
end

---添加一个普通资源任务
---@param assetName string
---@param resType ResType
---@param progressWeight number 进度权重
---@return boolean 本次操作是否成功
function ResBatchLoader.AddTask(assetName, resType, progressWeight)
    local assetPath = Res.GetAssetPath(assetName, resType)
    local ret = this.AddTaskWithAssetPath(assetPath, progressWeight)
    return ret
end

---添加一个普通资源任务
---@param assetPath string 资源路径
---@param progressWeight number 进度权重
function ResBatchLoader.AddTaskWithAssetPath(assetPath, assetType, progressWeight)
    progressWeight = progressWeight or 1.0
    local ret = CS_CLS.AddAssetTask(assetPath, assetType, progressWeight)
    return ret
end

---添加加载场景任务
---@param sceneName string 场景名
---@param progressWeight number 进度权重
---@param loadSceneMode CS.UnityEngine.SceneManagement.LoadSceneMode 场景加载模式
---@return boolean 本次操作是否成功
function ResBatchLoader.AddSceneTask(sceneName, progressWeight, loadSceneMode)
    progressWeight = progressWeight or 1.0
    loadSceneMode = loadSceneMode or CS.UnityEngine.SceneManagement.LoadSceneMode.Single
    return CS_CLS.AddSceneTask(sceneName, progressWeight, loadSceneMode)
end

---添加加载soundbank任务
---@param soundbankName string
---@param progressWeight number 进度权重（默认为1）
---@return bool 操作是否成功
function ResBatchLoader.AddSoundBankTask(soundbankName, progressWeight)
    progressWeight = progressWeight or 1.0
    return CS_CLS.AddSoundBankTask(soundbankName, progressWeight)
end

---执行异步加载
---@param loadingType GameConst.LoadingType 是否打开加载UI
---@param autoHideUI boolean 加载完成后是否自动关闭LoadingUI
---@param onComplete fun(batch:int)
---@param onProgress fun(batch:int, progress:float)
---@param uiProgressWeight number loadingUI的权重
---@param uiInitProgress number loadingUI初始进度（0~1）
---@return int batchId
function ResBatchLoader.LoadAsync(loadingType, autoHideUI, onComplete, onProgress, uiProgressWeight, uiInitProgress)
    if uiProgressWeight == nil then
        uiProgressWeight = 1.0
    end
    if uiInitProgress == nil then
        uiInitProgress = 0.0
    end
    local is_need_loading = false
    if loadingType and loadingType~= GameConst.LoadingType.None then
        is_need_loading = true
        UICommonUtil.SetLoadingEnable(loadingType,true)
    end
    local completeCall = function(batchId)
        if onComplete then
            onComplete(batchId)
        end
        if is_need_loading and autoHideUI then
            UICommonUtil.SetLoadingEnable(loadingType,false)
        end
    end
    local processCall = function(batchId,p)
        if onProgress then
            onProgress(batchId,p)
        end
        if is_need_loading then
            UICommonUtil.SetLoadingProgress( p * uiProgressWeight + uiInitProgress)
        end
    end
    local batchId = CS_CLS.LoadAsync(completeCall, processCall)
    return batchId
end

---执行异步加载（不呼出UI）
---@param onComplete fun(batch:int)
---@param onProgress fun(batch:int, progress:float)
---@return int batchId
function ResBatchLoader.LoadAsyncWithoutUI(onComplete, onProgress)
    local batchId = CS_CLS.LoadAsync(onComplete, onProgress)
    return batchId
end

---执行异步卸载
---@param batchId int
---@param onComplete fun(batchId:int):void 完成后的回调
function ResBatchLoader.UnloadAsync(batchId, onComplete)
    CS_CLS.UnloadAsync(batchId, onComplete)
end

---提取加载后的资产
---@param assetName string
---@param resType ResType
---@return UnityEngine.Object
function ResBatchLoader.RetrieveAsset(assetName, resType)
    local assetPath = Res.GetAssetPath(assetName, resType)
    return CS_CLS.RetrieveAsset(assetPath)
end

---给BatchId下所有已加载资产减引用计数和增加引用对象
---@param batchId int
---@param num int
---@param refObj UObject
function ResBatchLoader.SubRefCountAndAddRefObj(batchId, num, refObj)
    CS_CLS.SubRefCountAndAddRefObj(batchId, num, refObj)
end

---清除一个Batch
---@param batchId int
---@return boolean
function ResBatchLoader.RemoveBatch(batchId)
    local ret = CS_CLS.SubRefCountAndAddRefObj(batchId)
    return ret
end

---清除已经添加的任务
function ResBatchLoader.ClearTasks()
    CS_CLS.ClearTasks()
end

--[[---加载场景
---@param sceneName string
---@param loadSceneMode UnityEngine.SceneManagement.LoadSceneMode
---@param finishCall fun(type:boolean)
---@param loadingProcessCall fun(type:float)
function ResBatchLoader.LoadSceneAsync(sceneName,loadSceneMode,finishCall,loadingProcessCall)
    loadSceneMode = loadSceneMode or CS.UnityEngine.SceneManagement.LoadSceneMode.Single
    return CS_CLS.LoadSceneAsync(sceneName,loadSceneMode,finishCall,loadingProcessCall)
end]]

function ResBatchLoader.Init()
end

function ResBatchLoader.Clear()
    CS_CLS.Destroy();
end

function ResBatchLoader.Destroy()
    ResBatchLoader.Clear()
end

return ResBatchLoader