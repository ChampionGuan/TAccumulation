--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.Order:X3Data.X3DataBase 
---@field private UniqueId integer ProtoType: int64 Commit:  游戏订单id
---@field private OrderId string ProtoType: string Commit:  叠纸订单id
---@field private Uid integer ProtoType: uint64 Commit:  玩家id
---@field private DepositId integer ProtoType: int32 Commit:  游戏商品id（商品的透传参数，用于判断具体是哪个系统的哪个商品）
---@field private PayId integer ProtoType: int32 Commit:  充值id
---@field private Amount float ProtoType: float Commit:  充值金额
---@field private ChannelOrderId string ProtoType: string Commit:  渠道单号
---@field private Status integer ProtoType: int32 Commit:  订单状态 0未支付 1已支付 2已完成
---@field private PlatformId integer ProtoType: uint32 Commit:  平台ID
---@field private DeliverTime integer ProtoType: int64 Commit:  发货时间
---@field private ChargeOpType integer ProtoType: int32 Commit:  充值类型（1：正常充值，3：异常充值，4：续订充值）
---@field private ChannelProductId string ProtoType: string Commit:  渠道产品ID
---@field private CurrencyType string ProtoType: string Commit:  币种
---@field private CreateTime integer ProtoType: int64 Commit:  订单创建时间
---@field private PaidTime integer ProtoType: int64 Commit:  支付完成时间
local Order = class('Order', X3DataBase)

--region FieldType
---@class OrderFieldType X3Data.Order的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.Order.UniqueId] = 'integer',
    [X3DataConst.X3DataField.Order.OrderId] = 'string',
    [X3DataConst.X3DataField.Order.Uid] = 'integer',
    [X3DataConst.X3DataField.Order.DepositId] = 'integer',
    [X3DataConst.X3DataField.Order.PayId] = 'integer',
    [X3DataConst.X3DataField.Order.Amount] = 'float',
    [X3DataConst.X3DataField.Order.ChannelOrderId] = 'string',
    [X3DataConst.X3DataField.Order.Status] = 'integer',
    [X3DataConst.X3DataField.Order.PlatformId] = 'integer',
    [X3DataConst.X3DataField.Order.DeliverTime] = 'integer',
    [X3DataConst.X3DataField.Order.ChargeOpType] = 'integer',
    [X3DataConst.X3DataField.Order.ChannelProductId] = 'string',
    [X3DataConst.X3DataField.Order.CurrencyType] = 'string',
    [X3DataConst.X3DataField.Order.CreateTime] = 'integer',
    [X3DataConst.X3DataField.Order.PaidTime] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function Order:_GetFieldType(fieldName)
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
function Order:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.Order.UniqueId, 0)
    end
    rawset(self, X3DataConst.X3DataField.Order.OrderId, "")
    rawset(self, X3DataConst.X3DataField.Order.Uid, 0)
    rawset(self, X3DataConst.X3DataField.Order.DepositId, 0)
    rawset(self, X3DataConst.X3DataField.Order.PayId, 0)
    rawset(self, X3DataConst.X3DataField.Order.Amount, 0)
    rawset(self, X3DataConst.X3DataField.Order.ChannelOrderId, "")
    rawset(self, X3DataConst.X3DataField.Order.Status, 0)
    rawset(self, X3DataConst.X3DataField.Order.PlatformId, 0)
    rawset(self, X3DataConst.X3DataField.Order.DeliverTime, 0)
    rawset(self, X3DataConst.X3DataField.Order.ChargeOpType, 0)
    rawset(self, X3DataConst.X3DataField.Order.ChannelProductId, "")
    rawset(self, X3DataConst.X3DataField.Order.CurrencyType, "")
    rawset(self, X3DataConst.X3DataField.Order.CreateTime, 0)
    rawset(self, X3DataConst.X3DataField.Order.PaidTime, 0)
end

