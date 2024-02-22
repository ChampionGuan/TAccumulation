--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.Photo:X3Data.X3DataBase 
---@field private Url string ProtoType: string
---@field private TimeStamp integer ProtoType: int64 Commit:  时间戳，个人照片的唯一标识
---@field private Status X3DataConst.PhotoStatus ProtoType: EnumPhotoStatus Commit:  图片状态
---@field private RoleId integer ProtoType: int32 Commit:  男主
---@field private GroupMode X3DataConst.PhotoGroup ProtoType: EnumPhotoGroup Commit:  合照类型
---@field private Mode integer ProtoType: int32 Commit:  拍照模式
---@field private PuzzleMode integer ProtoType: int32 Commit:  拼图模式
---@field private ActionList integer[] ProtoType: repeated int32 Commit:  动作列表
---@field private DecorationList integer[] ProtoType: repeated int32 Commit:  装饰列表
---@field private SourcePhoto X3Data.Photo ProtoType: Photo Commit:  源图片
local Photo = class('Photo', X3DataBase)

--region FieldType
---@class PhotoFieldType X3Data.Photo的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.Photo.Url] = 'string',
    [X3DataConst.X3DataField.Photo.TimeStamp] = 'integer',
    [X3DataConst.X3DataField.Photo.Status] = 'integer',
    [X3DataConst.X3DataField.Photo.RoleId] = 'integer',
    [X3DataConst.X3DataField.Photo.GroupMode] = 'integer',
    [X3DataConst.X3DataField.Photo.Mode] = 'integer',
    [X3DataConst.X3DataField.Photo.PuzzleMode] = 'integer',
    [X3DataConst.X3DataField.Photo.ActionList] = 'array',
    [X3DataConst.X3DataField.Photo.DecorationList] = 'array',
    [X3DataConst.X3DataField.Photo.SourcePhoto] = 'Photo',
}

---@protected
---@param fieldName string 字段名称
---@return string
function Photo:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class PhotoMapOrArrayFieldValueType X3Data.Photo的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.Photo.ActionList] = 'integer',
    [X3DataConst.X3DataField.Photo.DecorationList] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function Photo:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType

--endregion MapFieldKeyType 结束

--region EnumFieldValueType

--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function Photo:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.Photo.Url, "")
    end
    rawset(self, X3DataConst.X3DataField.Photo.TimeStamp, 0)
    rawset(self, X3DataConst.X3DataField.Photo.Status, 0)
    rawset(self, X3DataConst.X3DataField.Photo.RoleId, 0)
    rawset(self, X3DataConst.X3DataField.Photo.GroupMode, 0)
    rawset(self, X3DataConst.X3DataField.Photo.Mode, 0)
    rawset(self, X3DataConst.X3DataField.Photo.PuzzleMode, 0)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.Photo.ActionList])
    rawset(self, X3DataConst.X3DataField.Photo.ActionList, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.Photo.DecorationList])
    rawset(self, X3DataConst.X3DataField.Photo.DecorationList, nil)
    rawset(self, X3DataConst.X3DataField.Photo.SourcePhoto, nil)
end

---@protected
---@param source table
---@return boolean
function Photo:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.Photo.Url])
    self:_SetBasicField(X3DataConst.X3DataField.Photo.TimeStamp, source[X3DataConst.X3DataField.Photo.TimeStamp])
    self:_SetEnumField(X3DataConst.X3DataField.Photo.Status, source[X3DataConst.X3DataField.Photo.Status], 'PhotoStatus')
    self:_SetBasicField(X3DataConst.X3DataField.Photo.RoleId, source[X3DataConst.X3DataField.Photo.RoleId])
    self:_SetEnumField(X3DataConst.X3DataField.Photo.GroupMode, source[X3DataConst.X3DataField.Photo.GroupMode], 'PhotoGroup')
    self:_SetBasicField(X3DataConst.X3DataField.Photo.Mode, source[X3DataConst.X3DataField.Photo.Mode])
    self:_SetBasicField(X3DataConst.X3DataField.Photo.PuzzleMode, source[X3DataConst.X3DataField.Photo.PuzzleMode])
    if source[X3DataConst.X3DataField.Photo.ActionList] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.Photo.ActionList]) do
            self:_AddTableValue(X3DataConst.X3DataField.Photo.ActionList, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.Photo.DecorationList] ~= nil then
        for k, v in ipairs(source[X3DataConst.X3DataField.Photo.DecorationList]) do
            self:_AddTableValue(X3DataConst.X3DataField.Photo.DecorationList, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.Photo.SourcePhoto] ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.Photo.SourcePhoto])
        data:Parse(source[X3DataConst.X3DataField.Photo.SourcePhoto])
        self:_SetX3DataField(X3DataConst.X3DataField.Photo.SourcePhoto, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function Photo:GetPrimaryKey()
    return X3DataConst.X3DataField.Photo.Url
end

--region Getter/Setter
---@return string
function Photo:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.Photo.Url)
end

