--- Runtime.System.Framework.GameBase.Res.SceneMgr
--- Created by 教主
--- DateTime:2021/5/19 11:50

---@class SceneMgr
local SceneMgr = {}
local LoadingSceneFinish, SetLoadingEnable, Init2DBackGround
local LoadingSceneName = ""
local LoadingFinishCall = nil
local LoadingType = nil
local CS_SceneMgr = CS.X3Game.SceneMgr
local CS_Res = CS.PapeGames.X3.Res
local CS_CharacterLightingProvider = CS.PapeGames.Rendering.CharacterLightingProvider
local isSceneObjsActive = true
local isLoading = false
local holdingSceneName = nil

local scene2DBGRenderer = nil --2D背景的Material
local scene2DBGDefaultTexture = nil --2D背景默认的贴图，用于Reset
local externalCloseUI = nil --外部控制关闭UI标记
local skipGCOnce = false

---@type table<string, int> 已播放的fx列表
local fxDict = nil
---@type table<string, boolean> 已播放的ppv列表
local ppvDict = nil
---@type table<string, int> 背景图路径转id列表
local scene2DBgDict = nil
---@type int 当前的2D场景ID
local curScene2DId = 0

local BG_Path = "Assets/Build/Res/GameObjectRes/Scene/Dynamic2DBackground/%s.png";
local FX_Path = "Assets/Build/Art/Fx/Prefab/Performance/AvgShow/%s.prefab";
local PPVAnim_Path = "Assets/Build/Art/Lightings/ppv_AniClip/%s.anim"
local DirectorWrapMode = CS.UnityEngine.Playables.DirectorWrapMode
local DirectorUpdateMode = CS.UnityEngine.Playables.DirectorUpdateMode
---@class SceneFxType
local SceneFxType = {
    None = 1,
    SyncCameraXY = 2,
}

---异步切换场景
---@param sceneName string 场景名称，对应SceneInfo表的SceneName，并非资源名
---@param loadSceneMode UnityEngine.SceneManagement.LoadSceneMode
---@param loadingType GameConst.LoadingType
---@param finishCall fun()
---@param isExternalCloseUI bool 外部控制关闭UI
function SceneMgr.LoadSceneAsync(sceneName, loadSceneMode, loadingType, finishCall, isExternalCloseUI)
    if CS_Res.CurSceneName == sceneName then
        if finishCall then
            finishCall()
        end
        return
    end
    LoadingFinishCall = finishCall
    LoadingSceneName = sceneName
    LoadingType = loadingType
    externalCloseUI = isExternalCloseUI
    loadSceneMode = loadSceneMode or CS.UnityEngine.SceneManagement.LoadSceneMode.Single
    loadingType = loadingType or GameConst.LoadingType.Common
    SetLoadingEnable(loadingType, loadingType ~= GameConst.LoadingType.None)
    ResBatchLoader.ClearTasks()
    ResBatchLoader.AddSceneTask(sceneName, 1.0, loadSceneMode)
    ResBatchLoader.LoadAsync(GameConst.LoadingType.None, false, LoadingSceneFinish)
end

---同步切换场景
---@param sceneName string 场景名称，对应SceneInfo表的SceneName，并非资源名
---@param loadSceneMode UnityEngine.SceneManagement.LoadSceneMode
---@param loadingType GameConst.LoadingType
---@param finishCall fun()
---@param isExternalCloseUI bool 外部控制关闭UI
function SceneMgr.LoadScene(sceneName, loadSceneMode, loadingType, finishCall, isExternalCloseUI)
    if CS_Res.CurSceneName == sceneName then
        if finishCall then
            finishCall()
        end
        return
    end
    LoadingFinishCall = finishCall
    LoadingSceneName = sceneName
    LoadingType = loadingType
    externalCloseUI = isExternalCloseUI
    loadSceneMode = loadSceneMode or CS.UnityEngine.SceneManagement.LoadSceneMode.Single
    loadingType = loadingType or GameConst.LoadingType.Common
    SetLoadingEnable(loadingType, loadingType ~= GameConst.LoadingType.None)
    Res.LoadScene(sceneName, loadSceneMode)
    LoadingSceneFinish()
end

---@return string 场景名称
function SceneMgr.GetCurScene()
    return CS_Res.CurSceneName
end

---获取场景第一层级GameObject
---@param name string GameObject名称，不支持路径查找，如需路径查找，获取GameObject之后通过GameObjectUtil.GetComponent()获取
---@return GameObject
function SceneMgr.GetSceneObj(name)
    return CS_SceneMgr.GetSceneObj(name)
end

---场景底是否显示
function SceneMgr.IsSceneObjActive()
    return isSceneObjsActive
