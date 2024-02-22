--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.DeliverOrder:X3Data.X3DataBase 
---@field private OrderId string ProtoType: string Commit:  叠纸订单id
---@field private ChannelOrderId string ProtoType: string Commit:  渠道单号
---@field private UniqueId integer ProtoType: int64 Commit:  游戏订单id（同下发的ProductId）
local DeliverOrder = class('DeliverOrder', X3DataBase)

--region FieldType
---@class DeliverOrderFieldType X3Data.DeliverOrder的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.DeliverOrder.OrderId] = 'string',
    [X3DataConst.X3DataField.DeliverOrder.ChannelOrderId] = 'string',
    [X3DataConst.X3DataField.DeliverOrder.UniqueId] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function DeliverOrder:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType

--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function DeliverOrder:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.DeliverOrder.OrderId, "")
    end
    rawset(self, X3DataConst.X3DataField.DeliverOrder.ChannelOrderId, "")
    rawset(self, X3DataConst.X3DataField.DeliverOrder.UniqueId, 0)
end

---@protected
---@param source table
---@return boolean
function DeliverOrder:Parse(source)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(source) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    self:Clear()
    -- Parse的时候不记录，引用全部丢失了
    local isEnableHistory = self.__isEnableHistory
    rawset(self, '__isEnableHistory', false)
    self:SetPrimaryValue(source[X3DataConst.X3DataField.DeliverOrder.OrderId])
    self:_SetBasicField(X3DataConst.X3DataField.DeliverOrder.ChannelOrderId, source[X3DataConst.X3DataField.DeliverOrder.ChannelOrderId])
    self:_SetBasicField(X3DataConst.X3DataField.DeliverOrder.UniqueId, source[X3DataConst.X3DataField.DeliverOrder.UniqueId])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function DeliverOrder:GetPrimaryKey()
    return X3DataConst.X3DataField.DeliverOrder.OrderId
end

--region Getter/Setter
---@return string
function DeliverOrder:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.DeliverOrder.OrderId)
end

---@param value string
---@return boolean
function DeliverOrder:SetPrimaryValue(value)
    -- 在数据库中主键不允许随便改变
    if self.__isInX3DataSet and not self.__isDisablePrimary then
        if self.__isPrimarySet then
            Debug.LogFormatWithTag(GameConst.LogTag.X3DataSys, "X3Data.%s 主键已经设置过，修改失败！！！", self.__cname)
            return false
        end
        
        -- 这里需要提前做安全检查
        if type(value) ~= "number" and type(value) ~= "string" then
            Debug.LogErrorFormatWithTag(GameConst.LogTag.X3DataSys, "X3Data.%s 主键类型错误，修改失败！！！", self.__cname)
            return false
        end
        
        -- 主键默认不能是 0 或 ""
        if value == 0 or value == "" then
            Debug.LogFormatWithTag(GameConst.LogTag.X3DataSys, "X3Data.%s 新的主键不能是默认值，修改失败！！！", self.__cname)
            return false
        end
        
        -- 当前主键发生冲突不允许修改
        if not X3DataMgr._AddPrimary(self, value) then
            Debug.LogErrorFormatWithTag(GameConst.LogTag.X3DataSys, "X3Data.%s 主键冲突，修改失败！！！", self.__cname)
            return false
        end
    end
    return self:_SetBasicField(X3DataConst.X3DataField.DeliverOrder.OrderId, value)
end

---@return string
function DeliverOrder:GetChannelOrderId()
    return self:_Get(X3DataConst.X3DataField.DeliverOrder.ChannelOrderId)
end

---@param value string
---@return boolean
function DeliverOrder:SetChannelOrderId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.DeliverOrder.ChannelOrderId, value)
end

---@return integer
function DeliverOrder:GetUniqueId()
    return self:_Get(X3DataConst.X3DataField.DeliverOrder.UniqueId)
end

---@param value integer
---@return boolean
function DeliverOrder:SetUniqueId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.DeliverOrder.UniqueId, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function DeliverOrder:DecodeByIncrement(source)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(source) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    if source.__X3DataBase then
        return self:ParseByIncrement(source)
    end
    
    -- DecodeByIncrement的时候不记录，引用全部丢失了
    local isEnableHistory = self.__isEnableHistory
    rawset(self, '__isEnableHistory', false)
    if source.OrderId then
        self:SetPrimaryValue(source.OrderId)
    end
    
    if source.ChannelOrderId then
        self:_SetBasicField(X3DataConst.X3DataField.DeliverOrder.ChannelOrderId, source.ChannelOrderId)
    end
    
    if source.UniqueId then
        self:_SetBasicField(X3DataConst.X3DataField.DeliverOrder.UniqueId, source.UniqueId)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function DeliverOrder:DecodeByField(source)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(source) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    if source.__X3DataBase then
        return self:ParseByField(source)
    end
    
    -- DecodeByField的时候不记录，引用全部丢失了
    local isEnableHistory = self.__isEnableHistory
    rawset(self, '__isEnableHistory', false)
    if source.OrderId then
        self:SetPrimaryValue(source.OrderId)
    end
    
    if source.ChannelOrderId then
        self:_SetBasicField(X3DataConst.X3DataField.DeliverOrder.ChannelOrderId, source.ChannelOrderId)
    end
    
    if source.UniqueId then
        self:_SetBasicField(X3DataConst.X3DataField.DeliverOrder.UniqueId, source.UniqueId)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function DeliverOrder:Decode(source)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(source) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    if source.__X3DataBase then
        return self:Parse(source)
    end
    
    self:Clear()
    -- Decode的时候不记录，引用全部丢失了
    local isEnableHistory = self.__isEnableHistory
    rawset(self, '__isEnableHistory', false)
    self:SetPrimaryValue(source.OrderId)
    self:_SetBasicField(X3DataConst.X3DataField.DeliverOrder.ChannelOrderId, source.ChannelOrderId)
    self:_SetBasicField(X3DataConst.X3DataField.DeliverOrder.UniqueId, source.UniqueId)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function DeliverOrder:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.OrderId = self:_Get(X3DataConst.X3DataField.DeliverOrder.OrderId)
    result.ChannelOrderId = self:_Get(X3DataConst.X3DataField.DeliverOrder.ChannelOrderId)
    result.UniqueId = self:_Get(X3DataConst.X3DataField.DeliverOrder.UniqueId)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(DeliverOrder).__newindex = X3DataBase
return DeliverOrder