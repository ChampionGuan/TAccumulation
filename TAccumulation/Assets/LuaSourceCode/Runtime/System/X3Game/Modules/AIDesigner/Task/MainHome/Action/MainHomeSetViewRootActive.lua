---Runtime.System.X3Game.Modules.AIDesigner.Task.MainHome.Action/MainHomeSetViewRootActive.lua
---Created By 教主
--- Created Time 18:54 2021/7/12

---@type MainHome.MainHomeConst
local MainHomeConst = require("Runtime.System.X3Game.Modules.MainHome.Data.MainHomeConst")
local AIAction = require("Runtime.Plugins.AIDesigner.Base.AITask").AIAction
---是否隐藏主界面wnd（非UIMgr操作）
---Category:MainHome
---@class MainHomeSetViewRootActive:AIAction
---@field hideUI AIVar|Boolean
---@field localHideUI Boolean
local MainHomeSetViewRootActive = class("MainHomeSetViewRootActive", AIAction)

function MainHomeSetViewRootActive:OnAwake()
    ---@type MainHomeBLL
    self.bll = BllMgr.Get("MainHomeBLL")
    self.localHideUI = false
end

function MainHomeSetViewRootActive:OnEnter()
    local hide_ui = self.hideUI:GetValue() or false
    if self.localHideUI~= hide_ui then
        self.localHideUI = hide_ui
        EventMgr.Dispatch(MainHomeConst.Event.MAIN_HOME_SET_ROOT_ACTIVE,not self.localHideUI)
    end

end

function MainHomeSetViewRootActive:OnUpdate()
    return AITaskState.Success
end


return MainHomeSetViewRootActive