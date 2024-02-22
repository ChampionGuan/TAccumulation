--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.ShareData 
---@field  data  table<number,pbcmessage.ShareItem> @ 分享记录
local  ShareData  = {}
---@class pbcmessage.ShareItem @import "x3x3.proto";
---@field groupID number 
---@field Num number 
---@field lastTm number 
local  ShareItem  = {}
---@class pbcmessage.ShareSuccessReply 
---@field shareNum number @ 分享次数
---@field lastTm number @ 分享重置时间
---@field Rewards pbcmessage.S3Int[] @ 分享奖励
local  ShareSuccessReply  = {}
---@class pbcmessage.ShareSuccessRequest @    rpc ShareSuccess(ShareSuccessRequest) returns (ShareSuccessReply) {}   分享成功
---@field SystemID number 
local  ShareSuccessRequest  = {}
