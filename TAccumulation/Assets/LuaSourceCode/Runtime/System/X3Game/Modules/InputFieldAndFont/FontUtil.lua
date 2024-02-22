﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by kaikai.
--- DateTime: 2/11/2023 6:20 PM
---

---@class FontUtil
---字体操作帮助函数
local FontUtil = {}

local FontAssetPath = {
    [1] = { -- CN
        TmpEdtiorPath = "Assets/Editor/TMPEditor/SourceHanSansCN.asset",
        TmpPath = "Assets/Build/Res/GameObjectRes/FontLocale/SourceHanSansCN.asset",
        FontPath = "Assets/Build/Res/GameObjectRes/FontLocale/MSmartPRC_CN.OTF",
        FontName = "Source Han Serif CN",
    },
    [2] = { -- TW
        TmpEdtiorPath = "Assets/Editor/TMPEditor/SourceHanSansTW.asset",
        TmpPath = "Assets/Build/Res/GameObjectRes/FontLocale/SourceHanSansTW.asset",
        FontPath = "Assets/Build/Res/GameObjectRes/FontLocale/MSmartPRC_TW.otf",
        FontName = "Source Han Serif TW"
    },
    [3] = { -- US
        TmpEdtiorPath = "Assets/Editor/TMPEditor/SourceHanSansUS.asset",
        TmpPath = "Assets/Build/Res/GameObjectRes/FontLocale/SourceHanSansUS.asset",
        FontPath = "Assets/Build/Res/GameObjectRes/FontLocale/MSmartPRC_US.otf",
        FontName = "Kepler Std"
    },
    [4] = { -- JP
        TmpEdtiorPath = "Assets/Editor/TMPEditor/SourceHanSansJP.asset",
        TmpPath = "Assets/Build/Res/GameObjectRes/FontLocale/SourceHanSansJP.asset",
        FontPath = "Assets/Build/Res/GameObjectRes/FontLocale/MSmartPRC_JP.otf",
        FontName = "FOT-Chiaro Std"
    },
    [5] = { -- KR
        TmpEdtiorPath = "Assets/Editor/TMPEditor/SourceHanSansKR.asset",
        TmpPath = "Assets/Build/Res/GameObjectRes/FontLocale/SourceHanSansKR.asset",
        FontPath = "Assets/Build/Res/GameObjectRes/FontLocale/MSmartPRC_KR.otf",
        FontName = "Leferi Point Type"
    }
}

local m_RootTmpAsset
local m_FallbackTmpAssets
local m_RootFontAsset
local m_FallbackFontAssets
local m_TMPSpriteAssets
local m_TMPDynamicFallbackAsset
local m_TMPDynamicFontAsset

---加载字体文件不卸载，跟随 Lua 虚拟机生命周期
---@param curLang Locale.Language
local function LoadFontAsset(curLang)
    if CS.UnityEngine.Application.isBatchMode then
        return
    end

    m_FallbackTmpAssets = {}
    m_FallbackFontAssets = {}
    m_RootTmpAsset = Res.LoadWithAssetPath("Assets/Build/Res/GameObjectRes/FontLocale/SourceHanSans.asset", AutoReleaseMode.None)
    m_RootFontAsset = Res.LoadWithAssetPath("Assets/Build/Res/GameObjectRes/FontLocale/MSmartPRC.OTF", AutoReleaseMode.None)

    local fonts = PoolUtil.GetTable()
    table.insert(fonts, FontAssetPath[curLang])

    -- TMP Fallback List
    local asset = Res.LoadWithAssetPath(fonts[1].TmpPath, AutoReleaseMode.None)
    if asset then
        table.insert(m_FallbackTmpAssets, asset)
    end

    local disableDynmaicTmp = PlayerPrefs.GetBool("disable dynmaic tmp font", false)
    if not disableDynmaicTmp then
        m_TMPDynamicFallbackAsset = Res.LoadWithAssetPath("Assets/Build/Res/GameObjectRes/FontLocale/SourceHanSansDynamic.asset", AutoReleaseMode.None)
        if m_TMPDynamicFallbackAsset then
            m_TMPDynamicFallbackAsset.atlasPopulationMode = CS.TMPro.AtlasPopulationMode.Dynamic
            table.insert(m_FallbackTmpAssets, m_TMPDynamicFallbackAsset)
        end
    end

    -- Font Fallback List
    local fontAsset = Res.LoadWithAssetPath(fonts[1].FontPath, AutoReleaseMode.None)
    if fontAsset then
        table.insert(m_FallbackFontAssets, fontAsset)
    end

    if m_RootTmpAsset then
        m_RootTmpAsset.fallbackFontAssetTable = m_FallbackTmpAssets
        m_RootTmpAsset.faceInfo = m_FallbackTmpAssets[1].faceInfo
    end

    if CS.TMPro.TMP_Settings.instance and not GameObjectUtil.IsNull(CS.TMPro.TMP_Settings.instance) then
        CS.TMPro.TMP_Settings.defaultFontAsset = m_RootTmpAsset
    end

    if UNITY_EDITOR then
        m_TMPSpriteAssets = Res.LoadWithAssetPath("Assets/Build/Res/SourceRes/Font/Emoji/Emoji.asset", AutoReleaseMode.None)
        CS.TMPro.TMP_Settings.defaultSpriteAsset = m_TMPSpriteAssets
    end

    if m_RootFontAsset then
        m_RootFontAsset:ResetFallbackFonts(m_FallbackFontAssets)
    end

    PoolUtil.ReleaseTable(fonts)
