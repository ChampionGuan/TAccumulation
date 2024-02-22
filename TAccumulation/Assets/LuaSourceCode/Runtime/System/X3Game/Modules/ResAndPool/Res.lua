--- X3@PapeGames
--- 资源加载类
--- Created by Tungway
--- Created Date: 2020/8/27

---@class Res
local Res = {}
local this = Res

---资源释放模式
---@class AutoReleaseMode
AutoReleaseMode = {
    -- 手动释放
    None = 0,
    -- 加载一个GameObject对象，该对象销毁时即释放
    GameObject = 1,
    -- 随着当前场景释放
    Scene = 2,
    -- 下一帧
    EndOfFrame = 3
}

--xlua.import_type("ResType")
--CS.ResType = ResType
local CLS = CS.PapeGames.X3.Res
local CS_AutoReleaseMode = CS.PapeGames.X3.Res.AutoReleaseMode
local CS_FUNC_DESTROY = CS.UnityEngine.Object.Destroy
local CS_FUNC_DESTROY_IMMEDIATE = CS.UnityEngine.Object.DestroyImmediate

local assetPathDict = {}

---convert lua number to cs.enum
local function toCSAutoReleaseMode(val)
    val = val or AutoReleaseMode.None
    if type(val) == 'number' then
        return CS_AutoReleaseMode.__CastFrom(val)
    else
        return val
    end
end

---同步加载一个资源
---@param assetName string 资源名称
---@param resType ResType 资源类型
---@param autoReleaseMode AutoReleaseMode 自动释放模式
---@param assetType System.Type | string 资产类型
---@param refObj UnityEngine.Object 引用对象
---@param onComplete fun(type:UObject):void  加载资源完毕的回调
---@return UObject 加载的资源
function Res.Load(assetName, resType, autoReleaseMode, assetType, refObj, onComplete)
    local assetPath = Res.GetAssetPath(assetName, resType)
    return Res.LoadWithAssetPath(assetPath, autoReleaseMode, assetType, refObj, onComplete)
end

---异步加载一个资源
---@param assetName string 资源名称
---@param resType ResType 资源类型
---@param autoReleaseMode AutoReleaseMode 自动释放模式
---@param assetType System.Type | string  CS.System.Type or string 资产类型
---@param refObj UnityEngine.Object 引用对象
---@param onComplete fun(type:UObject):void 加载资源完毕的回调
function Res.LoadAsync(assetName, resType, autoReleaseMode, assetType, refObj, onComplete, onProgress)
    local assetPath = Res.GetAssetPath(assetName, resType)
    Res.LoadWithAssetPathAsync(assetPath, autoReleaseMode, assetType, refObj, onComplete, onProgress)
end

---同步加载一个GameObject资源（GameObject被Destroy则资源自动销毁）
---@param assetNameOrPath string 资源名称或完整路径
---@param resType ResType 资源类型（如果是完整路径则不需要此参数）
---@param onComplete fun(type:UObject):void  加载资源完毕的回调
---@return GameObject 加载的资源
function Res.LoadGameObject(assetNameOrPath, resType, onComplete)
    local assetPath = assetNameOrPath
    if resType ~= nil then
        assetPath = Res.GetAssetPath(assetNameOrPath, resType)
    end
    return Res.LoadWithAssetPath(assetPath, AutoReleaseMode.GameObject, typeof(CS.UnityEngine.GameObject), nil, onComplete)
end

---异步加载一个GameObject资源（GameObject被Destroy则资源自动销毁）
---@param assetNameOrPath string 资源名称或完整路径
---@param resType ResType 资源类型（如果是完整路径则不需要此参数）
---@param onComplete fun(type:UObject):void 加载资源完毕的回调
---@param onProgress fun(type:float):void 加载资源进度的回调
function Res.LoadGameObjectAsync(assetNameOrPath, resType, onComplete, onProgress)
    local assetPath = assetNameOrPath
    if resType ~= nil then
        assetPath = Res.GetAssetPath(assetNameOrPath, resType)
    end
    Res.LoadWithAssetPathAsync(assetPath, AutoReleaseMode.GameObject, typeof(CS.UnityEngine.GameObject), nil, onComplete, onProgress)
end

