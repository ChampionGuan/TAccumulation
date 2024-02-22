﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xiaofang.
--- DateTime: 2023/1/10 10:46
---卖萌
---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
---@type CatCard.BaseDataParser
local BaseDataParser = require(CatCardConst.CAT_CARD_BASE_DATA_PARSER_PATH)
---@class CatCard.ExchangeDataParser:CatCard.BaseDataParser
local ExchangeDataParser = class("ExchangeDataParser", BaseDataParser)

function ExchangeDataParser:ctor()
    BaseDataParser.ctor(self)
end

---@param data {SPAction}
function ExchangeDataParser:Parse(data)
    local start_order = 0
    local player_type = 0
    if data.PlayerType then
        player_type = data.PlayerType
    else
        player_type = self.bll:GetPlayerType(data.Seat)
    end
    start_order = self:ParseBeginAction(player_type, start_order)
    if not table.isnilorempty(data.Actions) then
        start_order = self:ParseActions(data.Actions, start_order)
    end
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

function ExchangeDataParser:ParseAction(spAction, order, player_type)
    local action_list = PoolUtil.GetTable()
    local state = spAction.args and spAction.args[1] or CatCardConst.ExchangeState.INIT
    self.stateData:SetSpState(state)
    if state == CatCardConst.ExchangeState.INIT then
        self.stateData:SetExchangeType()
        if self.stateData:GetExchangeType() == CatCardConst.ExchangeType.Exchanging then
            local dialogue = CatCardConst.DialogueState.ExchangeCardFirstTime
            local is_success = self.bll:HasActionSuccess(CatCardConst.SpecialType.EXCHANGE, 1)
            if is_success then
                dialogue = CatCardConst.DialogueState.ExchangeCardNextTime
            end
            action_list = {
                [1] = {
                    ActionType = CatCardConst.ActionType.ChangeDialogueState,
                    Params = { dialogue }
                },
                [2] = {
                    ActionType = CatCardConst.ActionType.ExchangeConfirm,
                },
                [3] = {
                    ActionType = CatCardConst.ActionType.ExchangeEnd
                }
            }
        else
            action_list = {
                [1] = {
                    ActionType = CatCardConst.ActionType.ExchangeRegret,
                },
                [2] = {
                    ActionType = CatCardConst.ActionType.ExchangeEnd
                }
            }
        end
    else
        if self.stateData:GetExchangeType() ~= CatCardConst.ExchangeType.Exchanging then
            if state == CatCardConst.ExchangeState.SUCCESS and self.stateData:GetExchangeType() == CatCardConst.ExchangeType.None then
                --断线重连
                self.stateData:SetExchangeType(CatCardConst.ExchangeType.Exchanging)
            else
                self.stateData:SetExchangeType(CatCardConst.ExchangeType.ENDED)
            end
        end

        if state == CatCardConst.ExchangeState.SUCCESS then
            if self.bll:IsExchange() then
                action_list = {
                    [1] = {
                        ActionType = CatCardConst.ActionType.ChangeDialogueState,
                        Params = { CatCardConst.DialogueState.ExchangeCardSuccess }
                    },
                    [2] = {
                        ActionType = CatCardConst.ActionType.ExchangeHandCard,
                    },
                    [3] = {
                        ActionType = CatCardConst.ActionType.ChangeDialogueState,
                        Params = { CatCardConst.DialogueState.ExchangeCardRegretThinking }
                    },
                    [4] = {
                        ActionType = CatCardConst.ActionType.ExchangeEnd,
                    },
                }
            else
                --断线重连时从是否悔牌开始，不再播换牌动画（此时是已换过的数据）
                action_list = {
                    [1] = {
                        ActionType = CatCardConst.ActionType.ChangeDialogueState,
                        Params = { CatCardConst.DialogueState.ExchangeCardRegretThinking }
                    },
                    [2] = {
                        ActionType = CatCardConst.ActionType.ExchangeEnd,
                    },
                }
            end


        elseif state == CatCardConst.ExchangeState.FAIL then
            local has_success = self.bll:HasActionSuccess(CatCardConst.SpecialType.EXCHANGE, 1)
            self.stateData:SetExchangeType(CatCardConst.ExchangeType.ENDED)
            local dialog = has_success and CatCardConst.DialogueState.ExchangeCardFailedAfterSuccess or CatCardConst.DialogueState.ExchangeCardFailed
            action_list = {
                [1] = {
                    ActionType = CatCardConst.ActionType.ChangeDialogueState,
                    Params = { dialog }
                },
                [2] = {
                    ActionType = CatCardConst.ActionType.ExchangeEnd
                }
            }
        elseif state == CatCardConst.ExchangeState.UNDO_FAIL then
            self.stateData:SetExchangeType(CatCardConst.ExchangeType.ENDED)
            action_list = {
                [1] = {
                    ActionType = CatCardConst.ActionType.ChangeDialogueState,
                    Params = { CatCardConst.DialogueState.ExchangeCardRegretFailed }
                },
                [2] = {
                    ActionType = CatCardConst.ActionType.ExchangeEnd
                }
            }
        elseif state == CatCardConst.ExchangeState.UNDO_SUCCESS then
            self.stateData:SetExchangeType(CatCardConst.ExchangeType.ENDED)
            action_list = {
                [1] = {
                    ActionType = CatCardConst.ActionType.ChangeDialogueState,
                    Params = { CatCardConst.DialogueState.ExchangeCardRegretSuccess }
                },
                [2] = {
                    ActionType = CatCardConst.ActionType.ExchangeHandCard
                },
                [3] = {
                    ActionType = CatCardConst.ActionType.ExchangeEnd
                }
            }
        elseif state == CatCardConst.ExchangeState.GIVE_UP then
            self.stateData:SetExchangeType(CatCardConst.ExchangeType.ENDED)
            action_list = {
                [1] = {
                    ActionType = CatCardConst.ActionType.ExchangeEnd
                }
            }
        end
    end
    if self.bll:IsDebugMode() then
        self.bll:LogFormat("解析数据结果：state = %s,[%s]", state, table.dump(action_list, "ExchangeDataParser"))
    end
    order = BaseDataParser.ParseActionList(self, action_list, order, player_type)
    PoolUtil.ReleaseTable(action_list)
    return order
end

return ExchangeDataParser