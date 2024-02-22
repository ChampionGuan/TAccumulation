﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2022/7/29 11:08
---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.BaseActionData
local BaseActionData = require(CatCardConst.BASE_ACTION_DATA_PATH)
---@class CatCard.ScoreChangeActionData :CatCard.BaseActionData
local ScoreChangeActionData = class("ScoreChangeActionData", BaseActionData)

function ScoreChangeActionData:ctor()
    self.changeType = 0
    self.changeId = 0
    self.changeIndex = 0
    self.changeScore = 0
    self.showScoreSwitch = true
end

---@param type CatCardConst.CardType 修改类型
function ScoreChangeActionData:Set(type)
    self.changeType = type
end

---选择过程中会有变更，变更接口单独提供
---@param index int 槽位索引  1~8
---@param id int type = CARD 传cardid， type = SLOT 传slotid
function ScoreChangeActionData:SetChange(index, id)
    self.changeIndex = index
    self.changeId = id
end

function ScoreChangeActionData:GetChangeType()
    return self.changeType
end

function ScoreChangeActionData:GetChangeID()
    return self.changeId
end

function ScoreChangeActionData:GetChangeIndex()
    return self.changeIndex
end

function ScoreChangeActionData:SetChangeScore(score)
    self.changeScore = score
end

function ScoreChangeActionData:GetChangeScore()
    return self.changeScore
end

function ScoreChangeActionData:SetShowScoreSwitch(value)
    self.showScoreSwitch = value
end

---是否需要分数预览
function ScoreChangeActionData:GetShowScoreSwitch()
    return self.showScoreSwitch
end

return ScoreChangeActionData