---同步加载一个资产（使用完整资产路径）
---@param assetPath string 资产全路径（Assets/...）
---@param autoReleaseMode AutoReleaseMode 自动释放模式
---@param assetType System.Type | string 资产类型
---@param refObj UnityEngine.Object 引用对象
---@param onComplete fun(type:UObject):void 加载资源完毕的回调
---@return UObject 加载的资源
function Res.LoadWithAssetPath(assetPath, autoReleaseMode, assetType, refObj, onComplete)
    autoReleaseMode = autoReleaseMode or AutoReleaseMode.None
    autoReleaseMode = toCSAutoReleaseMode(autoReleaseMode)
    assetType = assetType or typeof(CS.UnityEngine.Object)

    ---invoke cs function
    local asset = CLS.Load(assetPath, assetType, autoReleaseMode, refObj)
    ---exe callback
    if onComplete ~= nil then
        onComplete(asset)
    end
    if UNITY_EDITOR and assetType == typeof(CS.UnityEngine.Object) then
        CS.X3Game.ResLoadListener.Attach(asset, assetPath)
    end
    return asset
end

---异步加载一个资产（使用完整资产路径）
---@param assetPath string 资产全路径（Assets/...）
---@param autoReleaseMode AutoReleaseMode 自动释放模式
---@param assetType System.Type | string 资产类型
---@param refObj UnityEngine.Object 引用对象
---@param onComplete fun(type:UObject):void 加载资源完毕的回调
---@param onProgress fun(type:float):void 加载资源进度的回调
function Res.LoadWithAssetPathAsync(assetPath, autoReleaseMode, assetType, refObj, onComplete, onProgress)
    autoReleaseMode = autoReleaseMode or AutoReleaseMode.None
    autoReleaseMode = toCSAutoReleaseMode(autoReleaseMode)
    assetType = assetType or typeof(CS.UnityEngine.Object)

    ---invoke cs function
    CLS.LoadAsync(assetPath, assetType, onComplete, onProgress, autoReleaseMode, refObj)
end

---同步加载Texture2D
---@param assetName string 资源名称
---@param resType ResType 资源类型
---@param autoReleaseMode AutoReleaseMode 自动释放模式
---@param refObj UObject 引用对象
---@param onComplete fun(type:UObject):void 加载资源完毕的回调
---@return Texture2D 加载的Texture2D资产
function Res.LoadTexture2D(assetName, resType, autoReleaseMode, refObj, onComplete)
    local assetPath = Res.GetAssetPath(assetName, resType)
    return Res.LoadWithAssetPath(assetPath, autoReleaseMode, typeof(CS.UnityEngine.Texture2D), refObj, onComplete)
end

---同步加载壳文件
---@param assetPath string 资产全路径
---@param autoReleaseMode AutoReleaseMode 自动释放模式
---@param refObj UObject 引用对象
---@param onComplete fun(type:UObject):void 加载资源完毕的回调
---@return Texture2D 加载的Texture2D资产
function Res.LoadFromShell(assetPath, autoReleaseMode, refObj, onComplete)
    ----本功能已废弃
    return nil
end

---同步加载二进制文件（文本文件），资源会在下一帧释放
---@param assetPath string 资产全路径
---@return byte[]
function Res.LoadBytes(assetPath)
    if string.isnilorempty(assetPath) then
        return nil
    end
    local bytes = CLS.LoadBytes(assetPath)
    return bytes
end

---同步加载场景
---@param sceneName string 场景名
---@param loadSceneMode UnityEngine.SceneManagement.LoadSceneMode 场景加载模式
function Res.LoadScene(sceneName, loadSceneMode)
    loadSceneMode = loadSceneMode or CS.UnityEngine.SceneManagement.LoadSceneMode.Single
    CLS.LoadScene(sceneName, loadSceneMode)
end

---异步加载场景
---@param sceneName string 场景名
---@param loadSceneMode UnityEngine.SceneManagement.LoadSceneMode 场景加载模式
---@param onComplete fun(type:boolean):void 加载完成的回调
---@param onProgress fun(type:float):void 加载进度的回调
function Res.LoadSceneAsync(sceneName, loadSceneMode, onComplete, onProgress)
    loadSceneMode = loadSceneMode or CS.UnityEngine.SceneManagement.LoadSceneMode.Single
    CLS.LoadSceneAsync(sceneName, loadSceneMode, onComplete, onProgress)
end

