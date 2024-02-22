---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-12-29 12:15:49
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class BlockTowerBLL
local BlockTowerBLL = class("BlockTowerBLL", BaseBll)
---@type BlockTowerConst
local Const = require("Runtime.System.X3Game.Modules.BlockTower.BlockTowerConst")

---初始化
function BlockTowerBLL:OnInit()
    ---@type pbcmessage.BlockTowerLayer[]
    self.blockList = nil
    self:DataClear()
end

---临时数据清理
function BlockTowerBLL:DataClear()
    ---@type cfg.BlockTowerDifficulty
    self.static_BlockTowerDifficulty = nil
    ---@type BlockTowerGameController
    self.curGameController = nil
end

--region
---设置静态表Id
---@param id int
function BlockTowerBLL:SetCfg(id)
    self.static_BlockTowerDifficulty = LuaCfgMgr.Get("BlockTowerDifficulty", id)
end

---获得静态数据
---@return cfg.BlockTowerDifficulty
function BlockTowerBLL:GetCfg()
    return self.static_BlockTowerDifficulty
end

---设置当前游戏控制器
---@param value BlockTowerGameController
function BlockTowerBLL:SetGameController(value)
    self.curGameController = value
end

---获取当前游戏控制器
---@return BlockTowerGameController
function BlockTowerBLL:GetGameController()
    return self.curGameController
end

---@param blockList pbcmessage.BlockTowerLayer[]
function BlockTowerBLL:SetBlockList(blockList)
    self.blockList = blockList
end

---@return pbcmessage.BlockTowerLayer[]
function BlockTowerBLL:GetBlockList()
    return self.blockList
end

---@return BlockTowerGameData
function BlockTowerBLL:GetBlockTowerData()
    return self:GetGameController():GetGameData()
end
--endregion

---条件检查
function BlockTowerBLL:CheckCondition(id, datas, ...)
    local result = false
    local logic = false
    local mode = GamePlayConst.GameMode.Default
    local times = 0
    if id == X3_CFG_CONST.CONDITION_BLOCKTOWER_SUCCESS_TIMES_G then
        mode = tonumber(datas[1])
        times = self:GetWinCount(mode)
        result = ConditionCheckUtil.IsInRange(times, tonumber(datas[2]), tonumber(datas[3]))
    elseif id == X3_CFG_CONST.CONDITION_BLOCKTOWER_FAIL_TIMES_G then
        mode = tonumber(datas[1])
        times = self:GetLoseCount(mode)
        result = ConditionCheckUtil.IsInRange(times, tonumber(datas[2]), tonumber(datas[3]))
    elseif id == X3_CFG_CONST.CONDITION_BLOCKTOWER_CONTISUCCESS_TIMES_G then
        mode = tonumber(datas[1])
        times = self:GetContinuitySuccessedTimes(mode)
        result = ConditionCheckUtil.IsInRange(times, tonumber(datas[2]), tonumber(datas[3]))
    elseif id == X3_CFG_CONST.CONDITION_BLOCKTOWER_CONTIFAIL_TIMES_G then
        mode = tonumber(datas[1])
        times = self:GetContinuityFailedTimes(mode)
        result = ConditionCheckUtil.IsInRange(times, tonumber(datas[2]), tonumber(datas[3]))
    elseif id == X3_CFG_CONST.CONDITION_BLOCKTOWER_NOWQUESTION then
        if self:GetBlockTowerData().questionID == tonumber(datas[1]) then
            result = true
        end
    elseif id == X3_CFG_CONST.CONDITION_BLOCKTOWER_SAFEBLOCKNUM then
        result = ConditionCheckUtil.IsInRange(#self:GetBlockTowerData().safeBlockList,
                tonumber(datas[2]), tonumber(datas[3]))
    elseif id == X3_CFG_CONST.CONDITION_BLOCKTOWER_ANSWERTIMES then
        
    elseif id == X3_CFG_CONST.CONDITION_BLOCKTOWER_WHOTURN then
        logic = datas[1] ~= "0"
        if (self:GetBlockTowerData().whoseTurn == tonumber(datas[1])) == logic then
            result = true
        end
    elseif id == X3_CFG_CONST.CONDITION_BLOCKTOWER_TARGETISANSWERED then

    elseif id == X3_CFG_CONST.CONDITION_BLOCKTOWER_HISTORYCHOICE then

    elseif id == X3_CFG_CONST.CONDITION_BLOCKTOWER_OVERTIME then
        logic = datas[1] ~= "0"
        if self.timeLimitFailed == logic then
            result = true
        end
    elseif id == X3_CFG_CONST.CONDITION_BLOCKTOWER_ISCENTREBLOCK then
        logic = datas[1] ~= "0"
        local blockType = self.curGameController:BlockTowerTypeTest(self:GetBlockTowerData().selectedBlock, true)
        local isMiddleBlockTower = (blockType == Const.BlockType.Middle)
        if isMiddleBlockTower == logic then
            result = true
        end
    end
    return result
end

function BlockTowerBLL:GetWinCount(mode)
    local times = 0
    if mode == GamePlayConst.GameMode.Default then
        times = self:GetBlockTowerData().winCount + self:GetBlockTowerData().loseCount
    elseif mode == GamePlayConst.GameMode.Player then
        times = self:GetBlockTowerData().winCount
    elseif mode == GamePlayConst.GameMode.AI then
        times = self:GetBlockTowerData().loseCount
    end

    return times
end

function BlockTowerBLL:GetLoseCount(mode)
    local times = 0
    if mode == GamePlayConst.GameMode.Default then
        times = self:GetBlockTowerData().winCount + self:GetBlockTowerData().loseCount
    elseif mode == GamePlayConst.GameMode.Player then
        times = self:GetBlockTowerData().loseCount
    elseif mode == GamePlayConst.GameMode.AI then
        times = self:GetBlockTowerData().winCount
    end

    return times
end

---
---@param mode GamePlayConst.GameMode
---@return int
function BlockTowerBLL:GetContinuitySuccessedTimes(mode)
    local times = 0
    if mode == GamePlayConst.GameMode.Player then
        times = self:GetBlockTowerData().continualPlayerSuccessedTimes
    elseif mode == GamePlayConst.GameMode.AI then
        times = self:GetBlockTowerData().continualAIWinTimes
    end

    return times
end

---
---@param mode GamePlayConst.GameMode
---@return int
function BlockTowerBLL:GetContinuityFailedTimes(mode)
    local times = 0
    if mode == GamePlayConst.GameMode.Player then
        times = self:GetBlockTowerData().continualAIWinTimes
    elseif mode == GamePlayConst.GameMode.AI then
        times = self:GetBlockTowerData().continualPlayerSuccessedTimes
    end

    return times
end

return BlockTowerBLL