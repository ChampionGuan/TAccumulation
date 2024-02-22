﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2023/1/10 10:39
---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.BaseDataParser
local BaseDataParser = require(CatCardConst.CAT_CARD_BASE_DATA_PARSER_PATH)
---@class CatCard.WanderDataParser:CatCard.BaseDataParser
local WanderDataParser = class("WanderDataParser", BaseDataParser)

function WanderDataParser:ctor()
    BaseDataParser.ctor(self)
end

---@param data {SPAction}
function WanderDataParser:Parse(data)
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

function WanderDataParser:ParseAction(spAction, order, player_type)
    local action_list = PoolUtil.GetTable()
    local res = spAction.args[1]
    self.stateData:SetActionRes(res)
    if res == CatCardConst.WanderingType.CANSWITCH then
        action_list = {
            [1] = {
                ActionType = CatCardConst.ActionType.WaitTime,
                Params = { spAction.args[2] / 1000 },
            },
            [2] = {
                ActionType = CatCardConst.ActionType.ChangeDialogueState,
                Params = { CatCardConst.DialogueState.ChangeCardWandering },
                isWait = false
            },
            [3] = {
                ActionType = CatCardConst.ActionType.WanderWait,
                Params = { res, spAction.args[3] / 1000 },
            },
            [4] = {
                ActionType = CatCardConst.ActionType.WanderEnd,
            }
        }
    elseif res == CatCardConst.WanderingType.SWITCHSUCCESS then
        if self.stateData:GetSpState() ~= CatCardConst.WanderingState.NONE then
            self.stateData:SetSpState(CatCardConst.WanderingState.ENDED)
            action_list = {
                [1] = {
                    ActionType = CatCardConst.ActionType.ChangeDialogueState,
                    Params = { CatCardConst.DialogueState.ChangeCardSuccess }
                },
                [2] = {
                    ActionType = CatCardConst.ActionType.WanderEnd,
                }
            }
        else
            self.stateData:SetSpState(CatCardConst.WanderingState.ENDED)
            action_list = {
                [1] = {
                    ActionType = CatCardConst.ActionType.WanderEnd,
                }
            }
        end
    elseif res == CatCardConst.WanderingType.SWITCHFAILED then
        if self.stateData:GetSpState() ~= CatCardConst.WanderingState.NONE then
            local slot_map = self.bll:GetSelectIndexs(CatCardConst.CardType.SLOT)
            action_list = {
                [1] = {
                    ActionType = CatCardConst.ActionType.ChangeDialogueState,
                    Params = { CatCardConst.DialogueState.ChangeCardFailCurrent }
                },
                [2] = {
                    ActionType = CatCardConst.ActionType.WanderChange,
                    Params = { slot_map[1], slot_map[2], true }
                },
                [3] = {
                    ActionType = CatCardConst.ActionType.ChangeDialogueState,
                    Params = { CatCardConst.DialogueState.ChangeCardFailRevert },
                },
                [4] = {
                    ActionType = CatCardConst.ActionType.WanderEnd,
                }
            }
        else
            self.stateData:SetSpState(CatCardConst.WanderingState.ENDED)
            action_list = {
                [1] = {
                    ActionType = CatCardConst.ActionType.WanderEnd,
                }
            }
        end
    end
    if self.bll:IsDebugMode() then
        self.bll:LogFormat("解析数据结果：state = %s,[%s]", res, table.dump(action_list, "WanderDataParser"))
    end
    order = BaseDataParser.ParseActionList(self, action_list, order, player_type)
    return order
end

return WanderDataParser