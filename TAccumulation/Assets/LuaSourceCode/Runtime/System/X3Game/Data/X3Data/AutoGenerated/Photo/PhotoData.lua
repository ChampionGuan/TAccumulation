--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.PhotoData:X3Data.X3DataBase 
---@field private Name string ProtoType: string
---@field private Mode integer ProtoType: int64
---@field private MaleID integer ProtoType: int64
---@field private FemaleID integer ProtoType: int64
---@field private PictureNum integer ProtoType: int64
---@field private NumOfPeople integer ProtoType: int64
---@field private UploadState X3DataConst.UploadStateEnum ProtoType: EnumUploadStateEnum
---@field private ParentID integer ProtoType: int64
---@field private PlayerID integer ProtoType: int64
---@field private TimeStamp integer ProtoType: int64
---@field private ActionString string ProtoType: string
---@field private DressString string ProtoType: string
---@field private ServerPhotoName string ProtoType: string
---@field private FullUrl string ProtoType: string
---@field private Md5String string ProtoType: string
local PhotoData = class('PhotoData', X3DataBase)

--region FieldType
---@class PhotoDataFieldType X3Data.PhotoData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.PhotoData.Name] = 'string',
    [X3DataConst.X3DataField.PhotoData.Mode] = 'integer',
    [X3DataConst.X3DataField.PhotoData.MaleID] = 'integer',
    [X3DataConst.X3DataField.PhotoData.FemaleID] = 'integer',
    [X3DataConst.X3DataField.PhotoData.PictureNum] = 'integer',
    [X3DataConst.X3DataField.PhotoData.NumOfPeople] = 'integer',
    [X3DataConst.X3DataField.PhotoData.UploadState] = 'integer',
    [X3DataConst.X3DataField.PhotoData.ParentID] = 'integer',
    [X3DataConst.X3DataField.PhotoData.PlayerID] = 'integer',
    [X3DataConst.X3DataField.PhotoData.TimeStamp] = 'integer',
    [X3DataConst.X3DataField.PhotoData.ActionString] = 'string',
    [X3DataConst.X3DataField.PhotoData.DressString] = 'string',
    [X3DataConst.X3DataField.PhotoData.ServerPhotoName] = 'string',
    [X3DataConst.X3DataField.PhotoData.FullUrl] = 'string',
    [X3DataConst.X3DataField.PhotoData.Md5String] = 'string',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhotoData:_GetFieldType(fieldName)
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
function PhotoData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.PhotoData.Name, "")
    end
    rawset(self, X3DataConst.X3DataField.PhotoData.Mode, 0)
    rawset(self, X3DataConst.X3DataField.PhotoData.MaleID, 0)
    rawset(self, X3DataConst.X3DataField.PhotoData.FemaleID, 0)
    rawset(self, X3DataConst.X3DataField.PhotoData.PictureNum, 0)
    rawset(self, X3DataConst.X3DataField.PhotoData.NumOfPeople, 0)
    rawset(self, X3DataConst.X3DataField.PhotoData.UploadState, 0)
    rawset(self, X3DataConst.X3DataField.PhotoData.ParentID, 0)
    rawset(self, X3DataConst.X3DataField.PhotoData.PlayerID, 0)
    rawset(self, X3DataConst.X3DataField.PhotoData.TimeStamp, 0)
    rawset(self, X3DataConst.X3DataField.PhotoData.ActionString, "")
    rawset(self, X3DataConst.X3DataField.PhotoData.DressString, "")
    rawset(self, X3DataConst.X3DataField.PhotoData.ServerPhotoName, "")
    rawset(self, X3DataConst.X3DataField.PhotoData.FullUrl, "")
    rawset(self, X3DataConst.X3DataField.PhotoData.Md5String, "")
end

---@protected
---@param source table
---@return boolean
function PhotoData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.PhotoData.Name])
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.Mode, source[X3DataConst.X3DataField.PhotoData.Mode])
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.MaleID, source[X3DataConst.X3DataField.PhotoData.MaleID])
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.FemaleID, source[X3DataConst.X3DataField.PhotoData.FemaleID])
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.PictureNum, source[X3DataConst.X3DataField.PhotoData.PictureNum])
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.NumOfPeople, source[X3DataConst.X3DataField.PhotoData.NumOfPeople])
    self:_SetEnumField(X3DataConst.X3DataField.PhotoData.UploadState, source[X3DataConst.X3DataField.PhotoData.UploadState], 'UploadStateEnum')
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.ParentID, source[X3DataConst.X3DataField.PhotoData.ParentID])
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.PlayerID, source[X3DataConst.X3DataField.PhotoData.PlayerID])
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.TimeStamp, source[X3DataConst.X3DataField.PhotoData.TimeStamp])
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.ActionString, source[X3DataConst.X3DataField.PhotoData.ActionString])
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.DressString, source[X3DataConst.X3DataField.PhotoData.DressString])
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.ServerPhotoName, source[X3DataConst.X3DataField.PhotoData.ServerPhotoName])
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.FullUrl, source[X3DataConst.X3DataField.PhotoData.FullUrl])
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.Md5String, source[X3DataConst.X3DataField.PhotoData.Md5String])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function PhotoData:GetPrimaryKey()
    return X3DataConst.X3DataField.PhotoData.Name
