﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by doudou.
--- DateTime: 2023/5/18 14:34
---@class FaceLocalDataUtil @捏脸数据本地化Util
local FaceLocalDataUtil = {}
local FaceEditUtil = require("Runtime.System.X3Game.Modules.FaceEdit.FaceEditUtil")
local FaceEditConst = require("Runtime.System.X3Game.GameConst.FaceEditConst")
local FaceLocalDataConst = require("Runtime.System.X3Game.GameConst.FaceLocalDataConst")

---@return string @本地数据的key
function FaceLocalDataUtil.GetPrefsKeyLocalData()
    local loginBll = BllMgr.GetLoginBLL()
    local id = loginBll:GetAccountInfo().Account
    if SDKMgr.IsHaveSDK() then
        id = SDKMgr.GetNid()
    end
    return string.format("%s%s%s", id, loginBll:GetServerId(), FaceEditConst.PrefsHeader_SaveLocalData)
end

function FaceLocalDataUtil.GetCurrentLocalVersion()
    return FaceLocalDataConst.CurrentVersion
end

function FaceLocalDataUtil.GetAllKey(versionId, includeVoice)
    versionId = versionId or FaceLocalDataUtil.GetCurrentLocalVersion()
    if not FaceLocalDataConst.LocalInfoDict[versionId] then
        return nil
    end

    local keys = {}

    -- 骨骼
    local allBones = LuaCfgMgr.GetAll("FaceBoneDetail")
    local boneIds = {}
    for _, v in pairs(allBones) do
        table.insert(boneIds, FaceEditUtil.GetKey(FaceEditConst.MainType.Bone, nil, v.ID))
    end
    table.sort(boneIds, function(a, b)
        return a < b
    end)

    for i = 1, #boneIds do
        table.insert(keys, { boneIds[i], 1 })
    end

    local dic = FaceLocalDataConst.LocalInfoDict[versionId] or {}
    for i = 1, #dic do
        table.insert(keys, dic[i])
    end

    if includeVoice then
        local voiceList = FaceLocalDataConst.LocalVoiceDict[versionId] or {}
        for i = 1, #voiceList do
            table.insert(keys, voiceList[i])
        end
    end

    return keys
end

function FaceLocalDataUtil.IsConvertFloatValue(mainKey, subType, propKey)
    return mainKey == FaceEditConst.MainType.Bone or
            mainKey == FaceEditConst.MainType.Voice or
            (mainKey == FaceEditConst.MainType.Makeup and (propKey == FaceEditConst.EditPropType.Density or propKey == FaceEditConst.EditPropType.SubDensity)) or
            (mainKey == FaceEditConst.MainType.Hair and propKey == FaceEditConst.EditPropType.FloatA) or
            propKey == FaceEditConst.EditPropType.PosA_Weight or
            propKey == FaceEditConst.EditPropType.PosB_Weight or
            propKey == FaceEditConst.EditPropType.PosC_Weight
end

function FaceLocalDataUtil.GetCfgName(mainKey, subType, propKey)
    if propKey == FaceEditConst.EditPropType.StyleAndColor or
            propKey == FaceEditConst.EditPropType.PosA_Index or
            propKey == FaceEditConst.EditPropType.PosB_Index or
            propKey == FaceEditConst.EditPropType.PosC_Index or
            propKey == FaceEditConst.EditPropType.EyeRCover or
            propKey == FaceEditConst.EditPropType.EyeLCover then
        if type(FaceEditConst.TypeToCfgDic[mainKey]) == "string" then
            return FaceEditConst.TypeToCfgDic[mainKey]
        elseif type(FaceEditConst.TypeToCfgDic[mainKey]) == "table" then
            return FaceEditConst.TypeToCfgDic[mainKey][subType]
        end
    elseif propKey == FaceEditConst.EditPropType.Gloss or propKey == FaceEditConst.EditPropType.SubGloss then
        return FaceEditConst.CfgNames.LipGloss
    end
end

function FaceLocalDataUtil.GetLocalValue(key, value)
    local mainKey = FaceEditUtil.GetMainTypeByKey(key)
    local subType = FaceEditUtil.GetSubTypeByKey(key)
    local propKey = FaceEditUtil.GetThirdType(key)

    if FaceLocalDataUtil.IsConvertFloatValue(mainKey, subType, propKey) then
        return FaceLocalDataUtil.FloatValueReal2Record(key, value)
    end

    return value * FaceEditConst.ServerDeflateFactor
end

