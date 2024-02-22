﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jianxin.
--- DateTime: 2022/4/24 14:04
---

local SubPackageConst = class("SubPackageConst")

--region new

---@class SubPackageConst.AssetResData
---@field type string
---@field source string
---@field value any
---@field force bool
---@field examineInclude int

---@class SubPackageConst.AssetResTab
---@field TypeKeyTab table<string,table<SubPackageConst.AssetResData>>

---@class SubPackageConst.TableKeyData
---@field key any
---@field assetDataTab SubPackageConst.AssetResData[]


---@class SubPackageConst.EditorPackageData
---@field packageID int
---@field assetDataTab SubPackageConst.AssetResData[]

SubPackageConst.ResType = {
    SceneInfo = "SceneInfo",
    MusicFunctionBGMStateConnect = "MusicFunctionBGMStateConnect",
    RoleClothSuit = "RoleClothSuit",
    RoleBaseModelAsset = "RoleBaseModelAsset",
    PartConfig = "PartConfig",
    ModelAsset = "ModelAsset",
    CutScene = "CutScene",
    WWise = "WWise",
    WWiseState = "WWiseState",
    Prefab = "Prefab",
    TextureAbbr1 = "TextureAbbr1",
    Video = "Video",
    AnimationClip = "AnimationClip",
    LipSync = "LipSync",
    ProceduralAnimClip = "ProceduralAnimClip",
    Dialogue = "Dialogue",
    UIAbbr1 = "UIAbbr1",
    FSM = "FSM",
}

SubPackageConst.DataType = {
    UIAbbr1 = "Res.UIAbbr1",
}

return SubPackageConst