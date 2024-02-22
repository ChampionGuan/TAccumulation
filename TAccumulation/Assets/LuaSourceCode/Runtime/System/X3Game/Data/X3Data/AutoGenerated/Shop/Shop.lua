--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.Shop:X3Data.X3DataBase 
---@field private Id integer ProtoType: int64 Commit:  商店id
---@field private Rands integer[] ProtoType: repeated int32 Commit:  随机的商品列表
---@field private Buys table<integer, integer> ProtoType: map<int32,int32> Commit:  购买记录
---@field private HandReNum integer ProtoType: int32 Commit:  手动重置次数
---@field private LastRefreshTime integer ProtoType: int64 Commit:  上一次刷新时间
---@field private ReSets table<integer, integer> ProtoType: map<int32,int64> Commit: 刷新商品的下一次刷新时间
---@field private LastBuyTime table<integer, integer> ProtoType: map<int32,int64> Commit:  该商品最后一次购买的时间
local Shop = class('Shop', X3DataBase)

--region FieldType
---@class ShopFieldType X3Data.Shop的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.Shop.Id] = 'integer',
    [X3DataConst.X3DataField.Shop.Rands] = 'array',
    [X3DataConst.X3DataField.Shop.Buys] = 'map',
    [X3DataConst.X3DataField.Shop.HandReNum] = 'integer',
    [X3DataConst.X3DataField.Shop.LastRefreshTime] = 'integer',
    [X3DataConst.X3DataField.Shop.ReSets] = 'map',
    [X3DataConst.X3DataField.Shop.LastBuyTime] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function Shop:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class ShopMapOrArrayFieldValueType X3Data.Shop的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.Shop.Rands] = 'integer',
    [X3DataConst.X3DataField.Shop.Buys] = 'integer',
    [X3DataConst.X3DataField.Shop.ReSets] = 'integer',
    [X3DataConst.X3DataField.Shop.LastBuyTime] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function Shop:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class ShopMapFieldKeyType X3Data.Shop的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.Shop.Buys] = 'integer',
    [X3DataConst.X3DataField.Shop.ReSets] = 'integer',
    [X3DataConst.X3DataField.Shop.LastBuyTime] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function Shop:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class ShopEnumFieldValueType X3Data.Shop的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function Shop:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function Shop:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.Shop.Id, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.Shop.Rands])
    rawset(self, X3DataConst.X3DataField.Shop.Rands, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.Shop.Buys])
    rawset(self, X3DataConst.X3DataField.Shop.Buys, nil)
    rawset(self, X3DataConst.X3DataField.Shop.HandReNum, 0)
    rawset(self, X3DataConst.X3DataField.Shop.LastRefreshTime, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.Shop.ReSets])
    rawset(self, X3DataConst.X3DataField.Shop.ReSets, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.Shop.LastBuyTime])
    rawset(self, X3DataConst.X3DataField.Shop.LastBuyTime, nil)
end

---@protected
---@param source table
---@return boolean
function Shop:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.Shop.Id])
    if source[X3DataConst.X3DataField.Shop.Rands] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.Shop.Rands]) do
            self:_AddTableValue(X3DataConst.X3DataField.Shop.Rands, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.Shop.Buys] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.Shop.Buys]) do
            self:_AddTableValue(X3DataConst.X3DataField.Shop.Buys, v, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.Shop.HandReNum, source[X3DataConst.X3DataField.Shop.HandReNum])
    self:_SetBasicField(X3DataConst.X3DataField.Shop.LastRefreshTime, source[X3DataConst.X3DataField.Shop.LastRefreshTime])
    if source[X3DataConst.X3DataField.Shop.ReSets] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.Shop.ReSets]) do
            self:_AddTableValue(X3DataConst.X3DataField.Shop.ReSets, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.Shop.LastBuyTime] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.Shop.LastBuyTime]) do
            self:_AddTableValue(X3DataConst.X3DataField.Shop.LastBuyTime, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function Shop:GetPrimaryKey()
    return X3DataConst.X3DataField.Shop.Id
end

--region Getter/Setter
---@return integer
function Shop:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.Shop.Id)
end

---@param value integer
---@return boolean
function Shop:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.Shop.Id, value)
end