end

---动态添加场景obj，部分UI开启时会需要隐藏场景的3D部分，添加进此列表会享受到此机制
---@param obj GameObject
function SceneMgr.AddSceneObj(obj)
    if obj ~= nil then
        CS_SceneMgr.AddSceneObj(obj)
        EventMgr.Dispatch(Const.Event.SET_SCENE_OBJS_ACTIVE, isSceneObjsActive, true)
    end
end

---场景prefab
---@param prefabObj GameObject
function SceneMgr.AddSceneRootObj(prefabObj)
    if prefabObj then
        CS_SceneMgr.AddSceneRootObj(prefabObj)
    end
end

---动态删除场景obj
---@param obj GameObject
function SceneMgr.RemoveSceneObj(obj)
    if obj ~= nil then
        CS_SceneMgr.RemoveSceneObj(obj)
    end
end

---激活某个加载完的场景，当LoadSceneMode为Additive时才有用
---@param sceneName string 激活场景
function SceneMgr.SetActiveScene(sceneName)
    CS.PapeGames.X3.Res.SetActiveScene(sceneName)
end

---废弃缓存的场景
---@param sceneName string
function SceneMgr.DiscardScene(sceneName)
    CS.PapeGames.X3.Res.UnloadScene(sceneName)
end

---切换GC开关
---@param value
function SceneMgr.SkipGCOnce(value)
    Debug.LogFormat("SkipGCOnce-%s", value)
    skipGCOnce = value
end

LoadingSceneFinish = function(isSuccess)
    CS.PapeGames.X3.Res.SetActiveScene(LoadingSceneName)

    Init2DBackGround()

    if LoadingFinishCall then
        LoadingFinishCall()
    end

    if not externalCloseUI then
        TimerMgr.AddTimer(TimerMgr.GetCurTickDelta() * 2, function()
            SetLoadingEnable(LoadingType, false)
        end)
    end
end

SetLoadingEnable = function(...)
    UICommonUtil.SetLoadingEnable(...)
end

local function OnSceneLoaded(sceneName)
    LoadingSceneName = sceneName
    scene2DBGRenderer = nil
    isLoading = false
    CS_SceneMgr.ClearObjs()
    SceneMgr.ClearScene2DEffect()
    curScene2DId = 0
    local root = CS.PapeGames.X3.Res.GetSceneRoot()
    ---从池里加载出来坐标会不对
    GameObjectUtil.SetPosition(root, 0, 0, 0)
    SceneMgr.AddSceneRootObj(root)
    Debug.LogFormat("OnSceneLoaded-%s", sceneName)
    if isSceneObjsActive ~= nil then
        EventMgr.Dispatch(Const.Event.SET_SCENE_OBJS_ACTIVE, isSceneObjsActive, true)
    end

    if skipGCOnce == false then
        DialogueManager.UnloadUnusedAsset()
        LuaUtil.GC()
        X3AssetInsProvider.DestroyPoolWhileSceneChanged()
        CS.UnityEngine.Resources.UnloadUnusedAssets()
        CS.System.GC.Collect()
    else
        skipGCOnce = false
    end
    CrashSightMgr.SetCurSceneName(sceneName)
    PerformanceLog.ReportScene(CS.PapeGames.X3.Res.PrevSceneName, sceneName)
end

local function OnSceneBeginLoad(sceneName)
    --Additive模式下加载场景也会有这个事件，但是没有OnSceneLoaded事件，会导致SetObj卡住
    --isLoading = true
    WwiseMgr.UnloadUnusedBanks()
    WwiseMgr.CollectReservedMemory()
    Debug.LogFormat("OnSceneBeginLoad-%s", sceneName)
    --isSceneObjsActive = nil
    ---清理CutSceneAssetInsProvider记录的物件骨骼的初始姿势
    ---CS.PapeGames.X3.CutSceneAssetInsProvider.ClearTransformPoses()
end

---设置场景GameObjace显示和隐藏
local function SetSceneObjsActive(active, is_force)
    if not is_force and isSceneObjsActive == active then
        return
    end
    Debug.LogFormat("SetSceneObjsActive-%s-Step%s", active, 1)
    isSceneObjsActive = active
    if isLoading then
        return
    end
    local currentProvider = nil
    --场景激活前记录一下LightingProvider
    if active then
        currentProvider = CS_CharacterLightingProvider.Current
    end
    Debug.LogFormat("SetSceneObjsActive-%s-Step%s", active, 2)
    CS_SceneMgr.SetSceneObjsActive(active)
    PostProcessVolumeMgr.SwitchAnimPPVActive(active)
    --激活场景前后灯光方案如果发生了改变，就再次激活下原有的LightingProvider
    if GameObjectUtil.IsNull(currentProvider) == false and currentProvider ~= CS_CharacterLightingProvider.Current then
        --晚Enable的生效，目前只有这个方法可以让灯光方案生效
        GameObjectUtil.SetActive(currentProvider, false)
        GameObjectUtil.SetActive(currentProvider, true)
    end
    EventMgr.Dispatch(Const.Event.SCENE_OBJ_ACTIVE_CHANGED, active)
