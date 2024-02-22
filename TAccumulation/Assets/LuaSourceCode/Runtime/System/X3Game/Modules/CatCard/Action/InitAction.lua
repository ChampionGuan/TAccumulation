﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by pc.
--- DateTime: 2020/11/10 16:28
---
---初始化
---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
local BaseAction = require(CatCardConst.BASE_ACTION_PATH)
---@class CatCard.Action.InitAction:CatCardBaseAction
local InitAction = class("InitAction", BaseAction)
function InitAction:Execute(SPAction)
    self:Start()
end

---状态变化
function InitAction:LocalStateChange(st, ...)
    if st == CatCardConst.LocalState.INITING then
        --初始化
        self:MakeLocalDatas()
        self.bll:SetLocalState(CatCardConst.LocalState.INITING_GET_CARDS)
    elseif st == CatCardConst.LocalState.INITING_GET_CARDS then
        --发牌
        self:ResetCardIndex()
        self:SetCardRotation(CatCardConst.PlayerType.PLAYER, CatCardConst.PLAYER_CARD_ROTATION_Z)
        self:GetCards(self.cur_card_index, function()
            EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_REFRESH_MODELS, CatCardConst.CardType.CARD)
            self.cur_card_index = self.max_card_count and self.max_card_count or self.cur_card_index
            self.bll:SetLocalState(CatCardConst.LocalState.INITING_PLAY_PREPARE_DIALOGUE)
        end)
    elseif st == CatCardConst.LocalState.INITING_PLAY_PREPARE_DIALOGUE then
        ---@type CatCardDialogueCtrl
        local dialogueCtrl = self:GetCtrl(CatCardConst.Ctrl.Dialogue)
        ---@type CatCard.ChangeDialogueStateActionData
        local actionData = self.bll:GetActionData(CatCardConst.ActionType.ChangeDialogueState, CatCardConst.PlayerType.PLAYER, function()
            --检查是否投降成功
            local p2Surender = dialogueCtrl:GetDialogueVariable(CatCardConst.DialogueVariable.SURRENDERID)
            --投降成功就进入结束
            if p2Surender == 2 then
                --2是结束对局 1是继续 0是无事发生
                self.bll:OnSurrender(Miao.MiaoPlayerPos.MiaoPlayerPosP2)
            elseif p2Surender == 1 then
                --1 继续游戏
                self.bll:SetLocalState(CatCardConst.LocalState.INITING_PREPARE_DIALOGUE_END)
            else
                --继续检查投降
                local actionData = self.bll:GetActionData(CatCardConst.ActionType.ChangeDialogueState, CatCardConst.PlayerType.PLAYER, function()
                    --投降成功就进入结束
                    local p1Surender = dialogueCtrl:GetDialogueVariable(CatCardConst.DialogueVariable.SURRENDERID)
                    if p1Surender == 2 then
                        --2是结束对局 1是继续 0是无事发生
                        self.bll:OnSurrender(Miao.MiaoPlayerPos.MiaoPlayerPosP1)
                    elseif p1Surender == 1 then
                        --1 继续游戏
                        self.bll:SetLocalState(CatCardConst.LocalState.INITING_PREPARE_DIALOGUE_END)
                    else
                        --进入prepare剧情
                        ---@type CatCard.ChangeDialogueStateActionData
                        local actionData = self.bll:GetActionData(CatCardConst.ActionType.ChangeDialogueState, CatCardConst.PlayerType.PLAYER, function()
                            --播放Prepare的剧情，播放以后进入游戏
                            if self.bll:GetStateData():GetState() ~= CatCardConst.State.ROLL then
                                return
                            end
                            self.bll:SetLocalState(CatCardConst.LocalState.INITING_PREPARE_DIALOGUE_END)
                        end)
                        actionData:SetState(CatCardConst.DialogueState.Prepare)
                        actionData:SetDialogueCtrlState(CatCardConst.DialogueCtrlState.Start)
                        actionData:Begin()
                    end
                end)
                actionData:SetState(CatCardConst.DialogueState.PSurrender)
                actionData:SetDialogueCtrlState(CatCardConst.DialogueCtrlState.Start)
                actionData:Begin()
            end
        end)
        actionData:SetState(CatCardConst.DialogueState.MSurrender)
        actionData:SetDialogueCtrlState(CatCardConst.DialogueCtrlState.Start)
        actionData:Begin()
    elseif st == CatCardConst.LocalState.INITING_PREPARE_DIALOGUE_END then
        self.bll:SetLocalState(CatCardConst.LocalState.INITING_PLAY_DIALOGUE)
    elseif st == CatCardConst.LocalState.INITING_PLAY_DIALOGUE then
        self.bll:SetLocalState(CatCardConst.LocalState.INITING_PLAY_DIALOGUE_END)
    elseif st == CatCardConst.LocalState.INITING_PLAY_DIALOGUE_END then
        self.bll:SetLocalState(CatCardConst.LocalState.INITING_CHECK_ROLL)
    elseif st == CatCardConst.LocalState.INITING_CHECK_ROLL then
        self.bll:CheckRoll()
    elseif st == CatCardConst.LocalState.INITING_ROLL_END then
        local cur_card_index = self.cur_card_index
        self:ResetCardIndex()
        self.cur_card_index = cur_card_index and (cur_card_index + 1) or self.max_card_count
        self:SetCardRotation(CatCardConst.PlayerType.PLAYER, CatCardConst.PLAYER_CARD_ROTATION_Z)
        local player_type = CatCardConst.PlayerType.PLAYER
        if self.bll:GetStateData():GetRollResult() == CatCardConst.RoundRes.WIN then
            player_type = CatCardConst.PlayerType.ENEMY
        end
        self:SetNewCard(player_type, true)
        self:GetCards(self.cur_card_index, function()
            EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_REFRESH_MODELS, CatCardConst.CardType.CARD)
            self.bll:SetLocalState(CatCardConst.LocalState.INITING_PREPARE_SHOW_CARDS)
        end)
    elseif st == CatCardConst.LocalState.INITING_PREPARE_SHOW_CARDS then
        --初始化预显示卡
        self:GetCards(self.cur_card_index + 1, function()
            self:ClearCacheCards()
            self.bll:SetLocalState(CatCardConst.LocalState.INITING_IDLE)
        end, true, CatCardConst.PlayerType.PLAYER, CatCardConst.PlayerType.PLAYER)
    elseif st == CatCardConst.LocalState.INITING_IDLE then
        self.bll:SetLocalState(CatCardConst.LocalState.INITING_END)
    elseif st == CatCardConst.LocalState.INITING_END then
        self:End()
    end
