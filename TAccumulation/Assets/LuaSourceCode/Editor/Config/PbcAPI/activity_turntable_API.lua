--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.ActivityTurntable @ 转盘活动
---@field  DropCount  table<number,number> @ ActivityTurntableDrop.ID->次数
---@field FreeResetTime number @ 免费次数重置时间
local  ActivityTurntable  = {}
---@class pbcmessage.ActivityTurntableCountRewardReply 
---@field Results ActivityTurntableReward[] @ 奖励
local  ActivityTurntableCountRewardReply  = {}
---@class pbcmessage.ActivityTurntableCountRewardRequest 
---@field ActivityID number 
local  ActivityTurntableCountRewardRequest  = {}
---@class pbcmessage.ActivityTurntableDrawReply 
---@field Draws ActivityTurntableReward[] @ 奖励
---@field FreeResetTime number 
---@field Trans pbcmessage.ItemTrans[] @ 转换道具信息
local  ActivityTurntableDrawReply  = {}
---@class pbcmessage.ActivityTurntableDrawRequest 
---@field ActivityID number 
---@field DrawCount number @ 抽取次数
local  ActivityTurntableDrawRequest  = {}
---@class pbcmessage.ActivityTurntableReward @    rpc ActivityTurntableCountReward(ActivityTurntableCountRewardRequest) returns (ActivityTurntableCountRewardReply) {}   领取抽数奖励
---@field ID number 
---@field Rewards pbcmessage.S3Int[] @ 奖励
local  ActivityTurntableReward  = {}