---@param value string
---@return boolean
function Photo:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.Photo.Url, value)
end

---@return integer
function Photo:GetTimeStamp()
    return self:_Get(X3DataConst.X3DataField.Photo.TimeStamp)
end

---@param value integer
---@return boolean
function Photo:SetTimeStamp(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Photo.TimeStamp, value)
end

---@return integer
function Photo:GetStatus()
    return self:_Get(X3DataConst.X3DataField.Photo.Status)
end

---@param value integer
---@return boolean
function Photo:SetStatus(value)
    return self:_SetEnumField(X3DataConst.X3DataField.Photo.Status, value, 'PhotoStatus')
end

---@return integer
function Photo:GetRoleId()
    return self:_Get(X3DataConst.X3DataField.Photo.RoleId)
end

---@param value integer
---@return boolean
function Photo:SetRoleId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Photo.RoleId, value)
end

---@return integer
function Photo:GetGroupMode()
    return self:_Get(X3DataConst.X3DataField.Photo.GroupMode)
end

---@param value integer
---@return boolean
function Photo:SetGroupMode(value)
    return self:_SetEnumField(X3DataConst.X3DataField.Photo.GroupMode, value, 'PhotoGroup')
end

---@return integer
function Photo:GetMode()
    return self:_Get(X3DataConst.X3DataField.Photo.Mode)
end

---@param value integer
---@return boolean
function Photo:SetMode(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Photo.Mode, value)
end

---@return integer
function Photo:GetPuzzleMode()
    return self:_Get(X3DataConst.X3DataField.Photo.PuzzleMode)
end

---@param value integer
---@return boolean
function Photo:SetPuzzleMode(value)
    return self:_SetBasicField(X3DataConst.X3DataField.Photo.PuzzleMode, value)
end

---@return table
function Photo:GetActionList()
    return self:_Get(X3DataConst.X3DataField.Photo.ActionList)
end

---@param value any
---@param key any
---@return boolean
function Photo:AddActionListValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.Photo.ActionList, value, key)
end

---@param key any
---@param value any
---@return boolean
function Photo:UpdateActionListValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.Photo.ActionList, key, value)
end

---@param key any
---@param value any
---@return boolean
function Photo:AddOrUpdateActionListValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.Photo.ActionList, key, value)
end

---@param key any
---@return boolean
function Photo:RemoveActionListValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.Photo.ActionList, key)
end

---@return boolean
function Photo:ClearActionListValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.Photo.ActionList)
end

---@return table
function Photo:GetDecorationList()
    return self:_Get(X3DataConst.X3DataField.Photo.DecorationList)
end

---@param value any
---@param key any
---@return boolean
function Photo:AddDecorationListValue(value, key)
    return self:_AddArrayValue(X3DataConst.X3DataField.Photo.DecorationList, value, key)
end

---@param key any
---@param value any
---@return boolean
function Photo:UpdateDecorationListValue(key, value)
    return self:_UpdateArrayValue(X3DataConst.X3DataField.Photo.DecorationList, key, value)
end

---@param key any
---@param value any
---@return boolean
function Photo:AddOrUpdateDecorationListValue(key, value)
    return self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.Photo.DecorationList, key, value)
