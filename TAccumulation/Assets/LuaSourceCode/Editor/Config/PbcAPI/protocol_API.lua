--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.Message 
---@field ID number 
---@field Payload number 
local  Message  = {}
---@class pbcmessage.Request @option go_package = "witchpb";
---@field Seq number 
---@field Message pbcmessage.Message 
local  Request  = {}
---@class pbcmessage.Respond 
---@field Seq number 
---@field Message pbcmessage.Message 
---@field ErrCode pbcmessage.Errno 
---@field Updates pbcmessage.Message[] 
local  Respond  = {}
