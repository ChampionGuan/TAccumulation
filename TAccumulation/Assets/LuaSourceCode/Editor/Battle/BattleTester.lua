---
---Created by bayue
---Date: 2020/9/5
---Time: 15:52
---

Mathf = require("Runtime.System.Framework.Base.Mathf")
Vector3 = require("Runtime.System.Framework.Base.Vector3")
Vector3Helper = require("Runtime.System.Framework.Base.Vector3Helper")

require("Runtime.Common.CommonInit")
require("Runtime.Battle.Logic.BattleMgr")
require("LuaCfg.CfgConst")


local pbc = require "pb"
local grpcMgr = require("Runtime.System.X3Game.Modules.Network.GrpcMgr")
Res = require("Runtime.System.X3Game.Modules.ResAndPool.Res")
grpcMgr.Init()

local FileClient = require("Runtime.Battle.View.FileClient")
local GameRecord = require("Runtime.Battle.Logic.ECS.Data.GameRecord")
local ActorSwitchAutoCommand = require("Runtime.Battle.Logic.Actor.Command.ActorSwitchAutoCommand")
local ActorSwitchAutoQTECommand = require("Runtime.Battle.Logic.Actor.Command.ActorSwitchAutoQTECommand")

---@class BattleTester
local BattleTester = XECS.class("BattleTester")

BattleTester.battleTestInputDataConfig = LuaCfgMgr.GetAll("Battle.Config.BattleTestInputData")
BattleTester.battleTestLevelSetConfig = LuaCfgMgr.GetAll("Battle.Config.BattleTestLevelSet")

---@param battleId Int
---@param SCoreSetId Int
---@param weaponSetId Int
---@param uid string
---@param SCoreSetGroupId Int
---@param testID Int
---@param taskCurCount Int
---@param isOutputRecord boolean
---@param isDiffRandSeed boolean
---@param respTxt string req.downloadHandler.text
function BattleTester:Startup(battleId,
                              SCoreSetId,
                              weaponSetId,
                              uid,
                              SCoreSetGroupId,
                              testID,
                              taskCurCount,
                              isOutputRecord,
                              isDiffRandSeed,
                              respTxt)

    local data = JsonUtil.Decode(respTxt)
    if not data["result"] then
        return
    end

    local msgData = CS.System.Convert.FromBase64String(data["result"]["BattleBytes"])
    local tbl, err = pbc.decode("pb.DungeonCreateReply", msgData)

    self:Init(isOutputRecord)
    self:CreateBattle(tbl,
            battleId,
            SCoreSetId,
            weaponSetId,
            uid,
            SCoreSetGroupId,
            testID,
            taskCurCount,
            isDiffRandSeed)
    self:Update()
end

---@param testGroupID Int
function BattleTester:GetTestInputData(testGroupID,scoreSetGroupID)
    local result = {}
    result.scoreSetIDGroup = {}
    result.weaponSetIDGroup = {}
    result.battleIDGroup = {}
    for _,v in pairs(self.battleTestInputDataConfig) do
        if v.TestGroup == testGroupID then
            table.insert(result.scoreSetIDGroup,v.ScoreSetID)
            table.insert(result.weaponSetIDGroup,v.WeaponSetID)
        end
    end

    for _,v in pairs(self.battleTestLevelSetConfig) do
        if v.LevelGroup == scoreSetGroupID then
            table.insert(result.battleIDGroup,v.Capacity)
        end
    end
    self.testConf = result
end

function BattleTester:GetHttpSendBytes(battleId,SCoreSetId,weaponSetId)

    local reqParam = {}
    reqParam.id = "1"
    reqParam.jsonrpc = "2.0"
    reqParam.method = "AdminSvr.CreateLimitDungeonAdmin"
    reqParam.params = {
        StageID = battleId,
        SCoreSetID = SCoreSetId,
        WeaponSetID = weaponSetId,
    }

    local jsonStr = nil
    jsonStr = JsonUtil.Encode(reqParam)

    if not jsonStr then
        return nil
    end

    return jsonStr

end

---@param isOutputRecord boolean
function BattleTester:Init(isOutputRecord)
    local replayPath = nil
    if isOutputRecord then
        replayPath = "../Tools/verifybattle/replays/"
    end
    g_BattleMgr:Init(false, replayPath, FileClient.new())
    g_BattleMgr:Enable(true)
end


function BattleTester:CreateBattle(dungeonData,
                                   battleId,
                                   SCoreSetId,
                                   weaponSetId,
                                   uid,
                                   SCoreSetGroupId,
                                   testID,
                                   taskCurCount,
                                   isDiffRandSeed)
    local IViewBattle = require("Runtime.Battle.Logic.IView.IViewBattle")

    ---@type Int
    local seed = isDiffRandSeed and math.random(1, 10000000) or 0

    ---@type BattleArg
    local battleArg = {}
    battleArg.battleView = IViewBattle.new()
    battleArg.startup = {}
    battleArg.startup.dungeon = dungeonData.Dungeon
    battleArg.startup.randomSeed = seed
    self.battle = g_BattleMgr:CreateBattle(battleArg)

    self.battle.statistics:SetTestInfo(uid,
            tonumber(SCoreSetId),
            tonumber(weaponSetId),
            tonumber(testID),
            tonumber(battleId),
            tonumber(SCoreSetGroupId),
            tonumber(taskCurCount),
            "../Tools/verifybattle/results")

    --设置自动战斗
    local actor = self.battle:GetActor(1)
    if actor then
        actor.commander:PushExternalCommand(ActorSwitchAutoCommand.new(true))
        actor.commander:PushExternalCommand(ActorSwitchAutoQTECommand.new(true))
    end
end


function BattleTester:Update()
    local beginTime = os.time()
    local battleResult = BattleResultType.Fail
    local frameCnt = 0
    for i = 1, 600000 do
        frameCnt = i
        --XECS.XPCall(g_BattleMgr.Update,g_BattleMgr,GlobalConst.FrameTime)
        self.battle:Update(BattleConst.FrameTime)
        battleResult = self.battle._resultType
        if battleResult ~= BattleResultType.Running or frameCnt == 600000 then
            g_BattleMgr:Uninit()
            break
        end
    end

    if frameCnt == 600000 then
        Debug.LogErrorFormat("frameCnt == 600000")
    end
    local endTime = os.time()
    return endTime - beginTime
end



g_BattleTester = BattleTester.new()
return g_BattleTester