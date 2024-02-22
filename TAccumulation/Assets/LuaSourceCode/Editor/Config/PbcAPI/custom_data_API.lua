--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.CustomData 
---@field  DataMap  table<number,pbcmessage.CustomValue> @ 键值对数量不超过65525
local  CustomData  = {}
---@class pbcmessage.CustomDataDeleteReply 
---@field Keys number[] @ 删除的键
local  CustomDataDeleteReply  = {}
---@class pbcmessage.CustomDataDeleteRequest 
---@field Keys number[] 
local  CustomDataDeleteRequest  = {}
---@class pbcmessage.CustomDataGetReply 
---@field  DataMap  table<number,pbcmessage.CustomValue> 
local  CustomDataGetReply  = {}
---@class pbcmessage.CustomDataGetRequest 
---@field Keys number[] 
local  CustomDataGetRequest  = {}
---@class pbcmessage.CustomDataSetReply 
---@field  Rets  table<number,pbcmessage.CustomDataSetRet> @ 设置结果
local  CustomDataSetReply  = {}
---@class pbcmessage.CustomDataSetRequest @    rpc GetValues(CustomDataGetRequest) returns (CustomDataGetReply) {}          获取键值对
---@field  DataMap  table<number,pbcmessage.CustomValue> 
local  CustomDataSetRequest  = {}
---@class pbcmessage.CustomDataSetRet 
---@field ErrNo pbcmessage.Errno 
---@field Value pbcmessage.CustomValue 
local  CustomDataSetRet  = {}
---@class pbcmessage.CustomValue @import "x3x3.proto";
---@field int64Val number @ int64
---@field stringVal string @ 自定义字符串长度不超过100
---@field boolVal boolean @ bool
---@field int32Array number[] @ int32数组，长度不超过20
local  CustomValue  = {}
