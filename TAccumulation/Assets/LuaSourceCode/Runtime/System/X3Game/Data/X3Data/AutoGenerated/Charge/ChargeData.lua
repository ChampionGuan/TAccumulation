--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.ChargeData:X3Data.X3DataBase 
---@field private PrimaryKey integer ProtoType: int64
---@field private Total float ProtoType: float Commit:  累计充值
---@field private ChargeRecords table<integer, X3Data.ChargeRecord> ProtoType: map<int32,ChargeRecord> Commit:  <充值类型,商品记录>
---@field private DeliverOrders table<integer, X3Data.DeliverOrder> ProtoType: map<int64,DeliverOrder> Commit: <游戏内订单id,订单信息> 记录已经发货的订单
---@field private LastChargeTime integer ProtoType: int64 Commit:  最近一次充值时间
---@field private PayLimitBirthday integer ProtoType: int32 Commit: // 记录客户端用于支付上报的生日，如200605 日服专用
---@field private PaidOrders X3Data.Order[] ProtoType: repeated Order Commit:  已支付待发货的订单
---@field private FirstState X3DataConst.FirstPayState ProtoType: EnumFirstPayState Commit:  首充奖励
local ChargeData = class('ChargeData', X3DataBase)

--region FieldType
---@class ChargeDataFieldType X3Data.ChargeData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.ChargeData.PrimaryKey] = 'integer',
    [X3DataConst.X3DataField.ChargeData.Total] = 'float',
    [X3DataConst.X3DataField.ChargeData.ChargeRecords] = 'map',
    [X3DataConst.X3DataField.ChargeData.DeliverOrders] = 'map',
    [X3DataConst.X3DataField.ChargeData.LastChargeTime] = 'integer',
    [X3DataConst.X3DataField.ChargeData.PayLimitBirthday] = 'integer',
    [X3DataConst.X3DataField.ChargeData.PaidOrders] = 'array',
    [X3DataConst.X3DataField.ChargeData.FirstState] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ChargeData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class ChargeDataMapOrArrayFieldValueType X3Data.ChargeData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.ChargeData.ChargeRecords] = 'ChargeRecord',
    [X3DataConst.X3DataField.ChargeData.DeliverOrders] = 'DeliverOrder',
    [X3DataConst.X3DataField.ChargeData.PaidOrders] = 'Order',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ChargeData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class ChargeDataMapFieldKeyType X3Data.ChargeData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.ChargeData.ChargeRecords] = 'integer',
    [X3DataConst.X3DataField.ChargeData.DeliverOrders] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ChargeData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class ChargeDataEnumFieldValueType X3Data.ChargeData的enum字段的Value类型
local EnumFieldValueType = 
{
    [X3DataConst.X3DataField.ChargeData.FirstState] = 'FirstPayState',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ChargeData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function ChargeData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.ChargeData.PrimaryKey, 0)
    end
    rawset(self, X3DataConst.X3DataField.ChargeData.Total, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.ChargeData.ChargeRecords])
    rawset(self, X3DataConst.X3DataField.ChargeData.ChargeRecords, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.ChargeData.DeliverOrders])
    rawset(self, X3DataConst.X3DataField.ChargeData.DeliverOrders, nil)
    rawset(self, X3DataConst.X3DataField.ChargeData.LastChargeTime, 0)
    rawset(self, X3DataConst.X3DataField.ChargeData.PayLimitBirthday, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.ChargeData.PaidOrders])
    rawset(self, X3DataConst.X3DataField.ChargeData.PaidOrders, nil)
    rawset(self, X3DataConst.X3DataField.ChargeData.FirstState, 0)
end

