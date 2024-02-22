--- X3@PapeGames
--- CharacterMgr
--- Created by Tungway
--- Created Date: 2021/01/08

---@class CharacterMgr
local CharacterMgr = {}
local this = CharacterMgr
---Character枚举值
local CharacterEnum = require("Runtime.System.X3Game.Modules.Character.CharacterEnum")
local X3CHARACTER_TYPE = typeof(CS.X3.Character.X3Character)
local X3ANIMATOR_TYPE = typeof(CS.X3Game.X3Animator)
local PLAYABLEANIMATOR_TYPE = typeof(CS.X3.PlayableAnimator.PlayableAnimator)
local CUTSCENEPARTICIPANT_TYPE = typeof(CS.PapeGames.CutScene.CutSceneParticipant)
local CUTSCENEACTOR_TYPE = typeof(CS.PapeGames.CutScene.CutSceneActor)
local RENDERACTOR_TYPE = typeof(CS.PapeGames.Rendering.RenderActor)
local CHARACTER_MGR_CLS = CS.PapeGames.X3.CharacterMgr
local X3_ASSET_INS_PROVIDER = CS.PapeGames.X3.X3AssetInsProvider.Instance
local CharacterWave = require("Runtime.System.X3Game.Modules.Character.CharacterWave").new()

local FaceEditConst = require("Runtime.System.X3Game.GameConst.FaceEditConst")

local X3ANIMATOR_ASSET_PATH = "Assets/Build/Res/GameObjectRes/Entity/CharacterData/X3Animator/%s.asset"

-- 左手武器挂点
local HAND_LEFT_WEAPON_BONE_NAME = "HPoint_hand_L"
-- 右手武器挂点
local HAND_RIGHT_WEAPON_BONE_NAME = "HPoint_hand_R"

local INVALID_INS_RET = 0

--region local variables
local globalLOD = CharacterEnum.LOD.HD --HD = 0, LD = 1
local insList = setmetatable({}, { __mod = "v" })
local usedInsList = setmetatable({}, { __mod = "v" })
local insPoolDict = {}
local lastUnusedDict = setmetatable({}, { __mod = "kv" })
local releaseDelegate = {}
---缓存角色身上的部件数据
---@type table<int, string[]>
local cachedInsPartKeysDict = {}

---缓存InstanceID->AssetId字典
---@type table<int, int>
local cachedInsToAssetIdDict = {}

---即将取消的uid字典
---@type table<int, boolean>
local toCancelDict = {}
---@type table<GameObject>
local insList = {}

---是否可用（当此值为false时，不接受新加载需求，原先的加载回来后直接丢弃且不再调用回调函数）
---@type boolean
local available = true
local initUUID = 0

---@type boolean
local createInsGuard = false
---@type boolean
local removeInsGuard = false
---@type boolean
local changePartsGuard = false
--endregion

---@type function Player自定义发型的回调
local PlayerChangeHairDelegate = nil

local function createNewIns(roleBaseKey)
    local ins = require("Runtime.System.X3Game.Modules.Character.CharacterIns").new(roleBaseKey)
    return ins
end

local function createNewInsPool(roleBaseKey)
    local pool = require("Runtime.System.Framework.GameBase.Pool.InstancePool").new(roleBaseKey, roleBaseKey, createNewIns)
    return pool
end

---处理PartKeys
local function procPartKeysParams(partKeys, outPartKeys)
    local ret = nil
    if (partKeys == nil) then
        if outPartKeys ~= nil then
            return outPartKeys
        else
            return {}
        end
    end

    if outPartKeys == nil then
        if type(partKeys) ~= "table" then
            ret = { partKeys }
        else
            ret = table.clone(partKeys)
        end
    else
        if type(partKeys) ~= "table" then
            table.insert(outPartKeys, partKeys)
        else
            for _, v in pairs(partKeys) do
                table.insert(outPartKeys, v)
            end
        end
        ret = outPartKeys
    end

    return ret
end

---获取RoleBase的配置文件
---@param roleBaseKey String
local function getRoleBaseCfg(roleBaseKey)
    local roleCfg = LuaCfgMgr.Get("RoleBaseModelAsset", roleBaseKey)
    if roleCfg == nil then
        Debug.LogWarning(string.format("Find no RoleBaseModelAsset with roleKey: %s", roleBaseKey))
        return nil
    end
    return roleCfg
end

---销毁委托
---@param obj GameObject
local function executeReleaseListener(obj)
    if obj then
        for k, v in pairs(releaseDelegate) do
            v(obj)
        end
    end
end

local function genUUID()
    initUUID = initUUID + 1
    return initUUID
end

---根据RoleBaseKey获取AssetId
---@param roleBaseKey string
---@return int
local function getAssetIdWithRoleBaseKey(roleBaseKey)
    ---@type cfg.RoleBaseModelAsset
    local cfg = LuaCfgMgr.Get("RoleBaseModelAsset", roleBaseKey)
    if cfg ~= nil then
        return cfg.AssetID
    end
    return nil
end

