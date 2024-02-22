---
---Created by liuwei
---Date: 2021/9/9
---Time: 15:52
---

local FsmDebugBase = require("Editor.Battle.FsmMaker.FsmDebugBase")

---@class FsmDebugBattle
local FsmDebugBattle = XECS.class("FsmDebugBattle", FsmDebugBase)

---@param moduleName string
function FsmDebugBattle:ctor(moduleName)
    FsmDebugBattle.super.ctor(self, moduleName)
end

function FsmDebugBattle:GetAllFSMs()
    local battle = g_BattleMgr:GetBattle()
    local actors = battle:GetActors()
    ---@type EditorRuntimeFSMData[]
    local allFSMs = {}
    for _, actor in XECS.dSortingPair(actors) do
        if actor.skillOwner or actor.battleElement or actor.triggerArea then
            self:GetActorFSMs(actor, allFSMs)
        end
    end

    ---@type BattleLevelFSM
    local levelFSM = g_BattleClient.levelFSM
    ---@type EditorRuntimeFSMData
    local battleFSM =
    {
        name = "Battle",
        id = -1,
        fsms = {
            [FSMType.Main] = {},
            [FSMType.Skill] = {},
            [FSMType.Buff] = {},
            [FSMType.Trigger] = {},
            [FSMType.Slot] = {},
            [FSMType.BattleLevel] = { levelFSM:GetFSM()},
            [FSMType.BattleElement] = {},
            [FSMType.TriggerArea] = {},
        },
    }
    table.insert(allFSMs, battleFSM)

    return allFSMs
end

---@param actor Actor|Role
function FsmDebugBattle:GetActorFSMs(actor, allFSMs)
    local mainFSMs = actor.mainState and {actor.mainState:GetFSM()} or {}
    if actor.characterController then
        local mainAnimFsm = actor.characterController:GetFSM()
        table.insert(mainFSMs, mainAnimFsm)
    end

    local skillFSMs = {}
    local skills = actor.skillOwner and actor.skillOwner:GetSkills() or {}
    for k, skill in XECS.dSortingPair(skills) do
        if skill.fsm then
            table.insert(skillFSMs, skill.fsm)
        end
    end

    local buffFSMs = {}
    local buffs = actor.buffOwner and actor.buffOwner:GetBuffs() or {}
    for i, buff in ipairs(buffs) do
        table.insert(buffFSMs, buff.fsm)
    end

    local triggerFSMs = {}
    local triggers = actor.triggerOwner and actor.triggerOwner:GetTriggers() or XECS.DT()
    for i, trigger in XECS.dSortingPair(triggers) do
        table.insert(triggerFSMs, trigger.fsm)
    end

    local slotFSMs = {}
    local slots = actor.skillOwner and actor.skillOwner.slots or {}
    for i, skillSlot in XECS.dSortingPair(slots) do
        if skillSlot:GetChooseFSM() then
            table.insert(slotFSMs, skillSlot:GetChooseFSM())
        end
    end

    local battleElementFSMs = {}
    if actor.battleElement then
        table.insert(battleElementFSMs, actor.battleElement.fsm)
    end

    local triggerAreaFSMs = {}
    if actor.triggerArea then
        table.insert(triggerAreaFSMs, actor.triggerArea.fsm)
    end

    ---编辑器当数组使用，中间没有数据，也必须是空表
    local fsms = {}
    fsms[FSMType.Main] = mainFSMs
    fsms[FSMType.Skill] = skillFSMs
    fsms[FSMType.Buff] = buffFSMs
    fsms[FSMType.Trigger] = triggerFSMs
    fsms[FSMType.Slot] = slotFSMs
    fsms[FSMType.BattleLevel] = {}
    fsms[FSMType.BattleElement] = battleElementFSMs
    fsms[FSMType.TriggerArea] = triggerAreaFSMs

    ---@type EditorRuntimeFSMData
    local actorRuntimeFSM =
    {
        name = actor:GetName(),
        id = actor:GetID(),
        fsms = fsms,
    }
    table.insert(allFSMs, actorRuntimeFSM)
end

return FsmDebugBattle