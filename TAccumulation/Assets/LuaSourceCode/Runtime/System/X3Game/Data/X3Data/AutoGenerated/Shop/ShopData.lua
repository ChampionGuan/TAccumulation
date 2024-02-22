--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.ShopData:X3Data.X3DataBase 
---@field private LastRefreshTime integer ProtoType: int64 Commit:  控制商店整体的刷新时机
---@field private HistoryBuys table<integer, integer> ProtoType: map<int32,int32> Commit:  商品历史购买记录 shopGroup表中ID
---@field private ShopGoodsNextRefTime table<integer, integer> ProtoType: map<int32,int64> Commit: 定时刷新的商品 下次刷新商品的时间戳 主要为红点服务
local ShopData = class('ShopData', X3DataBase)

--region FieldType
---@class ShopDataFieldType X3Data.ShopData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.ShopData.LastRefreshTime] = 'integer',
    [X3DataConst.X3DataField.ShopData.HistoryBuys] = 'map',
    [X3DataConst.X3DataField.ShopData.ShopGoodsNextRefTime] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ShopData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class ShopDataMapOrArrayFieldValueType X3Data.ShopData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.ShopData.HistoryBuys] = 'integer',
    [X3DataConst.X3DataField.ShopData.ShopGoodsNextRefTime] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ShopData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class ShopDataMapFieldKeyType X3Data.ShopData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.ShopData.HistoryBuys] = 'integer',
    [X3DataConst.X3DataField.ShopData.ShopGoodsNextRefTime] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ShopData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class ShopDataEnumFieldValueType X3Data.ShopData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function ShopData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function ShopData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.ShopData.LastRefreshTime, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.ShopData.HistoryBuys])
    rawset(self, X3DataConst.X3DataField.ShopData.HistoryBuys, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.ShopData.ShopGoodsNextRefTime])
    rawset(self, X3DataConst.X3DataField.ShopData.ShopGoodsNextRefTime, nil)
end

---@protected
---@param source table
---@return boolean
function ShopData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.ShopData.LastRefreshTime])
    if source[X3DataConst.X3DataField.ShopData.HistoryBuys] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.ShopData.HistoryBuys]) do
            self:_AddTableValue(X3DataConst.X3DataField.ShopData.HistoryBuys, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.ShopData.ShopGoodsNextRefTime] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.ShopData.ShopGoodsNextRefTime]) do
            self:_AddTableValue(X3DataConst.X3DataField.ShopData.ShopGoodsNextRefTime, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function ShopData:GetPrimaryKey()
    return X3DataConst.X3DataField.ShopData.LastRefreshTime
end

--region Getter/Setter
---@return integer
function ShopData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.ShopData.LastRefreshTime)
end

---@param value integer
---@return boolean
function ShopData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.ShopData.LastRefreshTime, value)
end

---@return table
function ShopData:GetHistoryBuys()
    return self:_Get(X3DataConst.X3DataField.ShopData.HistoryBuys)
end

---@param value any
---@param key any
---@return boolean
function ShopData:AddHistoryBuysValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ShopData.HistoryBuys, key, value)
end

---@param key any
---@param value any
---@return boolean
function ShopData:UpdateHistoryBuysValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.ShopData.HistoryBuys, key, value)
end

---@param key any
---@param value any
---@return boolean
function ShopData:AddOrUpdateHistoryBuysValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ShopData.HistoryBuys, key, value)
end

---@param key any
---@return boolean
function ShopData:RemoveHistoryBuysValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.ShopData.HistoryBuys, key)
end

---@return boolean
function ShopData:ClearHistoryBuysValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.ShopData.HistoryBuys)
end

---@return table
function ShopData:GetShopGoodsNextRefTime()
    return self:_Get(X3DataConst.X3DataField.ShopData.ShopGoodsNextRefTime)
end

---@param value any
---@param key any
---@return boolean
function ShopData:AddShopGoodsNextRefTimeValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ShopData.ShopGoodsNextRefTime, key, value)
end

---@param key any
---@param value any
---@return boolean
function ShopData:UpdateShopGoodsNextRefTimeValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.ShopData.ShopGoodsNextRefTime, key, value)
end

---@param key any
---@param value any
---@return boolean
function ShopData:AddOrUpdateShopGoodsNextRefTimeValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ShopData.ShopGoodsNextRefTime, key, value)
end

---@param key any
---@return boolean
function ShopData:RemoveShopGoodsNextRefTimeValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.ShopData.ShopGoodsNextRefTime, key)
end

---@return boolean
function ShopData:ClearShopGoodsNextRefTimeValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.ShopData.ShopGoodsNextRefTime)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function ShopData:DecodeByIncrement(source)
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
    if source.LastRefreshTime then
        self:SetPrimaryValue(source.LastRefreshTime)
    end
    
    if source.HistoryBuys ~= nil then
        for k, v in pairs(source.HistoryBuys) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ShopData.HistoryBuys, k, v)
        end
    end
    
    if source.ShopGoodsNextRefTime ~= nil then
        for k, v in pairs(source.ShopGoodsNextRefTime) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ShopData.ShopGoodsNextRefTime, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ShopData:DecodeByField(source)
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
    if source.LastRefreshTime then
        self:SetPrimaryValue(source.LastRefreshTime)
    end
    
    if source.HistoryBuys ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.ShopData.HistoryBuys)
        for k, v in pairs(source.HistoryBuys) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ShopData.HistoryBuys, k, v)
        end
    end
    
    if source.ShopGoodsNextRefTime ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.ShopData.ShopGoodsNextRefTime)
        for k, v in pairs(source.ShopGoodsNextRefTime) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ShopData.ShopGoodsNextRefTime, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ShopData:Decode(source)
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
    self:SetPrimaryValue(source.LastRefreshTime)
    if source.HistoryBuys ~= nil then
        for k, v in pairs(source.HistoryBuys) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ShopData.HistoryBuys, k, v)
        end
    end
    
    if source.ShopGoodsNextRefTime ~= nil then
        for k, v in pairs(source.ShopGoodsNextRefTime) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ShopData.ShopGoodsNextRefTime, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function ShopData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.LastRefreshTime = self:_Get(X3DataConst.X3DataField.ShopData.LastRefreshTime)
    local HistoryBuys = self:_Get(X3DataConst.X3DataField.ShopData.HistoryBuys)
    if HistoryBuys ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.ShopData.HistoryBuys]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.HistoryBuys = PoolUtil.GetTable()
            for k,v in pairs(HistoryBuys) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.HistoryBuys[k] = PoolUtil.GetTable()
                    v:Encode(result.HistoryBuys[k])
                end
            end
        else
            result.HistoryBuys = HistoryBuys
        end
    end
    
    local ShopGoodsNextRefTime = self:_Get(X3DataConst.X3DataField.ShopData.ShopGoodsNextRefTime)
    if ShopGoodsNextRefTime ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.ShopData.ShopGoodsNextRefTime]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.ShopGoodsNextRefTime = PoolUtil.GetTable()
            for k,v in pairs(ShopGoodsNextRefTime) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.ShopGoodsNextRefTime[k] = PoolUtil.GetTable()
                    v:Encode(result.ShopGoodsNextRefTime[k])
                end
            end
        else
            result.ShopGoodsNextRefTime = ShopGoodsNextRefTime
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(ShopData).__newindex = X3DataBase
return ShopData