---异步获取一个角色GameObject实例
---@param roleBaseKey String 基础模型
---@param partKeys String[] 部件数组
---@param filterPartTypes Int[] 要过滤的部件Type
---@param onComplete fun(ins:GameObject, uuid:int):void 成功后的回调
---@param faceChangeType Define.FaceChangeType
---@param faceHair int 发型ID
---@param excludeFromBlur bool 是否不参与模糊
---@param filter int[] 是否应用捏脸数据
---@return int uuid
function CharacterMgr.GetIns(roleBaseKey, partKeys, filterPartTypes, onComplete, faceChangeType, faceHair, excludeFromBlur,
                             filter)
    --Debug.LogFormatWithTag(GameConst.LogTag.FaceEdit, "1. CharacterMgr.GetIns key = %s, %s, faceChangeType = %s, faceHair = %s", roleBaseKey, table.dump(partKeys, "partKeys"), faceChangeType, faceHair)
    if not available then
        Debug.LogError("CharacterMgr.GetIns: error=CharacterMgr is not available")
        return INVALID_INS_RET
    end
    local roleBaseCfg = getRoleBaseCfg(roleBaseKey)
    ---find no cfg
    if (roleBaseCfg == nil) then
        if onComplete ~= nil then
            onComplete(nil, INVALID_INS_RET)
        end
        return INVALID_INS_RET
    end

    local uuid = genUUID()
    ResBatchLoader.ClearTasks()
    local assetPathList = PoolUtil.GetTable()
    local dstPartKeys = PoolUtil.GetTable()
    assetPathList, dstPartKeys = this.GetInsAssetList(roleBaseKey, partKeys, filterPartTypes, assetPathList, dstPartKeys)
    for _, path in pairs(assetPathList) do
        ResBatchLoader.AddTaskWithAssetPath(path)
    end
    PoolUtil.ReleaseTable(assetPathList)

    local exeOnLoaded = function(batchId)
        createInsGuard = true
        local ins = X3_ASSET_INS_PROVIDER:GetCharacterIns(roleBaseCfg.ModelAsset, nil, false)
        createInsGuard = false
        ---caching part keys
        if ins ~= nil then
            local insId = ins:GetInstanceID()
            local cachedPartKeys = cachedInsPartKeysDict[insId]
            if cachedPartKeys ~= nil then
                table.clear(cachedPartKeys)
            else
                cachedPartKeys = PoolUtil.GetTable()
            end
            for _, partKey in ipairs(dstPartKeys) do
                table.insert(cachedPartKeys, partKey)
            end
            cachedInsPartKeysDict[insId] = cachedPartKeys

            ---按现有的设计，Lua端主动更换部件不会触发应用“捏脸数据的回调”
            changePartsGuard = true
            CHARACTER_MGR_CLS.ChangeParts(ins, cachedPartKeys, false)

            ---todo:Should be "NeedFaceData"
            if CharacterMgr.NeedFaceData(ins) then
                --Debug.LogFormatWithTag(GameConst.LogTag.FaceEdit, "2. GetIns加载后捏脸 faceChangeType = %s, faceHair = %s, go = %s", faceChangeType, faceHair, ins)
                BllMgr.GetFaceBLL():SetHost(ins, faceChangeType, faceHair, nil, filter)
            end
            changePartsGuard = false

            ---记录ins.instanceId -> assetId
            local assetId = getAssetIdWithRoleBaseKey(roleBaseKey)
            cachedInsToAssetIdDict[insId] = assetId
            local ctsParticipantComp = ins:GetComponent(CUTSCENEPARTICIPANT_TYPE)
            if GameObjectUtil.IsNull(ctsParticipantComp) then
                ctsParticipantComp = ins:AddComponent(CUTSCENEACTOR_TYPE)
            end
            ctsParticipantComp.AssetId = assetId

            ---设置是否需要参与模糊 (默认为参与模糊)
            excludeFromBlur = excludeFromBlur or false
            CharacterMgr.ExcludeFromBlur(ins, excludeFromBlur)

            ---剪掉引用计数，添加ins为引用对象
            ResBatchLoader.SubRefCountAndAddRefObj(batchId, 1, nil)
        end
        ResBatchLoader.RemoveBatch(batchId)

        if available and not toCancelDict[uuid] and onComplete ~= nil then
            toCancelDict[uuid] = nil
            onComplete(ins, uuid)
            table.insert(insList, ins)
        else
            toCancelDict[uuid] = nil
            this.ReleaseIns(ins)
        end

        PoolUtil.ReleaseTable(dstPartKeys)
    end

    local batchId = ResBatchLoader.LoadAsyncWithoutUI(exeOnLoaded)
    return uuid
end

---获取角色所需的资源列表
---@param roleBaseKey String 基础模型
---@param inPartKeys String[] 部件数组
---@param filterPartTypes Int[] 要过滤的部件Type
---@param outAssetPathList String[] 外部传入的AssetPathList容器
---@return string[], string[]
function CharacterMgr.GetInsAssetList(roleBaseKey, inPartKeys, filterPartTypes, outAssetPathList, outDstPartKeys)
    local assetPathList = outAssetPathList and outAssetPathList or {}
    local dstPartKeys = outDstPartKeys and outDstPartKeys or {}
    local roleBaseCfg = getRoleBaseCfg(roleBaseKey)

    if (roleBaseCfg ~= nil) then
        local roleBasePartAssetPath = CharacterUtil.GetRoleBaseAssetPath(roleBaseKey)
        ---基础模型资源
        table.insert(assetPathList, roleBasePartAssetPath)
        ---模型部件资源
        ---去除部分类型的部件
        if filterPartTypes ~= nil then
            dstPartKeys = CharacterUtil.RemovePartsWithTypes(inPartKeys, filterPartTypes, dstPartKeys)
        else
            for _, v in pairs(inPartKeys) do
                table.insert(dstPartKeys, v)
            end
        end

        for _, part in pairs(dstPartKeys) do
            local partAssetPath = CharacterUtil.GetPartAssetPath(part, globalLOD)
            table.insert(assetPathList, partAssetPath)
        end
    end
    return assetPathList, dstPartKeys
end

