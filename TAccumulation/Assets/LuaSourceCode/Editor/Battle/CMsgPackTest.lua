require('Runtime.Common.Base.string')
require('Runtime.Common.Base.table')
Debug = require('Runtime.Common.Debug')
require('Runtime.Battle.Logic.Common.BattleEnum')
require("Runtime.Battle.Common.XECS")
require("Runtime.Battle.View.BattleClientUtil")
require("Runtime.Battle.View.BattleClientEnum")
require("Runtime.Battle.View.ResLoad.BattleResMgr")
require("Runtime.System.Framework.Engine.Application")

package.loaded["MsgPack"] = nil
---@type MsgPack
local MsgPack = require("Runtime.Battle.Common.MsgPack")

local MsgPackTest = {}
local testData = {
    strKey = "字符传",
    intKey = 10,
    floatKey = 1.5,
    tableKey = {
        strKey = "字符传",
        intKey = 20,
        floatKey = 2.5,
        tableKey = {
            strKey = "字符传",
            intKey = 20,
            floatKey = 2.5,
        },
    },
    --fixKey = FZero,   --不支持定点数的pack
}

function MsgPackTest:Test()
    self:TestPack()
    self:TestPack2()
    self:TestUnPackOne()
    self:TestUnPackLimit()
    self:TestUnPackLimit2()
end

function MsgPackTest:TestPack()
    Debug.LogError("<<*******TestPack*******>>")
    local packStr = MsgPack.Pack(testData)
    Debug.LogError(packStr)
    local unPackData = MsgPack.Unpack(packStr)
    Debug.LogErrorTable(unPackData)
end

function MsgPackTest:TestPack2()
    Debug.LogError("<<*******TestPack2*******>>")
    local packStr = MsgPack.Pack(testData, "第二个参数")
    Debug.LogError(packStr)
    local unPackData, unPackData2 = MsgPack.Unpack(packStr)
    Debug.LogErrorTable(unPackData)
    Debug.LogError(unPackData2)
end

function MsgPackTest:TestUnPackOne()
    Debug.LogError("<<*******TestUnPackOne*******>>")
    local packStr = MsgPack.Pack(testData, "第二个参数")
    Debug.LogError(packStr)
    local unPackLen, unPackData = MsgPack.UnpackOne(packStr)
    Debug.LogError(unPackLen)
    Debug.LogErrorTable(unPackData)
    -- 结果unpack出 第一个参数
end

function MsgPackTest:TestUnPackLimit()
    Debug.LogError("<<********TestUnPackLimit******>>")
    local packStr = MsgPack.Pack(testData, "第二个参数")
    Debug.LogError(packStr)
    local unPackLen, unPackData, unPackData2 = MsgPack.UnpackLimit(packStr, 2, 0)
    Debug.LogError(unPackLen)
    Debug.LogErrorTable(unPackData)
    Debug.LogError(unPackData2)
    -- 结果unpack出 两个参数
end

function MsgPackTest:TestUnPackLimit2()
    Debug.LogError("<<*******TestUnPackLimit2*******>>")
    local packStr = MsgPack.Pack(testData, "第二个参数")
    Debug.LogError(packStr)
    local unPackLen, unPackData = MsgPack.UnpackLimit(packStr, 1, 138)
    Debug.LogError(unPackLen)
    Debug.LogError(unPackData)
    -- 结果只unpack出 “第二个参数”
end

g_MsgPackTest = MsgPackTest