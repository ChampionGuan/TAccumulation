--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.PhoneContactData:X3Data.X3DataBase 
---@field private LastRefreshTime integer ProtoType: int64 Commit:  上次刷新时间
---@field private HeadPhotos table<integer, boolean> ProtoType: map<int32,bool> Commit:  静态头像 k:静态头像id v:是否为New
---@field private Signs table<integer, boolean> ProtoType: map<int32,bool> Commit:  签名 k:签名id v:是否为New
---@field private MomentCovers table<integer, boolean> ProtoType: map<int32,bool> Commit:  朋友圈封面 k:封面id v:是否为New
---@field private Bubbles table<integer, boolean> ProtoType: map<int32,bool> Commit:  聊天气泡
---@field private ChatBackgrounds table<integer, boolean> ProtoType: map<int32,bool> Commit:  聊天背景
local PhoneContactData = class('PhoneContactData', X3DataBase)

--region FieldType
---@class PhoneContactDataFieldType X3Data.PhoneContactData的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.PhoneContactData.LastRefreshTime] = 'integer',
    [X3DataConst.X3DataField.PhoneContactData.HeadPhotos] = 'map',
    [X3DataConst.X3DataField.PhoneContactData.Signs] = 'map',
    [X3DataConst.X3DataField.PhoneContactData.MomentCovers] = 'map',
    [X3DataConst.X3DataField.PhoneContactData.Bubbles] = 'map',
    [X3DataConst.X3DataField.PhoneContactData.ChatBackgrounds] = 'map',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneContactData:_GetFieldType(fieldName)
    return FieldType[fieldName]
end
--endregion FieldType 结束

--region MapOrArrayFieldValueType
---@class PhoneContactDataMapOrArrayFieldValueType X3Data.PhoneContactData的array/map字段的Value类型
local MapOrArrayFieldValueType = 
{
    [X3DataConst.X3DataField.PhoneContactData.HeadPhotos] = 'boolean',
    [X3DataConst.X3DataField.PhoneContactData.Signs] = 'boolean',
    [X3DataConst.X3DataField.PhoneContactData.MomentCovers] = 'boolean',
    [X3DataConst.X3DataField.PhoneContactData.Bubbles] = 'boolean',
    [X3DataConst.X3DataField.PhoneContactData.ChatBackgrounds] = 'boolean',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneContactData:_GetTableValueType(fieldName)
    return MapOrArrayFieldValueType[fieldName]
end
--endregion MapOrArrayFieldValueType 结束

--region MapFieldKeyType
---@class PhoneContactDataMapFieldKeyType X3Data.PhoneContactData的map字段的Key类型
local MapFieldKeyType = 
{
    [X3DataConst.X3DataField.PhoneContactData.HeadPhotos] = 'integer',
    [X3DataConst.X3DataField.PhoneContactData.Signs] = 'integer',
    [X3DataConst.X3DataField.PhoneContactData.MomentCovers] = 'integer',
    [X3DataConst.X3DataField.PhoneContactData.Bubbles] = 'integer',
    [X3DataConst.X3DataField.PhoneContactData.ChatBackgrounds] = 'integer',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneContactData:_GetMapKeyType(fieldName)
    return MapFieldKeyType[fieldName]
end
--endregion MapFieldKeyType 结束

--region EnumFieldValueType
---@class PhoneContactDataEnumFieldValueType X3Data.PhoneContactData的enum字段的Value类型
local EnumFieldValueType = 
{

}

---@protected
---@param fieldName string 字段名称
---@return string
function PhoneContactData:_GetEnumValueType(fieldName)
    return EnumFieldValueType[fieldName]
end
--endregion EnumFieldValueType 结束

---在X3DataMgr中初始化时会调用该方法
function PhoneContactData:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.PhoneContactData.LastRefreshTime, 0)
    end
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneContactData.HeadPhotos])
    rawset(self, X3DataConst.X3DataField.PhoneContactData.HeadPhotos, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneContactData.Signs])
    rawset(self, X3DataConst.X3DataField.PhoneContactData.Signs, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneContactData.MomentCovers])
    rawset(self, X3DataConst.X3DataField.PhoneContactData.MomentCovers, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneContactData.Bubbles])
    rawset(self, X3DataConst.X3DataField.PhoneContactData.Bubbles, nil)
    PoolUtil.ReleaseTable(self[X3DataConst.X3DataField.PhoneContactData.ChatBackgrounds])
    rawset(self, X3DataConst.X3DataField.PhoneContactData.ChatBackgrounds, nil)
end