---同步获取一个角色GameObject实例
---@param roleBaseKey String 基础模型
---@param partKeys String[] 部件数组
---@param filterPartTypes Int[] 要过滤的部件Type
---@param faceChangeType Define.FaceChangeType
---@param faceHair int 发型ID
---@param excludeFromBlur bool 是否不参与模糊
---@param filter int[]
---@return GameObject
function CharacterMgr.GetInsSync(roleBaseKey, partKeys, filterPartTypes, faceChangeType, faceHair, excludeFromBlur, filter)
    if not available then
        Debug.LogError("CharacterMgr is not available")
        return nil
    end
    local roleBaseCfg = getRoleBaseCfg(roleBaseKey)
    ---find no cfg
    if (roleBaseCfg == nil) then
        return nil
    end

    local dstPartKeys = PoolUtil.GetTable()
    local assetPathList = PoolUtil.GetTable()
    assetPathList, dstPartKeys = this.GetInsAssetList(roleBaseKey, partKeys, filterPartTypes, assetPathList, dstPartKeys)
    PoolUtil.ReleaseTable(assetPathList)

    createInsGuard = true
    local ins = X3_ASSET_INS_PROVIDER:GetCharacterIns(roleBaseKey, nil, false)
    createInsGuard = false

    ---caching part keys
    if ins ~= nil then
        local insId = ins:GetInstanceID()
        local cachedPartKeys = cachedInsPartKeysDict[insId]
        if cachedPartKeys ~= nil then
            table.clear(cachedPartKeys)
        else
            cachedPartKeys = PoolUtil.GetTable()
        end
        for _, partKey in ipairs(dstPartKeys) do
            table.insert(cachedPartKeys, partKey)
        end
        cachedInsPartKeysDict[insId] = cachedPartKeys

        ---按现有的设计，Lua端主动更换部件不会触发应用“捏脸数据的回调”
        changePartsGuard = true
        CHARACTER_MGR_CLS.ChangeParts(ins, cachedPartKeys, false)

        ---todo:Should be "NeedFaceData"
        if CharacterMgr.NeedFaceData(ins) then
            BllMgr.GetFaceBLL():SetHost(ins, faceChangeType, faceHair, nil, filter)
        end
        changePartsGuard = false

        ---设置是否需要参与模糊 (默认为参与模糊)
        excludeFromBlur = excludeFromBlur or false
        CHARACTER_MGR_CLS.ExcludeFromBlur(ins, excludeFromBlur)

        ---记录ins.instanceId -> assetId
        cachedInsToAssetIdDict[ins:GetInstanceID()] = getAssetIdWithRoleBaseKey(roleBaseKey)
        table.insert(insList, ins)
    end

    PoolUtil.ReleaseTable(dstPartKeys)
    return ins
end

---异步获取一个角色GameObject实例（根据套装）
---@param suitKey String 套装名
---@param onComplete fun(ins:GameObject, uuid:int):void 成功后的回调
---@param faceChangeType Define.FaceChangeType
---@param faceHair int 发型ID
---@param excludeFromBlur bool 是否不参与模糊
---@param filter int[] 应用捏脸数据
---@return int uuid
function CharacterMgr.GetInsWithSuitKey(suitKey, onComplete, faceChangeType, faceHair, excludeFromBlur, filter)
    local suitCfg = LuaCfgMgr.Get("RoleClothSuit", suitKey)
    if suitCfg == nil then
        Debug.LogWarningFormat("CharacterMgr.GetInsWithSuitKey: error=find no RoleClothSuit with suitKey: %s", suitKey)
        if (onComplete ~= nil) then
            onComplete(nil, INVALID_INS_RET)
        end
        return INVALID_INS_RET
    end
    local retUuid = this.GetIns(suitCfg.RoleBaseModelID, suitCfg.ClothList, nil, function(ins, uuid)
        if not string.isnilorempty(suitCfg.AddX3AnimatorAsset) then
            this.AddX3AnimatorData(ins, suitCfg.AddX3AnimatorAsset)
        end
        if (onComplete ~= nil) then
            onComplete(ins, uuid)
        end
    end, faceChangeType, faceHair, excludeFromBlur, filter)
    return retUuid
end

---获取角色所需的资源列表（根据套装）
---@param suitKey String 套装名
---@param outAssetPathList string[] 外部传入assetPathList容器
---@param outDstPartKeys string[] 外部传入dstPartKeys容器
---@return string[], string[], string
function CharacterMgr.GetAssetListWithSuitKey(suitKey, outAssetPathList, outDstPartKeys)
    local suitCfg = LuaCfgMgr.Get("RoleClothSuit", suitKey)
    local assetPathList = nil
    local dstPartKeys = nil
    local roleBaseKey = nil
    if suitCfg ~= nil then
        roleBaseKey = suitCfg.RoleBaseModelID
        assetPathList, dstPartKeys = this.GetInsAssetList(suitCfg.RoleBaseModelID, suitCfg.ClothList, outAssetPathList, outDstPartKeys)
        if not string.isnilorempty(suitCfg.AddX3AnimatorAsset) then
            table.insert(assetPathList, string.format(X3ANIMATOR_ASSET_PATH, suitCfg.AddX3AnimatorAsset))
        end
    else
        Debug.LogWarningFormat("CharacterMgr.GetAssetListWithSuitKey: Find no RoleClothSuit with key: %s", suitKey)
    end
    return assetPathList, dstPartKeys, roleBaseKey
end

---同步获取一个角色GameObject实例（根据套装）
---@param suitKey String 套装名
---@param filterPartTypes Int[] 要过滤的部件Type
---@param faceChangeType Define.FaceChangeType
---@param faceHair int 发型ID
---@param excludeFromBlur bool 是否不参与模糊
---@param filter int[] 是否引用捏脸数据
---@return GameObject
function CharacterMgr.GetInsWithSuitKeySync(suitKey, filterPartTypes, faceChangeType, faceHair, excludeFromBlur, filter)
    if not available then
        Debug.LogError("CharacterMgr.GetInsWithSuitKeySync：error=CharacterMgr is not available")
        return nil
    end

    local suitCfg = LuaCfgMgr.Get("RoleClothSuit", suitKey)
    if suitCfg == nil then
        Debug.LogWarningFormat("CharacterMgr.GetInsWithSuitKeySync: error=find no RoleClothSuit with suitKey: %s", suitKey)
        return nil
    end

    local ins = this.GetInsSync(suitCfg.RoleBaseModelID, suitCfg.ClothList, filterPartTypes, faceChangeType, faceHair, excludeFromBlur, filter)

    if not string.isnilorempty(suitCfg.AddX3AnimatorAsset) then
        this.AddX3AnimatorData(ins, suitCfg.AddX3AnimatorAsset)
    end

    return ins
