﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2023/1/10 10:47
---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.BaseDataParser
local BaseDataParser = require(CatCardConst.CAT_CARD_BASE_DATA_PARSER_PATH)
---@class CatCard.RobDataParser:CatCard.BaseDataParser
local RobDataParser = class("RobDataParser", BaseDataParser)

function RobDataParser:ctor()
    BaseDataParser.ctor(self)
end

---@param data {SPAction}
function RobDataParser:Parse(data)
    local start_order = 0
    local player_type = 0
    if data.PlayerType then
        player_type = data.PlayerType
    else
        player_type = self.bll:GetPlayerType(data.Seat)
    end
    start_order = self:ParseBeginAction(player_type, start_order)
    if not self:IsFinish() then
        local data = self:GetRunningActionData()
        if data then
            start_order = data:GetOrder() + 1
        end
    end
    if data.SPAction then
        start_order = self:ParseAction(data.SPAction, start_order, player_type)
    end
    start_order = self:ParseEndAction(player_type, start_order)
    self:Prepare()
end

function RobDataParser:ParseAction(spAction, order, player_type)
    local action_list = PoolUtil.GetTable()
    local state = spAction.args and spAction.args[1] or CatCardConst.RobState.INIT
    self.stateData:SetSpState(state)
    if state == CatCardConst.RobState.INIT then
        action_list = {
            [1] = {
                ActionType = CatCardConst.ActionType.RobInit
            }
        }
    elseif state == CatCardConst.RobState.FAIL then
        self.stateData:SetSpState(CatCardConst.RobState.END)
        local is_has_success_get_card = self.bll:HasActionSuccess(CatCardConst.SpecialType.ROB)
        local dialogFirst = is_has_success_get_card and CatCardConst.DialogueState.GetManCardNextTime or CatCardConst.DialogueState.GetManCardFirstTime
        local dialogSecond = is_has_success_get_card and CatCardConst.DialogueState.GetManCardFailedAfterSuccess or CatCardConst.DialogueState.GetManCardFailed
        action_list = {
            [1] = {
                ActionType = CatCardConst.ActionType.ChangeDialogueState,
                Params = { dialogFirst }
            },
            [2] = {
                ActionType = CatCardConst.ActionType.ChangeDialogueState,
                Params = { dialogSecond }
            },
            [3] = {
                ActionType = CatCardConst.ActionType.RobEnd
            }
        }
    elseif state == CatCardConst.RobState.SUCCESS_NO_GET_CARD then
        local is_has_success_get_card = self.bll:HasActionSuccess(CatCardConst.SpecialType.ROB)
        local dialogFirst = is_has_success_get_card and CatCardConst.DialogueState.GetManCardNextTime or CatCardConst.DialogueState.GetManCardFirstTime
        local dialogSecond = CatCardConst.DialogueState.GetManCardSuccess
        action_list = {
            [1] = {
                ActionType = CatCardConst.ActionType.ChangeDialogueState,
                Params = { dialogFirst }
            },
            [2] = {
                ActionType = CatCardConst.ActionType.ChangeDialogueState,
                Params = { dialogSecond }
            },
            [3] = {
                ActionType = CatCardConst.ActionType.RobShowView,
            },
            [4] = {
                ActionType = CatCardConst.ActionType.RobEnd
            }
        }
    end
    if self.bll:IsDebugMode() then
        self.bll:LogFormat("解析数据结果：state = %s,[%s]", state, table.dump(action_list, "RobDataParser"))
    end
    order = BaseDataParser.ParseActionList(self, action_list, order, player_type)
    PoolUtil.ReleaseTable(action_list)
    return order
end

return RobDataParser