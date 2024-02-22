﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2023/8/21 16:03
--- 测试数组的基础类型

---@class X3Game.TestArrayAction:FSM.FSMAction
---@field testArrayInt FSM.FSMVarArray | int[] 测试intArray
---@field testArrayBoolean FSM.FSMVarArray | boolean[] 测试 booleanArray
---@field testArrayString FSM.FSMVarArray | string[] 测试stringArray
---@field testArrayFloat FSM.FSMVarArray | float[] 测试floatArray
---@field testVector2 FSM.FSMVar | Vector2
---@field testVector3 FSM.FSMVar | Vector3
---@field testVector4 FSM.FSMVar | Vector4
local TestArrayAction = class("TestArrayAction", FSMAction)

function TestArrayAction:OnEnter()
    self.context:Log("TestArrayAction:OnEnter")
    self.context:Log(self.testArrayInt:ToString())
    self.context:Log(self.testArrayBoolean:ToString())
    self.context:Log(self.testArrayString:ToString())
    self.context:Log(self.testArrayFloat:ToString())
    self.context:Log(self.testVector2:ToString())
    self.context:Log(self.testVector3:ToString())
    self.context:Log(self.testVector4:ToString())

    --打印当前的
    local idx = self.context:Random(1, self.testArrayInt:GetLength())
    self.context:LogFormat("testArrayInt,idx=[%s],value=[%s]", idx, self.testArrayInt:GetElement(idx))

    --增加数据
    self.testArrayInt:AddElement(5)
    self.context:Log(string.format("增加数据[5],idx=[%s],", self.testArrayInt:GetLength()), self.testArrayInt:ToString())

    --删除数据
    idx = self.context:Random(1, self.testArrayInt:GetLength())
    local v = self.testArrayInt:GetElement(idx)
    self.testArrayInt:RemoveElementByIndex(idx)
    self.context:Log(string.format("删除数据idx=[%s],value=[%s]", idx, v), self.testArrayInt:ToString())

    --修改数据
    idx = self.context:Random(1, self.testArrayInt:GetLength())
    self.testArrayInt:SetElement(idx, 1234)
    self.context:Log(string.format("修改数据idx=[%s],value=[%s]", idx, 1234), self.testArrayInt:ToString())

    self:Finish()
end

return TestArrayAction