end

--region Getter/Setter
---@return string
function PhotoData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.PhotoData.Name)
end

---@param value string
---@return boolean
function PhotoData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.PhotoData.Name, value)
end

---@return integer
function PhotoData:GetMode()
    return self:_Get(X3DataConst.X3DataField.PhotoData.Mode)
end

---@param value integer
---@return boolean
function PhotoData:SetMode(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhotoData.Mode, value)
end

---@return integer
function PhotoData:GetMaleID()
    return self:_Get(X3DataConst.X3DataField.PhotoData.MaleID)
end

---@param value integer
---@return boolean
function PhotoData:SetMaleID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhotoData.MaleID, value)
end

---@return integer
function PhotoData:GetFemaleID()
    return self:_Get(X3DataConst.X3DataField.PhotoData.FemaleID)
end

---@param value integer
---@return boolean
function PhotoData:SetFemaleID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhotoData.FemaleID, value)
end

---@return integer
function PhotoData:GetPictureNum()
    return self:_Get(X3DataConst.X3DataField.PhotoData.PictureNum)
end

---@param value integer
---@return boolean
function PhotoData:SetPictureNum(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhotoData.PictureNum, value)
end

---@return integer
function PhotoData:GetNumOfPeople()
    return self:_Get(X3DataConst.X3DataField.PhotoData.NumOfPeople)
end

---@param value integer
---@return boolean
function PhotoData:SetNumOfPeople(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhotoData.NumOfPeople, value)
end

---@return integer
function PhotoData:GetUploadState()
    return self:_Get(X3DataConst.X3DataField.PhotoData.UploadState)
end

---@param value integer
---@return boolean
function PhotoData:SetUploadState(value)
    return self:_SetEnumField(X3DataConst.X3DataField.PhotoData.UploadState, value, 'UploadStateEnum')
end

---@return integer
function PhotoData:GetParentID()
    return self:_Get(X3DataConst.X3DataField.PhotoData.ParentID)
end

---@param value integer
---@return boolean
function PhotoData:SetParentID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhotoData.ParentID, value)
end

---@return integer
function PhotoData:GetPlayerID()
    return self:_Get(X3DataConst.X3DataField.PhotoData.PlayerID)
end

---@param value integer
---@return boolean
function PhotoData:SetPlayerID(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhotoData.PlayerID, value)
end

---@return integer
function PhotoData:GetTimeStamp()
    return self:_Get(X3DataConst.X3DataField.PhotoData.TimeStamp)
end

---@param value integer
---@return boolean
function PhotoData:SetTimeStamp(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhotoData.TimeStamp, value)
end

---@return string
function PhotoData:GetActionString()
    return self:_Get(X3DataConst.X3DataField.PhotoData.ActionString)
end

---@param value string
---@return boolean
function PhotoData:SetActionString(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhotoData.ActionString, value)
end

---@return string
function PhotoData:GetDressString()
    return self:_Get(X3DataConst.X3DataField.PhotoData.DressString)
end

---@param value string
---@return boolean
function PhotoData:SetDressString(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhotoData.DressString, value)
end

---@return string
function PhotoData:GetServerPhotoName()
    return self:_Get(X3DataConst.X3DataField.PhotoData.ServerPhotoName)
end

---@param value string
---@return boolean
function PhotoData:SetServerPhotoName(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhotoData.ServerPhotoName, value)
end

---@return string
function PhotoData:GetFullUrl()
    return self:_Get(X3DataConst.X3DataField.PhotoData.FullUrl)
end

---@param value string
---@return boolean
function PhotoData:SetFullUrl(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhotoData.FullUrl, value)
end

---@return string
function PhotoData:GetMd5String()
    return self:_Get(X3DataConst.X3DataField.PhotoData.Md5String)
end