---@return table
function Shop:GetRands()
    return self:_Get(X3DataConst.X3DataField.Shop.Rands)
end

---@param value any
---@param key any
---@return boolean
function Shop:AddRandsValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.Shop.Rands, value, key)
end

---@param key any
---@param value any
---@return boolean
function Shop:UpdateRandsValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.Shop.Rands, key, value)
end

---@param key any
---@param value any
---@return boolean
function Shop:AddOrUpdateRandsValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.Shop.Rands, key, value)
end

---@param key any
---@return boolean
function Shop:RemoveRandsValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.Shop.Rands, key)
end

---@return boolean
function Shop:ClearRandsValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.Shop.Rands)
end

---@return table
function Shop:GetBuys()
    return self:_Get(X3DataConst.X3DataField.Shop.Buys)
end

---@param value any
---@param key any
---@return boolean
function Shop:AddBuysValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.Shop.Buys, key, value)
end

---@param key any
---@param value any
---@return boolean
function Shop:UpdateBuysValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.Shop.Buys, key, value)
end

---@param key any
---@param value any
---@return boolean
function Shop:AddOrUpdateBuysValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.Shop.Buys, key, value)
end

---@param key any
---@return boolean
function Shop:RemoveBuysValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.Shop.Buys, key)
end

---@return boolean
function Shop:ClearBuysValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.Shop.Buys)
end

---@return integer
function Shop:GetHandReNum()
    return self:_Get(X3DataConst.X3DataField.Shop.HandReNum)
end

---@param value integer
---@return boolean
function Shop:SetHandReNum(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Shop.HandReNum, value)
end

---@return integer
function Shop:GetLastRefreshTime()
    return self:_Get(X3DataConst.X3DataField.Shop.LastRefreshTime)
end

---@param value integer
---@return boolean
function Shop:SetLastRefreshTime(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Shop.LastRefreshTime, value)
end

---@return table
function Shop:GetReSets()
    return self:_Get(X3DataConst.X3DataField.Shop.ReSets)
end

---@param value any
---@param key any
---@return boolean
function Shop:AddReSetsValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.Shop.ReSets, key, value)
end

---@param key any
---@param value any
---@return boolean
function Shop:UpdateReSetsValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.Shop.ReSets, key, value)
end

---@param key any
---@param value any
---@return boolean
function Shop:AddOrUpdateReSetsValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.Shop.ReSets, key, value)
end

---@param key any
---@return boolean
function Shop:RemoveReSetsValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.Shop.ReSets, key)
end

---@return boolean
function Shop:ClearReSetsValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.Shop.ReSets)
end

---@return table
function Shop:GetLastBuyTime()
    return self:_Get(X3DataConst.X3DataField.Shop.LastBuyTime)
end

---@param value any
---@param key any
---@return boolean
function Shop:AddLastBuyTimeValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.Shop.LastBuyTime, key, value)
end

---@param key any
---@param value any
---@return boolean
function Shop:UpdateLastBuyTimeValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.Shop.LastBuyTime, key, value)
end

---@param key any
---@param value any
---@return boolean
function Shop:AddOrUpdateLastBuyTimeValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.Shop.LastBuyTime, key, value)
end

---@param key any
---@return boolean
function Shop:RemoveLastBuyTimeValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.Shop.LastBuyTime, key)
end