end

---异步获取一个角色GameObject实例（根据AssetId）
---@param assetId int cutscene资产id
---@param onComplete fun(ins:GameObject, uuid:int):void 成功后的回调
---@return int uuid
function CharacterMgr.GetInsWithAssetId(assetId, onComplete)
    local cfg = LuaCfgMgr.Get("CutSceneAsset", assetId)
    if cfg == nil then
        Debug.LogWarningFormat("CharacterMgr.GetInsWithAssetId: error=find no CutSceneAsset with assetId: %s", assetId)
        if (onComplete ~= nil) then
            onComplete(nil)
        end
        return
    end
    local retUuid = this.GetIns(cfg.ModelKey, cfg.PartKey, onComplete)
    return retUuid
end

---释放一个角色
---@param ins GameObject 资产实例
---@param keepAliveInSeconds float 该实例在池里存活的时间（秒）
---@return Boolean 操作是否成功
function CharacterMgr.ReleaseIns(ins, keepAliveInSeconds)
    BllMgr.GetFaceBLL():ClearHost(ins)
    removeInsGuard = true
    if keepAliveInSeconds == nil then
        keepAliveInSeconds = 0
    end
    --- remove cache partkeys
    if not GameObjectUtil.IsNull(ins) then
        local instanceId = ins:GetInstanceID()
        PoolUtil.ReleaseTable(cachedInsPartKeysDict[instanceId])
        cachedInsPartKeysDict[instanceId] = nil
        cachedInsToAssetIdDict[instanceId] = nil
    end
    ---需要释放自己的X3ANIMATOR_TYPE
    CharacterMgr.RemoveCSComponent(ins)
    local ret = X3_ASSET_INS_PROVIDER:ReleaseIns(ins, false, true, true, keepAliveInSeconds)
    if ret then
        executeReleaseListener(ins)
    end
    table.removebyvalue(insList, ins)
    removeInsGuard = false
    return ret
end

---释放一个角色身上的Cs脚本
---@param ins GameObject 资产实例
function CharacterMgr.RemoveCSComponent(ins)
    GameObjectUtil.RemoveCSComponent(ins, X3ANIMATOR_TYPE)
    GameObjectUtil.RemoveCSComponent(ins, PLAYABLEANIMATOR_TYPE)
end

function CharacterMgr.RemoveX3AnimatorCSComponent(ins)
    GameObjectUtil.RemoveCSComponent(ins, X3ANIMATOR_TYPE)
end

function CharacterMgr.PhysicsSmoothBlendCurrentPose(ins)
    CHARACTER_MGR_CLS.PhysicsSmoothBlendCurrentPose(ins);
end

---给角色换装
---@param ins GameObject 资产实例
---@param partKeys string[] 部件数组
---@param filterPartTypes Int[] 要过滤的部件Type
---@param onComplete fun(result:boolean):void 操作完成的回调
function CharacterMgr.ChangeParts(ins, partKeys, filterPartTypes, onComplete)
    if GameObjectUtil.IsNull(ins) then
        if onComplete ~= nil then
            onComplete(false)
        end
        return
    end

    local comp = ins:GetComponent(X3CHARACTER_TYPE)
    if comp == nil then
        Debug.LogError("CharacterMgr.ChangeParts: error=对象身上未附加X3Character组件")
        if onComplete ~= nil then
            onComplete(false)
        end
        return
    end

    local oldPartKeys = cachedInsPartKeysDict[ins:GetInstanceID()]
    local toChangeParts = partKeys
    ---去除部分类型的部件
    if filterPartTypes ~= nil then
        toChangeParts = table.clone(partKeys)
        toChangeParts = CharacterUtil.RemovePartsWithTypes(toChangeParts, filterPartTypes)
    end
    local dstPartKeys = PoolUtil.GetTable()
    local toAddPartKeys = PoolUtil.GetTable()
    local toRemovePartKeys = PoolUtil.GetTable()
    dstPartKeys, toAddPartKeys, toRemovePartKeys = CharacterUtil.ReplaceParts(oldPartKeys, toChangeParts, dstPartKeys, toAddPartKeys, toRemovePartKeys)
    local insId = ins:GetInstanceID()
    local cachedPartKeys = cachedInsPartKeysDict[insId]
    if (cachedPartKeys == nil) then
        cachedPartKeys = PoolUtil.GetTable()
    else
        table.clear(cachedPartKeys)
    end
    for _, v in pairs(dstPartKeys) do
        table.insert(cachedPartKeys, v)
    end
    cachedInsPartKeysDict[insId] = cachedPartKeys

    ---按现有的设计，Lua端主动更换部件不会触发应用“捏脸数据的回调”
    changePartsGuard = true
    CHARACTER_MGR_CLS.ChangeParts(ins, dstPartKeys, false)
    changePartsGuard = false
    --TODO 需要在CtsPlay前调用一下才能保证当帧灯光不闪
    comp:Update()
    if X3AnimatorUtil ~= nil then
        X3AnimatorUtil.ClearExternalStateCache(ins)
    end
    PoolUtil.ReleaseTable(dstPartKeys)
    PoolUtil.ReleaseTable(toAddPartKeys)
    PoolUtil.ReleaseTable(toRemovePartKeys)
    if onComplete ~= nil then
        onComplete(true)
    end
end

