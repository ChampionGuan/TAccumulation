﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2023/8/8 19:30
---
---@type FSM.FSMBase
local FSMBase = require(FSMConst.FSMBasePath)

---@alias FSMVarValueType int | string | float | boolean | Vector2 | Vector3 | Vector4  | Rect | Object 

---@class FSM.FSMVar:FSM.FSMBase
local FSMVar = class("FSMVar", FSMBase)

---@private
function FSMVar:ctor()

    ---@private
    ---@type FSM.FSMVarType 当前数据类型
    self.varType = nil

    ---@private
    ---@type string 变量名称
    self.name = nil

    ---@private
    ---@type FSMVarValueType 变量数据值
    self.value = nil

    ---@private
    ---@type FSMVarValueType 默认值
    self.defaultValue = nil

    ---@private
    ---@type FSMVarValueType 初始化值，重置之后如果有初始化值就会回到初始化值，否则用默认值
    self.initValue = nil

    ---@private
    ---@type FSM.FSMVarShareType 是独有的还是共享数据
    self.shareType = nil

    ---@private
    ---@type boolean 是否是只读
    self.readonly = false
end

---@return FSMVarValueType
function FSMVar:GetValue()
    return self.value
end

---@param value FSMVarValueType
function FSMVar:SetValue(value)
    if  self:IsReadonly() then
        self.context:LogErrorFormat("[FSMVar:SetValue] failed try change readonly var[%s]",self:ToString())
        return
    end
    self.value = value
    self:NotifyValueChanged()
end

---@return boolean
function FSMVar:IsReadonly()
    return self.readonly
end

---@return boolean
function FSMVar:IsArray()
    return self.varType == FSMConst.FSMVarType.Array
end

---@return boolean
function FSMVar:IsNumber()
    return self.varType == FSMConst.FSMVarType.Int or self.varType == FSMConst.FSMVarType.Float
end

---@return boolean
function FSMVar:IsBoolean()
    return self.varType == FSMConst.FSMVarType.Bool
end

---@return boolean
function FSMVar:IsString()
    return self.varType == FSMConst.FSMVarType.String
end

---@return boolean
function FSMVar:IsLuaObject()
    return self.varType == FSMConst.FSMVarType.LuaObject
end

---数据解析
---@private
---@param name string
---@param varType FSM.FSMVarType
---@param value FSMVarValueType
---@param shareType FSM.FSMVarShareType
---@param readonly boolean 是否只读
function FSMVar:Parse(name, value, varType, shareType,readonly)
    self.name = name
    self.varType = varType
    self.shareType = shareType or FSMConst.FSMVarShareType.Normal
    self.readonly = readonly
    self:SetInitValue(value)
end

---@private
---@return FSMVarValueType
function FSMVar:GetDefaultValue()
    if self.defaultValue == nil then
        self.defaultValue = self.context:GetDefaultValue(self.varType)
    end
    return self.defaultValue
end


---@private
---@return FSMVarValueType
function FSMVar:GetResetValue()
    local value = self.initValue
    if value == nil then
        value = self:GetDefaultValue()
    end
    return value
end

---重置
---@private
function FSMVar:OnReset()
    self:SetValue(self:GetResetValue())
end

---设置初始化数据
---@private
function FSMVar:SetInitValue(value)
    self.initValue = value
    self.value = value
end

---数据变更通知
---@private
function FSMVar:NotifyValueChanged()
    local delegate = self.context:GetDelegate()
    if delegate then
        if self.shareType == FSMConst.FSMVarShareType.Normal then
            delegate:OnActionVariableValueChanged(self.fsm.id,self.fsmState.layer.name,self.fsmState.name,self.owner.id,self.name,self.value)
        elseif self.shareType == FSMConst.FSMVarShareType.Embed then
            delegate:OnVariableValueChanged(self.fsm.id,self.name,self.value)
        elseif self.shareType == FSMConst.FSMVarShareType.Global then
            delegate:OnGlobalVariableValueChanged(self.name,self.value)
        end
    end
end

---数据清理
---@private
function FSMVar:OnDestroy()
    self.name = nil
    self.varType = nil
    self.value = nil
    self.defaultValue = nil
    self.initValue = nil
end

---@return string
function FSMVar:ToString()
    return string.format("[FSMVar] name=[%s],varType=[%s],value=[%s],shareType=[%s],readonly=[%s]", self.name, self.varType, self.value, self.shareType,self.readonly)
end

return FSMVar