--- X3@PapeGames
--- CharacterUtil
--- Created by Tungway
--- Created Date: 2021/01/18

---@class CharacterUtil
local CharacterUtil = {}
local X3CHARACTER_TYPE = typeof(CS.X3.Character.X3Character)
---Character枚举值
local CharacterEnum = require("Runtime.System.X3Game.Modules.Character.CharacterEnum")

local function getRoleBaseCfg(roleBaseKey)
    local roleCfg = LuaCfgMgr.Get("RoleBaseModelAsset", roleBaseKey)
    if roleCfg == nil then
        Debug.LogWarningFormat("find no RoleBaseModelAsset with roleKey: %s", roleBaseKey)
        return nil
    end
    return roleCfg
end

local function getPartCfg(partKey)
    local partCfg = LuaCfgMgr.Get("PartConfig", partKey)
    if partCfg == nil then
        Debug.LogWarningFormat("find no PartConfig with partKey: %s", partKey)
        return nil
    end
    return partCfg
end

local function getAssetPathWithModelKey(modelKey)
    local assetCfg = LuaCfgMgr.Get("ModelAsset", modelKey)
    if assetCfg == nil then
        Debug.LogWarningFormat("find no ModelAsset with stringKey: %s", modelKey)
        return nil
    end
    return assetCfg.PrefabPath
end

---根据roleBaseKey获取对应的AssetPath
---@param roleBaseKey string
---@return string assetPath
function CharacterUtil.GetRoleBaseAssetPath(roleBaseKey)
    local roleCfg = getRoleBaseCfg(roleBaseKey)
    if roleCfg == nil then
        return nil
    end
    local assetPath = getAssetPathWithModelKey(roleCfg.ModelAsset)
    return assetPath
end

---根据lod和PartKey获取对应的AssetPath
---@param partKey string
---@param lod Int LOD
---@return string assetPath
function CharacterUtil.GetPartAssetPath(partKey, lod)
    lod = lod or CharacterEnum.LOD.HD
    lod = math.round(lod)
    local partCfg = LuaCfgMgr.Get("PartConfig", partKey)
    if partCfg == nil then
        Debug.LogErrorFormat("CharacterUtil.GetPartAssetPath: error=find no PartConfig with partKey: %s", partKey)
        return nil
    end

    if not partCfg.Sources then
        Debug.LogErrorFormat("CharacterUtil.GetPartAssetPath: error=PartCfg(%s).Sources is nil", partKey)
        return nil
    end

    local modelKey = nil
    if #partCfg.Sources > 1 and lod > 0 then
        modelKey = partCfg.Sources[lod + 1]
    else
        modelKey = partCfg.Sources[1]
    end

    local assetCfg = LuaCfgMgr.Get("ModelAsset", modelKey)
    if assetCfg == nil then
        Debug.LogErrorFormat("Find no ModelAsset with StringKey: %s,lod=%s,partKey=%s", modelKey,lod,partKey)
        return nil
    end
    local assetPath = assetCfg.PrefabPath
    return assetPath
end

