--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3Data.PayInfo:X3Data.X3DataBase 
---@field private PayID integer ProtoType: int64 Commit: payInfo id
---@field private Name string ProtoType: string Commit: 商品名称
---@field private Desc string ProtoType: string Commit:  商品描述
---@field private ProductId string ProtoType: string Commit: 渠道商品ID
---@field private Money string ProtoType: string Commit: 商品价格
---@field private Currency string ProtoType: string Commit: 价格币种
---@field private Amount string ProtoType: string Commit: 带货币符号价格 例如 
---@field private Align integer ProtoType: int32 Commit:  货币符号位置 前置为0，后置为1
---@field private Symbol string ProtoType: string Commit: 货币符号 例如
---@field private Pattern string ProtoType: string Commit: 货币符号format格式 
local PayInfo = class('PayInfo', X3DataBase)

--region FieldType
---@class PayInfoFieldType X3Data.PayInfo的字段类型
local FieldType = 
{
    [X3DataConst.X3DataField.PayInfo.PayID] = 'integer',
    [X3DataConst.X3DataField.PayInfo.Name] = 'string',
    [X3DataConst.X3DataField.PayInfo.Desc] = 'string',
    [X3DataConst.X3DataField.PayInfo.ProductId] = 'string',
    [X3DataConst.X3DataField.PayInfo.Money] = 'string',
    [X3DataConst.X3DataField.PayInfo.Currency] = 'string',
    [X3DataConst.X3DataField.PayInfo.Amount] = 'string',
    [X3DataConst.X3DataField.PayInfo.Align] = 'integer',
    [X3DataConst.X3DataField.PayInfo.Symbol] = 'string',
    [X3DataConst.X3DataField.PayInfo.Pattern] = 'string',
}

---@protected
---@param fieldName string 字段名称
---@return string
function PayInfo:_GetFieldType(fieldName)
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
function PayInfo:Clear()
    rawset(self, '__isDirty', false)
    rawset(self, '__isEnableHistory', false)
    rawset(self, '__isDisableFieldRecord', false)
    rawset(self, '__isDisableModifyRecord', false)
    rawset(self, '__isDisablePrimary', false)
    if not self.__isInX3DataSet then
        rawset(self, X3DataConst.X3DataField.PayInfo.PayID, 0)
    end
    rawset(self, X3DataConst.X3DataField.PayInfo.Name, "")
    rawset(self, X3DataConst.X3DataField.PayInfo.Desc, "")
    rawset(self, X3DataConst.X3DataField.PayInfo.ProductId, "")
    rawset(self, X3DataConst.X3DataField.PayInfo.Money, "")
    rawset(self, X3DataConst.X3DataField.PayInfo.Currency, "")
    rawset(self, X3DataConst.X3DataField.PayInfo.Amount, "")
    rawset(self, X3DataConst.X3DataField.PayInfo.Align, 0)
    rawset(self, X3DataConst.X3DataField.PayInfo.Symbol, "")
    rawset(self, X3DataConst.X3DataField.PayInfo.Pattern, "")
end

---@protected
---@param source table
---@return boolean
function PayInfo:Parse(source)
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
    self:SetPrimaryValue(source[X3DataConst.X3DataField.PayInfo.PayID])
    self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Name, source[X3DataConst.X3DataField.PayInfo.Name])
    self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Desc, source[X3DataConst.X3DataField.PayInfo.Desc])
    self:_SetBasicField(X3DataConst.X3DataField.PayInfo.ProductId, source[X3DataConst.X3DataField.PayInfo.ProductId])
    self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Money, source[X3DataConst.X3DataField.PayInfo.Money])
    self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Currency, source[X3DataConst.X3DataField.PayInfo.Currency])
    self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Amount, source[X3DataConst.X3DataField.PayInfo.Amount])
    self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Align, source[X3DataConst.X3DataField.PayInfo.Align])
    self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Symbol, source[X3DataConst.X3DataField.PayInfo.Symbol])
    self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Pattern, source[X3DataConst.X3DataField.PayInfo.Pattern])
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@return number
function PayInfo:GetPrimaryKey()
    return X3DataConst.X3DataField.PayInfo.PayID
end

--region Getter/Setter
---@return integer
function PayInfo:GetPrimaryValue()
    return self:_Get(X3DataConst.X3DataField.PayInfo.PayID)
end

---@param value integer
---@return boolean
function PayInfo:SetPrimaryValue(value)
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
    return self:_SetBasicField(X3DataConst.X3DataField.PayInfo.PayID, value)
end

---@return string
function PayInfo:GetName()
    return self:_Get(X3DataConst.X3DataField.PayInfo.Name)
end

---@param value string
---@return boolean
function PayInfo:SetName(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Name, value)
end

---@return string
function PayInfo:GetDesc()
    return self:_Get(X3DataConst.X3DataField.PayInfo.Desc)
end

---@param value string
---@return boolean
function PayInfo:SetDesc(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Desc, value)
end

---@return string
function PayInfo:GetProductId()
    return self:_Get(X3DataConst.X3DataField.PayInfo.ProductId)
end

---@param value string
---@return boolean
function PayInfo:SetProductId(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PayInfo.ProductId, value)
end