end

local function OnSceneLoadComplete(sceneName)

end

---
function SceneMgr.HoldCurSceneGO()
    if string.isnilorempty(holdingSceneName) == false then
        SceneMgr.ClearHoldingScene()
    end
    holdingSceneName = SceneMgr.GetCurScene()
    CS_Res.SetSceneLifeTime(holdingSceneName, 60 * 60)
end

---
function SceneMgr.ClearHoldingScene()
    if string.isnilorempty(holdingSceneName) == false then
        CS_Res.SetSceneLifeTime(holdingSceneName, 0)
    end
end

function SceneMgr.Init()
    EventMgr.AddListener(Const.Event.SCENE_LOADED, OnSceneLoaded)
    EventMgr.AddListener(Const.Event.SCENE_BEGIN_LOAD, OnSceneBeginLoad)
    EventMgr.AddListener(Const.Event.SET_SCENE_OBJS_ACTIVE, SetSceneObjsActive)
    EventMgr.AddListener(Const.Event.SCENE_LOAD_COMPLETE, OnSceneLoadComplete)
    skipGCOnce = false
    fxDict = {}
    ppvDict = {}
    scene2DBgDict = {}
    local cfgAll = LuaCfgMgr.GetAll("Scene2DInfo")
    for k, v in pairs(cfgAll) do
        scene2DBgDict[string.format(BG_Path, v.SceneName)] = k
    end

end

function SceneMgr.Clear()
    EventMgr.RemoveListener(Const.Event.SCENE_LOADED, OnSceneLoaded)
    EventMgr.RemoveListener(Const.Event.SCENE_BEGIN_LOAD, OnSceneBeginLoad)
    EventMgr.RemoveListener(Const.Event.SET_SCENE_OBJS_ACTIVE, SetSceneObjsActive)
    EventMgr.RemoveListener(Const.Event.SCENE_LOAD_COMPLETE, OnSceneLoadComplete)
    SceneMgr.ClearScene2DEffect()
    CS_SceneMgr.ClearObjs()
end

---播放PPV动画
---@param name string
function SceneMgr.PlayPPVAnim(name)
    if not ppvDict[name] then
        local clip = Res.LoadWithAssetPath(string.format(PPVAnim_Path, name), AutoReleaseMode.Scene)
        PostProcessVolumeMgr.PlayAnimState(name, clip, DirectorWrapMode.Loop, DirectorUpdateMode.GameTime)
        ppvDict[name] = true
    end
end

---关闭PPV动画
---@param name string
function SceneMgr.StopPPVAnim(name)
    if ppvDict[name] then
        PostProcessVolumeMgr.RemoveAnimState(name)
        ppvDict[name] = nil
    end
end

---播放SceneFx动画
---@param name string Fx名字，将统一拼接路径
---@param parent Transform 父容器，不需要就传nil
---@param fadeDuration float 过度时长，-1为默认
---@return int
function SceneMgr.PlaySceneFx(name, parent, fadeDuration)
    if fxDict[name] == nil then
        local path = string.format(FX_Path, name)
        fxDict[name] = FxMgr.PlayFx(path, parent, fadeDuration)
    end
    local sceneFx = LuaCfgMgr.Get("SceneFx", name)
    if sceneFx and sceneFx.Type == SceneFxType.SyncCameraXY then
        local fxGameObject = FxMgr.GetFxGameObjIns(fxDict[name])
        if fxGameObject then
            GameObjectCtrl.GetOrAddCtrl(fxGameObject, "Runtime.System.X3Game.Modules.Scene.SceneFxSyncCtrl")
        end
    end
    return fxDict[name]
end

---停止SceneFx动画
---@param name string
---@param fadeDuration float 过度时长，-1为默认
function SceneMgr.StopSceneFx(name, fadeDuration)
    local playingId = fxDict[name]
    if playingId then
        FxMgr.StopFx(playingId, fadeDuration)
        fxDict[name] = nil
    end
end