---@protected
---@param source table
---@return boolean
function Order:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.Order.UniqueId])
    self:_SetBasicField(X3DataConst.X3DataField.Order.OrderId, source[X3DataConst.X3DataField.Order.OrderId])
    self:_SetBasicField(X3DataConst.X3DataField.Order.Uid, source[X3DataConst.X3DataField.Order.Uid])
    self:_SetBasicField(X3DataConst.X3DataField.Order.DepositId, source[X3DataConst.X3DataField.Order.DepositId])
    self:_SetBasicField(X3DataConst.X3DataField.Order.PayId, source[X3DataConst.X3DataField.Order.PayId])
    self:_SetBasicField(X3DataConst.X3DataField.Order.Amount, source[X3DataConst.X3DataField.Order.Amount])
    self:_SetBasicField(X3DataConst.X3DataField.Order.ChannelOrderId, source[X3DataConst.X3DataField.Order.ChannelOrderId])
    self:_SetBasicField(X3DataConst.X3DataField.Order.Status, source[X3DataConst.X3DataField.Order.Status])
    self:_SetBasicField(X3DataConst.X3DataField.Order.PlatformId, source[X3DataConst.X3DataField.Order.PlatformId])
    self:_SetBasicField(X3DataConst.X3DataField.Order.DeliverTime, source[X3DataConst.X3DataField.Order.DeliverTime])
    self:_SetBasicField(X3DataConst.X3DataField.Order.ChargeOpType, source[X3DataConst.X3DataField.Order.ChargeOpType])
    self:_SetBasicField(X3DataConst.X3DataField.Order.ChannelProductId, source[X3DataConst.X3DataField.Order.ChannelProductId])
    self:_SetBasicField(X3DataConst.X3DataField.Order.CurrencyType, source[X3DataConst.X3DataField.Order.CurrencyType])
    self:_SetBasicField(X3DataConst.X3DataField.Order.CreateTime, source[X3DataConst.X3DataField.Order.CreateTime])
    self:_SetBasicField(X3DataConst.X3DataField.Order.PaidTime, source[X3DataConst.X3DataField.Order.PaidTime])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function Order:GetPrimaryKey()
    return X3DataConst.X3DataField.Order.UniqueId
end

--region Getter/Setter
---@return integer
function Order:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.Order.UniqueId)
end

---@param value integer
---@return boolean
function Order:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.Order.UniqueId, value)
end

---@return string
function Order:GetOrderId()
    return self:_Get(X3DataConst.X3DataField.Order.OrderId)
end

---@param value string
---@return boolean
function Order:SetOrderId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Order.OrderId, value)
end

---@return integer
function Order:GetUid()
    return self:_Get(X3DataConst.X3DataField.Order.Uid)
end

---@param value integer
---@return boolean
function Order:SetUid(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Order.Uid, value)
end

---@return integer
function Order:GetDepositId()
    return self:_Get(X3DataConst.X3DataField.Order.DepositId)
end

---@param value integer
---@return boolean
function Order:SetDepositId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Order.DepositId, value)
end

---@return integer
function Order:GetPayId()
    return self:_Get(X3DataConst.X3DataField.Order.PayId)
end

---@param value integer
---@return boolean
function Order:SetPayId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Order.PayId, value)
end

---@return float
function Order:GetAmount()
    return self:_Get(X3DataConst.X3DataField.Order.Amount)
end

---@param value float
---@return boolean
function Order:SetAmount(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Order.Amount, value)
end

---@return string
function Order:GetChannelOrderId()
    return self:_Get(X3DataConst.X3DataField.Order.ChannelOrderId)
end

---@param value string
---@return boolean
function Order:SetChannelOrderId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Order.ChannelOrderId, value)
end

---@return integer
function Order:GetStatus()
    return self:_Get(X3DataConst.X3DataField.Order.Status)
end

---@param value integer
---@return boolean
function Order:SetStatus(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Order.Status, value)
end

---@return integer
function Order:GetPlatformId()
    return self:_Get(X3DataConst.X3DataField.Order.PlatformId)
end

---@param value integer
---@return boolean
function Order:SetPlatformId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Order.PlatformId, value)
end

---@return integer
function Order:GetDeliverTime()
    return self:_Get(X3DataConst.X3DataField.Order.DeliverTime)
end

---@param value integer
---@return boolean
function Order:SetDeliverTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Order.DeliverTime, value)
end

---@return integer
function Order:GetChargeOpType()
    return self:_Get(X3DataConst.X3DataField.Order.ChargeOpType)
end