---@return string
function PayInfo:GetMoney()
    return self:_Get(X3DataConst.X3DataField.PayInfo.Money)
end

---@param value string
---@return boolean
function PayInfo:SetMoney(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Money, value)
end

---@return string
function PayInfo:GetCurrency()
    return self:_Get(X3DataConst.X3DataField.PayInfo.Currency)
end

---@param value string
---@return boolean
function PayInfo:SetCurrency(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Currency, value)
end

---@return string
function PayInfo:GetAmount()
    return self:_Get(X3DataConst.X3DataField.PayInfo.Amount)
end

---@param value string
---@return boolean
function PayInfo:SetAmount(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Amount, value)
end

---@return integer
function PayInfo:GetAlign()
    return self:_Get(X3DataConst.X3DataField.PayInfo.Align)
end

---@param value integer
---@return boolean
function PayInfo:SetAlign(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Align, value)
end

---@return string
function PayInfo:GetSymbol()
    return self:_Get(X3DataConst.X3DataField.PayInfo.Symbol)
end

---@param value string
---@return boolean
function PayInfo:SetSymbol(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Symbol, value)
end

---@return string
function PayInfo:GetPattern()
    return self:_Get(X3DataConst.X3DataField.PayInfo.Pattern)
end

---@param value string
---@return boolean
function PayInfo:SetPattern(value)
    return self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Pattern, value)
end
--endregion Getter/Setter 结束

--region Decode/Encode
---@param source table
---@return boolean
function PayInfo:DecodeByIncrement(source)
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
    if source.PayID then
        self:SetPrimaryValue(source.PayID)
    end
    
    if source.Name then
        self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Name, source.Name)
    end
    
    if source.Desc then
        self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Desc, source.Desc)
    end
    
    if source.ProductId then
        self:_SetBasicField(X3DataConst.X3DataField.PayInfo.ProductId, source.ProductId)
    end
    
    if source.Money then
        self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Money, source.Money)
    end
    
    if source.Currency then
        self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Currency, source.Currency)
    end
    
    if source.Amount then
        self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Amount, source.Amount)
    end
    
    if source.Align then
        self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Align, source.Align)
    end
    
    if source.Symbol then
        self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Symbol, source.Symbol)
    end
    
    if source.Pattern then
        self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Pattern, source.Pattern)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PayInfo:DecodeByField(source)
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
    if source.PayID then
        self:SetPrimaryValue(source.PayID)
    end
    
    if source.Name then
        self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Name, source.Name)
    end
    
    if source.Desc then
        self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Desc, source.Desc)
    end
    
    if source.ProductId then
        self:_SetBasicField(X3DataConst.X3DataField.PayInfo.ProductId, source.ProductId)
    end
    
    if source.Money then
        self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Money, source.Money)
    end
    
    if source.Currency then
        self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Currency, source.Currency)
    end
    
    if source.Amount then
        self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Amount, source.Amount)
    end
    
    if source.Align then
        self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Align, source.Align)
    end
    
    if source.Symbol then
        self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Symbol, source.Symbol)
    end
    
    if source.Pattern then
        self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Pattern, source.Pattern)
    end
    
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param source table
---@return boolean
function PayInfo:Decode(source)
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
    self:SetPrimaryValue(source.PayID)
    self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Name, source.Name)
    self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Desc, source.Desc)
    self:_SetBasicField(X3DataConst.X3DataField.PayInfo.ProductId, source.ProductId)
    self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Money, source.Money)
    self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Currency, source.Currency)
    self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Amount, source.Amount)
    self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Align, source.Align)
    self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Symbol, source.Symbol)
    self:_SetBasicField(X3DataConst.X3DataField.PayInfo.Pattern, source.Pattern)
    rawset(self, '__isEnableHistory', isEnableHistory)
    return true
end

---@param result table
---@return boolean
function PayInfo:Encode(result)
    ---- 安全检查开始 ----
    if X3DataMgr._GetIsEnableSafetyCheck() then
        if type(result) ~= "table" then
            return false
        end
    end
    ---- 安全检查结束 ----
    
    result.PayID = self:_Get(X3DataConst.X3DataField.PayInfo.PayID)
    result.Name = self:_Get(X3DataConst.X3DataField.PayInfo.Name)
    result.Desc = self:_Get(X3DataConst.X3DataField.PayInfo.Desc)
    result.ProductId = self:_Get(X3DataConst.X3DataField.PayInfo.ProductId)
    result.Money = self:_Get(X3DataConst.X3DataField.PayInfo.Money)
    result.Currency = self:_Get(X3DataConst.X3DataField.PayInfo.Currency)
    result.Amount = self:_Get(X3DataConst.X3DataField.PayInfo.Amount)
    result.Align = self:_Get(X3DataConst.X3DataField.PayInfo.Align)
    result.Symbol = self:_Get(X3DataConst.X3DataField.PayInfo.Symbol)
    result.Pattern = self:_Get(X3DataConst.X3DataField.PayInfo.Pattern)
    return true
end
--endregion Decode/Encode 结束

--metatable的设置必须放在方法已经初始化完成以后
getmetatable(PayInfo).__newindex = X3DataBase
return PayInfo