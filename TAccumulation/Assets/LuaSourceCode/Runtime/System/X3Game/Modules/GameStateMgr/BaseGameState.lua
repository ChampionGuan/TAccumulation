--- X3@PapeGames
--- BaseGameState
--- Created by Tungway
--- Created Date: 2020/7/24

---@class BaseGameState
local BaseGameState = class("BaseGameState")
BaseGameState.CLS = nil
BaseGameState.Name = nil

function BaseGameState:GetName()
	return self.Name;
end

function BaseGameState:OnEnter(prevStateName)
	self:CheckScreenMode()
	if self.CLS ~= nil then
		self.CLS.OnEnter(prevStateName)
	end
end

function BaseGameState:OnExit(nextStateName)
	if self.CLS ~= nil then
		self.CLS.OnExit(nextStateName)
	end
end

function BaseGameState:CanExit(nextStateName)
	if self.CLS ~= nil then
		return self.CLS.CanExit(nextStateName)
	end
	return true
end

---检测屏幕方向
function BaseGameState:CheckScreenMode()
	if self:IsPortraitMode() then
		UIMgr.SetPortraitMode()
	else
		UIMgr.SetLandscapeMode()
	end
end

---是否是竖屏模式
---@return boolean
function BaseGameState:IsPortraitMode()
	return true
end

return  BaseGameState