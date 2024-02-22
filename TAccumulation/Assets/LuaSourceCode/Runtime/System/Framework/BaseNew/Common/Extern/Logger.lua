﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by jiaozhu.
--- DateTime: 2023/6/5 15:46
---@class Framework.Logger
---@field private proxy Debug
---@field owner Framework.BaseCtrl
local Logger = class("Logger")

---@vararg any
function Logger:Log(...)
    self.proxy.Log(...)
end

---@param formatStr string 遵循string.format格式 eg:string.format("a = %s,b=%s",1,2)
---@vararg any
function Logger:LogFormat(formatStr, ...)
    self.proxy.LogFormat(formatStr, ...)
end

---@vararg any
function Logger:LogError(...)
    self.proxy.LogError(...)
end

---@param formatStr string 遵循string.format格式 eg:string.format("a = %s,b=%s",1,2)
---@vararg any
function Logger:LogErrorFormat(formatStr, ...)
    self.proxy.LogErrorFormat(formatStr, ...)
end

---@vararg any
function Logger:LogFatal(...)
    self.proxy.LogFatal(...)
end

---@parama formatStr string 遵循string.format格式 eg:string.format("a = %s,b=%s",1,2)
---@vararg any
function Logger:LogFatalFormat(formatStr, ...)
    self.proxy.LogFatalFormat(formatStr, ...)
end

---@vararg any
function Logger:LogWarning(...)
    self.proxy.LogWarning(...)
end

---@param formatStr string 遵循string.format格式 eg:string.format("a = %s,b=%s",1,2)
---@vararg any
function Logger:LogWarningFormat(formatStr, ...)
    self.proxy.LogWarningFormat(formatStr, ...)
end

---@param tbl table
function Logger:LogTable(tbl)
    self.proxy.LogTable(tbl)
end

---@param tbl table
function Logger:LogErrorTable(tbl)
    self.proxy.LogErrorTable(tbl)
end

function Logger:LogTableWithTag(tag, tbl)
    self.proxy.LogTableWithTag(tag, tbl)
end

function Logger:LogErrorTableWithTag(tag, tbl)
    self.proxy.LogErrorTableWithTag(tag, tbl)
end

--region codesegment 普通日志输出
---输出带标记的日志
---@param tag GameConst.LogTag
function Logger:LogWithTag(tag, ...)
    self.proxy.LogWithTag(tag, ...)
end

---输出格式化带标记的日志
---@param tag GameConst.LogTag
---@param formatStr string
function Logger:LogFormatWithTag(tag, formatStr, ...)
    self.proxy.LogFormatWithTag(tag, formatStr, ...)
end

--endregion

---输出带标记的warning日志
---@param tag GameConst.LogTag
function Logger:LogWarningWithTag(tag, ...)
    self.proxy.LogWarningWithTag(tag, ...)
end

---输出格式化带标记的warning日志
---@param tag GameConst.LogTag
---@param formatStr string
function Logger:LogWarningFormatWithTag(tag, formatStr, ...)
    self.proxy.LogWarningFormatWithTag(tag, formatStr, ...)
end

---输出带标记的error日志
---@param tag GameConst.LogTag
function Logger:LogErrorWithTag(tag, ...)
    self.proxy.LogErrorWithTag(tag, ...)
end

---输出带标记的fatal日志
---@param tag GameConst.LogTag
function Logger:LogFatalWithTag(tag, ...)
    self.proxy.LogFatalWithTag(tag, ...)
end

---输出格式化带标记的fatal日志
---@param tag GameConst.LogTag
---@param formatStr string
function Logger:LogFatalFormatWithTag(tag, formatStr, ...)
    self.proxy.LogFatalFormatWithTag(tag, formatStr, ...)
end

---输出格式化的带标记的error日志
---@param tag GameConst.LogTag
---@param formatStr string
function Logger:LogErrorFormatWithTag(tag, formatStr, ...)
    self.proxy.LogErrorFormatWithTag(tag, formatStr, ...)
end


--region  底层调用
---@private
---@param proxy Debug
function Logger:SetProxy(proxy)
    self.proxy = proxy
end

---@private
---@param owner Framework.BaseCtrl
function Logger:SetOwner(owner)
    self.owner = owner
end
--endregion

return Logger