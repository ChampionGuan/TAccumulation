--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.CommonGestureOperatedModeData:X3Data.X3DataBase 
---@field private id integer ProtoType: int64 Commit: id
---@field private dragState X3DataConst.CommonGestureOperatedModeDragState ProtoType: EnumCommonGestureOperatedModeDragState Commit: 拖拽状态
---@field private yawAngle float ProtoType: float Commit: 水平旋转角度
---@field private yawLimits float[] ProtoType: repeated float Commit: 水平旋转的极值(最小值+回弹范围，最小值，最大值，最大值+回弹范围)依次增大
---@field private initYawAngle float ProtoType: float Commit: 水平旋转的初始角度
---@field private initPitchAngle float ProtoType: float Commit: 垂直旋转的初始角度
local CommonGestureOperatedModeData = class('CommonGestureOperatedModeData', X3DataBase)

--region FieldType
---@class CommonGestureOperatedModeDataFieldType X3Data.CommonGestureOperatedModeData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.CommonGestureOperatedModeData.id] = 'integer',
    [X3DataConst.X3DataField.CommonGestureOperatedModeData.dragState] = 'integer',
    [X3DataConst.X3DataField.CommonGestureOperatedModeData.yawAngle] = 'float',
    [X3DataConst.X3DataField.CommonGestureOperatedModeData.yawLimits] = 'array',
    [X3DataConst.X3DataField.CommonGestureOperatedModeData.initYawAngle] = 'float',
    [X3DataConst.X3DataField.CommonGestureOperatedModeData.initPitchAngle] = 'float',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CommonGestureOperatedModeData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class CommonGestureOperatedModeDataMapOrArrayFieldValueType X3Data.CommonGestureOperatedModeData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.CommonGestureOperatedModeData.yawLimits] = 'float',
}

---@protected
---@param fieldName string 字段名称
---@return string
function CommonGestureOperatedModeData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function CommonGestureOperatedModeData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.CommonGestureOperatedModeData.id, 0)
    end
    rawset(self, X3DataConst.X3DataField.CommonGestureOperatedModeData.dragState, 0)
    rawset(self, X3DataConst.X3DataField.CommonGestureOperatedModeData.yawAngle, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.CommonGestureOperatedModeData.yawLimits])
    rawset(self, X3DataConst.X3DataField.CommonGestureOperatedModeData.yawLimits, nil)
    rawset(self, X3DataConst.X3DataField.CommonGestureOperatedModeData.initYawAngle, 0)
    rawset(self, X3DataConst.X3DataField.CommonGestureOperatedModeData.initPitchAngle, 0)
end

---@protected
---@param source table
---@return boolean
function CommonGestureOperatedModeData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.CommonGestureOperatedModeData.id])
    self:_SetEnumField(X3DataConst.X3DataField.CommonGestureOperatedModeData.dragState, source[X3DataConst.X3DataField.CommonGestureOperatedModeData.dragState], 'CommonGestureOperatedModeDragState')
    self:_SetBasicField(X3DataConst.X3DataField.CommonGestureOperatedModeData.yawAngle, source[X3DataConst.X3DataField.CommonGestureOperatedModeData.yawAngle])
    if source[X3DataConst.X3DataField.CommonGestureOperatedModeData.yawLimits] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.CommonGestureOperatedModeData.yawLimits]) do
            self:_AddTableValue(X3DataConst.X3DataField.CommonGestureOperatedModeData.yawLimits, v, k)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.CommonGestureOperatedModeData.initYawAngle, source[X3DataConst.X3DataField.CommonGestureOperatedModeData.initYawAngle])
    self:_SetBasicField(X3DataConst.X3DataField.CommonGestureOperatedModeData.initPitchAngle, source[X3DataConst.X3DataField.CommonGestureOperatedModeData.initPitchAngle])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function CommonGestureOperatedModeData:GetPrimaryKey()
    return X3DataConst.X3DataField.CommonGestureOperatedModeData.id
end

--region Getter/Setter
---@return integer
function CommonGestureOperatedModeData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.CommonGestureOperatedModeData.id)
end

---@param value integer
---@return boolean
function CommonGestureOperatedModeData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.CommonGestureOperatedModeData.id, value)
end

---@return integer
function CommonGestureOperatedModeData:GetDragState()
    return self:_Get(X3DataConst.X3DataField.CommonGestureOperatedModeData.dragState)
end

---@param value integer
---@return boolean
function CommonGestureOperatedModeData:SetDragState(value)
    return self:_SetEnumField(X3DataConst.X3DataField.CommonGestureOperatedModeData.dragState, value, 'CommonGestureOperatedModeDragState')
end

---@return float
function CommonGestureOperatedModeData:GetYawAngle()
    return self:_Get(X3DataConst.X3DataField.CommonGestureOperatedModeData.yawAngle)
end

---@param value float
---@return boolean
function CommonGestureOperatedModeData:SetYawAngle(value)
    return self:_SetBasicField(X3DataConst.X3DataField.CommonGestureOperatedModeData.yawAngle, value)
end

---@return table
function CommonGestureOperatedModeData:GetYawLimits()
    return self:_Get(X3DataConst.X3DataField.CommonGestureOperatedModeData.yawLimits)
end

---@param value any
---@param key any
---@return boolean
function CommonGestureOperatedModeData:AddYawLimitsValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.CommonGestureOperatedModeData.yawLimits, value, key)
end

---@param key any
---@param value any
---@return boolean
function CommonGestureOperatedModeData:UpdateYawLimitsValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.CommonGestureOperatedModeData.yawLimits, key, value)
end