---给角色换装（同步）
---@param ins GameObject 资产实例
---@param partKeys string[] 部件数组
---@param filterPartTypes Int[] 要过滤的部件Type
---@return boolean success
function CharacterMgr.ChangePartsSync(ins, partKeys, filterPartTypes)
    if GameObjectUtil.IsNull(ins) then
        return false
    end

    local comp = ins:GetComponent(X3CHARACTER_TYPE)
    if comp == nil then
        Debug.LogError("对象身上未附加X3Character组件")
        return false
    end

    local oldPartKeys = cachedInsPartKeysDict[ins:GetInstanceID()]
    local toChangeParts = partKeys
    ---去除部分类型的部件
    if filterPartTypes ~= nil then
        toChangeParts = table.clone(partKeys)
        toChangeParts = CharacterUtil.RemovePartsWithTypes(toChangeParts, filterPartTypes)
    end
    local dstPartKeys = PoolUtil.GetTable()
    local toAddPartKeys = PoolUtil.GetTable()
    local toRemovePartKeys = PoolUtil.GetTable()
    dstPartKeys, toAddPartKeys, toRemovePartKeys = CharacterUtil.ReplaceParts(oldPartKeys, toChangeParts, dstPartKeys, toAddPartKeys, toRemovePartKeys)
    local insId = ins:GetInstanceID()
    local cachedPartKeys = cachedInsPartKeysDict[insId]
    if (cachedPartKeys == nil) then
        cachedPartKeys = PoolUtil.GetTable()
    else
        table.clear(cachedPartKeys)
    end
    for _, v in pairs(dstPartKeys) do
        table.insert(cachedPartKeys, v)
    end
    cachedInsPartKeysDict[insId] = cachedPartKeys

    ---按现有的设计，Lua端主动更换部件不会触发应用“捏脸数据的回调”
    changePartsGuard = true
    CHARACTER_MGR_CLS.ChangeParts(ins, dstPartKeys, false)
    changePartsGuard = false
    --TODO 需要在CtsPlay前调用一下才能保证当帧灯光不闪
    comp:Update()
    if X3AnimatorUtil ~= nil then
        X3AnimatorUtil.ClearExternalStateCache(ins)
    end
    PoolUtil.ReleaseTable(dstPartKeys)
    PoolUtil.ReleaseTable(toAddPartKeys)
    PoolUtil.ReleaseTable(toRemovePartKeys)
    return true
end

---@param ins GameObject 角色实例
---@param partName string 即将更换的部件名称
---@param fromFaceEdit bool 是否从捏脸逻辑过来的
---@return bool
function CharacterMgr.ReplacePart(ins, partName, fromFaceEdit)
    if GameObjectUtil.IsNull(ins) or string.isnilorempty(partName) then
        return false
    end
    if fromFaceEdit == nil then
        fromFaceEdit = false
    end
    local tbl = PoolUtil.GetTable()
    table.insert(tbl, partName)
    if fromFaceEdit then
        changePartsGuard = true
    end
    local ret = this.ChangePartsSync(ins, tbl)
    if fromFaceEdit then
        changePartsGuard = false
    end
    PoolUtil.ReleaseTable(tbl)
    return ret
end

---移除角色身上的部件
---@param ins GameObject 资产实例
---@param partKey string 部件名
---@param onComplete fun(result:boolean):void 操作完成的回调
function CharacterMgr.RemovePart(ins, partKey, onComplete)
    if GameObjectUtil.IsNull(ins) then
        if onComplete ~= nil then
            onComplete(false)
        end
        return
    end

    local cachedPartKeys = cachedInsPartKeysDict[ins:GetInstanceID()]
    if cachedPartKeys ~= nil then
        table.removebyvalue(cachedPartKeys, partKey)
    end

    local comp = ins:GetComponent(X3CHARACTER_TYPE)
    if comp == nil then
        Debug.LogError("对象身上未附加X3Character组件")
        if onComplete ~= nil then
            onComplete(false)
        end
        return
    end
    CHARACTER_MGR_CLS.RemovePart(ins, partKey)
    if X3AnimatorUtil ~= nil then
        X3AnimatorUtil.ClearExternalStateCache(ins)
    end
    if onComplete ~= nil then
        onComplete(true)
    end
end

---添加角色身上的部件
---@param ins GameObject 资产实例
---@param partKey string 部件名
---@param onComplete fun(result:boolean):void 操作完成的回调
function CharacterMgr.AddPart(ins, partKey, onComplete)
    if GameObjectUtil.IsNull(ins) then
        if onComplete ~= nil then
            onComplete(false)
        end
        return
    end

    local cachedPartKeys = cachedInsPartKeysDict[ins:GetInstanceID()]
    local index = false
    if cachedPartKeys ~= nil then
        index = table.indexof(cachedPartKeys, partKey)
        if not index then
            table.insert(cachedPartKeys, partKey)
        end
    end

    if index ~= false then
        Debug.LogErrorFormat("CharacterMgr.AddPart: error=已存在同一部件: %s", partKey)
        if onComplete ~= nil then
            onComplete(false)
        end
        return
    end

    local comp = ins:GetComponent(X3CHARACTER_TYPE)
    if comp == nil then
        Debug.LogErrorFormat("CharacterMgr.AddPart: error=对象身上未附加X3Character组件")
        if onComplete ~= nil then
            onComplete(false)
        end
        return
    end

    ---按现有的设计，Lua端主动更换部件不会触发应用“捏脸数据的回调”
    changePartsGuard = true
    CHARACTER_MGR_CLS.AddPart(ins, partKey, true, false)
    changePartsGuard = false

    if X3AnimatorUtil ~= nil then
        X3AnimatorUtil.ClearExternalStateCache(ins)
    end

    if onComplete ~= nil then
        onComplete(true)
    end
end

---添移除角色身上所有的部件
---@param ins GameObject 资产实例
---@param onComplete fun(result:boolean):void 操作完成的回调
function CharacterMgr.RemoveAllParts(ins, onComplete)
    if GameObjectUtil.IsNull(ins) then
        if onComplete ~= nil then
            onComplete(false)
        end
        return
    end

    local dict = cachedInsPartKeysDict[ins:GetInstanceID()]
    if (dict ~= nil) then
        table.clear(dict)
    end

    local comp = ins:GetComponent(X3CHARACTER_TYPE)
    if comp == nil then
        Debug.LogError("对象身上未附加X3Character组件")
        if onComplete ~= nil then
            onComplete(false)
        end
        return
    end
    CHARACTER_MGR_CLS.RemoveAllParts(ins)
    if X3AnimatorUtil ~= nil then
        X3AnimatorUtil.ClearExternalStateCache(ins)
    end
    if onComplete ~= nil then
        onComplete(true)
    end
