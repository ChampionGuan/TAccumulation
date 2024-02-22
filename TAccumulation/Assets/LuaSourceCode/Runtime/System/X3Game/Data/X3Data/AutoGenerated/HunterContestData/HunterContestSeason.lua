﻿--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.HunterContestSeason:X3Data.X3DataBase 
---@field private ID integer ProtoType: int64 Commit:  段位组ID
---@field private TotalStar integer ProtoType: int32 Commit:  赛季总星数
---@field private Pass boolean ProtoType: bool Commit:  是否通关
local HunterContestSeason = class('HunterContestSeason', X3DataBase)

--region FieldType
---@class HunterContestSeasonFieldType X3Data.HunterContestSeason的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.HunterContestSeason.ID] = 'integer',
    [X3DataConst.X3DataField.HunterContestSeason.TotalStar] = 'integer',
    [X3DataConst.X3DataField.HunterContestSeason.Pass] = 'boolean',
}

---@protected
---@param fieldName string 字段名称
---@return string
function HunterContestSeason:_GetFieldType(fieldName)
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
function HunterContestSeason:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.HunterContestSeason.ID, 0)
    end
    rawset(self, X3DataConst.X3DataField.HunterContestSeason.TotalStar, 0)
    rawset(self, X3DataConst.X3DataField.HunterContestSeason.Pass, false)
end

---@protected
---@param source table
---@return boolean
function HunterContestSeason:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.HunterContestSeason.ID])
    self:_SetBasicField(X3DataConst.X3DataField.HunterContestSeason.TotalStar, source[X3DataConst.X3DataField.HunterContestSeason.TotalStar])
    self:_SetBasicField(X3DataConst.X3DataField.HunterContestSeason.Pass, source[X3DataConst.X3DataField.HunterContestSeason.Pass])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function HunterContestSeason:GetPrimaryKey()
    return X3DataConst.X3DataField.HunterContestSeason.ID
end

--region Getter/Setter
---@return integer
function HunterContestSeason:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.HunterContestSeason.ID)
end

---@param value integer
---@return boolean
function HunterContestSeason:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.HunterContestSeason.ID, value)
end

---@return integer
function HunterContestSeason:GetTotalStar()
    return self:_Get(X3DataConst.X3DataField.HunterContestSeason.TotalStar)
end

---@param value integer
---@return boolean
function HunterContestSeason:SetTotalStar(value)
    return self:_SetBasicField(X3DataConst.X3DataField.HunterContestSeason.TotalStar, value)
end

---@return boolean
function HunterContestSeason:GetPass()
    return self:_Get(X3DataConst.X3DataField.HunterContestSeason.Pass)
end

---@param value boolean
---@return boolean
function HunterContestSeason:SetPass(value)
    return self:_SetBasicField(X3DataConst.X3DataField.HunterContestSeason.Pass, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function HunterContestSeason:DecodeByIncrement(source)
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
    if source.ID then
        self:SetPrimaryValue(source.ID)
    end
    
    if source.TotalStar then
        self:_SetBasicField(X3DataConst.X3DataField.HunterContestSeason.TotalStar, source.TotalStar)
    end
    
    if source.Pass then
        self:_SetBasicField(X3DataConst.X3DataField.HunterContestSeason.Pass, source.Pass)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function HunterContestSeason:DecodeByField(source)
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
    if source.ID then
        self:SetPrimaryValue(source.ID)
    end
    
    if source.TotalStar then
        self:_SetBasicField(X3DataConst.X3DataField.HunterContestSeason.TotalStar, source.TotalStar)
    end
    
    if source.Pass then
        self:_SetBasicField(X3DataConst.X3DataField.HunterContestSeason.Pass, source.Pass)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function HunterContestSeason:Decode(source)
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
    self:SetPrimaryValue(source.ID)
    self:_SetBasicField(X3DataConst.X3DataField.HunterContestSeason.TotalStar, source.TotalStar)
    self:_SetBasicField(X3DataConst.X3DataField.HunterContestSeason.Pass, source.Pass)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function HunterContestSeason:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.ID = self:_Get(X3DataConst.X3DataField.HunterContestSeason.ID)
    result.TotalStar = self:_Get(X3DataConst.X3DataField.HunterContestSeason.TotalStar)
    result.Pass = self:_Get(X3DataConst.X3DataField.HunterContestSeason.Pass)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(HunterContestSeason).__newindex = X3DataBase
return HunterContestSeason