---替换PartKeys（同类型的部件会被替换掉）
---@param oldPartKeys string[] 旧的PartKey数组
---@param newPartKeys string[] 新的PartKey数组
---@param outDstPartKeys string[] 外部传入的dstPartKeys容器
---@param outToAddPartKeys string[] 外部传入的toAddPartKeys容器
---@param outToRemovePartKeys string[] 外部传入的toRemovePartKeys容器
---@return string[],string[],string[] dstPartKeys,toAddPartKeys,toRemovePartKeys
function CharacterUtil.ReplaceParts(oldPartKeys, newPartKeys, outDstPartKeys, outToAddPartKeys, outToRemovePartKeys)
    local tmpNewPartKeys = PoolUtil.GetTable()
    if newPartKeys ~= nil then
        if (type(newPartKeys) ~= "table") then
            table.insert(tmpNewPartKeys, newPartKeys)
        else
            for _, v in pairs(newPartKeys) do
                table.insert(tmpNewPartKeys, v)
            end
        end
    end

    local dstPartKeys = outDstPartKeys and outDstPartKeys or {}
    local toAddPartKeys = outToAddPartKeys and outToAddPartKeys or {}
    local toRemovePartKeys = outToRemovePartKeys and outToRemovePartKeys or {}
    local tmpList = PoolUtil.GetTable()

    if oldPartKeys ~= nil then
        for _, oldPartKey in ipairs(oldPartKeys) do
            ---旧的部件是否能保留
            local canKeep = true
            if not table.indexof(tmpNewPartKeys, oldPartKey) then
                local oldCfg = getPartCfg(oldPartKey)
                if oldCfg ~= nil then
                    for _, newPart in ipairs(tmpNewPartKeys) do
                        local newCfg = getPartCfg(newPart)
                        if  newCfg ~= nil and newCfg.Type == oldCfg.Type and newCfg.SubType == oldCfg.SubType then
                            canKeep = false
                            break
                        end
                    end
                end
            end
            if not canKeep then
                table.insert(toRemovePartKeys, oldPartKey)
            else
                table.insert(tmpList, oldPartKey)
            end
        end
    end

    for _, newPartKey in ipairs(tmpNewPartKeys) do
        if not table.indexof(tmpList, newPartKey) then
            table.insert(toAddPartKeys, newPartKey)
            table.insert(tmpList, newPartKey)
        end
    end

    ---在newPartKeys内做互斥操作
    for _,part1 in ipairs(tmpList) do
        local cfg1 = getPartCfg(part1)
        if cfg1 ~= nil then
            local canInsert = true
            for _,part2 in ipairs(dstPartKeys) do
                local cfg2 = getPartCfg(part2)
                if cfg1.Type == cfg2.Type and cfg1.SubType == cfg2.SubType then
                    canInsert = false
                    break
                end
            end

            if canInsert == true then
                table.insert(dstPartKeys, part1)
            end
        end
    end

    PoolUtil.ReleaseTable(tmpList)
    PoolUtil.ReleaseTable(tmpNewPartKeys)
    return dstPartKeys, toAddPartKeys, toRemovePartKeys
end

---移除部件类的指定类型（不会修改传入的数据）
---@param inPartKeys string[]
---@param partTypes Int[]
---@param outDstPartKeys string[] 外部传入的PartKeys容器
---@return string[] 经过处理后的partKeys
function CharacterUtil.RemovePartsWithTypes(inPartKeys, partTypes, outDstPartKeys)
    if inPartKeys == nil or 0 == #inPartKeys then
        if outDstPartKeys then
            return outDstPartKeys
        end
        return inPartKeys
    end
    local dstTbl = outDstPartKeys and outDstPartKeys or {}
    for _, partKey in ipairs(inPartKeys) do
        local cfg = getPartCfg(partKey)
        if cfg ~= nil and not table.indexof(partTypes, cfg.Type) then
            table.insert(dstTbl, partKey)
        end
    end
    return dstTbl
end


---根据partKey数组返回AssetPath数组
---@param partKeys string[] partKey数组
---@param lod Int hd=0,ld=1
---@param outAssetList string[] 外部传入的AssetList容器
---@return string[] 部件AssetPath数组
function CharacterUtil.GetPartAssetPathList(partKeys, lod, outAssetList)
    lod = lod or CharacterEnum.LOD.HD
    local list = outAssetList and outAssetList or {}
    if partKeys ~= nil then
        for _, partKey in ipairs(partKeys) do
            local assetPath = CharacterUtil.GetPartAssetPath(partKey, lod)
            if assetPath ~= nil then
                table.insert(list, assetPath)
            end
        end
    end
    return list
end

---根据ModelKey获取部件AssetPath
---@param modelKey string
---@return string 部件AssetPath
function CharacterUtil.GetAssetPathWithModelKey(modelKey)
    return getAssetPathWithModelKey(modelKey)
end

return CharacterUtil