---同步加载场景
---@param scenePath string 场景路径（Assets/...）
---@param loadSceneMode UnityEngine.SceneManagement.LoadSceneMode 场景加载模式
function Res.LoadSceneWithPath(scenePath, loadSceneMode)
    loadSceneMode = loadSceneMode or CS.UnityEngine.SceneManagement.LoadSceneMode.Single
    CLS.LoadSceneWithPath(scenePath, loadSceneMode)
end

---异步加载场景
---@param scenePath string 场景路径（Assets/...）
---@param loadSceneMode UnityEngine.SceneManagement.LoadSceneMode 场景加载模式
---@param onComplete fun(type:boolean):void 加载完成的回调
---@param onProgress fun(type:float):void 加载进度的回调
function Res.LoadSceneWithPathAsync(scenePath, loadSceneMode, onComplete, onProgress)
    loadSceneMode = loadSceneMode or CS.UnityEngine.SceneManagement.LoadSceneMode.Single
    CLS.LoadSceneWithPathAsync(scenePath, loadSceneMode, onComplete, onProgress)
end

---激活场景且设置为“当前”场景
---@param sceneName string 场景名
---@param onComplete fun():void 完成后的回调
function Res.SetActiveScene(sceneName, onComplete)
    CLS.SetActiveScene(sceneName, onComplete)
end

---卸载已加载的资源文件
---@param asset UObject 资产文件
---@return boolean 是否卸载成功
function Res.Unload(asset)
    if not asset then
        return false
    end
    return CLS.Unload(asset)
end

---将资产与外部引用对象关联
---@param asset UObject 已加载的资源
---@param refObj UObject 引用资源对象
---@return boolean 本次操作是否成功
function Res.AddRefObj(asset, refObj)
    if (not asset) or (not refObj) then
        return false
    end
    return CLS.AddRefObj(asset, refObj)
end

---将资产与外部引用对象解绑
---@param asset UObject 已加载的资源
---@param refObj UObject 引用资源对象
---@return boolean 本次操作是否成功
function Res.RemoveRefObj(asset, refObj)
    if (not asset) or (not refObj) then
        return false
    end
    return CLS.RemoveRefObj(asset, refObj)
end

---添加资产引用计数
---@param asset UObject 已加载的资源
---@param num int
function Res.AddRefCount(asset, num)
    if (not asset) then
        return false
    end
    return CLS.AddRefCount(asset, num)
end

---减少资产引用计数
---@param asset UObject 已加载的资源
---@param num int
function Res.SubRefCount(asset, num)
    if (not asset) then
        return false
    end
    return CLS.SubRefCount(asset, num)
end

---只有在ABUnload(false)阶段才需要调用此函数销毁Obj
---@param asset UObject
function Res.DestroyObj(asset)
    CS_FUNC_DESTROY(asset)
end

--[[
当unloadABAndUnloadAsset为true时，释放AB会同时卸载资产，此时按AutoReleaseMode.GameObject加载的资产会从池里走。
当unloadABAndUnloadAsset为false时，释放AB时不会卸载资产，此时按AutoReleaseMode.GameObject加载的资产不会如池，且AB会在下帧自动释放。
]]--
---卸载AB同时释放资产
---@param unloadABAndUnloadAsset bool
function Res.SetABUnloadParameter(unloadABAndUnloadAsset)
    CLS.SetABUnloadParameter(unloadABAndUnloadAsset)
end

---卸载AB同时释放资产
---@return bool
function Res.GetABUnloadParameter(unloadABAndUnloadAsset)
    return CLS.ABUnloadParameter
end

---丢弃一个GameObject对象或者返回池
---@param go GameObject 要丢弃的对象
function Res.DiscardGameObject(go)
    if (go ~= nil) then
        CLS.DiscardGameObject(go)
    end
end

---卸载无用的资源(立即调用)
function Res.UnloadUnusedLoaders()
    CLS.UnloadUnusedLoaders()
end

---卸载All
function Res.ForceUnloadAllLoaders()
    CLS.ForceUnloadAllLoaders()
end

---卸载依赖场景加载出来的资源
function Res.DestroySceneRefObj()
    CLS.DestroySceneRefObj()
end

---进入空场景并卸载所有资源
function Res.EnterEmptyAndUnloadUnUsed()
    Res.LoadScene("Empty")
    Res.UnloadUnusedLoaders()