end

---给角色换装（按SuitKey）
---@param ins GameObject 资产实例
---@param suitKey string
---@param onComplete fun(result:boolean):void 操作完成的回调
function CharacterMgr.ChangePartsWithSuitKey(ins, suitKey, onComplete)
    if GameObjectUtil.IsNull(ins) then
        if onComplete ~= nil then
            onComplete(false)
        end
        return
    end

    local suitCfg = LuaCfgMgr.Get("RoleClothSuit", suitKey)
    if suitCfg == nil then
        Debug.LogErrorFormat("CharacterMgr.ChangePartsWithSuitKey: error=Find no RoleClothSuit with suitKey: %s", suitKey)
        if (onComplete ~= nil) then
            onComplete(nil)
            return
        end
    end
    this.RemoveAllParts(ins)
    this.ChangeParts(ins, suitCfg.ClothList, nil, onComplete)
end

---给角色换装（按SuitKey），会先移除掉所有部件重新添加
---@param ins GameObject 资产实例
---@param suitKey string
---@param faceChangeType Define.FaceChangeType
---@param faceHair int 发型ID
---@param filter int[] 是否引用捏脸数据
---@return boolean success
function CharacterMgr.RebuildPartsWithSuitKeySync(ins, suitKey, faceChangeType, faceHair, filter)
    if GameObjectUtil.IsNull(ins) then
        return false
    end
    local suitCfg = LuaCfgMgr.Get("RoleClothSuit", suitKey)
    if suitCfg == nil then
        Debug.LogErrorFormat("Find no RoleClothSuit with suitKey: %s", suitKey)
        return false
    end
    return CharacterMgr.RebuildParts(ins, suitCfg.RoleBaseModelID, suitCfg.ClothList, faceChangeType, faceHair, filter)
end

---给角色换装（按roleBaseKey和partKeys），会先移除掉所有部件重新添加
---@param roleBaseKey String
---@param partKeys string[]
---@param faceChangeType Define.FaceChangeType
---@param faceHair int 发型ID
---@param filter int[]
function CharacterMgr.RebuildParts(ins, roleBaseKey, partKeys, faceChangeType, faceHair, filter)
    if GameObjectUtil.IsNull(ins) then
        return false
    end
    this.RemoveAllParts(ins)
    partKeys = procPartKeysParams(partKeys)
    local dstPartKeys = partKeys
    local ret = this.ChangePartsSync(ins, dstPartKeys, nil)
    if CharacterMgr.NeedFaceData(ins) then
        BllMgr.GetFaceBLL():SetHost(ins, faceChangeType, faceHair, nil, filter)
    end
end

---显示部件
---@param ins GameObject 资产实例
---@param partKey string 部件名
function CharacterMgr.ShowPart(ins, partKey)
    if GameObjectUtil.IsNull(ins) then
        return
    end

    local comp = ins:GetComponent(X3CHARACTER_TYPE)
    if comp == nil then
        Debug.LogErrorFormat("CharacterMgr.ShowPart: error=对象身上未附加X3Character组件: %s", ins.name)
        return
    end

    comp:HidePart(partKey, false)
end

---隐藏部件
---@param ins GameObject 资产实例
---@param partKey string 部件名
function CharacterMgr.HidePart(ins, partKey)
    if GameObjectUtil.IsNull(ins) then
        return
    end

    local comp = ins:GetComponent(X3CHARACTER_TYPE)
    if comp == nil then
        Debug.LogErrorFormat("CharacterMgr.HidePart: error=对象(%s)身上未附加X3Character组件", ins.name)
        return
    end

    comp:HidePart(partKey, true)
end

---添加角色数据资产
---@param ins GameObject 资产实例
---@param X3AnimatorAssetName String 资产名
---@return X3Animator
function CharacterMgr.AddX3AnimatorData(ins, X3AnimatorAssetName)
    if GameObjectUtil.IsNull(ins) then
        return nil
    end
    local comp = ins:GetComponent(X3ANIMATOR_TYPE)
    if comp == nil then
        comp = ins:AddComponent(X3ANIMATOR_TYPE)
    end
    ---自动设置assetId
    local assetId = cachedInsToAssetIdDict[ins:GetInstanceID()]
    if assetId ~= nil then
        comp.AssetId = assetId
    end
    if string.isnilorempty(X3AnimatorAssetName) then
        return comp
    end
    local assetPath = string.format(X3ANIMATOR_ASSET_PATH, X3AnimatorAssetName)
    local asset = Res.LoadWithAssetPath(assetPath, AutoReleaseMode.EndOfFrame, nil, ins)
    if asset == nil then
        Debug.LogErrorFormat("CharacterMgr.AddX3AnimatorData: error=find no X3AnimatorAsset asset with name: %s", X3AnimatorAssetName)
        return comp
    end
    ---统一走通用表演库逻辑
    comp.DataProviderEnabled = true
    comp:LoadFromAsset(asset)
    comp.DataProviderEnabled = false
    return comp
end

---获取角色身上的Dummy点
---@param ins GameObject 资产实例
---@param dummyName String dummy点名称
---@return Transform
function CharacterMgr.GetDummyByName(ins, dummyName)
    if GameObjectUtil.IsNull(ins) or string.isnilorempty(dummyName) then
        return nil
    end
    local subComp = this.GetSubSystem(ins, CS.X3.Character.ISubsystem.Type.Skeleton)
    if (subComp == nil) then
        return nil
    end
    local ret = subComp:GetDummyByName(dummyName)
    return ret
end

