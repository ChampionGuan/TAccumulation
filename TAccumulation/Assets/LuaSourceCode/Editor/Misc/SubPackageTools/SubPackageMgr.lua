---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2021-02-24 14:15:29
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class SubPackageMgr
local SubPackageMgr = {}

local tempPath = string.concat(CS.UnityEngine.Application.dataPath, "/../Library/ResourcesPacker/")
local APackageID = 0
local this = SubPackageMgr
local DialogueSubPackageUtil = require("Editor.Dialogue.DialogueSubPackageUtil")
local FileUtility = CS.PapeGames.X3.FileUtility
local CSEnumToInt = CS.System.Convert.ToInt32
---@class DebugHandleType 操作类型
local DebugHandleType = CS.X3GameEditor.SubPackage.DebugHandleType

function SubPackageMgr:Init()
    ---@type table<string,SubPackageConst.AssetResData>
    self.resKeyTab = {}
    ---@type string[]
    self.TableNameTab = {}
    ---@type SubPackageConst.TableKeyData[]
    self.tableKeyTab = {}
    ---@type SubPackageConst.EditorPackageData[]
    self.packageTab = {}

    ---@type table<string, DebugDeprecateHandleType> 弃用类型
    self.HandleCacheTab = {}

    ---@type table 对索引表的访问缓存
    self.ExcelIndexCache = {}
    TableTypeTools:SetIndexCallback(self.FillExcelIndexCache)

    ---@type table 临时处理下，记录dialog对wwise资源引用，后续拓展为全资源的引用链
    self.DialogueWwiseCache = {}
    self.DialogueWwiseCache.EventDic = {}
    self.DialogueWwiseCache.StateDic = {}

    self.GetExcelResKeyTab()
    self.GetTableJson()
    self.GetPackageTab()
    self.ExeDialogueToResData()
    local JsonTab = {}
    JsonTab.resKeyTab = self.resKeyTab
    JsonTab.tableKeyTab = self.tableKeyTab
    JsonTab.packageTab = self.packageTab
    ---clone时会去除元表，所以需要clone下
    local jsonStr = JsonUtil.Encode(table.clone(JsonTab))
    FileUtility.WriteText(string.concat(tempPath, "assetData.json"), jsonStr)
    self:BuildAvailableUIAbbrFile()
    self:BuildHandleCache()

    ---Excel访问缓存
    JsonTab = {}
    JsonTab.dataList = self.ExcelIndexCache
    jsonStr = JsonUtil.Encode(table.clone(JsonTab))
    FileUtility.WriteText(string.concat(tempPath, "LuaExcelIndexCache.json"), jsonStr)

    ---DialogWwise缓存
    JsonTab = {}
    JsonTab.dataList = self.DialogueWwiseCache
    jsonStr = JsonUtil.Encode(table.clone(JsonTab))
    FileUtility.WriteText(string.concat(tempPath, "DialogueWWiseCache.json"), jsonStr)
end

---仅为快速Debug出包所用
function SubPackageMgr:InitForFastBuild()
    ---@type table<string,SubPackageConst.AssetResData>
    self.resKeyTab = {}
    ---@type string[]
    self.TableNameTab = {}
    ---@type SubPackageConst.TableKeyData[]
    self.tableKeyTab = {}
    ---@type SubPackageConst.EditorPackageData[]
    self.packageTab = {}
    self.GetExcelResKeyTabForFastBuild()
    self.GetTableJson()
    local JsonTab = {}
    JsonTab.resKeyTab = self.resKeyTab
    JsonTab.tableKeyTab = self.tableKeyTab
    JsonTab.packageTab = self.packageTab
    ---clone时会去除元表，所以需要clone下
    local jsonStr = JsonUtil.Encode(table.clone(JsonTab))
    FileUtility.WriteText(string.concat(tempPath, "assetData.json"), jsonStr)
end

---用于生成分包搜集的可用图片列表文件
function SubPackageMgr:BuildAvailableUIAbbrFile()
    if (self.resKeyTab and self.resKeyTab[SubPackageConst.ResType.UIAbbr1]) then
        local jsonStr = JsonUtil.Encode(table.clone(self.resKeyTab[SubPackageConst.ResType.UIAbbr1]))
        FileUtility.WriteText(string.concat(tempPath, "AvailableUIAbbr.json"), jsonStr)
    end