---@param value string
---@return boolean
function PhotoData:SetMd5String(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PhotoData.Md5String, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function PhotoData:DecodeByIncrement(source)
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
    if source.Name then
        self:SetPrimaryValue(source.Name)
    end
    
    if source.Mode then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.Mode, source.Mode)
    end
    
    if source.MaleID then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.MaleID, source.MaleID)
    end
    
    if source.FemaleID then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.FemaleID, source.FemaleID)
    end
    
    if source.PictureNum then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.PictureNum, source.PictureNum)
    end
    
    if source.NumOfPeople then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.NumOfPeople, source.NumOfPeople)
    end
    
    if source.UploadState then
        self:_SetEnumField(X3DataConst.X3DataField.PhotoData.UploadState, source.UploadState or X3DataConst.UploadStateEnum[source.UploadState], 'UploadStateEnum')
    end
    
    if source.ParentID then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.ParentID, source.ParentID)
    end
    
    if source.PlayerID then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.PlayerID, source.PlayerID)
    end
    
    if source.TimeStamp then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.TimeStamp, source.TimeStamp)
    end
    
    if source.ActionString then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.ActionString, source.ActionString)
    end
    
    if source.DressString then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.DressString, source.DressString)
    end
    
    if source.ServerPhotoName then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.ServerPhotoName, source.ServerPhotoName)
    end
    
    if source.FullUrl then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.FullUrl, source.FullUrl)
    end
    
    if source.Md5String then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.Md5String, source.Md5String)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhotoData:DecodeByField(source)
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
    if source.Name then
        self:SetPrimaryValue(source.Name)
    end
    
    if source.Mode then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.Mode, source.Mode)
    end
    
    if source.MaleID then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.MaleID, source.MaleID)
    end
    
    if source.FemaleID then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.FemaleID, source.FemaleID)
    end
    
    if source.PictureNum then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.PictureNum, source.PictureNum)
    end
    
    if source.NumOfPeople then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.NumOfPeople, source.NumOfPeople)
    end
    
    if source.UploadState then
        self:_SetEnumField(X3DataConst.X3DataField.PhotoData.UploadState, source.UploadState or X3DataConst.UploadStateEnum[source.UploadState], 'UploadStateEnum')
    end
    
    if source.ParentID then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.ParentID, source.ParentID)
    end
    
    if source.PlayerID then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.PlayerID, source.PlayerID)
    end
    
    if source.TimeStamp then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.TimeStamp, source.TimeStamp)
    end
    
    if source.ActionString then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.ActionString, source.ActionString)
    end
    
    if source.DressString then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.DressString, source.DressString)
    end
    
    if source.ServerPhotoName then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.ServerPhotoName, source.ServerPhotoName)
    end
    
    if source.FullUrl then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.FullUrl, source.FullUrl)
    end
    
    if source.Md5String then
        self:_SetBasicField(X3DataConst.X3DataField.PhotoData.Md5String, source.Md5String)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhotoData:Decode(source)
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
    self:SetPrimaryValue(source.Name)
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.Mode, source.Mode)
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.MaleID, source.MaleID)
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.FemaleID, source.FemaleID)
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.PictureNum, source.PictureNum)
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.NumOfPeople, source.NumOfPeople)
    self:_SetEnumField(X3DataConst.X3DataField.PhotoData.UploadState, source.UploadState or X3DataConst.UploadStateEnum[source.UploadState], 'UploadStateEnum')
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.ParentID, source.ParentID)
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.PlayerID, source.PlayerID)
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.TimeStamp, source.TimeStamp)
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.ActionString, source.ActionString)
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.DressString, source.DressString)
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.ServerPhotoName, source.ServerPhotoName)
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.FullUrl, source.FullUrl)
    self:_SetBasicField(X3DataConst.X3DataField.PhotoData.Md5String, source.Md5String)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function PhotoData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.Name = self:_Get(X3DataConst.X3DataField.PhotoData.Name)
    result.Mode = self:_Get(X3DataConst.X3DataField.PhotoData.Mode)
    result.MaleID = self:_Get(X3DataConst.X3DataField.PhotoData.MaleID)
    result.FemaleID = self:_Get(X3DataConst.X3DataField.PhotoData.FemaleID)
    result.PictureNum = self:_Get(X3DataConst.X3DataField.PhotoData.PictureNum)
    result.NumOfPeople = self:_Get(X3DataConst.X3DataField.PhotoData.NumOfPeople)
    local UploadState = self:_Get(X3DataConst.X3DataField.PhotoData.UploadState)
    result.UploadState = UploadState
    
    result.ParentID = self:_Get(X3DataConst.X3DataField.PhotoData.ParentID)
    result.PlayerID = self:_Get(X3DataConst.X3DataField.PhotoData.PlayerID)
    result.TimeStamp = self:_Get(X3DataConst.X3DataField.PhotoData.TimeStamp)
    result.ActionString = self:_Get(X3DataConst.X3DataField.PhotoData.ActionString)
    result.DressString = self:_Get(X3DataConst.X3DataField.PhotoData.DressString)
    result.ServerPhotoName = self:_Get(X3DataConst.X3DataField.PhotoData.ServerPhotoName)
    result.FullUrl = self:_Get(X3DataConst.X3DataField.PhotoData.FullUrl)
    result.Md5String = self:_Get(X3DataConst.X3DataField.PhotoData.Md5String)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(PhotoData).__newindex = X3DataBase
return PhotoData