---获取角色身上的指定骨骼节点
---@param ins GameObject 资产实例
---@param boneName string 骨骼名称
---@param includeExtraBones boolean false表示仅在基础骨架中搜索，true表示所有骨架中搜索
---@return Transform
function CharacterMgr.GetBoneByName(ins, boneName, includeExtraBones)
    if includeExtraBones == nil then includeExtraBones = false end
    if GameObjectUtil.IsNull(ins) or string.isnilorempty(boneName) then
        return nil
    end
    local subComp = this.GetSubSystem(ins, CS.X3.Character.ISubsystem.Type.Skeleton)
    if (subComp == nil) then
        return nil
    end
    local ret = subComp:GetBone(boneName, includeExtraBones)
    return ret
end

--- 获取角色身上的武器骨骼点（是武器本身的骨骼点，不是人手骨骼）
---@return Transform[]
function CharacterMgr.GetWeaponBones(ins)
    local leftBone = CharacterMgr.GetBoneByName(ins, HAND_LEFT_WEAPON_BONE_NAME)
    local rightBone = CharacterMgr.GetBoneByName(ins, HAND_RIGHT_WEAPON_BONE_NAME)
    local bones = { leftBone, rightBone }
    local weaponBones = nil
    for _, handBone in pairs(bones) do
        if handBone then
            local childCount = handBone.childCount
            if childCount > 0 then
                for i = 0, childCount - 1 do
                    local child = handBone:GetChild(i)
                    if not weaponBones then
                        weaponBones = {}
                    end
                    table.insert(weaponBones, child)
                end
            end
        end
    end
    return weaponBones
end

---获取部件（武器、衣服）的父节点
---@param ins GameObject 资产实例
---@param partKey string 部件名称
---@return Transform, GameObject
function CharacterMgr.GetPartParentBone(ins, partKey)
    if GameObjectUtil.IsNull(ins) or string.isnilorempty(partKey) then
        return nil
    end
    local subComp = this.GetSubSystem(ins, CS.X3.Character.ISubsystem.Type.SkinnedMesh)
    if (subComp == nil) then
        return nil
    end
    local smr = subComp:GetBodyPartByName(partKey)
    if (GameObjectUtil.IsNull(smr)) then
        return nil
    end
    local parentBone = smr.rootBone.transform.parent
    return parentBone, smr.gameObject  -- 第二个返回值是为了隐藏武器，临时测试用的，后面接入材质动画后就删掉（by 长空）
end

---获取角色身上的子系统
---@param ins GameObject 资产实例
---@param subType X3.Character.ISubsystem.Type 子系统的枚举值
---@return System.Object
function CharacterMgr.GetSubSystem(ins, subType)
    if GameObjectUtil.IsNull(ins) then
        return nil
    end
    local comp = ins:GetComponent(X3CHARACTER_TYPE)
    if comp == nil then
        Debug.LogErrorFormat("CharacterMgr.GetSubSystem: error=find no X3Character on ins: %s", ins.name)
        return nil
    end
    local subComp = comp:GetSubsystem(subType)
    if subComp == nil then
        Debug.LogErrorFormat("CharacterMgr.GetSubSystem: error=find no X3Skeleton on ins: %s", ins.name)
        return nil
    end
    return subComp
end

---角色身上添加子系统，如果已经存在则获取已存子系统
---@param ins GameObject 资产实例
---@param subType X3.Character.ISubsystem.Type 子系统的枚举值
---@return System.Object
function CharacterMgr.EnsureSubSystem(ins, subType)
    if GameObjectUtil.IsNull(ins) then
        return nil
    end

    local comp = ins:GetComponent(X3CHARACTER_TYPE)
    if comp == nil then
        Debug.LogErrorFormat("CharacterMgr.EnsureSubSystem: error=find no X3Character on ins: %s", ins.name)
        return nil
    end

    local subComp = comp:GetSubsystem(subType)
    if subComp ~= nil then
        return subComp
    end

    return comp:AddSubsystem(subType)
end

---关闭角色身上添加子系统
---@param ins GameObject 资产实例
---@param subType X3.Character.ISubsystem.Type 子系统的枚举值
---@param enable bool
function CharacterMgr.EnableSubSystem(ins, subType, enable)
    if GameObjectUtil.IsNull(ins) then
        return nil
    end

    local comp = ins:GetComponent(X3CHARACTER_TYPE)
    if comp == nil then
        Debug.LogErrorFormat("CharacterMgr.EnableSubSystem: error=find no X3Character on ins: %s", ins.name)
        return nil
    end

    comp:EnableSubsystem(subType, enable)
end

---判断系统是否存在
---@param ins GameObject 资产实例
---@param subType X3.Character.ISubsystem.Type 子系统的枚举值
---@return boolean
function CharacterMgr.HasSubSystem(ins, subType)
    if GameObjectUtil.IsNull(ins) then
        return false
    end
    local comp = ins:GetComponent(X3CHARACTER_TYPE)
    if comp == nil then
        return false
    end
    local subComp = comp:GetSubsystem(subType)
    if subComp == nil then
        return false
    end
    return true
end

---判断是否需要捏脸数据
---@param ins GameObject 角色GameObject
---@return boolean
function CharacterMgr.NeedFaceData(ins)
    return CharacterMgr.HasSubSystem(ins, CS.X3.Character.ISubsystem.Type.FaceMorph)
end

---获取角色身上的部件列表
---@param ins GameObject
---@return string[] 部件列表（partKeys） readonly
function CharacterMgr.GetPartKeys(ins)
    if (GameObjectUtil.IsNull(ins)) then
        return nil
    end

    local partKeys = cachedInsPartKeysDict[ins:GetInstanceID()]

    --todo get partKeys from C# is quite expensive
    local arr = CHARACTER_MGR_CLS.GetPartKeys(ins)
    if arr ~= nil and arr.Length > 0 then
        partKeys = {}
        for i = 0, arr.Length - 1 do
            table.insert(partKeys, arr[i])
        end
    end

    return partKeys
end

---设置是否可用
---@param _available boolean
function CharacterMgr.SetAvailable(_available)
    available = _available
end