end

---获取初始化手牌
---@return int,int,int
function InitAction:GetInitHandCount()
    local state_data = self.bll:GetStateData()
    local difficulty = state_data:GetMiaoCardDiff()
    local first_count = difficulty.FirstStartNumCard + difficulty.FirstStartFuncCard
    local later_count = difficulty.LaterStartNumCard + difficulty.LaterStartFuncCard
    local count = math.min(first_count, later_count)
    local num_count, func_count
    if count == first_count then
        num_count = difficulty.FirstStartNumCard
    else
        num_count = difficulty.LaterStartNumCard
    end
    func_count = count - num_count
    return num_count, func_count
end

---创建临时数据
function InitAction:MakeLocalDatas()
    if not self:IsNeedGetCards() then
        return
    end
    local num_count, func_count = self:GetInitHandCount()
    local datas = {}
    for k, v in pairs(CatCardConst.PlayerType) do
        table.insert(datas, { player_type = v, num_count = num_count, func_count = func_count })
    end
    self.bll:MakeLocalCards(datas)
    for k, v in pairs(CatCardConst.PlayerType) do
        self:SetNewCard(v, true, true)
    end
end

function InitAction:SetNewCard(player_type, is_new, is_all)
    local data_list = self.bll:GetDataList(CatCardConst.CardType.CARD, player_type)
    if is_all then
        for k, v in pairs(data_list) do
            v:SetIsNew(is_new)
        end
    else
        local num_count, func_count = self:GetInitHandCount()
        if #data_list >= 2 then
            table.sort(data_list, self.bll.OnSortDataByIndex)
        end
        ---@type CatCardData[]
        local func_cards = PoolUtil.GetTable()
        ---@type CatCardData[]
        local num_cards = PoolUtil.GetTable()
        for k, v in ipairs(data_list) do
            if v:IsFuncCard() then
                table.insert(func_cards, v)
            else
                table.insert(num_cards, v)
            end
        end
        for k, v in ipairs(func_cards) do
            if k > func_count then
                v:SetIsNew(is_new)
            end
        end
        for k, v in ipairs(num_cards) do
            if k > num_count then
                v:SetIsNew(is_new)
            end
        end
        PoolUtil.ReleaseTable(func_cards)
        PoolUtil.ReleaseTable(num_cards)
    end

    PoolUtil.ReleaseTable(data_list)
