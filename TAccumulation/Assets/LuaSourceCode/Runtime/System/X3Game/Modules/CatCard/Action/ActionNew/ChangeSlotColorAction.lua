﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by hongyun.
--- DateTime: 2022/6/8 18:27
---

---@type CatCardConst
local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")

---@type CatCard.CatCardBaseAction
local BaseAction = require(CatCardConst.BASE_ACTION_PATH_NEW)

---修改格子上的颜色的Action
---@class CatCard.ChangeSlotColorAction:CatCard.CatCardBaseAction
local ChangeSlotColorAction = class("ChangeSlotColorAction", BaseAction)

function ChangeSlotColorAction:ctor()
    BaseAction.ctor(self)
end

---@param actionData CatCard.ChangeSlotColorActionData
function ChangeSlotColorAction:Begin(actionData)

    self.playerType = actionData:GetPlayerType()
    if self.playerType == CatCardConst.PlayerType.PLAYER then
        ---女主不需要随机选格子
        self:StartRandomColor()
    else
        ---男主模拟随机选格子
        local CatCardConst = require("Runtime.System.X3Game.Modules.CatCard.Data.CatCardConst")
        ---@type CatCard.RandomSelectSlotActionData
        local randomSelectSlotActionData = BllMgr.GetCatCardBLL():GetActionData(CatCardConst.ActionType.RandomSelectSlot, CatCardConst.PlayerType.ENEMY, function()
            self:StartRandomColor()
        end)

        local funcCardType = CatCardConst.FuncCardType.DISCOLORCARD
        local finalSlot = actionData:GetSlotIndex()
        randomSelectSlotActionData:Set(funcCardType, finalSlot)
        randomSelectSlotActionData:Begin()
    end


end

---开始随机格子颜色
function ChangeSlotColorAction:StartRandomColor()
    ---@type CatCard.ChangeSlotColorActionData
    local actionData = self:GetData()
    local slotIndex = actionData:GetSlotIndex()
    ---@type SlotData
    self.slotData = self.bll:GetData(CatCardConst.CardType.SLOT, slotIndex)
    local oldSlotId = self.bll:GetOldSlotIdByIndex(slotIndex)
    ---3:绿 2:蓝 1:棕 4:红
    self.slotIds = { 1230, 1220, 1210, 1240, 1100 }
    table.removebyvalue(self.slotIds, oldSlotId)
    self.originalSlotId = self.slotData:GetId()
    self.timer = 0
    self.curLoopCount = 0

    self:RandomSlotIds()

    self.singleTime = actionData:GetAnimTime() / 4
    self.curIndex = 1
    self:ChangeSlotColor(self.slotIds[self.curIndex], true)

    self.timerId = TimerMgr.AddTimer(0, self.Update, self, -1)
end

---修改格子颜色
function ChangeSlotColorAction:ChangeSlotColor(id, ignoreEffect)
    self.slotData.cup_model = nil
    self.slotData.cup_plate_model = nil
    self.slotData:SetId(id)
    if ignoreEffect then
        self.bll:CheckSound(CatCardConst.SoundType.DEFAULT, CatCardConst.Sound.SYSTEM_MIAO_RANDOMCOLOR)
    else
        self.bll:CheckSound(CatCardConst.SoundType.DEFAULT, CatCardConst.Sound.SYSTEM_MIAO_SMOKE)
    end
    local actionData = self:GetData()
    local slotIndex = actionData:GetSlotIndex()
    EventMgr.Dispatch(CatCardConst.Event.CAT_CARD_REFRESH_MODEL, CatCardConst.CardType.SLOT, slotIndex, actionData:GetPlayerType(), nil, ignoreEffect)
end

function ChangeSlotColorAction:Update()
    local deltaTime = TimerMgr.GetCurTickDelta()
    self.timer = self.timer + deltaTime

    if self.timer >= self.curIndex * self.singleTime then

        ---切换颜色
        self.curIndex = self.curIndex + 1
        if self.curIndex > 4 then
            self.curIndex = 1
            self.timer = 0
            self.curLoopCount = self.curLoopCount + 1

            ---@type CatCard.ChangeSlotColorActionData
            local actionData = self:GetData()

            if self.curLoopCount >= actionData:GetLoopCount() then
                ---循环次数到了 结束循环动画 修改为这个格子真正的颜色
                self:ChangeSlotColor(self.originalSlotId)

                ---播放音效
                self.bll:CheckSound(CatCardConst.SoundType.DEFAULT, CatCardConst.Sound.SYSTEM_MIAO_APPEAR)

                ---播放UI特效
                ---@type CatCard.EffectActionData
                local effectAction = self.bll:GetActionData(CatCardConst.ActionType.EffectAction)
                local slotIndex = actionData:GetSlotIndex()
                effectAction:Set(CatCardConst.EffectState.SHOW, CatCardConst.Effect.MODEL_APPEAR_UI, slotIndex, CatCardConst.CardType.SLOT)
                effectAction:Begin()

                TimerMgr.Discard(self.timerId)
                if self.playerType == CatCardConst.PlayerType.ENEMY then
                    self.bll:SetChangeSlotEvent(slotIndex)
                end
                self:End()
                return
            else
                ---循环次数还没到 就打乱slotIds开始新的一轮动画
                self:RandomSlotIds()
            end
        end

        self:ChangeSlotColor(self.slotIds[self.curIndex], true)
    end
end

---随机格子颜色
function ChangeSlotColorAction:RandomSlotIds()
    local tempTable = PoolUtil.GetTable()
    for i = 1, 4 do
        table.insert(tempTable, self.slotIds[i])
    end
    table.clear(self.slotIds)
    table.random_table(tempTable, self.slotIds)
    PoolUtil.ReleaseTable(tempTable)
end

---结束
function ChangeSlotColorAction:End()
    local changeEvent = self.bll:GetChangeSlot()
    if changeEvent then
        if self.slotData:GetCardId() > 0 then
            self.bll:DoChangeSlotEvent(self.slotData:GetPlayerType())
        else
            self.bll:SetChangeSlotEvent(nil)
        end
    end
    BaseAction.End(self)
end

return ChangeSlotColorAction