---取消加载（取消加载后将不再收到加载完成的回调）
---@param uuid int
function CharacterMgr.Cancel(uuid)
    toCancelDict[uuid] = true
end

---设置全局LOD,HD=0,LD=1
---@param lod Int HD=0,LD=1
function CharacterMgr.SetGlobalLOD(lod)
    lod = lod or CharacterEnum.LOD.HD
    lod = math.round(lod)
    globalLOD = lod
    CHARACTER_MGR_CLS.SetLOD(globalLOD)
    Debug.LogFormat("CharacterMgr.SetGlobalLOD: %s", globalLOD)
end

---获取全局LOD,HD=0,LD=1
---@return Int HD=0,LD=1
function CharacterMgr.GetGlobalLOD()
    return globalLOD
end

---设置人物特写
---@param ins GameObject
---@param exclude boolean 是否开启
function CharacterMgr.ExcludeFromBlur(ins, exclude)
    CHARACTER_MGR_CLS.ExcludeFromBlur(ins, exclude or false)
end

---获取指定 bone 在 ins 下的坐标
---@param ins GameObject
---@param boneName string
function CharacterMgr.GetBoneRootPosition(ins, boneName)
    return CHARACTER_MGR_CLS.GetBoneRootPosition(ins, boneName)
end

---已知 BodyPart 的情况下，获取指定 bone 在 ins 下的坐标，效率优于 GetBoneRootPosition
---@param ins GameObject
---@param boneName string
function CharacterMgr.GetBoneRootPositionByBodyPart(ins, boneName, bodyPart)
    return CHARACTER_MGR_CLS.GetBoneRootPositionByBodyPart(ins, boneName, bodyPart)
end

---@param listener fun(type:GameObject)
function CharacterMgr.AddReleaseListener(listener)
    releaseDelegate[listener] = listener
end

---@param listener fun(type:GameObject)
function CharacterMgr.RemoveReleaseListener(listener)
    releaseDelegate[listener] = nil
end

---@return CharacterWave
function CharacterMgr.GetCharacterWave()
    return CharacterWave
end

---给角色换装
---@param ins GameObject 资产实例
---@param bodyTypes X3.Character.CharacterDefines.BodyType[] 部件数组
function CharacterMgr.SetPartsToShadowOnly(ins, bodyTypes, isShadowOnly)
    for _, v in pairs(bodyTypes) do
        CHARACTER_MGR_CLS.SetPartToShadowOnly(ins, v, isShadowOnly)
    end
end

function CharacterMgr.AddListeners()
    CHARACTER_MGR_CLS.AddCharacterListener(CharacterMgr.__OnAddCharacter, CharacterMgr.__OnChangeParts, CharacterMgr.__OnRemoveCharacter)
end

function CharacterMgr.RemoveListeners()
    CHARACTER_MGR_CLS.RemoveCharacterListener(CharacterMgr.__OnAddCharacter, CharacterMgr.__OnChangeParts, CharacterMgr.__OnRemoveCharacter)
end

---创建新角色的回调
---@param ins GameObject 角色实例
---@param roleBaseKey string
function CharacterMgr.__OnAddCharacter(ins, roleBaseKey)
    if (not Application.IsPlaying()) then
        return
    end
    if (not createInsGuard) and CharacterMgr.NeedFaceData(ins) then
        if roleBaseKey == GameConst.RoleBaseKey.Player then
            if PlayerChangeHairDelegate then
                local faceHairType, faceHairId = PlayerChangeHairDelegate()
                BllMgr.GetFaceBLL():SetHost(ins, faceHairType, faceHairId)
            else
                BllMgr.GetFaceBLL():SetHost(ins)
            end
        else
            BllMgr.GetFaceBLL():SetHost(ins)
        end
    end
end

---更换部件的回调
---@param ins GameObject 角色实例
---@param roleBaseKey string
---@param partNames string[] 最终部件名字列表，CTS换装需要更新这个缓存，不然会导致捏脸应用错误
function CharacterMgr.__OnChangeParts(ins, roleBaseKey, partNames)
    if (not Application.IsPlaying()) then
        return
    end
    if (not changePartsGuard) and (not createInsGuard) and CharacterMgr.NeedFaceData(ins) then
        changePartsGuard = true
        if partNames and partNames.Count > 0 then
            local cachedPartKeys = cachedInsPartKeysDict[ins:GetInstanceID()]
            if cachedPartKeys == nil then
                cachedPartKeys = PoolUtil.GetTable()
                cachedInsPartKeysDict[ins:GetInstanceID()] = cachedPartKeys
            end
            table.clear(cachedPartKeys)
            for i = 0, partNames.Count - 1 do
                table.insert(cachedPartKeys, partNames[i])
            end
        end
        BllMgr.GetFaceBLL():RefreshHost(ins)
        changePartsGuard = false
    end
end

function CharacterMgr.__OnRemoveCharacter(ins)
    if (not Application.IsPlaying()) then
        return
    end
    if (not removeInsGuard) and CharacterMgr.NeedFaceData(ins) then
        BllMgr.GetFaceBLL():ClearHost(ins)
        cachedInsPartKeysDict[ins:GetInstanceID()] = nil
    end
end

---销毁所有加载过的角色Ins
function CharacterMgr.ReleaseAllIns()
    local length = #insList
    for i = length, 1 , -1 do
        if GameObjectUtil.IsNull(insList[i]) == false then
            this.ReleaseIns(insList[i])
        end
    end
    table.clear(insList)
end

---设置自定义女主发型的回调
function CharacterMgr.SetPlayerChangeHairCb(cb)
    PlayerChangeHairDelegate = cb
end

function CharacterMgr.Clear()
    this.ReleaseAllIns()
    this.SetAvailable(false)
    this.RemoveListeners()
    this.SetPlayerChangeHairCb(nil)
end

function CharacterMgr.Destroy()
    this.Clear()
end

function CharacterMgr.Init()
    this.SetAvailable(true)
    this.AddListeners()
end

return CharacterMgr