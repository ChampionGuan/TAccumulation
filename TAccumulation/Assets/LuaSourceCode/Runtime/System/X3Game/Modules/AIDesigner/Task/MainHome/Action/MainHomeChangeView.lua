---Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action/MainHomeChangeView.lua
---Created By 教主
--- Created Time 19:40 2021/7/2
---切换view

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action.MainHomeBaseAIAction")
---切换view
---1.约会 2.主界面 3.行动
---Category:MainHome
---@class MainHomeChangeView:MainHomeBaseAIAction
---@field viewType Int
local MainHomeChangeView = class("MainHomeChangeView", AIAction)


function MainHomeChangeView:OnAwake()
    AIAction.OnAwake(self)
    self.isChangeSuccess = false
    self.changeFinishCall = handler(self,self.OnChangeSuccess)
end

function MainHomeChangeView:OnAddEvent()
    EventMgr.AddListener(MainHomeConst.Event.MAIN_HOME_BREAK_CHANGE_VIEW,self.OnEventViewChangeBreak,self)
end

function MainHomeChangeView:OnEventViewChangeBreak()
    self.tree:SetVariable("viewType",self.bll:GetCurViewType())
    self.tree:SetVariable("lastViewType",self.bll:GetCurViewType())
    self.viewType = self.bll:GetCurViewType()
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ViewChangeFinish,true)
end


function MainHomeChangeView:OnEnter()
    self:CheckView()
end

function MainHomeChangeView:OnChangeSuccess()
    self.bll:SetHandlerRunning(MainHomeConst.HandlerType.ViewChangeFinish,true)
end

function MainHomeChangeView:OnUpdate()
    if not self.isChangeSuccess  then
        if  UIMgr.IsOpened(UIConf.MainHomeWnd) then
            self:CheckView()
        else
            return AITaskState.Running
        end
    end
    return AITaskState.Success
end

function MainHomeChangeView:CheckView()
    local global_view_type = self.tree:GetVariable("viewType")
    if self.viewType~= global_view_type then
        if not self.isChangeSuccess and UIMgr.IsOpened(UIConf.MainHomeWnd) then
            self.isChangeSuccess = true
        end
        if self.isChangeSuccess then
            EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_CHANGE_VIEW,global_view_type,self.changeFinishCall)
            self.viewType = global_view_type
        end
    end
end


return MainHomeChangeView