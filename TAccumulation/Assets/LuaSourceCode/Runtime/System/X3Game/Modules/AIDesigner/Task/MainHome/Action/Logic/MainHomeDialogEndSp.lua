---Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.Logic/MainHomeDialogEndSp.lua
---Created By 教主
--- Created Time 15:20 2021/7/20

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.Plugins.AIDesigner.Base.AITask").AIAction
---剧情结束之后特殊调用
---Category:MainHome
---@class MainHomeDialogEndSp:AIAction
---@field dialogSpEvent AIVar|String
local MainHomeDialogEndSp = class("MainHomeDialogEndSp", AIAction)
function MainHomeDialogEndSp:OnAwake()
    ---@type MainHomeBLL
    self.bll = BllMgr.Get("MainHomeBLL")
    self:RegisterEvent()
    self.localDialogSpEvent = ""
end

function MainHomeDialogEndSp:OnEnter()
    if self.localDialogSpEvent~=self.dialogSpEvent:GetValue() then
        self.dialogSpEvent:SetValue(self.localDialogSpEvent)
        self.localDialogSpEvent = ""
    end
end

function MainHomeDialogEndSp:OnUpdate()
    return AITaskState.Success
end

function MainHomeDialogEndSp:OnSpEvent(eventParam)
    if eventParam and eventParam.params then
        self.localDialogSpEvent = eventParam.params[1] or ""
    end
end

function MainHomeDialogEndSp:RegisterEvent()
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_DIALOG_END_SP_EVENT,self.OnSpEvent,self)
end

function MainHomeDialogEndSp:UnRegisterEvent()
    EventMgr.RemoveListenerByTarget(self)
end

function MainHomeDialogEndSp:OnDestroy()
    self:UnRegisterEvent()
end


return MainHomeDialogEndSp