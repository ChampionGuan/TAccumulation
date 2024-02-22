--- X3@PapeGames
--- FSMFinishedAction(fsm结束的时候通知相关业务)
--- Created by jiaozhu
--- Created Date: 2023-10-31

---@class X3Game.FSMFinishedAction:FSM.FSMAction
local FSMFinishedAction = class("FSMFinishedAction", FSMAction)

---进入Action
function FSMFinishedAction:OnEnter()
    ---if need to complete action, call Finish()
    ---self:Finish()
    EventMgr.Dispatch(FSMConst.EventName.FSMFinished, self.fsm.id)
    self:Finish()
end

return FSMFinishedAction