---@param value integer
---@return boolean
function Order:SetChargeOpType(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Order.ChargeOpType, value)
end

---@return string
function Order:GetChannelProductId()
    return self:_Get(X3DataConst.X3DataField.Order.ChannelProductId)
end

---@param value string
---@return boolean
function Order:SetChannelProductId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Order.ChannelProductId, value)
end

---@return string
function Order:GetCurrencyType()
    return self:_Get(X3DataConst.X3DataField.Order.CurrencyType)
end

---@param value string
---@return boolean
function Order:SetCurrencyType(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Order.CurrencyType, value)
end

---@return integer
function Order:GetCreateTime()
    return self:_Get(X3DataConst.X3DataField.Order.CreateTime)
end

---@param value integer
---@return boolean
function Order:SetCreateTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Order.CreateTime, value)
end

---@return integer
function Order:GetPaidTime()
    return self:_Get(X3DataConst.X3DataField.Order.PaidTime)
end

---@param value integer
---@return boolean
function Order:SetPaidTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Order.PaidTime, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function Order:DecodeByIncrement(source)
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
    if source.UniqueId then
        self:SetPrimaryValue(source.UniqueId)
    end
    
    if source.OrderId then
        self:_SetBasicField(X3DataConst.X3DataField.Order.OrderId, source.OrderId)
    end
    
    if source.Uid then
        self:_SetBasicField(X3DataConst.X3DataField.Order.Uid, source.Uid)
    end
    
    if source.DepositId then
        self:_SetBasicField(X3DataConst.X3DataField.Order.DepositId, source.DepositId)
    end
    
    if source.PayId then
        self:_SetBasicField(X3DataConst.X3DataField.Order.PayId, source.PayId)
    end
    
    if source.Amount then
        self:_SetBasicField(X3DataConst.X3DataField.Order.Amount, source.Amount)
    end
    
    if source.ChannelOrderId then
        self:_SetBasicField(X3DataConst.X3DataField.Order.ChannelOrderId, source.ChannelOrderId)
    end
    
    if source.Status then
        self:_SetBasicField(X3DataConst.X3DataField.Order.Status, source.Status)
    end
    
    if source.PlatformId then
        self:_SetBasicField(X3DataConst.X3DataField.Order.PlatformId, source.PlatformId)
    end
    
    if source.DeliverTime then
        self:_SetBasicField(X3DataConst.X3DataField.Order.DeliverTime, source.DeliverTime)
    end
    
    if source.ChargeOpType then
        self:_SetBasicField(X3DataConst.X3DataField.Order.ChargeOpType, source.ChargeOpType)
    end
    
    if source.ChannelProductId then
        self:_SetBasicField(X3DataConst.X3DataField.Order.ChannelProductId, source.ChannelProductId)
    end
    
    if source.CurrencyType then
        self:_SetBasicField(X3DataConst.X3DataField.Order.CurrencyType, source.CurrencyType)
    end
    
    if source.CreateTime then
        self:_SetBasicField(X3DataConst.X3DataField.Order.CreateTime, source.CreateTime)
    end
    
    if source.PaidTime then
        self:_SetBasicField(X3DataConst.X3DataField.Order.PaidTime, source.PaidTime)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function Order:DecodeByField(source)
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
    if source.UniqueId then
        self:SetPrimaryValue(source.UniqueId)
    end
    
    if source.OrderId then
        self:_SetBasicField(X3DataConst.X3DataField.Order.OrderId, source.OrderId)
    end
    
    if source.Uid then
        self:_SetBasicField(X3DataConst.X3DataField.Order.Uid, source.Uid)
    end
    
    if source.DepositId then
        self:_SetBasicField(X3DataConst.X3DataField.Order.DepositId, source.DepositId)
    end
    
    if source.PayId then
        self:_SetBasicField(X3DataConst.X3DataField.Order.PayId, source.PayId)
    end
    
    if source.Amount then
        self:_SetBasicField(X3DataConst.X3DataField.Order.Amount, source.Amount)
    end
    
    if source.ChannelOrderId then
        self:_SetBasicField(X3DataConst.X3DataField.Order.ChannelOrderId, source.ChannelOrderId)
    end
    
    if source.Status then
        self:_SetBasicField(X3DataConst.X3DataField.Order.Status, source.Status)
    end
    
    if source.PlatformId then
        self:_SetBasicField(X3DataConst.X3DataField.Order.PlatformId, source.PlatformId)
    end
    
    if source.DeliverTime then
        self:_SetBasicField(X3DataConst.X3DataField.Order.DeliverTime, source.DeliverTime)
    end
    
    if source.ChargeOpType then
        self:_SetBasicField(X3DataConst.X3DataField.Order.ChargeOpType, source.ChargeOpType)
    end
    
    if source.ChannelProductId then
        self:_SetBasicField(X3DataConst.X3DataField.Order.ChannelProductId, source.ChannelProductId)
    end
    
    if source.CurrencyType then
        self:_SetBasicField(X3DataConst.X3DataField.Order.CurrencyType, source.CurrencyType)
    end
    
    if source.CreateTime then
        self:_SetBasicField(X3DataConst.X3DataField.Order.CreateTime, source.CreateTime)
    end
    
    if source.PaidTime then
        self:_SetBasicField(X3DataConst.X3DataField.Order.PaidTime, source.PaidTime)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function Order:Decode(source)
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
    self:SetPrimaryValue(source.UniqueId)
    self:_SetBasicField(X3DataConst.X3DataField.Order.OrderId, source.OrderId)
    self:_SetBasicField(X3DataConst.X3DataField.Order.Uid, source.Uid)
    self:_SetBasicField(X3DataConst.X3DataField.Order.DepositId, source.DepositId)
    self:_SetBasicField(X3DataConst.X3DataField.Order.PayId, source.PayId)
    self:_SetBasicField(X3DataConst.X3DataField.Order.Amount, source.Amount)
    self:_SetBasicField(X3DataConst.X3DataField.Order.ChannelOrderId, source.ChannelOrderId)
    self:_SetBasicField(X3DataConst.X3DataField.Order.Status, source.Status)
    self:_SetBasicField(X3DataConst.X3DataField.Order.PlatformId, source.PlatformId)
    self:_SetBasicField(X3DataConst.X3DataField.Order.DeliverTime, source.DeliverTime)
    self:_SetBasicField(X3DataConst.X3DataField.Order.ChargeOpType, source.ChargeOpType)
    self:_SetBasicField(X3DataConst.X3DataField.Order.ChannelProductId, source.ChannelProductId)
    self:_SetBasicField(X3DataConst.X3DataField.Order.CurrencyType, source.CurrencyType)
    self:_SetBasicField(X3DataConst.X3DataField.Order.CreateTime, source.CreateTime)
    self:_SetBasicField(X3DataConst.X3DataField.Order.PaidTime, source.PaidTime)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function Order:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.UniqueId = self:_Get(X3DataConst.X3DataField.Order.UniqueId)
    result.OrderId = self:_Get(X3DataConst.X3DataField.Order.OrderId)
    result.Uid = self:_Get(X3DataConst.X3DataField.Order.Uid)
    result.DepositId = self:_Get(X3DataConst.X3DataField.Order.DepositId)
    result.PayId = self:_Get(X3DataConst.X3DataField.Order.PayId)
    result.Amount = self:_Get(X3DataConst.X3DataField.Order.Amount)
    result.ChannelOrderId = self:_Get(X3DataConst.X3DataField.Order.ChannelOrderId)
    result.Status = self:_Get(X3DataConst.X3DataField.Order.Status)
    result.PlatformId = self:_Get(X3DataConst.X3DataField.Order.PlatformId)
    result.DeliverTime = self:_Get(X3DataConst.X3DataField.Order.DeliverTime)
    result.ChargeOpType = self:_Get(X3DataConst.X3DataField.Order.ChargeOpType)
    result.ChannelProductId = self:_Get(X3DataConst.X3DataField.Order.ChannelProductId)
    result.CurrencyType = self:_Get(X3DataConst.X3DataField.Order.CurrencyType)
    result.CreateTime = self:_Get(X3DataConst.X3DataField.Order.CreateTime)
    result.PaidTime = self:_Get(X3DataConst.X3DataField.Order.PaidTime)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(Order).__newindex = X3DataBase
return Order