---@protected
---@param source table
---@return boolean
function ChargeData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.ChargeData.PrimaryKey])
    self:_SetBasicField(X3DataConst.X3DataField.ChargeData.Total, source[X3DataConst.X3DataField.ChargeData.Total])
    if source[X3DataConst.X3DataField.ChargeData.ChargeRecords] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.ChargeData.ChargeRecords]) do
            ---@type X3Data.ChargeRecord
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.ChargeData.ChargeRecords])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.ChargeData.ChargeRecords, data, k)
        end
    end
    
    if source[X3DataConst.X3DataField.ChargeData.DeliverOrders] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.ChargeData.DeliverOrders]) do
            ---@type X3Data.DeliverOrder
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.ChargeData.DeliverOrders])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.ChargeData.DeliverOrders, data, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.ChargeData.LastChargeTime, source[X3DataConst.X3DataField.ChargeData.LastChargeTime])
    self:_SetBasicField(X3DataConst.X3DataField.ChargeData.PayLimitBirthday, source[X3DataConst.X3DataField.ChargeData.PayLimitBirthday])
    if source[X3DataConst.X3DataField.ChargeData.PaidOrders] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.ChargeData.PaidOrders]) do
            ---@type X3Data.Order
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.ChargeData.PaidOrders])
            data:Parse(v)
            self:_AddTableValue(X3DataConst.X3DataField.ChargeData.PaidOrders, data, k)
        end
    end
    
    self:_SetEnumField(X3DataConst.X3DataField.ChargeData.FirstState, source[X3DataConst.X3DataField.ChargeData.FirstState], 'FirstPayState')
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function ChargeData:GetPrimaryKey()
    return X3DataConst.X3DataField.ChargeData.PrimaryKey
end

--region Getter/Setter
---@return integer
function ChargeData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.ChargeData.PrimaryKey)
end

---@param value integer
---@return boolean
function ChargeData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.ChargeData.PrimaryKey, value)
end

---@return float
function ChargeData:GetTotal()
    return self:_Get(X3DataConst.X3DataField.ChargeData.Total)
end

---@param value float
---@return boolean
function ChargeData:SetTotal(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ChargeData.Total, value)
end

---@return table
function ChargeData:GetChargeRecords()
    return self:_Get(X3DataConst.X3DataField.ChargeData.ChargeRecords)
end

---@param value any
---@param key any
---@return boolean
function ChargeData:AddChargeRecordsValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ChargeData.ChargeRecords, key, value)
end

---@param key any
---@param value any
---@return boolean
function ChargeData:UpdateChargeRecordsValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.ChargeData.ChargeRecords, key, value)
end

---@param key any
---@param value any
---@return boolean
function ChargeData:AddOrUpdateChargeRecordsValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ChargeData.ChargeRecords, key, value)
end

---@param key any
---@return boolean
function ChargeData:RemoveChargeRecordsValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.ChargeData.ChargeRecords, key)
end

---@return boolean
function ChargeData:ClearChargeRecordsValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.ChargeData.ChargeRecords)
end

---@return table
function ChargeData:GetDeliverOrders()
    return self:_Get(X3DataConst.X3DataField.ChargeData.DeliverOrders)
end

---@param value any
---@param key any
---@return boolean
function ChargeData:AddDeliverOrdersValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ChargeData.DeliverOrders, key, value)
end

---@param key any
---@param value any
---@return boolean
function ChargeData:UpdateDeliverOrdersValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.ChargeData.DeliverOrders, key, value)
end

---@param key any
---@param value any
---@return boolean
function ChargeData:AddOrUpdateDeliverOrdersValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ChargeData.DeliverOrders, key, value)
end

---@param key any
---@return boolean
function ChargeData:RemoveDeliverOrdersValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.ChargeData.DeliverOrders, key)
end

---@return boolean
function ChargeData:ClearDeliverOrdersValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.ChargeData.DeliverOrders)
end

---@return integer
function ChargeData:GetLastChargeTime()
    return self:_Get(X3DataConst.X3DataField.ChargeData.LastChargeTime)
end

---@param value integer
---@return boolean
function ChargeData:SetLastChargeTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ChargeData.LastChargeTime, value)
end

---@return integer
function ChargeData:GetPayLimitBirthday()
    return self:_Get(X3DataConst.X3DataField.ChargeData.PayLimitBirthday)
end

---@param value integer
---@return boolean
function ChargeData:SetPayLimitBirthday(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ChargeData.PayLimitBirthday, value)
end

---@return table
function ChargeData:GetPaidOrders()
    return self:_Get(X3DataConst.X3DataField.ChargeData.PaidOrders)
end

---@param value any
---@param key any
---@return boolean
function ChargeData:AddPaidOrdersValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.ChargeData.PaidOrders, value, key)
end

---@param key any
---@param value any
---@return boolean
function ChargeData:UpdatePaidOrdersValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.ChargeData.PaidOrders, key, value)
end

---@param key any
---@param value any
---@return boolean
function ChargeData:AddOrUpdatePaidOrdersValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.ChargeData.PaidOrders, key, value)
end

---@param key any
---@return boolean
function ChargeData:RemovePaidOrdersValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.ChargeData.PaidOrders, key)
end

