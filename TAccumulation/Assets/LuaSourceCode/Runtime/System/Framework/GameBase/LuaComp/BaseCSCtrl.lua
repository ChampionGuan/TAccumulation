---@class BaseCSCtrl
local BaseCSCtrl = class("BaseCSCtrl")

function BaseCSCtrl:Init(cs)
    self.CS = cs
    self.gameObject = cs and cs.gameObject or nil
end

function BaseCSCtrl:OnClear()
    
end

return BaseCSCtrl