---@protected
---@param source table
---@return boolean
function PhoneContactData:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.PhoneContactData.LastRefreshTime])
    if source[X3DataConst.X3DataField.PhoneContactData.HeadPhotos] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PhoneContactData.HeadPhotos]) do
            self:_AddTableValue(X3DataConst.X3DataField.PhoneContactData.HeadPhotos, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.PhoneContactData.Signs] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PhoneContactData.Signs]) do
            self:_AddTableValue(X3DataConst.X3DataField.PhoneContactData.Signs, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.PhoneContactData.MomentCovers] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PhoneContactData.MomentCovers]) do
            self:_AddTableValue(X3DataConst.X3DataField.PhoneContactData.MomentCovers, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.PhoneContactData.Bubbles] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PhoneContactData.Bubbles]) do
            self:_AddTableValue(X3DataConst.X3DataField.PhoneContactData.Bubbles, v, k)
        end
    end
    
    if source[X3DataConst.X3DataField.PhoneContactData.ChatBackgrounds] ~= nil then
        for k, v in pairs(source[X3DataConst.X3DataField.PhoneContactData.ChatBackgrounds]) do
            self:_AddTableValue(X3DataConst.X3DataField.PhoneContactData.ChatBackgrounds, v, k)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function PhoneContactData:GetPrimaryKey()
    return X3DataConst.X3DataField.PhoneContactData.LastRefreshTime
end

--region Getter/Setter
---@return integer
function PhoneContactData:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.PhoneContactData.LastRefreshTime)
end

---@param value integer
---@return boolean
function PhoneContactData:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.PhoneContactData.LastRefreshTime, value)
end

---@return table
function PhoneContactData:GetHeadPhotos()
    return self:_Get(X3DataConst.X3DataField.PhoneContactData.HeadPhotos)
end

---@param value any
---@param key any
---@return boolean
function PhoneContactData:AddHeadPhotosValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.HeadPhotos, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneContactData:UpdateHeadPhotosValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PhoneContactData.HeadPhotos, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneContactData:AddOrUpdateHeadPhotosValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.HeadPhotos, key, value)
end

---@param key any
---@return boolean
function PhoneContactData:RemoveHeadPhotosValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PhoneContactData.HeadPhotos, key)
end

---@return boolean
function PhoneContactData:ClearHeadPhotosValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PhoneContactData.HeadPhotos)
end

---@return table
function PhoneContactData:GetSigns()
    return self:_Get(X3DataConst.X3DataField.PhoneContactData.Signs)
end

---@param value any
---@param key any
---@return boolean
function PhoneContactData:AddSignsValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.Signs, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneContactData:UpdateSignsValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PhoneContactData.Signs, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneContactData:AddOrUpdateSignsValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.Signs, key, value)
end

---@param key any
---@return boolean
function PhoneContactData:RemoveSignsValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PhoneContactData.Signs, key)
end

---@return boolean
function PhoneContactData:ClearSignsValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PhoneContactData.Signs)
end

---@return table
function PhoneContactData:GetMomentCovers()
    return self:_Get(X3DataConst.X3DataField.PhoneContactData.MomentCovers)
end

---@param value any
---@param key any
---@return boolean
function PhoneContactData:AddMomentCoversValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.MomentCovers, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneContactData:UpdateMomentCoversValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PhoneContactData.MomentCovers, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneContactData:AddOrUpdateMomentCoversValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.MomentCovers, key, value)
end

---@param key any
---@return boolean
function PhoneContactData:RemoveMomentCoversValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PhoneContactData.MomentCovers, key)
end

---@return boolean
function PhoneContactData:ClearMomentCoversValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PhoneContactData.MomentCovers)
end

---@return table
function PhoneContactData:GetBubbles()
    return self:_Get(X3DataConst.X3DataField.PhoneContactData.Bubbles)
end

---@param value any
---@param key any
---@return boolean
function PhoneContactData:AddBubblesValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.Bubbles, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneContactData:UpdateBubblesValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PhoneContactData.Bubbles, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneContactData:AddOrUpdateBubblesValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.Bubbles, key, value)
end

---@param key any
---@return boolean
function PhoneContactData:RemoveBubblesValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PhoneContactData.Bubbles, key)
end

---@return boolean
function PhoneContactData:ClearBubblesValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PhoneContactData.Bubbles)
end

---@return table
function PhoneContactData:GetChatBackgrounds()
    return self:_Get(X3DataConst.X3DataField.PhoneContactData.ChatBackgrounds)
end

---@param value any
---@param key any
---@return boolean
function PhoneContactData:AddChatBackgroundsValue(value, key)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.ChatBackgrounds, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneContactData:UpdateChatBackgroundsValue(key, value)
    return self:_UpdateMapValue(X3DataConst.X3DataField.PhoneContactData.ChatBackgrounds, key, value)
end

---@param key any
---@param value any
---@return boolean
function PhoneContactData:AddOrUpdateChatBackgroundsValue(key, value)
    return self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.ChatBackgrounds, key, value)
end

---@param key any
---@return boolean
function PhoneContactData:RemoveChatBackgroundsValue(key)
    return self:_RemoveMapValue(X3DataConst.X3DataField.PhoneContactData.ChatBackgrounds, key)
end