---清除所有的2D场景效果
function SceneMgr.ClearScene2DEffect()
    if fxDict then
        for name, _ in pairs(fxDict) do
            SceneMgr.StopSceneFx(name, 0)
        end
    end
    if ppvDict then
        for name, _ in pairs(ppvDict) do
            SceneMgr.StopPPVAnim(name)
        end
    end
    PostProcessVolumeMgr.DeactiveAllAnimPPV()
    table.clear(fxDict)
    table.clear(ppvDict)
end

---清理场景自带的效果
---@param id int
function SceneMgr.ClearSceneInitEffect(id)
    local scene2DInfo = LuaCfgMgr.Get("Scene2DInfo", id)
    if scene2DInfo then
        if scene2DInfo.InitialFx then
            for _, name in pairs(scene2DInfo.InitialFx) do
                SceneMgr.StopSceneFx(name, 0)
            end
        end
        if scene2DInfo.InitialPpv then
            for _, name in pairs(scene2DInfo.InitialPpv) do
                SceneMgr.StopPPVAnim(name)
            end
        end
    end
end

--region Scene2D
Init2DBackGround = function()
    local sceneInfo = LuaCfgMgr.Get("SceneInfo", LoadingSceneName)
    scene2DBGRenderer = nil
    scene2DBGDefaultTexture = nil
    if sceneInfo == nil or string.isnilorempty(sceneInfo.BackgroundNodePath) then
        return
    end

    local bgObject = CS.UnityEngine.GameObject.Find(sceneInfo.BackgroundNodePath)
    if bgObject then
        local render = GameObjectUtil.GetComponent(bgObject, nil, "MeshRenderer")
        scene2DBGRenderer = render
        scene2DBGDefaultTexture = render.sharedMaterial.mainTexture
    end
end
---手动设置背景物体
---@param nodePath string 背景结点名称
function SceneMgr.SetBGObject(nodePath)
    local bgObject = CS.UnityEngine.GameObject.Find(nodePath)
    if bgObject then
        local render = GameObjectUtil.GetComponent(bgObject, nil, "MeshRenderer")
        scene2DBGRenderer = render
        scene2DBGDefaultTexture = render.sharedMaterial.mainTexture
    end
end
---清理设置的背景，原则上只清理手动设置的背景
function SceneMgr.ClearBGObject()
    scene2DBGRenderer = nil
    scene2DBGDefaultTexture = nil
    curScene2DId = 0
end

---设置场景2D背景
---@param resPath string 2D背景路径
function SceneMgr.Set2DBG(resPath)
    if not scene2DBGRenderer then
        Init2DBackGround()
    end

    if scene2DBGRenderer then
        local texture = Res.LoadWithAssetPath(resPath, AutoReleaseMode.EndOfFrame, typeof(CS.UnityEngine.Texture))
        Res.AddRefObj(texture, scene2DBGRenderer)
        if texture then
            scene2DBGRenderer.material.mainTexture = texture
        end
    end
end

---恢复场景2D背景，用于需要还原的情况
function SceneMgr.Reset2DBG()
    --if not scene2DBGRenderer or GameObjectUtil.IsNull(scene2DBGDefaultTexture) then
    if GameObjectUtil.IsNull(scene2DBGRenderer) or GameObjectUtil.IsNull(scene2DBGDefaultTexture) then
        return
    end
    scene2DBGRenderer.material.mainTexture = scene2DBGDefaultTexture
end

---切2D场景
---@param id int
function SceneMgr.Change2DScene(id)
    if curScene2DId ~= id then
        SceneMgr.ClearSceneInitEffect(curScene2DId)
        local scene2DInfo = LuaCfgMgr.Get("Scene2DInfo", id)
        if scene2DInfo then
            curScene2DId = id
            SceneMgr.Set2DBG(string.format(BG_Path, scene2DInfo.SceneName))
            if scene2DInfo.InitialFx then
                for _, name in pairs(scene2DInfo.InitialFx) do
                    SceneMgr.PlaySceneFx(name, nil, 0)
                end
            end
            if scene2DInfo.InitialPpv then
                for _, name in pairs(scene2DInfo.InitialPpv) do
                    SceneMgr.PlayPPVAnim(name)
                end
            end
        end
    end
end

---根据背景图路径切2D场景
---@param assetPath string
function SceneMgr.Change2DSceneByPath(assetPath)
    local scene2DInfoId = SceneMgr.GetScene2DInfoId(assetPath)
    if scene2DInfoId then
        SceneMgr.Change2DScene(scene2DInfoId)
    else
        SceneMgr.Set2DBG(assetPath)
    end
end

---根据背景图路径获取Scene2DInfo的Id
---@param assetPath string
---@return int
function SceneMgr.GetScene2DInfoId(assetPath)
    return scene2DBgDict[assetPath]
end
--endregion

return SceneMgr