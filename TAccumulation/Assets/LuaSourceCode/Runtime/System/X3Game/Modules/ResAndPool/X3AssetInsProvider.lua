--- X3@PapeGames
--- GameObject资产实例提供器
--- Created by Tungway
--- Created Date: 2021/06/02

---@class X3AssetInsProvider
local X3AssetInsProvider = {}
local this = X3AssetInsProvider
local CLS_PROVIDER = CS.PapeGames.X3.X3AssetInsProvider
local CLS_PROVIDER_INS = CLS_PROVIDER.Instance
---@class GameObjectPoolLifeMode
---@field Normal = 1,
---@field Temp = 2,
---@field Long = 4,
---@field Persistent = 8,
---@field All = Normal | Temp | Long | Persistent
local GameObjectPoolLifeMode = CS.PapeGames.X3.GameObjectPoolLifeMode
local inited = false

function X3AssetInsProvider.Init()
    if (inited) then
        return
    end
    CLS_PROVIDER.ManualUpdate = false
    inited = true
end

function X3AssetInsProvider.Clear()
    inited = false
end

function X3AssetInsProvider.Destroy()
    X3AssetInsProvider.Clear()
end

---清理cs的加载资产
function X3AssetInsProvider.CSClear()
    CLS_PROVIDER.Clear()
end

---根据roleBaseKey, partKeys获取一个角色GameObject实例
---@param roleBaseKey String 基础模型
---@param partKeys String[] 部件数组
---@param filterPartTypes Int[] 要过滤的部件Type
---@return GameObject
function X3AssetInsProvider.GetCharacterIns(roleBaseKey, partKeys, filterPartTypes)
    local ins = CharacterMgr.GetInsSync(roleBaseKey, partKeys, filterPartTypes)
    return ins
end

---根据套装获取一个角色GameObject实例
---@param suitKey String 套装名
---@param GameObject
function X3AssetInsProvider.GetCharacterInsWithSuitKey(suitKey)
    local ins = CharacterMgr.GetInsWithSuitKeySync(suitKey)
    return ins
end

---根据ModelKey获取一个GameObject实例
---@param modelKey string
---@return GameObject
function X3AssetInsProvider.GetInsWithModelKey(modelKey)
    local ins = CLS_PROVIDER_INS:GetInsWithModelKey(modelKey)
    return ins
end

---根据assetPath获取一个GameObject实例
---@param assetPath string
---@return GameObject
function X3AssetInsProvider.GetInsWithAssetPath(assetPath, forceGet)
    forceGet = forceGet or false
    local ins = CLS_PROVIDER_INS:GetInsWithAssetPath(assetPath, forceGet)
    return ins
end

---@param prefab GameObject
---@param lifeMode GameObjectPoolLifeMode
---@param forceGet bool
---@return GameObject
function X3AssetInsProvider.GetInsWithPrefab(prefab, lifeMode, forceGet)
    if lifeMode == nil then
        lifeMode = GameObjectPoolLifeMode.Temp
    end
    if forceGet == nil then
        forceGet = false
    end
    local ins = CLS_PROVIDER_INS:GetInsWithPrefab(prefab, lifeMode, forceGet)
    return ins
end

---归还一个GameObject实例
---@param ins GameObject
---@param restoreTFInfos boolean 是否恢复被改变的Transform信息
---@return boolean 是否归还成功
function X3AssetInsProvider.ReleaseIns(ins, restoreTFInfos)
    restoreTFInfos = restoreTFInfos or false
    local ret = CLS_PROVIDER_INS:ReleaseIns(ins, restoreTFInfos)
    return ret
end

---根据AssetId获取一个注入的GameObject实例
---@param assetId int
---@return GameObject
function X3AssetInsProvider.GetInjectedIns(assetId)
    local ins = CLS_PROVIDER_INS:GetInjectedIns(assetId)
    return ins
end

---归还一个注入的GameObject实例
---@param ins GameObject
---@return boolean 是否归还成功
function X3AssetInsProvider.ReleaseInjectedIns(ins)
    local ret = CLS_PROVIDER_INS:ReleaseInjectedIns(ins)
    return ret
end

---X3Animator注入AssetId和GameObject实例
---@param assetId int
---@param ins GameObject
function X3AssetInsProvider.InjectAssetIns(assetId, ins)
    if ins == nil then
        return
    end
    local ret = CLS_PROVIDER_INS:InjectAssetIns(assetId, ins)
    return ret
end

---X3Animator移除注入的GameObject实例
---@param ins GameObject
---@param force bool
function X3AssetInsProvider.RemoveAssetIns(ins, force)
    if ins == nil then
        return
    end
    if force == nil then
        force = false
    end
    local ret = CLS_PROVIDER_INS:RemoveAssetIns(ins, force)
    return ret
end

function X3AssetInsProvider.IsUsed(ins)
    return CLS_PROVIDER_INS:IsUsed(ins)
end

---销毁GameObjectPoolLifeMode.Temp | GameObjectPoolLifeMode.Normal生命周期的池
function X3AssetInsProvider.DestroyPoolWhileSceneChanged()
    CLS_PROVIDER_INS:DestroyPoolWhileSceneChanged()
end

---销毁所有生命周期的池
function X3AssetInsProvider.DestroyPoolAllLifeMode()
    CLS_PROVIDER_INS:DestroyPoolAllLifeMode()
end

---设置是否开启缓存
---@param enable bool 是否开启
function X3AssetInsProvider.SetCacheEnable(enable)
    CLS_PROVIDER_INS.CacheEnable = enable
end

return X3AssetInsProvider