end

---@param key any
---@return boolean
function Photo:RemoveDecorationListValue(key)
    return self:_RemoveArrayValue(X3DataConst.X3DataField.Photo.DecorationList, key)
end

---@return boolean
function Photo:ClearDecorationListValue()
    return self:_ClearArrayValue(X3DataConst.X3DataField.Photo.DecorationList)
end

---@return X3Data.Photo
function Photo:GetSourcePhoto()
    return self:_Get(X3DataConst.X3DataField.Photo.SourcePhoto)
end

---@param value X3Data.Photo
---@return boolean
function Photo:SetSourcePhoto(value)
    return self:_SetX3DataField(X3DataConst.X3DataField.Photo.SourcePhoto, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function Photo:DecodeByIncrement(source)
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
    if source.Url then
        self:SetPrimaryValue(source.Url)
    end
    
    if source.TimeStamp then
        self:_SetBasicField(X3DataConst.X3DataField.Photo.TimeStamp, source.TimeStamp)
    end
    
    if source.Status then
        self:_SetEnumField(X3DataConst.X3DataField.Photo.Status, source.Status or X3DataConst.PhotoStatus[source.Status], 'PhotoStatus')
    end
    
    if source.RoleId then
        self:_SetBasicField(X3DataConst.X3DataField.Photo.RoleId, source.RoleId)
    end
    
    if source.GroupMode then
        self:_SetEnumField(X3DataConst.X3DataField.Photo.GroupMode, source.GroupMode or X3DataConst.PhotoGroup[source.GroupMode], 'PhotoGroup')
    end
    
    if source.Mode then
        self:_SetBasicField(X3DataConst.X3DataField.Photo.Mode, source.Mode)
    end
    
    if source.PuzzleMode then
        self:_SetBasicField(X3DataConst.X3DataField.Photo.PuzzleMode, source.PuzzleMode)
    end
    
    if source.ActionList ~= nil then
        for k, v in ipairs(source.ActionList) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.Photo.ActionList, k, v)
        end
    end
    
    if source.DecorationList ~= nil then
        for k, v in ipairs(source.DecorationList) do
            self:_AddOrUpdateArrayValue(X3DataConst.X3DataField.Photo.DecorationList, k, v)
        end
    end
    
    if source.SourcePhoto ~= nil then
        local data = self[X3DataConst.X3DataField.Photo.SourcePhoto]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.Photo.SourcePhoto])
        end
        
        data:DecodeByIncrement(source.SourcePhoto)
        self:_SetX3DataField(X3DataConst.X3DataField.Photo.SourcePhoto, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function Photo:DecodeByField(source)
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
    if source.Url then
        self:SetPrimaryValue(source.Url)
    end
    
    if source.TimeStamp then
        self:_SetBasicField(X3DataConst.X3DataField.Photo.TimeStamp, source.TimeStamp)
    end
    
    if source.Status then
        self:_SetEnumField(X3DataConst.X3DataField.Photo.Status, source.Status or X3DataConst.PhotoStatus[source.Status], 'PhotoStatus')
    end
    
    if source.RoleId then
        self:_SetBasicField(X3DataConst.X3DataField.Photo.RoleId, source.RoleId)
    end
    
    if source.GroupMode then
        self:_SetEnumField(X3DataConst.X3DataField.Photo.GroupMode, source.GroupMode or X3DataConst.PhotoGroup[source.GroupMode], 'PhotoGroup')
    end
    
    if source.Mode then
        self:_SetBasicField(X3DataConst.X3DataField.Photo.Mode, source.Mode)
    end
    
    if source.PuzzleMode then
        self:_SetBasicField(X3DataConst.X3DataField.Photo.PuzzleMode, source.PuzzleMode)
    end
    
    if source.ActionList ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.Photo.ActionList)
        for k, v in ipairs(source.ActionList) do
            self:_AddArrayValue(X3DataConst.X3DataField.Photo.ActionList, v)
        end
    end
    
    if source.DecorationList ~= nil then
        self:_ClearArrayValue(X3DataConst.X3DataField.Photo.DecorationList)
        for k, v in ipairs(source.DecorationList) do
            self:_AddArrayValue(X3DataConst.X3DataField.Photo.DecorationList, v)
        end
    end
    
    if source.SourcePhoto ~= nil then
        local data = self[X3DataConst.X3DataField.Photo.SourcePhoto]
        if data == nil then
            data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.Photo.SourcePhoto])
        end
        
        data:DecodeByField(source.SourcePhoto)
        self:_SetX3DataField(X3DataConst.X3DataField.Photo.SourcePhoto, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function Photo:Decode(source)
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
    self:SetPrimaryValue(source.Url)
    self:_SetBasicField(X3DataConst.X3DataField.Photo.TimeStamp, source.TimeStamp)
    self:_SetEnumField(X3DataConst.X3DataField.Photo.Status, source.Status or X3DataConst.PhotoStatus[source.Status], 'PhotoStatus')
    self:_SetBasicField(X3DataConst.X3DataField.Photo.RoleId, source.RoleId)
    self:_SetEnumField(X3DataConst.X3DataField.Photo.GroupMode, source.GroupMode or X3DataConst.PhotoGroup[source.GroupMode], 'PhotoGroup')
    self:_SetBasicField(X3DataConst.X3DataField.Photo.Mode, source.Mode)
    self:_SetBasicField(X3DataConst.X3DataField.Photo.PuzzleMode, source.PuzzleMode)
    if source.ActionList ~= nil then
        for k, v in ipairs(source.ActionList) do
            self:_AddArrayValue(X3DataConst.X3DataField.Photo.ActionList, v)
        end
    end
    
    if source.DecorationList ~= nil then
        for k, v in ipairs(source.DecorationList) do
            self:_AddArrayValue(X3DataConst.X3DataField.Photo.DecorationList, v)
        end
    end
    
    if source.SourcePhoto ~= nil then
        local data = X3DataMgr.Create(FieldType[X3DataConst.X3DataField.Photo.SourcePhoto])
        data:Decode(source.SourcePhoto)
        self:_SetX3DataField(X3DataConst.X3DataField.Photo.SourcePhoto, data)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function Photo:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Url = self:_Get(X3DataConst.X3DataField.Photo.Url)
    result.TimeStamp = self:_Get(X3DataConst.X3DataField.Photo.TimeStamp)
    local Status = self:_Get(X3DataConst.X3DataField.Photo.Status)
    result.Status = Status
    
    result.RoleId = self:_Get(X3DataConst.X3DataField.Photo.RoleId)
    local GroupMode = self:_Get(X3DataConst.X3DataField.Photo.GroupMode)
    result.GroupMode = GroupMode
    
    result.Mode = self:_Get(X3DataConst.X3DataField.Photo.Mode)
    result.PuzzleMode = self:_Get(X3DataConst.X3DataField.Photo.PuzzleMode)
    local ActionList = self:_Get(X3DataConst.X3DataField.Photo.ActionList)
    if ActionList ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.Photo.ActionList]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.ActionList = PoolUtil.GetTable()
            for k,v in pairs(ActionList) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.ActionList[k] = PoolUtil.GetTable()
                    v:Encode(result.ActionList[k])
                end
            end
        else
            result.ActionList = ActionList
        end
    end
    
    local DecorationList = self:_Get(X3DataConst.X3DataField.Photo.DecorationList)
    if DecorationList ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.Photo.DecorationList]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.DecorationList = PoolUtil.GetTable()
            for k,v in pairs(DecorationList) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.DecorationList[k] = PoolUtil.GetTable()
                    v:Encode(result.DecorationList[k])
                end
            end
        else
            result.DecorationList = DecorationList
        end
    end
    
    if self:_Get(X3DataConst.X3DataField.Photo.SourcePhoto) ~= nil then
        result.SourcePhoto = PoolUtil.GetTable()
        ---@type X3Data.Photo
        local data = self:_Get(X3DataConst.X3DataField.Photo.SourcePhoto)
        data:Encode(result.SourcePhoto)
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(Photo).__newindex = X3DataBase
return Photo