end

---用于记录分包中被弃用的原因
function SubPackageMgr:BuildHandleCache()
    if (self.HandleCacheTab) then
        local JsonTab = {}
        JsonTab.deprecateHandleTab = self.HandleCacheTab
        ---无需克隆，没有元表问题
        local jsonStr = JsonUtil.Encode(JsonTab)
        FileUtility.WriteText(string.concat(tempPath, "HandleCache.json"), jsonStr)
    end
end

--region lua输出配置相关json 不处理逻辑，逻辑放到c#处理

---仅为快速Debug打包所用
function SubPackageMgr.GetExcelResKeyTabForFastBuild()
    local assetTablePath = string.concat(CS.UnityEngine.Application.dataPath, "/../../Binaries/Tables/Output/assets_table_debug.json")
    if not CS.System.IO.File.Exists(assetTablePath) then
        Debug.LogError("assets_table_debug File Not Exist!!")
        Debug.LogError("基础信息不存在，请执行 Program Binaries Tables Tools生成数据(资源分析).bat")
        return
    end
    local jsonStr = io.readfile(assetTablePath)
    local jsonTab = JsonUtil.Decode(jsonStr)
    for i, assets in ipairs(jsonTab) do
        for k, value1 in pairs(assets) do
            if k == "Table" then
                this.GetResWithTableTitle(value1, assets, assets.ExamineInclude)
            end
        end
    end
end

---处理assets_table_debug.json
function SubPackageMgr.GetExcelResKeyTab()
    local assetTablePath = string.concat(CS.UnityEngine.Application.dataPath, "/../../Binaries/Tables/Output/assets_table_debug.json")
    if not CS.System.IO.File.Exists(assetTablePath) then
        Debug.LogError("assets_table_debug File Not Exist!!")
        Debug.LogError("基础信息不存在，请执行 Program Binaries Tables Tools生成数据(资源分析).bat")
        return
    end
    local jsonStr = io.readfile(assetTablePath)
    local jsonTab = JsonUtil.Decode(jsonStr)
    for i, assets in ipairs(jsonTab) do
        for k, value1 in pairs(assets) do
            if k == "Table" then
                this.GetResWithTableTitle(value1, assets.ExamineInclude)
            elseif k == "Mix" then
                this.GetResWithMixTitle(value1, assets.ExamineInclude)
            end
        end
        local data = assets.Res
        for type, valueList in pairs(data) do
            for source, value in pairs(valueList) do
                ---@type SubPackageConst.AssetResData
                local assetValue = {}
                assetValue.type = type
                assetValue.value = value
                assetValue.source = source
                assetValue.examineInclude = assets.ExamineInclude
                this.AddResKey(this.resKeyTab, assetValue)
            end
        end
    end
end

---向来源中增加force标签
function SubPackageMgr.CheckForceState(type, fileName)
    --if(type == SubPackageConst.ResType.UIAbbr1) then
    --    local data = TableTypeTools:GetSourceData(fileName)
    --    if(data and data.Force == 1) then
    --        return true
    --    end
    --end
    --return false
end

