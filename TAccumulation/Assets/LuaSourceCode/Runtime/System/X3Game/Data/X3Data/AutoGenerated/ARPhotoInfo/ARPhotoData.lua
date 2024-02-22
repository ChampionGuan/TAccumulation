--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.ARPhotoData:X3Data.X3DataBase 
---@field private id integer ProtoType: int64
---@field private backgroundID integer ProtoType: int32
---@field private actionID integer ProtoType: int32
---@field private clothDataList table<integer, integer> ProtoType: map<int32,int32>
---@field private beautyDelta float ProtoType: float
---@field private lightID integer ProtoType: int32
---@field private lightIntensity float ProtoType: float
---@field private useRealIntensity boolean ProtoType: bool
---@field private lightAngles float ProtoType: float
local ARPhotoData = class('ARPhotoData', X3DataBase)

--region FieldType
---@class ARPhotoDataFieldType X3Data.ARPhotoData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.ARPhotoData.id] = 'integer',
    [X3DataConst.X3DataField.ARPhotoData.backgroundID] = 'integer',
    [X3DataConst.X3DataField.ARPhotoData.actionID] = 'integer',
    [X3DataConst.X3DataField.ARPhotoData.clothDataList] = 'map',
    [X3DataConst.X3DataField.ARPhotoData.beautyDelta] = 'float',
    [X3DataConst.X3DataField.ARPhotoData.lightID] = 'integer',
    [X3DataConst.X3DataField.ARPhotoData.lightIntensity] = 'float',
    [X3DataConst.X3DataField.ARPhotoData.useRealIntensity] = 'boolean',
    [X3DataConst.X3DataField.ARPhotoData.lightAngles] = 'float',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ARPhotoData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class ARPhotoDataMapOrArrayFieldValueType X3Data.ARPhotoData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.ARPhotoData.clothDataList] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ARPhotoData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class ARPhotoDataMapFieldKeyType X3Data.ARPhotoData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.ARPhotoData.clothDataList] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function ARPhotoData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class ARPhotoDataEnumFieldValueType X3Data.ARPhotoData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function ARPhotoData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function ARPhotoData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.ARPhotoData.id, 0)
    end
    rawset(self, X3DataConst.X3DataField.ARPhotoData.backgroundID, 0)
    rawset(self, X3DataConst.X3DataField.ARPhotoData.actionID, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.ARPhotoData.clothDataList])
    rawset(self, X3DataConst.X3DataField.ARPhotoData.clothDataList, nil)
    rawset(self, X3DataConst.X3DataField.ARPhotoData.beautyDelta, 0)
    rawset(self, X3DataConst.X3DataField.ARPhotoData.lightID, 0)
    rawset(self, X3DataConst.X3DataField.ARPhotoData.lightIntensity, 0)
    rawset(self, X3DataConst.X3DataField.ARPhotoData.useRealIntensity, false)
    rawset(self, X3DataConst.X3DataField.ARPhotoData.lightAngles, 0)
end

---@protected
---@param source table
---@return boolean
function ARPhotoData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.ARPhotoData.id])
    self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.backgroundID, source[X3DataConst.X3DataField.ARPhotoData.backgroundID])
    self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.actionID, source[X3DataConst.X3DataField.ARPhotoData.actionID])
    if source[X3DataConst.X3DataField.ARPhotoData.clothDataList] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.ARPhotoData.clothDataList]) do
            self:_AddTableValue(X3DataConst.X3DataField.ARPhotoData.clothDataList, v, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.beautyDelta, source[X3DataConst.X3DataField.ARPhotoData.beautyDelta])
    self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.lightID, source[X3DataConst.X3DataField.ARPhotoData.lightID])
    self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.lightIntensity, source[X3DataConst.X3DataField.ARPhotoData.lightIntensity])
    self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.useRealIntensity, source[X3DataConst.X3DataField.ARPhotoData.useRealIntensity])
    self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.lightAngles, source[X3DataConst.X3DataField.ARPhotoData.lightAngles])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function ARPhotoData:GetPrimaryKey()
    return X3DataConst.X3DataField.ARPhotoData.id
end

--region Getter/Setter
---@return integer
function ARPhotoData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.ARPhotoData.id)
end

---@param value integer
---@return boolean
function ARPhotoData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.id, value)
end

---@return integer
function ARPhotoData:GetBackgroundID()
    return self:_Get(X3DataConst.X3DataField.ARPhotoData.backgroundID)
end

---@param value integer
---@return boolean
function ARPhotoData:SetBackgroundID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.backgroundID, value)
end

---@return integer
function ARPhotoData:GetActionID()
    return self:_Get(X3DataConst.X3DataField.ARPhotoData.actionID)
end

---@param value integer
---@return boolean
function ARPhotoData:SetActionID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.actionID, value)
end

---@return table
function ARPhotoData:GetClothDataList()
    return self:_Get(X3DataConst.X3DataField.ARPhotoData.clothDataList)
end

---@param value any
---@param key any
---@return boolean
function ARPhotoData:AddClothDataListValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ARPhotoData.clothDataList, key, value)
end

---@param key any
---@param value any
---@return boolean
function ARPhotoData:UpdateClothDataListValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.ARPhotoData.clothDataList, key, value)
end

---@param key any
---@param value any
---@return boolean
function ARPhotoData:AddOrUpdateClothDataListValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ARPhotoData.clothDataList, key, value)
end

