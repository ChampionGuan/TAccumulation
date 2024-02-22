--- X3@PapeGames
--- CharacterClickAction
--- Created by doudou
--- Created Date: 2023-10-31

---@class X3Game.CharacterClickAction:FSM.FSMAction
---@field Character FSM.FSMVar | UObject
---@field BodyGroup FSM.FSMVar | int
---@field IsColliderMode FSM.FSMVar | boolean
---@field ClickEvent FSM.FSMVar | string
---@field ClickPartId FSM.FSMVar | int
---@field ClickCollider FSM.FSMVar | UObject
---@field ClickPos FSM.FSMVar | Vector2
---@field CustomMoveThresholdDis FSM.FSMVar | boolean
---@field MoveThresholdDis FSM.FSMVar | int
---@field CustomClickEffect FSM.FSMVar | boolean
---@field ClickEffect FSM.FSMVar | string
---@field DragEffect FSM.FSMVar | string
---@field LongPressEffect FSM.FSMVar | string
local CharacterClickAction = class("CharacterClickAction", FSMAction)


---初始化
function CharacterClickAction:OnAwake()
end

---进入Action
function CharacterClickAction:OnEnter()
    local character = self.Character:GetValue()
    if character then
        local clickObj = GameObjClickUtil.GetOrAddCharacterClick(character, self.BodyGroup:GetValue(),
                handler(self, self.OnCharacterClick), nil, self.IsColliderMode:GetValue())
        clickObj:SetTouchBlockEnableByUI(GameObjClickUtil.TouchType.ON_TOUCH_DOWN, true)
        if self.CustomMoveThresholdDis:GetValue() then
            clickObj:SetMoveThresholdDis(self.MoveThresholdDis:GetValue())
            clickObj:SetTargetEffect(self.ClickEffect:GetValue(), self.DragEffect:GetValue(), self.LongPressEffect:GetValue())
        end
    end

    CutSceneMgr.Pause()
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function CharacterClickAction:OnPause(isPaused)
end

--[[如需Action Tick需在Action Csharp类上标识Tickable
function CharacterClickAction:OnUpdate()
end
--]]

---退出Action
function CharacterClickAction:OnExit()
    GameObjClickUtil.Remove(self.Character:GetValue())
end

---被重置
function CharacterClickAction:OnReset()
end

---被销毁
function CharacterClickAction:OnDestroy()
end

function CharacterClickAction:OnCharacterClick(partType, collider, touchPos)
    self.ClickPartId:SetValue(partType)
    self.ClickCollider:SetValue(collider)
    self.ClickPos:SetValue(touchPos)
    self.fsm:FireEvent(self.ClickEvent:GetValue())
end

return CharacterClickAction