end

---根据资源名称和资源类型获取资源全路径（Assets/...）
---@param assetName string 资源名称
---@param resType ResType 资源类型（参照ResType）
---@return string 资源全路径
function Res.GetAssetPath(assetName, resType)
    if (not assetName) or (not resType) then
        return nil
    end

    local ret = nil
    if (assetPathDict[resType] == nil) then
        assetPathDict[resType] = {}
    end
    ret = assetPathDict[resType][assetName]
    if (ret ~= nil) then
        return ret
    end

    if string.find(assetName, ".", 1, true) == nil then
        ret = string.format("%s%s%s", ResConst.AssetPath[resType], assetName, ResConst.Ext[resType])
    else
        ret = string.format("%s%s", ResConst.AssetPath[resType], assetName)
    end
    assetPathDict[resType][assetName] = ret;
    return ret
end

---根据SceneName获取ScenePath
---@param sceneName string
---@return string ScenePath
function Res.GetScenePath(sceneName)
    if (not sceneName) then
        return nil
    end
    local ret = CLS.GetScenePath(sceneName)
    return ret
end

function Res.GetSceneType(sceneName)
    if (not sceneName) then
        return nil
    end
    local ret = CLS.GetSceneType(sceneName)
    return ret
end

---设置每帧同时释放的ab数量
---@param count int
function Res.SetFileLoaderMaxReleaseCount(count)
    CLS.SetFileLoaderMaxReleaseCount(count)
end

---设置语言版本
---@param lang int
function Res.SetLanguage(lang)
    CLS.SetLanguage(lang)
end

---设置语音版本
---@param lang int
function Res.SetSoundLanguage(lang)
    CLS.SetSoundLanguage(lang)
end

---设置Fallback语言
---@param region int
---@param lang int
function Res.AddFallbackLang(region, lang)
    CLS.AddFallbackLang(region, lang)
end

---设置默认语言
---@param region int
---@param lang int
function Res.AddDefaultLang(region, lang)
    CLS.AddDefaultLang(region, lang)
end

---设置是否可用
---@param available bool
function Res.SetAvailable(available)
    CLS.Available = available
end

---设置是否异步实例化
---@param value bool
function Res.SetInstantiateAsync(value)
    CLS.InstantiateAsync = value
end

---返回是否开启了异步实例化
---@return bool
function Res.GetInstantiateAsync()
    return CLS.InstantiateAsync
end

---检测文件是否存在
---@param path string 完整Asset路径
---@param includeDependencies boolean
function Res.IsAssetFileExist(path, includeDependencies)
    if string.isnilorempty(path) then
        return false
    end
    includeDependencies = includeDependencies or false
    return CLS.IsAssetFileExist(path, includeDependencies)
end

---初始化
function Res.Init()
    local funcUpdateRelativePathDict = CLS.UpdateRelativePathDict
    for resType, relativePath in pairs(ResConst.AssetPath) do
        funcUpdateRelativePathDict(resType, relativePath)
    end

    local funcUpdateFileExtDict = CLS.UpdateFileExtDict
    for resType, fileExt in pairs(ResConst.Ext) do
        funcUpdateFileExtDict(resType, fileExt)
    end
    CLS.SetDelegate(this)
end

function Res.ForceInit()
    X3AssetInsProvider.DestroyPoolAllLifeMode()
    Res.Destroy()
    CLS.Init()
    Res.Init()
end

---清除（一般重启游戏后需要调用此方法）
function Res.Destroy()
    CLS.Destroy()
    CLS.SetDelegate(nil)
    assetPathDict = {}
end

---清除
function Res.Clear()
    assetPathDict = {}
end

--region Delegate
function Res.OnSceneLoadBegin(self, sceneName)
    EventMgr.Dispatch(Const.Event.SCENE_BEGIN_LOAD, sceneName)
end

function Res.OnSceneLoadComplete(self, sceneName)
    EventMgr.Dispatch(Const.Event.SCENE_LOAD_COMPLETE, sceneName)
end

function Res.OnSceneLoaded(self, sceneName)
    EventMgr.Dispatch(Const.Event.SCENE_LOADED, sceneName)
end

function Res.OnSceneUnloaded(self, sceneName)
    EventMgr.Dispatch(Const.Event.SCENE_UNLOADED, sceneName)
end
--endregion

return Res