---处理分包数据
function SubPackageMgr.GetPackageTab()
    ---@type cfg.SubModule[]
    local subModuleTab = LuaCfgMgr.GetAll("SubModule")
    for k, v in pairs(subModuleTab) do
        if k == 1002 then
            Debug.Log(k)
        end
        ---@type SubPackageConst.EditorPackageData
        local packageData = {}
        packageData.packageID = v.ID
        packageData.assetDataTab = {}
        for i, key in ipairs(v.KeyArray) do
            local tempAssetDataTab = this.GetSubPackageTableTitleData(key, v.TableName)
            for _, assetData in ipairs(tempAssetDataTab) do
                this.AddResKey(packageData.assetDataTab, assetData)
            end
        end
        this.packageTab[#this.packageTab + 1] = packageData
    end
end

---@param fieldStr string  CommonStageEntry.ChapterInfoID
---@param key any
---@param forceValue int 0为false, 1为true
---@param examineInclude int
---@return SubPackageConst.AssetResData[]
function SubPackageMgr.GetPackageTitleData(key, fieldStr, forceValue, examineInclude)
    local AssetResDataTab = {}
    local strTab = string.split(fieldStr, ".")
    if strTab[1] == "Package" then
        local tableName = strTab[2]
        ---AssetX:Package.Table  处理表名为key的所有配置表数据
        if tableName == "Table" then
            local dataTab = LuaCfgMgr.GetAll(key)
            ---配置表可能为空
            if not table.isnilorempty(dataTab) then
                for k, v in pairs(dataTab) do
                    local CfgTypeTab = TableTypeTools:GetTableType()[key]
                    for k1, v1 in pairs(CfgTypeTab) do
                        table.insertto(AssetResDataTab, this.GetPackageTitleData(v[k1], v1.DataType, ((not forceValue) or forceValue == 0) and v1.Force or forceValue, v.ExamineInclude))
                    end
                end
            end
        else
            ---AssetX:Package.xxx.yyy  处理表名为xxx的 yyy字段和key的所有匹配项
            local fieldName = strTab[3]
            local condition = {}
            condition[fieldName] = key
            local dataTab = LuaCfgMgr.GetListByCondition(tableName, condition)
            for k, v in pairs(dataTab) do
                local CfgtypeTab = TableTypeTools:GetTableType()[tableName]
                if not table.isnilorempty(CfgtypeTab) then
                    for k1, v1 in pairs(CfgtypeTab) do
                        table.insertto(AssetResDataTab, this.GetPackageTitleData(v[k1], v1.DataType, ((not forceValue) or forceValue == 0) and v1.Force or forceValue, v.ExamineInclude))
                    end
                else
                    Debug.LogError(tableName)
                end
            end
        end
    else
        if strTab[1] == "Table" then
            local tableName = strTab[2]
            local assetDataTab = TableTypeTools:GetTableTypeRes(tableName, key, nil, examineInclude)
            for k, v in pairs(assetDataTab) do
                if ((not forceValue) or (forceValue == 0)) then
                    table.insert(AssetResDataTab, v)
                else
                    table.insert(this.HandleCacheTab, { value = key, type = CSEnumToInt(DebugHandleType.ForceNoB) })
                end
            end
        elseif strTab[1] == "Res" then
            ---force状态时，不再填充B包数据
            if ((not forceValue) or (forceValue == 0)) then
                ---@type SubPackageConst.AssetResData
                local assetValue = {}
                assetValue.type = strTab[2]
                assetValue.value = key
                assetValue.examineInclude = examineInclude
                AssetResDataTab[#AssetResDataTab + 1] = assetValue
            elseif (forceValue and forceValue == 1) then
                table.insert(this.HandleCacheTab, { value = key, type = CSEnumToInt(DebugHandleType.ForceNoB) })
            end
        elseif strTab[1] == "Mix" then
            local mixType = strTab[2]
            local tab = { key }
            local assetDataTab = MixTypeTools:MixTypeDisposeWithType(mixType, tab, examineInclude)
            for k, v in pairs(assetDataTab) do
                if ((not forceValue) or (forceValue == 0)) then
                    table.insert(AssetResDataTab, v)
                else
                    table.insert(this.HandleCacheTab, { value = key, type = CSEnumToInt(DebugHandleType.ForceNoB) })
                end
            end
        end
    end
    return AssetResDataTab
end

---@param fieldStr string  ChapterInfo.ID|int
---@param key string
---@return SubPackageConst.AssetResData[]
function SubPackageMgr.GetSubPackageTableTitleData(key, fieldStr)
    local strTab = string.split(fieldStr, "|")
    local type = strTab[2]
    if type == "int" then
        key = tonumber(key)
    end
    return this.GetPackageTitleData(key, strTab[1])
end

---处理Table数据
function SubPackageMgr.GetTableJson()
    for _, tableName in ipairs(this.TableNameTab) do
        local dataTab_cfg = LuaCfgMgr.GetAll(tableName)
        for k, v in pairs(dataTab_cfg) do
            ---@type SubPackageConst.AssetResData[]
            local assetResData = TableTypeTools:GetTableKeyRes(tableName, v)
            ---@type SubPackageConst.TableKeyData
            local tableKeyData = {}
            tableKeyData.key = k
            if not table.isnilorempty(assetResData) then
                tableKeyData.assetDataTab = {}
                for _, assetData in ipairs(assetResData) do
                    this.AddResKey(tableKeyData.assetDataTab, assetData)
                end
            end
            this.AddTableKeyTab(tableName, tableKeyData)
        end
    end
end

---@param tableKeyData SubPackageConst.TableKeyData
function SubPackageMgr.AddTableKeyTab(tableName, tableKeyData)
    if this.tableKeyTab[tableName] == nil then
        this.tableKeyTab[tableName] = {}
    end
    local count = #this.tableKeyTab[tableName]
    this.tableKeyTab[tableName][count + 1] = tableKeyData
end


----处理原数据

---@param tableData table<string,table<string,int|string>>
---@param examineInclude int
function SubPackageMgr.GetResWithTableTitle(tableData, examineInclude)
    for tableName, value in pairs(tableData) do
        this.TableNameTab[#this.TableNameTab + 1] = tableName
        ---@type table<string,any>
        local assetResDataTab = value
        for source, tableValue in pairs(assetResDataTab) do
            local assetResDataTab = TableTypeTools:GetTableTypeRes(tableName, tableValue, source, examineInclude)
            this.AddResKeyTab(assetResDataTab)
            this.FillExcelIndexCache(tableName, tableValue, source)
        end
    end
end

---@param tableData table<string,table<string,int|string>>
------@param examineInclude int
function SubPackageMgr.GetResWithMixTitle(tableData, examineInclude)
    local assetResDataTab = MixTypeTools:MixTypeDispose(tableData, examineInclude)
    this.AddResKeyTab(assetResDataTab)
end

---@param assetDataTab SubPackageConst.AssetResData[]
function SubPackageMgr.AddResKeyTab(assetDataTab)
    if table.isnilorempty(this.resKeyTab) then
        this.resKeyTab = {}
    end
    for i, v in ipairs(assetDataTab) do
        this.AddResKey(this.resKeyTab, v)
    end
end

---@param originalTab table<string,SubPackageConst.AssetResData[]>
---@param assetData SubPackageConst.AssetResData
function SubPackageMgr.AddResKey(originalTab, assetData)
    if assetData == nil then
        return
    end
    if assetData.type == nil then
        Debug.LogTable(assetData)
    end
    if table.isnilorempty(originalTab[assetData.type]) then
        originalTab[assetData.type] = {}
    end
    local count = #originalTab[assetData.type]
    originalTab[assetData.type][count + 1] = assetData
end

function SubPackageMgr.ExeDialogueToResData()
    this.DialogueConversionResKey(this.resKeyTab)
    for k, v in pairs(this.tableKeyTab) do
        this.DialogueConversionResKey(v.assetDataTab)
    end
    for k, v in pairs(this.packageTab) do
        this.DialogueConversionResKey(v.assetDataTab)
    end
end

---@param assetResDataTab table<string,SubPackageConst.AssetResData[]>
function SubPackageMgr.DialogueConversionResKey(assetResDataTab)
    if assetResDataTab == nil then
        return
    end
    if assetResDataTab[SubPackageConst.ResType.Dialogue] ~= nil then
        ---@type SubPackageConst.AssetResData[]
        local dialogueTitleTab = assetResDataTab[SubPackageConst.ResType.Dialogue]
        for k, v in pairs(dialogueTitleTab) do
            ---@type SubPackageConst.AssetResData[]
            local tempAssetTab = this.GetDialogResKeyTab(v.value, v.source, v.examineInclude)
            for i, assetResData in ipairs(tempAssetTab) do
                this.AddResKey(assetResDataTab, assetResData)
            end
        end
        assetResDataTab[SubPackageConst.ResType.Dialogue] = nil
    end
end

---dialog 处理
---dialog 需要拆成对应的Res类型
---@param dialogName string
---@param source string 来源
---@param examineInclude int
---@return SubPackageConst.AssetResData[]
function SubPackageMgr.GetDialogResKeyTab(dialogName, source, examineInclude)
    local assetDataTab = {}
    local timeLineTab = DialogueSubPackageUtil.GetAllResPath(dialogName)
    if table.isnilorempty(timeLineTab) then
        return assetDataTab
    end
    for k, v in pairs(timeLineTab) do
        --处理table类型
        if k == SubPackageConst.ResType.SceneInfo or k == SubPackageConst.ResType.RoleClothSuit or k == SubPackageConst.ResType.RoleBaseModelAsset or k == SubPackageConst.ResType.PartConfig or k == SubPackageConst.ResType.ModelAsset then
            for i, v1 in ipairs(v) do
                local tempAssetResDataTab = TableTypeTools:GetTableTypeRes(k, v1, source, examineInclude)
                for _, assetResData in ipairs(tempAssetResDataTab) do
                    assetDataTab[#assetDataTab + 1] = assetResData
                end
            end
            --处理RES类型
        elseif k == SubPackageConst.ResType.CutScene or k == SubPackageConst.ResType.WWise or k == SubPackageConst.ResType.Prefab or k == SubPackageConst.ResType.TextureAbbr1 or k == SubPackageConst.ResType.Video or k == SubPackageConst.ResType.UIAbbr1 or k == SubPackageConst.ResType.FSM then
            ---11.9 新增FSM 类型 Res.FSM
            for i, v1 in ipairs(v) do
                ---@type SubPackageConst.AssetResData
                local assetValue = {}
                assetValue.type = k
                assetValue.value = v1
                assetValue.source = source
                assetValue.examineInclude = examineInclude
                assetDataTab[#assetDataTab + 1] = assetValue
                --临时处理下wwise引用链的需求
                if (k == SubPackageConst.ResType.WWise) then
                    SubPackageMgr.FillDialogueWwiseData(dialogName, v1, nil, source)
                end
            end
            --不区分类型，默认用prefab(指不做任何处理，即解析或逻辑处理)(--todo名字后面改下)
        elseif k == SubPackageConst.ResType.AnimationClip or k == SubPackageConst.ResType.LipSync or k == SubPackageConst.ResType.ProceduralAnimClip then
            for i, v1 in ipairs(v) do
                ---@type SubPackageConst.AssetResData
                local assetValue = {}
                assetValue.type = SubPackageConst.ResType.Prefab
                assetValue.value = v1
                assetValue.source = source
                assetValue.examineInclude = examineInclude
                assetDataTab[#assetDataTab + 1] = assetValue
            end
        elseif k == SubPackageConst.ResType.MusicFunctionBGMStateConnect then
            for i, v1 in ipairs(v) do
                ---@type SubPackageConst.AssetResData
                local assetValue = {}
                assetValue.type = SubPackageConst.ResType.WWiseState
                assetValue.value = v1
                assetValue.source = source
                assetValue.examineInclude = examineInclude
                assetDataTab[#assetDataTab + 1] = assetValue

                --临时处理下wwise引用链的需求
                SubPackageMgr.FillDialogueWwiseData(dialogName, nil, v1, source)
            end
        end
    end
    return assetDataTab
end

function SubPackageMgr.FillDialogueWwiseData(dialogName, eventName, stateName, source)

    local baseDic = eventName and this.DialogueWwiseCache.EventDic or this.DialogueWwiseCache.StateDic
    local baseName = eventName or stateName
    if (not baseDic[baseName]) then
        baseDic[baseName] = {}
    end
    if (not baseDic[baseName][dialogName]) then
        baseDic[baseName][dialogName] = {}
    end
    if (source) then
        baseDic[baseName][dialogName][source] = true
    end

end

function SubPackageMgr.JointTab(baseTab, jointTab)
    if table.isnilorempty(jointTab) then
        return
    end
    for i, v in ipairs(jointTab) do
        if not table.indexof(baseTab, v) then
            baseTab[#baseTab + 1] = v
        end
    end
end

---记录对索引表的缓存
function SubPackageMgr.FillExcelIndexCache(tableName, key, origin)
    if (this.ExcelIndexCache) then
        local assetValue = {}
        assetValue.tableName = tableName
        assetValue.key = key
        assetValue.origin = origin
        table.insert(this.ExcelIndexCache, assetValue)
    end
end

return SubPackageMgr