end

---尝试预烘培字型
---@param chrs string
function FontUtil.TryBakeCharacters(chrs)
    if m_RootTmpAsset and m_TMPDynamicFallbackAsset and m_TMPDynamicFontAsset then
        m_RootTmpAsset:HasCharacters(chrs, true, true)
    end
end

---强制重新加载字体文件
---@param curLang Locale.Language
function FontUtil.ForceReloadFontAsset(curLang)
    FontUtil.Unload()
    LoadFontAsset(curLang)
end

function FontUtil.Unload()
    if m_TMPDynamicFontAsset then
        Res.Unload(m_TMPDynamicFontAsset)
        m_TMPDynamicFontAsset = nil
    end

    if m_TMPDynamicFallbackAsset then
        if UNITY_EDITOR and not GameObjectUtil.IsNull(m_TMPDynamicFallbackAsset) then
            m_TMPDynamicFallbackAsset:ClearFontAssetData()
        end
        Res.Unload(m_TMPDynamicFallbackAsset)
        m_TMPDynamicFallbackAsset = nil
    end

    if m_RootTmpAsset then
        m_RootTmpAsset.fallbackFontAssetTable = {}
        Res.Unload(m_RootTmpAsset)
    end

    if m_FallbackTmpAssets then
        for _, v in pairs(m_FallbackTmpAssets) do
            Res.Unload(v)
        end
        m_TMPDynamicFallbackAsset = nil
    end

    if m_FallbackFontAssets then
        for _, v in pairs(m_FallbackFontAssets) do
            Res.Unload(v)
        end
    end

    if m_RootFontAsset then
        Res.Unload(m_RootFontAsset)
    end

    if m_TMPSpriteAssets then
        Res.Unload(m_TMPSpriteAssets)
    end

    m_RootTmpAsset = nil
    m_RootFontAsset = nil
    m_FallbackTmpAssets = nil
    m_FallbackFontAssets = nil
    m_TMPSpriteAssets = nil

    CS.TMPro.TMP_MaterialManager.ForceRemoveAllFallbackMaterials()
end

function FontUtil.LoadTMPSpriteAsset()
    m_TMPSpriteAssets = Res.LoadWithAssetPath("Assets/Build/Res/SourceRes/Font/Emoji/Emoji.asset", AutoReleaseMode.None)
    CS.TMPro.TMP_Settings.defaultSpriteAsset = m_TMPSpriteAssets

    local disableDynmaicTmp = PlayerPrefs.GetBool("disable dynmaic tmp font", false)
    if not disableDynmaicTmp then
        m_TMPDynamicFontAsset = Res.LoadWithAssetPath("Assets/Build/Res/GameObjectRes/FontLocale/NotoSansCJKtc-Regular.otf", AutoReleaseMode.None)
        if m_TMPDynamicFallbackAsset and m_TMPDynamicFontAsset then
            m_TMPDynamicFallbackAsset.atlasPopulationMode = CS.TMPro.AtlasPopulationMode.Dynamic
            m_TMPDynamicFallbackAsset.sourceFontFile = m_TMPDynamicFontAsset
        end
    end
end

function FontUtil.UnloadTMPSpriteAsset()

    CS.TMPro.TMP_Settings.defaultSpriteAsset = nil
    if m_TMPSpriteAssets then
        Res.Unload(m_TMPSpriteAssets)
    end
    m_TMPSpriteAssets = nil

    if m_TMPDynamicFallbackAsset then
        m_TMPDynamicFallbackAsset.atlasPopulationMode = CS.TMPro.AtlasPopulationMode.Static
        m_TMPDynamicFallbackAsset.sourceFontFile = nil

        if m_TMPDynamicFontAsset then
            Res.Unload(m_TMPDynamicFontAsset)
            m_TMPDynamicFontAsset = nil
        end
    end

    CS.UnityEngine.Resources.UnloadUnusedAssets()
    CS.System.GC.Collect()
end

---@public 检查字体资产中是否存在某些字符，如果缺少任何字符，函数将返回false
---@param text string 字符串
---@return bool
function FontUtil.HasCharacters(text)
    if not text then
        return true
    end

    if m_FallbackTmpAssets[1]:HasCharacters(text) then
        return true
    end

    return m_TMPDynamicFallbackAsset:HasCharacters(text,false,true)
end

return FontUtil