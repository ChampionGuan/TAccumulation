--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.ListValue @ The JSON representation for `ListValue` is JSON array.
---   // Repeated field of dynamically typed values.
---@field values pbcmessage.Value[] 
local  ListValue  = {}
---@class pbcmessage.Struct @ The JSON representation for `Struct` is JSON object.
---   // Unordered map of dynamically typed values.
---@field  fields  table<string,pbcmessage.Value> 
local  Struct  = {}
---@class pbcmessage.Value @ The JSON representation for `Value` is JSON value.
---   // The kind of value.
---     // Represents a null value.
---@field null_value pbcmessage.NullValue 
---     // Represents a double value.
---@field number_value number 
---     // Represents a string value.
---@field string_value string 
---     // Represents a boolean value.
---@field bool_value boolean 
---     // Represents a structured value.
---@field struct_value pbcmessage.Struct 
---     // Represents a repeated `Value`.
---@field list_value pbcmessage.ListValue 
local  Value  = {}
