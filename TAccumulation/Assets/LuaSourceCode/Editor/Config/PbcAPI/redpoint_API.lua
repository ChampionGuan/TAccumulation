--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.RedPointGroup @ 更多维向量以此类推
---@field  ValueMap  table<number,number> 
---@field  GroupMap  table<number,pbcmessage.RedPointGroup> 
local  RedPointGroup  = {}
---@class pbcmessage.RedPointOperate 
---@field ID number[] 
---@field Value number 
---@field OpType pbcmessage.RedPointOperateType 
local  RedPointOperate  = {}
---@class pbcmessage.RedPointSetReply 
---@field Operates pbcmessage.RedPointOperate[] 
local  RedPointSetReply  = {}
---@class pbcmessage.RedPointSetRequest @    rpc RedPointSet(RedPointSetRequest) returns (RedPointSetReply) {}   红点设置
---@field Operates pbcmessage.RedPointOperate[] 
local  RedPointSetRequest  = {}