function FaceLocalDataUtil.GetEditValue(key, value, dataVersion)
    if value == 0 then
        return nil
    end

    local mainKey = FaceEditUtil.GetMainTypeByKey(key)
    local subType = FaceEditUtil.GetSubTypeByKey(key)
    local propKey = FaceEditUtil.GetThirdType(key)

    if FaceLocalDataUtil.IsConvertFloatValue(mainKey, subType, propKey) then
        return FaceLocalDataUtil.FloatValueRecord2Real(key, value)
    end

    local rawCfgName = FaceLocalDataUtil.GetCfgName(mainKey, subType, propKey)
    if rawCfgName then
        if dataVersion <= FaceLocalDataConst.LastConvertVersion then
            local convertCfg = LuaCfgMgr.Get(rawCfgName..FaceLocalDataConst.Convert2CfgIdTableSuffix, value)
            if convertCfg then
                return convertCfg.CfgId * FaceEditConst.ServerInflateFactor
            else
                local cfg = LuaCfgMgr.GetAll(rawCfgName)
                if cfg and next(cfg) then
                    EventMgr.Dispatch("FACE_EDIT_IMPORT_OLD_DATA")
                    return cfg[1].ID * FaceEditConst.ServerInflateFactor
                else
                    return nil, true
                end
            end
        else
            return  value * FaceEditConst.ServerInflateFactor
        end
    end

    return value * FaceEditConst.ServerInflateFactor
end

local RECORD_OFFSET = 101
function FaceLocalDataUtil.FloatValueReal2Record(key, value)
    if key == FaceEditUtil.GetKey(FaceEditConst.MainType.Voice, FaceEditConst.VoiceType.Age, FaceEditConst.EditPropType.StyleAndColor) then
        value = value / 10
    end
    local realMin, realMax, limitMin, limitMax = FaceLocalDataUtil.GetValueCovertParams(key)
    value = value * FaceEditConst.ServerDeflateFactor
    local recordValue = 0
    if value < 0 then
        recordValue = FaceLocalDataUtil.ConvertValue(0, realMin, 0, limitMin, value)
    else
        recordValue = FaceLocalDataUtil.ConvertValue(0, realMax, 0, limitMax, value)
    end

    recordValue = math.floor(recordValue) + RECORD_OFFSET
    if recordValue > 255 then
        Debug.LogErrorFormatWithTag(GameConst.LogTag.FaceEdit, "FloatValueReal2Record: key = %d, value = %d, recordValue = %d", key, value, recordValue)
    end
    return recordValue
end

function FaceLocalDataUtil.FloatValueRecord2Real(key, value)
    value = value - RECORD_OFFSET
    local realMin, realMax, limitMin, limitMax = FaceLocalDataUtil.GetValueCovertParams(key)
    local result = value
    if value < 0 then
        result = FaceLocalDataUtil.ConvertValue(0, limitMin, 0, realMin, value)
    else
        result = FaceLocalDataUtil.ConvertValue(0, limitMax, 0, realMax, value)
    end

    if key == FaceEditUtil.GetKey(FaceEditConst.MainType.Voice, FaceEditConst.VoiceType.Age, FaceEditConst.EditPropType.StyleAndColor) then
        result = result * 10
    end
    return math.floor(result * FaceEditConst.ServerInflateFactor)
end

function FaceLocalDataUtil.GetValueCovertParams(key)
    local realMin, realMax, limitMin, limitMax
    local mainType = FaceEditUtil.GetMainTypeByKey(key)
    local subType = FaceEditUtil.GetSubTypeByKey(key)

    if mainType == FaceEditConst.MainType.StyleFace then
        return 0, 1, 0, 100
    end

    if mainType == FaceEditConst.MainType.Voice then
        return -100, 100, -100, 100
    end

    local sundyConfigKey = FaceEditConst.MakeupDensityRealRangeKey[subType]
    local sliderUIRangeKey = FaceEditConst.SliderUIRangeKey[mainType]
    if sliderUIRangeKey then
        local uiRange = LuaCfgMgr.Get("SundryConfig", sliderUIRangeKey)
        limitMin = uiRange.ID
        limitMax = uiRange.Num
    end

    if sundyConfigKey then
        local range = LuaCfgMgr.Get("SundryConfig", sundyConfigKey)
        realMin = range.ID / 1000
        realMax = range.Num / 1000
    elseif mainType == FaceEditConst.MainType.Bone then
        realMin = -1
        realMax = 1
    else
        realMin = 0
        realMax = 1
    end

    return realMin, realMax, limitMin, limitMax
end

function FaceLocalDataUtil.ConvertValue(srcBegin, srcEnd, dstBegin, dstEnd, value)
    if srcBegin == srcEnd or dstBegin == dstEnd then
        return srcBegin
    end

    return (value - srcBegin) / (srcEnd - srcBegin) * (dstEnd - dstBegin) + dstBegin
end

return FaceLocalDataUtil