---@return boolean
function Shop:ClearLastBuyTimeValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.Shop.LastBuyTime)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function Shop:DecodeByIncrement(source)
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
    if source.Id then
        self:SetPrimaryValue(source.Id)
    end
    
    if source.Rands ~= nil then
        for k, v in ipairs(source.Rands) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.Shop.Rands, k, v)
        end
    end
    
    if source.Buys ~= nil then
        for k, v in pairs(source.Buys) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.Shop.Buys, k, v)
        end
    end
    
    if source.HandReNum then
        self:_SetBasicField(X3DataConst.X3DataField.Shop.HandReNum, source.HandReNum)
    end
    
    if source.LastRefreshTime then
        self:_SetBasicField(X3DataConst.X3DataField.Shop.LastRefreshTime, source.LastRefreshTime)
    end
    
    if source.ReSets ~= nil then
        for k, v in pairs(source.ReSets) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.Shop.ReSets, k, v)
        end
    end
    
    if source.LastBuyTime ~= nil then
        for k, v in pairs(source.LastBuyTime) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.Shop.LastBuyTime, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function Shop:DecodeByField(source)
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
    if source.Id then
        self:SetPrimaryValue(source.Id)
    end
    
    if source.Rands ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.Shop.Rands)
        for k, v in ipairs(source.Rands) do
            self:_AddArrayValue(X3DataConst.X3DataField.Shop.Rands, v)
        end
    end
    
    if source.Buys ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.Shop.Buys)
        for k, v in pairs(source.Buys) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.Shop.Buys, k, v)
        end
    end
    
    if source.HandReNum then
        self:_SetBasicField(X3DataConst.X3DataField.Shop.HandReNum, source.HandReNum)
    end
    
    if source.LastRefreshTime then
        self:_SetBasicField(X3DataConst.X3DataField.Shop.LastRefreshTime, source.LastRefreshTime)
    end
    
    if source.ReSets ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.Shop.ReSets)
        for k, v in pairs(source.ReSets) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.Shop.ReSets, k, v)
        end
    end
    
    if source.LastBuyTime ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.Shop.LastBuyTime)
        for k, v in pairs(source.LastBuyTime) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.Shop.LastBuyTime, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function Shop:Decode(source)
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
    self:SetPrimaryValue(source.Id)
    if source.Rands ~= nil then
        for k, v in ipairs(source.Rands) do
            self:_AddArrayValue(X3DataConst.X3DataField.Shop.Rands, v)
        end
    end
    
    if source.Buys ~= nil then
        for k, v in pairs(source.Buys) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.Shop.Buys, k, v)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.Shop.HandReNum, source.HandReNum)
    self:_SetBasicField(X3DataConst.X3DataField.Shop.LastRefreshTime, source.LastRefreshTime)
    if source.ReSets ~= nil then
        for k, v in pairs(source.ReSets) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.Shop.ReSets, k, v)
        end
    end
    
    if source.LastBuyTime ~= nil then
        for k, v in pairs(source.LastBuyTime) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.Shop.LastBuyTime, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function Shop:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Id = self:_Get(X3DataConst.X3DataField.Shop.Id)
    local Rands = self:_Get(X3DataConst.X3DataField.Shop.Rands)
    if Rands ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.Shop.Rands]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.Rands = PoolUtil.GetTable()
            for k,v in pairs(Rands) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.Rands[k] = PoolUtil.GetTable()
                    v:Encode(result.Rands[k])
                end
            end
        else
            result.Rands = Rands
        end
    end
    
    local Buys = self:_Get(X3DataConst.X3DataField.Shop.Buys)
    if Buys ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.Shop.Buys]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.Buys = PoolUtil.GetTable()
            for k,v in pairs(Buys) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.Buys[k] = PoolUtil.GetTable()
                    v:Encode(result.Buys[k])
                end
            end
        else
            result.Buys = Buys
        end
    end
    
    result.HandReNum = self:_Get(X3DataConst.X3DataField.Shop.HandReNum)
    result.LastRefreshTime = self:_Get(X3DataConst.X3DataField.Shop.LastRefreshTime)
    local ReSets = self:_Get(X3DataConst.X3DataField.Shop.ReSets)
    if ReSets ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.Shop.ReSets]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.ReSets = PoolUtil.GetTable()
            for k,v in pairs(ReSets) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.ReSets[k] = PoolUtil.GetTable()
                    v:Encode(result.ReSets[k])
                end
            end
        else
            result.ReSets = ReSets
        end
    end
    
    local LastBuyTime = self:_Get(X3DataConst.X3DataField.Shop.LastBuyTime)
    if LastBuyTime ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.Shop.LastBuyTime]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.LastBuyTime = PoolUtil.GetTable()
            for k,v in pairs(LastBuyTime) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.LastBuyTime[k] = PoolUtil.GetTable()
                    v:Encode(result.LastBuyTime[k])
                end
            end
        else
            result.LastBuyTime = LastBuyTime
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(Shop).__newindex = X3DataBase
return Shop