---@return boolean
function PhoneContactData:ClearChatBackgroundsValue()
    return self:_ClearMapValue(X3DataConst.X3DataField.PhoneContactData.ChatBackgrounds)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function PhoneContactData:DecodeByIncrement(source)
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
    
    if source.HeadPhotos ~= nil then
        for k, v in pairs(source.HeadPhotos) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.HeadPhotos, k, v)
        end
    end
    
    if source.Signs ~= nil then
        for k, v in pairs(source.Signs) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.Signs, k, v)
        end
    end
    
    if source.MomentCovers ~= nil then
        for k, v in pairs(source.MomentCovers) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.MomentCovers, k, v)
        end
    end
    
    if source.Bubbles ~= nil then
        for k, v in pairs(source.Bubbles) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.Bubbles, k, v)
        end
    end
    
    if source.ChatBackgrounds ~= nil then
        for k, v in pairs(source.ChatBackgrounds) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.ChatBackgrounds, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneContactData:DecodeByField(source)
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
    
    if source.HeadPhotos ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PhoneContactData.HeadPhotos)
        for k, v in pairs(source.HeadPhotos) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.HeadPhotos, k, v)
        end
    end
    
    if source.Signs ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PhoneContactData.Signs)
        for k, v in pairs(source.Signs) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.Signs, k, v)
        end
    end
    
    if source.MomentCovers ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PhoneContactData.MomentCovers)
        for k, v in pairs(source.MomentCovers) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.MomentCovers, k, v)
        end
    end
    
    if source.Bubbles ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PhoneContactData.Bubbles)
        for k, v in pairs(source.Bubbles) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.Bubbles, k, v)
        end
    end
    
    if source.ChatBackgrounds ~= nil then
        self:_ClearMapValue(X3DataConst.X3DataField.PhoneContactData.ChatBackgrounds)
        for k, v in pairs(source.ChatBackgrounds) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.ChatBackgrounds, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PhoneContactData:Decode(source)
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
    if source.HeadPhotos ~= nil then
        for k, v in pairs(source.HeadPhotos) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.HeadPhotos, k, v)
        end
    end
    
    if source.Signs ~= nil then
        for k, v in pairs(source.Signs) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.Signs, k, v)
        end
    end
    
    if source.MomentCovers ~= nil then
        for k, v in pairs(source.MomentCovers) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.MomentCovers, k, v)
        end
    end
    
    if source.Bubbles ~= nil then
        for k, v in pairs(source.Bubbles) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.Bubbles, k, v)
        end
    end
    
    if source.ChatBackgrounds ~= nil then
        for k, v in pairs(source.ChatBackgrounds) do
            self:_AddOrUpdateMapValue(X3DataConst.X3DataField.PhoneContactData.ChatBackgrounds, k, v)
        end
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function PhoneContactData:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.LastRefreshTime = self:_Get(X3DataConst.X3DataField.PhoneContactData.LastRefreshTime)
    local HeadPhotos = self:_Get(X3DataConst.X3DataField.PhoneContactData.HeadPhotos)
    if HeadPhotos ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneContactData.HeadPhotos]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.HeadPhotos = PoolUtil.GetTable()
            for k,v in pairs(HeadPhotos) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.HeadPhotos[k] = PoolUtil.GetTable()
                    v:Encode(result.HeadPhotos[k])
                end
            end
        else
            result.HeadPhotos = HeadPhotos
        end
    end
    
    local Signs = self:_Get(X3DataConst.X3DataField.PhoneContactData.Signs)
    if Signs ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneContactData.Signs]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.Signs = PoolUtil.GetTable()
            for k,v in pairs(Signs) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.Signs[k] = PoolUtil.GetTable()
                    v:Encode(result.Signs[k])
                end
            end
        else
            result.Signs = Signs
        end
    end
    
    local MomentCovers = self:_Get(X3DataConst.X3DataField.PhoneContactData.MomentCovers)
    if MomentCovers ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneContactData.MomentCovers]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.MomentCovers = PoolUtil.GetTable()
            for k,v in pairs(MomentCovers) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.MomentCovers[k] = PoolUtil.GetTable()
                    v:Encode(result.MomentCovers[k])
                end
            end
        else
            result.MomentCovers = MomentCovers
        end
    end
    
    local Bubbles = self:_Get(X3DataConst.X3DataField.PhoneContactData.Bubbles)
    if Bubbles ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneContactData.Bubbles]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.Bubbles = PoolUtil.GetTable()
            for k,v in pairs(Bubbles) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.Bubbles[k] = PoolUtil.GetTable()
                    v:Encode(result.Bubbles[k])
                end
            end
        else
            result.Bubbles = Bubbles
        end
    end
    
    local ChatBackgrounds = self:_Get(X3DataConst.X3DataField.PhoneContactData.ChatBackgrounds)
    if ChatBackgrounds ~= nil then
        local tableValueType = MapOrArrayFieldValueType[X3DataConst.X3DataField.PhoneContactData.ChatBackgrounds]
        if X3DataConst.X3Data[tableValueType] ~= nil then
            result.ChatBackgrounds = PoolUtil.GetTable()
            for k,v in pairs(ChatBackgrounds) do
                if type(v) == "table" and v.__X3DataBase ~= nil then
                    result.ChatBackgrounds[k] = PoolUtil.GetTable()
                    v:Encode(result.ChatBackgrounds[k])
                end
            end
        else
            result.ChatBackgrounds = ChatBackgrounds
        end
    end
    
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(PhoneContactData).__newindex = X3DataBase
return PhoneContactData