---@param key any
---@param value any
---@return boolean
function CommonGestureOperatedModeData:AddOrUpdateYawLimitsValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.CommonGestureOperatedModeData.yawLimits, key, value)
end

---@param key any
---@return boolean
function CommonGestureOperatedModeData:RemoveYawLimitsValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.CommonGestureOperatedModeData.yawLimits, key)
end

---@return boolean
function CommonGestureOperatedModeData:ClearYawLimitsValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.CommonGestureOperatedModeData.yawLimits)
end

---@return float
function CommonGestureOperatedModeData:GetInitYawAngle()
    return self:_Get(X3DataConst.X3DataField.CommonGestureOperatedModeData.initYawAngle)
end

---@param value float
---@return boolean
function CommonGestureOperatedModeData:SetInitYawAngle(value)
    return self:_SetBasicField(X3DataConst.X3DataField.CommonGestureOperatedModeData.initYawAngle, value)
end

---@return float
function CommonGestureOperatedModeData:GetInitPitchAngle()
    return self:_Get(X3DataConst.X3DataField.CommonGestureOperatedModeData.initPitchAngle)
end

---@param value float
---@return boolean
function CommonGestureOperatedModeData:SetInitPitchAngle(value)
    return self:_SetBasicField(X3DataConst.X3DataField.CommonGestureOperatedModeData.initPitchAngle, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function CommonGestureOperatedModeData:DecodeByIncrement(source)
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
    
    if source.dragState then
        self:_SetEnumField(X3DataConst.X3DataField.CommonGestureOperatedModeData.dragState, source.dragState or X3DataConst.CommonGestureOperatedModeDragState[source.dragState], 'CommonGestureOperatedModeDragState')
    end
    
    if source.yawAngle then
        self:_SetBasicField(X3DataConst.X3DataField.CommonGestureOperatedModeData.yawAngle, source.yawAngle)
    end
    
    if source.yawLimits ~= nil then
        for k, v in ipairs(source.yawLimits) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.CommonGestureOperatedModeData.yawLimits, k, v)
        end
    end
    
    if source.initYawAngle then
        self:_SetBasicField(X3DataConst.X3DataField.CommonGestureOperatedModeData.initYawAngle, source.initYawAngle)
    end
    
    if source.initPitchAngle then
        self:_SetBasicField(X3DataConst.X3DataField.CommonGestureOperatedModeData.initPitchAngle, source.initPitchAngle)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function CommonGestureOperatedModeData:DecodeByField(source)
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
    
    if source.dragState then
        self:_SetEnumField(X3DataConst.X3DataField.CommonGestureOperatedModeData.dragState, source.dragState or X3DataConst.CommonGestureOperatedModeDragState[source.dragState], 'CommonGestureOperatedModeDragState')
    end
    
    if source.yawAngle then
        self:_SetBasicField(X3DataConst.X3DataField.CommonGestureOperatedModeData.yawAngle, source.yawAngle)
    end
    
    if source.yawLimits ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.CommonGestureOperatedModeData.yawLimits)
        for k, v in ipairs(source.yawLimits) do
            self:_AddArrayValue(X3DataConst.X3DataField.CommonGestureOperatedModeData.yawLimits, v)
        end
    end
    
    if source.initYawAngle then
        self:_SetBasicField(X3DataConst.X3DataField.CommonGestureOperatedModeData.initYawAngle, source.initYawAngle)
    end
    
    if source.initPitchAngle then
        self:_SetBasicField(X3DataConst.X3DataField.CommonGestureOperatedModeData.initPitchAngle, source.initPitchAngle)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function CommonGestureOperatedModeData:Decode(source)
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
    self:_SetEnumField(X3DataConst.X3DataField.CommonGestureOperatedModeData.dragState, source.dragState or X3DataConst.CommonGestureOperatedModeDragState[source.dragState], 'CommonGestureOperatedModeDragState')
    self:_SetBasicField(X3DataConst.X3DataField.CommonGestureOperatedModeData.yawAngle, source.yawAngle)
    if source.yawLimits ~= nil then
        for k, v in ipairs(source.yawLimits) do
            self:_AddArrayValue(X3DataConst.X3DataField.CommonGestureOperatedModeData.yawLimits, v)
        end
    end
    
    self:_SetBasicField(X3DataConst.X3DataField.CommonGestureOperatedModeData.initYawAngle, source.initYawAngle)
    self:_SetBasicField(X3DataConst.X3DataField.CommonGestureOperatedModeData.initPitchAngle, source.initPitchAngle)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function CommonGestureOperatedModeData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.id = self:_Get(X3DataConst.X3DataField.CommonGestureOperatedModeData.id)
    local dragState = self:_Get(X3DataConst.X3DataField.CommonGestureOperatedModeData.dragState)
    result.dragState = dragState
    
    result.yawAngle = self:_Get(X3DataConst.X3DataField.CommonGestureOperatedModeData.yawAngle)
    local yawLimits = self:_Get(X3DataConst.X3DataField.CommonGestureOperatedModeData.yawLimits)
    if yawLimits ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.CommonGestureOperatedModeData.yawLimits]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.yawLimits = PoolUtil.GetTable()
            for k,v in pairs(yawLimits) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.yawLimits[k] = PoolUtil.GetTable()
                    v:Encode(result.yawLimits[k])
                end
            end
        else
            result.yawLimits = yawLimits
        end
    end
    
    result.initYawAngle = self:_Get(X3DataConst.X3DataField.CommonGestureOperatedModeData.initYawAngle)
    result.initPitchAngle = self:_Get(X3DataConst.X3DataField.CommonGestureOperatedModeData.initPitchAngle)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(CommonGestureOperatedModeData).__newindex = X3DataBase
return CommonGestureOperatedModeData