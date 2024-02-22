--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.GetUnlockInfoReply 
---@field Unlock pbcmessage.UnlockData 
local  GetUnlockInfoReply  = {}
---@class pbcmessage.GetUnlockInfoRequest @    rpc SetUnlockRead(SetUnlockReadRequest) returns (SetUnlockReadReply) {}   设置unlock状态
local  GetUnlockInfoRequest  = {}
---@class pbcmessage.SetUnlockReadReply 
---@field UnlockList number[] @ 成功解锁的id
local  SetUnlockReadReply  = {}
---@class pbcmessage.SetUnlockReadRequest 
---@field UnlockList number[] 
local  SetUnlockReadRequest  = {}
---@class pbcmessage.SetUnlockReply 
---@field UnlockList number[] @ 成功解锁的id
---@field RewardList pbcmessage.S3Int[] @ 奖励
local  SetUnlockReply  = {}
---@class pbcmessage.SetUnlockRequest 
---@field UnlockList number[] 
local  SetUnlockRequest  = {}
---@class pbcmessage.UnlockData @import "x3x3.proto";
---@field  UnlockMap        table<number,boolean> @  key：系统id, value: 客户端存储标志位(有 key 说明已解锁, 对应 value true 表示已读)
---@field LastUnlockSystemID number @ 最后解锁系统 id
local  UnlockData  = {}
---@class pbcmessage.UpdateSystemDisableReply 
---@field Diables number[] @ 一键关闭自定义配置更新
local  UpdateSystemDisableReply  = {}
