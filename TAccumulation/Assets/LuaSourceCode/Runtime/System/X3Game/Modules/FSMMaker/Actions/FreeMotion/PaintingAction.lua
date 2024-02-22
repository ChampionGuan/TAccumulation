--- X3@PapeGames
--- PaintingAction
--- Created by liyan
--- Created Date: 2023-10-28

---@class X3Game.PaintingAction:FSM.FSMAction
---@field filledRateThreshold FSM.FSMVar | float 填充率
---@field distanceThreshold FSM.FSMVar | float 平均距离
---@field image FSM.FSMVar | string 背景图
---@field imageWorldPosition FSM.FSMVar | Vector3 背景图世界坐标
---@field viewTag FSM.FSMVar | string 绘制窗口
---@field sdf FSM.FSMVar | string SDF 数据
---@field validateRegion FSM.FSMVarArray | Rect[] 绘制起始区域
---@field paintingMat FSM.FSMVar | string 绘制材质
local PaintingAction = class("PaintingAction", FSMAction)

---初始化
function PaintingAction:OnAwake()
end

---进入Action
function PaintingAction:OnEnter()
    UIMgr.Open(self.viewTag:GetValue(),
            self.fsm.id,
            self.paintingMat:GetValue(),
            self.filledRateThreshold:GetValue(),
            self.distanceThreshold:GetValue(),
            self.sdf:GetValue(),
            self.image:GetValue(),
            self.imageWorldPosition:GetValue(),
            self.validateRegion:GetValue())

    self:Finish()
end

---暂停或恢复，true==暂停
---@param isPaused boolean
function PaintingAction:OnPause(isPaused)
end

--[[如需Action Tick需在Action Csharp类上标识Tickable
function PaintingAction:OnUpdate()
end
--]]

---退出Action
function PaintingAction:OnExit()
end

---被重置
function PaintingAction:OnReset()
end

---被销毁
function PaintingAction:OnDestroy()
end

return PaintingAction