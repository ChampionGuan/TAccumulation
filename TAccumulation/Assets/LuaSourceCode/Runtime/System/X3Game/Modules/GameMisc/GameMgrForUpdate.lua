--- X3@PapeGames
--- GameMgr
--- 本类用来作为获取引擎的各种事件或Update调用的入口
--- 事件更新的顺序依次为：Update -> LateUpdate -> FinalUpdate

local GameDataBridge = require("Runtime.System.X3Game.Modules.GameDataBridge.GameDataBridge")

local GameMgr = {}

---Update
local updateMap = {}
---当前帧数
local frameCount = 0
---是否登录进入游戏
local enterGame = false

---@class UpdateType
local UpdateType =
{
    OnPreUpdate = 1,
    OnFixedUpdate = 2,
    OnUpdate = 3,
    OnPreLateUpdate = 4,
    OnLateUpdate = 5,
    OnPreFinalUpdate = 6,
    OnFinalUpdate = 7,
}

local DoUpdateByType

---@param dt float
---@param realtimeSinceStartup float
function GameMgr:OnPreUpdate(dt, realtimeSinceStartup)
    DoUpdateByType(UpdateType.OnPreUpdate , dt , realtimeSinceStartup)
    frameCount = frameCount + 1
end

---@param dt float
---@param realtimeSinceStartup float
function GameMgr:OnFixedUpdate(dt, realtimeSinceStartup)
    DoUpdateByType(UpdateType.OnFixedUpdate , dt , realtimeSinceStartup)
end

---引擎的Update
--- dt float delta time
---@param dt float
function GameMgr:OnUpdate(dt, realtimeSinceStartup)
    DoUpdateByType(UpdateType.OnUpdate , dt , realtimeSinceStartup)
end

---@param dt float
---@param realtimeSinceStartup float
function GameMgr:OnPreLateUpdate(dt, realtimeSinceStartup)
    DoUpdateByType(UpdateType.OnPreLateUpdate , dt , realtimeSinceStartup)
end

---引擎的LateUpdate
---@param dt float
function GameMgr:OnLateUpdate(dt, realtimeSinceStartup)
    DoUpdateByType(UpdateType.OnLateUpdate , dt , realtimeSinceStartup)
end

--region Canvas.preWillRenderCanvases
---此函数依赖Canvas.preWillRenderCanvases，这里不要设置属性，尽量只处理资产销毁等逻辑
---@param dt float
---@param realtimeSinceStartup float
function GameMgr:OnPreFinalUpdate(dt, realtimeSinceStartup)
    DoUpdateByType(UpdateType.OnPreFinalUpdate , dt , realtimeSinceStartup)
end

---此函数依赖Canvas.preWillRenderCanvases，这里不要设置属性，尽量只处理资产销毁等逻辑
---@param dt float
---@param realtimeSinceStartup float
function GameMgr:OnFinalUpdate(dt, realtimeSinceStartup)
    ---释放临时temp
    Vector2.ReleaseTemps()
    Vector3.ReleaseTemps()
    Vector4.ReleaseTemps()
end

---获取已经持续的帧数(Time.frameCount)
---@return int
function GameMgr.GetFrameCount()
    return frameCount
end
--endregion

DoUpdateByType = function(updateType , dt , realtimeSinceStartup)
    local updateList = updateMap and updateMap[updateType] or nil
    if updateList then
        for _, update in ipairs(updateList) do
            update(dt , realtimeSinceStartup)
        end
    end
end

---设置是否进入游戏
function GameMgr.EnterGame()
    enterGame = true
end

---初始化UpdateMap
function GameMgr.Init()
    updateMap =
    {
        [UpdateType.OnPreUpdate] = {
            TimerMgr.Update,
            GameStateMgr.Tick
        },
        [UpdateType.OnFixedUpdate] = {
            TimerMgr.FixedUpdate,
            FSMMgr.FixedUpdate,
            GamePlayMgr.FixedUpdate,
        },
        [UpdateType.OnUpdate] = {
            PreloadMgr.Update,
            PreloadBatchMgr.Update,
            FSMMgr.Update,
            DialogueManager.Update,
            GameDataBridge.Tick,
            FxMgr.OnUpdate,
            DateManager.DateUpdate,
            GamePlayMgr.Update,
            AIMgr.Update,
            LuaCfgMgr.Tick,
        },
        [UpdateType.OnPreLateUpdate] = {
            TimerMgr.LateUpdate,
            ErrandMgr.LateUpdate
        },
        [UpdateType.OnLateUpdate] = {
            FxMgr.OnLateUpdate,
            FSMMgr.LateUpdate
        },
        [UpdateType.OnPreFinalUpdate] = {
            TimerMgr.FinalUpdate,
        },
        [UpdateType.OnFinalUpdate] = {
        },
    }
end

function GameMgr.AddUpdateMap(fun)
    table.insert(updateMap[UpdateType.OnUpdate] , fun)
end

function GameMgr.RemoveUpdateMap(fun)
    for i, v in pairs(updateMap[UpdateType.OnUpdate]) do
        if v == fun then
            table.remove(updateMap[UpdateType.OnUpdate], i)
            break
        end
    end
end

function GameMgr.Clear()
    updateMap = nil
end

return GameMgr