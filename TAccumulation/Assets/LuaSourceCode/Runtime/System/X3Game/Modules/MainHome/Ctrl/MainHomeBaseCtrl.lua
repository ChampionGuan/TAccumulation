---Runtime.System.X3Game.Modules.MainHome.Ctrl/MainHomeBaseCtrl.lua
---Created By 教主
--- Created Time 16:20 2021/7/1

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
---@class MainHomeBaseCtrl
local MainHomeBaseCtrl = class("MainHomeBaseCtrl")

function MainHomeBaseCtrl:ctor()
    ---@type boolean
    self.isRunning = false
    ---@type MainHomeBLL
    self.bll = nil
    ---@type boolean
    self.isEnter = false
end

function MainHomeBaseCtrl:IsEnter()
    return self.isEnter
end

function MainHomeBaseCtrl:SetBll(bll)
    ---@type MainHomeBLL
    self.bll = bll
end

function MainHomeBaseCtrl:CheckRunning()
    self.bll:CheckRunning()
end

function MainHomeBaseCtrl:IsRunning()
    return self.isRunning
end

function MainHomeBaseCtrl:OnUpdate()

end

function MainHomeBaseCtrl:SetIsRunning(isRunning)
    if isRunning~= self.isRunning then
        self.isRunning = isRunning
        self:CheckRunning()
    end
end

function MainHomeBaseCtrl:Enter()
    self.isEnter = true
end

function MainHomeBaseCtrl:Exit()
    self:SetIsRunning(false)
    self.isEnter = false
end

function MainHomeBaseCtrl:RegisterEvent()

end

function MainHomeBaseCtrl:UnRegisterEvent()
    EventMgr.RemoveListenerByTarget(self)
end

function MainHomeBaseCtrl:OnDestroy()
    GameUtil.ClearTarget(self)
end

function MainHomeBaseCtrl:OnGameFocus(focus)
    
end

return MainHomeBaseCtrl