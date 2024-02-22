local function getCurrentDir()
    local function sum(a, b)
        return a + b
    end
    local info = debug.getinfo(sum)
    local path = info.source
    path = string.sub(path, 2, -1) -- 去掉开头的"@"
    path = string.gsub(path, '\\', '/')
    path = string.match(path, "^(.*)/") -- 捕获最后一个 "/" 之前的部分 就是我们最终要的目录部分
    return path
end

local cur_path = getCurrentDir()
local root_path = string.gsub(cur_path, "/PostProcess", "")

print("--------启动lua后处理--------")

--- 所有配置表后处理入口
require("LuaStart")
require("Editor.Misc.CfgTools.BaseCfgHandler")

-------------------------------Start：顺序很重要，CfgTypeDefine必须在最后，因为CfgTypeDefine改变了全局函数，比如FInt
require("Editor.Misc.CfgTools.CfgTypeDefine")
-------------------------------End：顺序很重要，CfgTypeDefine必须在最后，因为CfgTypeDefine改变了全局函数，比如FInt

---抓取敏感词数据
---@class GenDBByCMS:BaseCfgHandler
local GenDBByCMS = class("GenDBByCMS", BaseCfgHandler)
local DBHelper = require("Runtime.Common.DBHelper")
require("Runtime.Common.Utils.JsonUtil")
LanguageTag = {
    --中文简体（中国大陆）
    ZH_CN = "zh-CN",
    --中文繁体（港澳台）
    ZH_TW = "zh-TW",
    --英文
    EN_US = "en-US",
    --日本语
    JA_JP = "ja-JP",
    --韩国语
    KO_KR = "ko-KR"
}
Locale = require("Runtime.System.X3Game.Modules.Locale.Locale")
--- 大区 3，4，5都使用3 区数据
CMSLangTag = {
    [Locale.Region.ChinaMainland] = LanguageTag.ZH_CN,
    [Locale.Region.ChinaOther] = LanguageTag.ZH_TW,
    [Locale.Region.EuropeAmericaAsia] = LanguageTag.EN_US,
    [Locale.Region.Japan] = LanguageTag.EN_US,
    [Locale.Region.SouthKorea] = LanguageTag.EN_US,
}

local assetPath = CS.UnityEngine.Application.dataPath
local tablePath = string.gsub(assetPath, "Client/Assets", "Binaries/Tables/DirtyWords/Locale")
local dBFolderPathFormat = tablePath .. "/%s/DBCfg"
local dBPath = tablePath .. "/%s/DBCfg/%s.db"
local jsonPath = tablePath .. "/%s/DBCfg/%s.json"

function GenDBByCMS:Execute()
    local jsonName = ""
    ---生成敏感词DB  国服和海外逻辑不一样，分开处理
    if Locale.GetRegion() == Locale.Region.ChinaMainland then
        jsonName = "DirtyWords"
        self:GenByLanguage(CMSLangTag[Locale.GetRegion()], jsonName, false)
        jsonName = "RegionDirtyWords"
        self:GenByLanguage(CMSLangTag[Locale.GetRegion()], jsonName, true)
    else
        ---自定义标签
        jsonName = "RegionDirtyWords"
        for k, v in pairs(CMSLangTag) do
            if k ~= Locale.Region.ChinaMainland then
                self:GenByLanguage(v, jsonName, true)
            end
        end
    end
    print("[GenDBByCMS]生成结束")
end

---生成多语言铭感词DB文件
---@param language string
---@param jsonName string
---@param isCustom bool
function GenDBByCMS:GenByLanguage(language, jsonName, isCustom)
    ---生成到目录
    local jsonFullPath = string.format(jsonPath, language, jsonName)
    if not io.exists(jsonFullPath) then
        ---不存在就不创建数据库
        return
    end
    ---print("[GenDBByCMS] GenByLanguage: ", cfgPath)
    local file = io.open(jsonFullPath, "r")
    local jsonTxt = file:read('*all')
    file:close()
    jsonTxt = JsonUtil.Decode(jsonTxt)
    local record = jsonTxt.wordlist
    local version = jsonTxt.version
    version = version and tonumber(version) or 0
    if not record then
        print("[GenDBByCMS] not record: ", jsonFullPath)
        return
    end
    ---记录头word
    local recordDict = {}
    local len = #record
    ---print("[GenDBByCMS] len: ", len)
    for i = 1, len do
        local word = record[i]
        local wordDict = nil
        for p, c in utf8.codes(word) do
            wordDict = { id = c, value = word }
            break
        end
        ---print(word)
        table.insert(recordDict, wordDict)
    end
    ---print("[GenDBByCMS] #recordDict: ", #recordDict)
    ---json
    local sqliteTable = {}
    for _, recordData in ipairs(recordDict) do
        local isFind = false
        for i = 1, #sqliteTable do
            local sqliteData = sqliteTable[i]
            if sqliteData.id == recordData.id then
                isFind = true
                table.insert(sqliteData.value, recordData.value)
                sqliteTable[i] = sqliteData
                break
            end
        end
        if isFind == false then
            local value = {}
            table.insert(value, recordData.value)
            table.insert(sqliteTable, { id = recordData.id, value = value })
        end
    end
    ---print("[GenDBByCMS] #sqliteTable: ", #sqliteTable)
    table.sort(sqliteTable, function(a, b)
        return a.id < b.id
    end)
    local id_table = {}
    for i = 1, #sqliteTable do
        local sqliteData = sqliteTable[i]
        ---从大到小(为了优先命中大的,命中就跳过)
        table.sort(sqliteData.value, function(a, b)
            local lenA = utf8.len(a)
            local lenB = utf8.len(b)
            if lenA ~= lenB then
                return lenA > lenB
            end
            return false
        end)
        local tmp = {}
        for _, v in ipairs(sqliteData.value) do
            local len = utf8.len(v)
            table.insert(tmp, len)
            table.insert(tmp, v)
        end
        sqliteData.value = tmp
        sqliteTable[i] = sqliteData
        id_table[sqliteData.id] = { value = sqliteData.id }
    end
    ---sqlite
    local dbFolderPath = string.format(dBFolderPathFormat, language)
    local dbPath = string.format(dBPath, language, "DirtyWords")
    if io.exists(dbPath) then
        ---自定义标签的数据库不需要删除,需要在之前的基础上添加
        if not isCustom then
            os.remove(dbPath)
        end
    end
    local helper = DBHelper.new(dbPath)
    local tableName = isCustom and "RegionDirtyWords" or "DirtyWords"
    local data1 = sqliteTable[1]
    helper:CreateTable(tableName, {
        [data1.id] = {
            value = data1.value
        }
    })
    helper:AddValues(tableName, sqliteTable)
    ---写入自定义标签的版本号
    if isCustom then
        helper:CreateTable("Prefs", { [1] = { value = version } })
        helper:Add("Prefs", 1, { value = version })
    end
    ---处理HashID
    local idTableName = isCustom and "RegionDirtyWordsId" or "DirtyWordsId"
    helper:CreateTable(idTableName, { [1] = { value = 1 } })
    helper:AddValues(idTableName, id_table)
    helper:Close()
    return true
end

---执行导表
GenDBByCMS:Execute()

return GenDBByCMS