---@param key any
---@return boolean
function ARPhotoData:RemoveClothDataListValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.ARPhotoData.clothDataList, key)
end

---@return boolean
function ARPhotoData:ClearClothDataListValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.ARPhotoData.clothDataList)
end

---@return float
function ARPhotoData:GetBeautyDelta()
    return self:_Get(X3DataConst.X3DataField.ARPhotoData.beautyDelta)
end

---@param value float
---@return boolean
function ARPhotoData:SetBeautyDelta(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.beautyDelta, value)
end

---@return integer
function ARPhotoData:GetLightID()
    return self:_Get(X3DataConst.X3DataField.ARPhotoData.lightID)
end

---@param value integer
---@return boolean
function ARPhotoData:SetLightID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.lightID, value)
end

---@return float
function ARPhotoData:GetLightIntensity()
    return self:_Get(X3DataConst.X3DataField.ARPhotoData.lightIntensity)
end

---@param value float
---@return boolean
function ARPhotoData:SetLightIntensity(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.lightIntensity, value)
end

---@return boolean
function ARPhotoData:GetUseRealIntensity()
    return self:_Get(X3DataConst.X3DataField.ARPhotoData.useRealIntensity)
end

---@param value boolean
---@return boolean
function ARPhotoData:SetUseRealIntensity(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.useRealIntensity, value)
end

---@return float
function ARPhotoData:GetLightAngles()
    return self:_Get(X3DataConst.X3DataField.ARPhotoData.lightAngles)
end

---@param value float
---@return boolean
function ARPhotoData:SetLightAngles(value)
    return self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.lightAngles, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function ARPhotoData:DecodeByIncrement(source)
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
    if source.id then
        self:SetPrimaryValue(source.id)
    end
    
    if source.backgroundID then
        self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.backgroundID, source.backgroundID)
    end
    
    if source.actionID then
        self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.actionID, source.actionID)
    end
    
    if source.clothDataList ~= nil then
        for k, v in pairs(source.clothDataList) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ARPhotoData.clothDataList, k, v)
        end
    end
    
    if source.beautyDelta then
        self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.beautyDelta, source.beautyDelta)
    end
    
    if source.lightID then
        self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.lightID, source.lightID)
    end
    
    if source.lightIntensity then
        self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.lightIntensity, source.lightIntensity)
    end
    
    if source.useRealIntensity then
        self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.useRealIntensity, source.useRealIntensity)
    end
    
    if source.lightAngles then
        self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.lightAngles, source.lightAngles)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ARPhotoData:DecodeByField(source)
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
    if source.id then
        self:SetPrimaryValue(source.id)
    end
    
    if source.backgroundID then
        self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.backgroundID, source.backgroundID)
    end
    
    if source.actionID then
        self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.actionID, source.actionID)
    end
    
    if source.clothDataList ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.ARPhotoData.clothDataList)
        for k, v in pairs(source.clothDataList) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ARPhotoData.clothDataList, k, v)
        end
    end
    
    if source.beautyDelta then
        self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.beautyDelta, source.beautyDelta)
    end
    
    if source.lightID then
        self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.lightID, source.lightID)
    end
    
    if source.lightIntensity then
        self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.lightIntensity, source.lightIntensity)
    end
    
    if source.useRealIntensity then
        self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.useRealIntensity, source.useRealIntensity)
    end
    
    if source.lightAngles then
        self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.lightAngles, source.lightAngles)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function ARPhotoData:Decode(source)
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
    self:SetPrimaryValue(source.id)
    self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.backgroundID, source.backgroundID)
    self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.actionID, source.actionID)
    if source.clothDataList ~= nil then
        for k, v in pairs(source.clothDataList) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.ARPhotoData.clothDataList, k, v)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.beautyDelta, source.beautyDelta)
    self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.lightID, source.lightID)
    self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.lightIntensity, source.lightIntensity)
    self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.useRealIntensity, source.useRealIntensity)
    self:_SetBasicField(X3DataConst.X3DataField.ARPhotoData.lightAngles, source.lightAngles)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function ARPhotoData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.id = self:_Get(X3DataConst.X3DataField.ARPhotoData.id)
    result.backgroundID = self:_Get(X3DataConst.X3DataField.ARPhotoData.backgroundID)
    result.actionID = self:_Get(X3DataConst.X3DataField.ARPhotoData.actionID)
    local clothDataList = self:_Get(X3DataConst.X3DataField.ARPhotoData.clothDataList)
    if clothDataList ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.ARPhotoData.clothDataList]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.clothDataList = PoolUtil.GetTable()
            for k,v in pairs(clothDataList) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.clothDataList[k] = PoolUtil.GetTable()
                    v:Encode(result.clothDataList[k])
                end
            end
        else
            result.clothDataList = clothDataList
        end
    end
    
    result.beautyDelta = self:_Get(X3DataConst.X3DataField.ARPhotoData.beautyDelta)
    result.lightID = self:_Get(X3DataConst.X3DataField.ARPhotoData.lightID)
    result.lightIntensity = self:_Get(X3DataConst.X3DataField.ARPhotoData.lightIntensity)
    result.useRealIntensity = self:_Get(X3DataConst.X3DataField.ARPhotoData.useRealIntensity)
    result.lightAngles = self:_Get(X3DataConst.X3DataField.ARPhotoData.lightAngles)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(ARPhotoData).__newindex = X3DataBase
return ARPhotoData