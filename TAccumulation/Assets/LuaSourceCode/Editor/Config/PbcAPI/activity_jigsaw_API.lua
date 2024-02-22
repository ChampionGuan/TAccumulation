--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.ActivityJigsaw @ 拼图活动
---@field  Progress   table<number,number> @ subID->拼图进度，按位存储
---@field  RewardClaim  table<number,boolean> @ subID->是否已领奖
local  ActivityJigsaw  = {}
---@class pbcmessage.ActivityJigsawOpenReply 
local  ActivityJigsawOpenReply  = {}
---@class pbcmessage.ActivityJigsawOpenRequest 
---@field ActivityID number 
---@field SubID number @ 拼图id
---@field PieceNumber number @ 拼图块索引(从0开始)
local  ActivityJigsawOpenRequest  = {}
---@class pbcmessage.ActivityJigsawRewardReply 
---@field Rewards pbcmessage.S3Int[] @ 奖励
local  ActivityJigsawRewardReply  = {}
---@class pbcmessage.ActivityJigsawRewardRequest 
---@field ActivityID number 
---@field SubID number 
local  ActivityJigsawRewardRequest  = {}