end

---@param player_type CatCardConst.CardType
---@param rotation_z number
function InitAction:SetCardRotation(player_type, rotation_z)
    rotation_z = rotation_z or 0
    local data_list = self.bll:GetDataList(CatCardConst.CardType.CARD, player_type)
    for k, v in pairs(data_list) do
        v:SetRotationZ(rotation_z)
    end
    PoolUtil.ReleaseTable(data_list)
end

---初始化index
function InitAction:ResetCardIndex()
    if not self:IsNeedGetCards() then
        return
    end
    self.cur_card_index = self.cur_card_index or 1
    local max_count = 0
    for k, v in pairs(CatCardConst.PlayerType) do
        local count = self.bll:GetCardCount(v)
        if count > max_count then
            max_count = count
        end
    end
    self.max_card_count = max_count
end

---摸牌动画
function InitAction:GetCards(start_index, callback, is_clear_cache, rotation_type, replace_type)
    if not self:IsNeedGetCards() then
        if callback then
            callback()
        end
        return
    end
    rotation_type = rotation_type and rotation_type or -1
    replace_type = replace_type and replace_type or -1
    local index = 2
    local is_finish = false
    local function ani_call()
        index = index - 1
        if not is_finish and index <= 0 then
            is_finish = true
            if callback then
                callback()
            end
        end
    end
    self.bll:CheckAction(CatCardConst.SpecialType.INIT_HAND, false, ani_call, start_index, CatCardConst.PlayerType.ENEMY, rotation_type == CatCardConst.PlayerType.ENEMY, true, replace_type == CatCardConst.PlayerType.ENEMY)
    self.bll:CheckAction(CatCardConst.SpecialType.INIT_HAND, false, ani_call, start_index, CatCardConst.PlayerType.PLAYER, rotation_type == CatCardConst.PlayerType.PLAYER, false, replace_type == CatCardConst.PlayerType.PLAYER)
end

function InitAction:ClearCacheCards()
    if not self:IsNeedGetCards() then
        return
    end
    self.bll:CheckAction(CatCardConst.SpecialType.INIT_HAND, true, nil, CatCardConst.MAX_INIT_CARD_COUNT, CatCardConst.PlayerType.PLAYER)
    self.bll:CheckAction(CatCardConst.SpecialType.INIT_HAND, true, nil, CatCardConst.MAX_INIT_CARD_COUNT, CatCardConst.PlayerType.ENEMY)
end

function InitAction:IsNeedGetCards()
    return self.is_need_roll
end

function InitAction:Start()
    self:SetIsRunning(true)
    self.cur_card_index = 1
    self.max_card_count = self.cur_card_index
    self.card_speed = CatCardConst.CARD_SPEED
    self:RegisterEvent()
    self.is_need_roll = self.bll:IsNeedRoll()
    self.bll:SetLocalState(CatCardConst.LocalState.INITING)
end

function InitAction:End()
    self:UnRegisterEvent()
    self.bll:SetLocalState(CatCardConst.LocalState.NONE)
    self:SetIsRunning(false)
    if self:IsNeedGetCards() then
        self:CheckSpecialState(true)
    else
        self:CheckState()
    end

end

return InitAction