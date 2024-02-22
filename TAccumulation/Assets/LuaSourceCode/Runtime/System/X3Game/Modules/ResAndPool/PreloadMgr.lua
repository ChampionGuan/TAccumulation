--- X3@PapeGames
--- 资源预加载管理器
--- 对于强依赖的资源不应通过本管理器进行加载，本管理器不保证资源一定能够加载成功。
--- 本管理器适用于：后面可能会用到某资源，在空闲的情况下先进行加载。
--- Created by Tungway
--- Created Date: 2021/01/04
--- Updated by Tungway
--- Update Date: 2021/01/04

---@class PreloadMgr
local PreloadMgr = {}
--[[
    任务列表
    {{AssetPath = "Assets/1", Expire = 1, OnComplete = nil}, {AssetPath = "Assets/2", Expire = 1, OnComplete = nil}}
--]]
local taskList = {}
--[[
    任务字典
    {"Assets/2" = {AssetPath = "Assets/2", Expire = 1, OnComplete = nil}, "Assets/2" = {AssetPath = "", Expire = 1, OnComplete = nil}}
--]]
local taskDict = {}
---最大任务数量
local maxTaskCount = 1
--[[
    正在预加载的任务列表
    {{AssetPath = "Assets/1", Expire = 1, OnComplete = nil}, {AssetPath = "Assets/2", Expire = 1, OnComplete = nil}}
--]]
local loadingList = {}
--[[
    加载完成的资产列表
    {{Asset = Obj1, Expire = 13244}, {Asset = Obj2, Expire = 13247}}
--]]
local assetList = {}

---任务是否已存在
local hasTask = function(assetPath)
    if string.isnilorempty(assetPath) then return false end
    local task = taskDict[assetPath]
    return task ~= nil
end

---是否能开启预加载任务
local canStartTask = function()
    if(GameMgr.GetFps() < 30) then
        return false
    end

    if(#loadingList >= maxTaskCount) then
        return false
    end

    return true
end

---尝试开启预加载任务
local tryStartTask = function()
    if not canStartTask() then
        return
    end
    if #taskList == 0 then return end

    while #loadingList < maxTaskCount do
        local task = taskList[#taskList]
        table.insert(loadingList, task)
        Res.LoadWithAssetPathAsync(task.AssetPath, AutoReleaseMode.None, nil, function(asset)
            table.removebyvalue(loadingList, task)
            table.removebyvalue(taskList, task)
            if(taskDict[task.AssetPath] ~= nil) then
                taskDict[task.AssetPath] = nil
                if(asset ~= nil) then
                    table.insert(assetList, { Asset = asset, Expire = os.time() + task.Expire })
                end
                if task.OnComplete ~= nil then
                    task.OnComplete(asset)
                end
            else
                ---这种情况可能是Clear被调用了，这时立即卸载已加载的文件
                Res.Unload(asset);
            end
        end)
    end
end

---添加一个任务
---@param assetPath string 资源路径（Assets/...）
---@param expire int 资产加载后存活多少秒
---@param onComplete fun(type:UObject) System.Action<UObject> 资产加载成功后的回调
function PreloadMgr.AddTask(assetPath, expire, onComplete)
    if string.isnilorempty(assetPath) then return false end

    if hasTask(assetPath) then
        ---任务已经存在
        return true
    end
    ---过期时间（秒），加载N秒后自动卸载
    expire = expire or 5
    local task = {AssetPath = assetPath, OnComplete = onComplete, Expire = expire}
    taskDict[assetPath] = task
    table.insert(taskList, task)
    return true
end

---删除一个任务
---@param assetPath string 资源路径（Assets/...）
---@return boolean
function PreloadMgr.RemoveTask(assetPath)
    if string.isnilorempty(assetPath) then return false end
    local task = taskDict[assetPath]
    if task ~= nil then
        taskDict[assetPath] = nil
        table.removebyvalue(taskList, task)
        return true
    end
    return false
end

---Update方法（被GameMgr.Update调用）
function PreloadMgr.Update()
    tryStartTask()

    ---卸载过期的资产
    local now = os.time()
    for k,v in ipairs(assetList) do
        if (now - v.Expire) >= 0 then
            Res.Unload(v.Asset)
        end
        table.remove(assetList, k)
    end
end

---清除所有数据
function PreloadMgr.Clear()
    for k,v in ipairs(assetList) do
        Res.Unload(v.Asset)
    end
    assetList = {}
    loadingList = {}
    taskDict = {}
    taskList = {}
end

return PreloadMgr