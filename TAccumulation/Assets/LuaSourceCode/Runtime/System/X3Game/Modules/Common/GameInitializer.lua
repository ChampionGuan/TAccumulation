--- X3@PapeGames
--- GameInitializer
--- Created by Tungway
--- Created Date: 2021/9/07

---@class GameInitializer
local GameInitializer = {}

---初始场景相关的数据信息
function GameInitializer.InitSceneInfo()
    Debug.Log("InitSceneInfo...")
    local cfgList = LuaCfgMgr.GetAll("SceneInfo")
    local updateScenePathDict = CS.PapeGames.X3.Res.UpdateScenePathDict
    local updateNavMeshPathDict = CS.PapeGames.X3.Res.UpdateNavMeshAssetPathDict
    local navMeshPath = "Assets/Build/Art/Scene/NavMeshes/{0}.asset"
    if cfgList then
        for _, v in pairs(cfgList) do
            updateScenePathDict(v.SceneName, v.ScenePath)
            updateNavMeshPathDict(v.SceneName, string.concat(navMeshPath, v.SceneName))
        end
    end
end

---Init emoji info for rich text
function GameInitializer.InitEmojiInfo()
    Debug.Log("InitEmojiInfo...")
    local cs_func = CS.X3Game.X3RichTextEntry.UpdateEmojiFileName
    local cfgList = LuaCfgMgr.GetAll("Emoji")
    for k, v in pairs(cfgList) do
        cs_func(UITextHelper.GetUIText(v["Name"]), v["FileName"])
    end
end

---初始化
function GameInitializer.Init()
    GameInitializer.InitSceneInfo()
    GameInitializer.InitEmojiInfo()
    GameInitializer.InitGameSetting()
end

function GameInitializer.InitGameSetting()
    ---initialize TMPSettings
    CS.X3Game.X3GameSettings.Destroy()
    CS.TMPro.TMP_Settings.InjectIns(CS.X3Game.X3GameSettings.Instance.TMPSettings)
    local leadingCharacters = CS.TMPro.TMP_Settings.leadingCharacters.text
    local followingCharacters = CS.TMPro.TMP_Settings.followingCharacters.text
    CS.PapeGames.X3UI.RichText.SetLeadingAndFollowingWords(leadingCharacters, followingCharacters)

    CS.PapeGames.CutScene.CutSceneCollector.InjectIns(CS.X3Game.X3GameSettings.Instance.CutSceneCollector)
    local uiSettingsIns = CS.X3Game.X3GameSettings.Instance.UISettings
    CS.PapeGames.X3UI.UISystem.Settings = uiSettingsIns

    --提前初始化Cts相关表格，防止Lazy模式第一次初始化json解析卡顿 start --
    local tableToMessagePacker = PoolUtil.GetTable()
    local partConfigAll = table.clone(LuaCfgMgr.GetAll("PartConfig"), true)
    if partConfigAll then
        table.dictoarray(partConfigAll, tableToMessagePacker)
        CS.X3.Testbed.TablePartConfig.Inject(tableToMessagePacker)
        table.clear(tableToMessagePacker)
    end

    local modelAssetAll = table.clone(LuaCfgMgr.GetAll("ModelAsset"), true)
    if modelAssetAll then
        table.dictoarray(modelAssetAll, tableToMessagePacker)
        CS.X3.Testbed.TableModelAsset.Inject(tableToMessagePacker)
        table.clear(tableToMessagePacker)
    end
    local cutSceneAssetAll = table.clone(LuaCfgMgr.GetAll("CutSceneAsset"), true)
    if cutSceneAssetAll then
        table.dictoarray(cutSceneAssetAll, tableToMessagePacker)
        CS.PapeGames.CutScene.CutSceneAssetCfg.Inject(tableToMessagePacker)
        table.clear(tableToMessagePacker)
    end
    PoolUtil.ReleaseTable(tableToMessagePacker)
    --提前初始化Cts相关表格，防止Lazy模式第一次初始化json解析卡顿 end --
end

return GameInitializer