---@return boolean
function ChargeData:ClearPaidOrdersValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.ChargeData.PaidOrders)
end

---@return integer
function ChargeData:GetFirstState()
    return self:_Get(X3DataConst.X3DataField.ChargeData.FirstState)
end

---@param value integer
---@return boolean
function ChargeData:SetFirstState(value)
    return self:_SetEnumField(X3DataConst.X3DataField.ChargeData.FirstState, value, 'FirstPayState')
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function ChargeData:DecodeByIncrement(source)
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
    if source.PrimaryKey then
        self:SetPrimaryValue(source.PrimaryKey)
    end
    
    if source.Total then
        self:_SetBasicField(X3DataConst.X3DataField.ChargeData.Total, source.Total)
    end
    
    if source.ChargeRecords ~= nil then
        local map = self:_Get(X3DataConst.X3DataField.ChargeData.ChargeRecords)
        if map == nil then
            for k, v in pairs(source.ChargeRecords) do
                ---@type X3Data.ChargeRecord
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.ChargeData.ChargeRecords])
                data:DecodeByIncrement(v)
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ChargeData.ChargeRecords, k, data)
            end
        else
            for k, v in pairs(source.ChargeRecords) do
                ---@type X3Data.ChargeRecord
                local data = map[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.ChargeData.ChargeRecords])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ChargeData.ChargeRecords, k, data)        
            end
        end
    end

    if source.DeliverOrders ~= nil then
        local map = self:_Get(X3DataConst.X3DataField.ChargeData.DeliverOrders)
        if map == nil then
            for k, v in pairs(source.DeliverOrders) do
                ---@type X3Data.DeliverOrder
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.ChargeData.DeliverOrders])
                data:DecodeByIncrement(v)
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ChargeData.DeliverOrders, k, data)
            end
        else
            for k, v in pairs(source.DeliverOrders) do
                ---@type X3Data.DeliverOrder
                local data = map[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.ChargeData.DeliverOrders])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ChargeData.DeliverOrders, k, data)        
            end
        end
    end

    if source.LastChargeTime then
        self:_SetBasicField(X3DataConst.X3DataField.ChargeData.LastChargeTime, source.LastChargeTime)
    end
    
    if source.PayLimitBirthday then
        self:_SetBasicField(X3DataConst.X3DataField.ChargeData.PayLimitBirthday, source.PayLimitBirthday)
    end
    
    if source.PaidOrders ~= nil then
        local array = self:_Get(X3DataConst.X3DataField.ChargeData.PaidOrders)
        if array == nil then
            for k, v in ipairs(source.PaidOrders) do
                ---@type X3Data.Order
                local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.ChargeData.PaidOrders])
                data:DecodeByIncrement(v)
                self:_AddArrayValue(X3DataConst.X3DataField.ChargeData.PaidOrders, data)
            end
        else
            for k, v in ipairs(source.PaidOrders) do
                ---@type X3Data.Order
                local data = array[k]
                if data ~= nil then
                    data:DecodeByIncrement(v)
                else
                    data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.ChargeData.PaidOrders])
                    data:DecodeByIncrement(v)
                end
                
                self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.ChargeData.PaidOrders, k, data)        
            end
        end
    end

    if source.FirstState then
        self:_SetEnumField(X3DataConst.X3DataField.ChargeData.FirstState, source.FirstState or X3DataConst.FirstPayState[source.FirstState], 'FirstPayState')
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ChargeData:DecodeByField(source)
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
    if source.PrimaryKey then
        self:SetPrimaryValue(source.PrimaryKey)
    end
    
    if source.Total then
        self:_SetBasicField(X3DataConst.X3DataField.ChargeData.Total, source.Total)
    end
    
    if source.ChargeRecords ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.ChargeData.ChargeRecords)
        for k, v in pairs(source.ChargeRecords) do
            ---@type X3Data.ChargeRecord
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.ChargeData.ChargeRecords])
            data:DecodeByField(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ChargeData.ChargeRecords, k, data)
        end
    end
    
    if source.DeliverOrders ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.ChargeData.DeliverOrders)
        for k, v in pairs(source.DeliverOrders) do
            ---@type X3Data.DeliverOrder
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.ChargeData.DeliverOrders])
            data:DecodeByField(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ChargeData.DeliverOrders, k, data)
        end
    end
    
    if source.LastChargeTime then
        self:_SetBasicField(X3DataConst.X3DataField.ChargeData.LastChargeTime, source.LastChargeTime)
    end
    
    if source.PayLimitBirthday then
        self:_SetBasicField(X3DataConst.X3DataField.ChargeData.PayLimitBirthday, source.PayLimitBirthday)
    end
    
    if source.PaidOrders ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.ChargeData.PaidOrders)
        for k, v in ipairs(source.PaidOrders) do
            ---@type X3Data.Order
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.ChargeData.PaidOrders])
            data:DecodeByField(v)
            self:_AddArrayValue(X3DataConst.X3DataField.ChargeData.PaidOrders, data)
        end
    end

    if source.FirstState then
        self:_SetEnumField(X3DataConst.X3DataField.ChargeData.FirstState, source.FirstState or X3DataConst.FirstPayState[source.FirstState], 'FirstPayState')
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ChargeData:Decode(source)
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
    self:SetPrimaryValue(source.PrimaryKey)
    self:_SetBasicField(X3DataConst.X3DataField.ChargeData.Total, source.Total)
    if source.ChargeRecords ~= nil then
        for k, v in pairs(source.ChargeRecords) do
            ---@type X3Data.ChargeRecord
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.ChargeData.ChargeRecords])
            data:Decode(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ChargeData.ChargeRecords, k, data)
        end
    end
    
    if source.DeliverOrders ~= nil then
        for k, v in pairs(source.DeliverOrders) do
            ---@type X3Data.DeliverOrder
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.ChargeData.DeliverOrders])
            data:Decode(v)
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ChargeData.DeliverOrders, k, data)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.ChargeData.LastChargeTime, source.LastChargeTime)
    self:_SetBasicField(X3DataConst.X3DataField.ChargeData.PayLimitBirthday, source.PayLimitBirthday)
    if source.PaidOrders ~= nil then
        for k, v in ipairs(source.PaidOrders) do
            ---@type X3Data.Order
            local data = X3DataMgr.Create(MapOrArrayFieldValueType[X3DataConst.X3DataField.ChargeData.PaidOrders])
            data:Decode(v)
            self:_AddArrayValue(X3DataConst.X3DataField.ChargeData.PaidOrders, data)
        end
    end
    
    self:_SetEnumField(X3DataConst.X3DataField.ChargeData.FirstState, source.FirstState or X3DataConst.FirstPayState[source.FirstState], 'FirstPayState')
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function ChargeData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.PrimaryKey = self:_Get(X3DataConst.X3DataField.ChargeData.PrimaryKey)
    result.Total = self:_Get(X3DataConst.X3DataField.ChargeData.Total)
    local ChargeRecords = self:_Get(X3DataConst.X3DataField.ChargeData.ChargeRecords)
    if ChargeRecords ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.ChargeData.ChargeRecords]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.ChargeRecords = PoolUtil.GetTable()
            for k,v in pairs(ChargeRecords) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.ChargeRecords[k] = PoolUtil.GetTable()
                    v:Encode(result.ChargeRecords[k])
                end
            end
        else
            result.ChargeRecords = ChargeRecords
        end
    end
    
    local DeliverOrders = self:_Get(X3DataConst.X3DataField.ChargeData.DeliverOrders)
    if DeliverOrders ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.ChargeData.DeliverOrders]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.DeliverOrders = PoolUtil.GetTable()
            for k,v in pairs(DeliverOrders) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.DeliverOrders[k] = PoolUtil.GetTable()
                    v:Encode(result.DeliverOrders[k])
                end
            end
        else
            result.DeliverOrders = DeliverOrders
        end
    end
    
    result.LastChargeTime = self:_Get(X3DataConst.X3DataField.ChargeData.LastChargeTime)
    result.PayLimitBirthday = self:_Get(X3DataConst.X3DataField.ChargeData.PayLimitBirthday)
    local PaidOrders = self:_Get(X3DataConst.X3DataField.ChargeData.PaidOrders)
    if PaidOrders ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.ChargeData.PaidOrders]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.PaidOrders = PoolUtil.GetTable()
            for k,v in pairs(PaidOrders) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.PaidOrders[k] = PoolUtil.GetTable()
                    v:Encode(result.PaidOrders[k])
                end
            end
        else
            result.PaidOrders = PaidOrders
        end
    end
    
    local FirstState = self:_Get(X3DataConst.X3DataField.ChargeData.FirstState)
    result.FirstState = FirstState
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(ChargeData).__newindex = X3DataBase
return ChargeData