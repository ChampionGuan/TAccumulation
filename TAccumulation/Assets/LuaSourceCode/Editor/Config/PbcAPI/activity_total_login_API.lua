--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.ActivityTotalLogin @ 累计登录活动
---@field Progress number 
---@field LastUpdateTime number 
---@field  Rewarded  table<number,boolean> @已领取奖励列表
local  ActivityTotalLogin  = {}
---@class pbcmessage.ActivityTotalLoginClaimReply 
---@field Rewards pbcmessage.S3Int[] @ 奖励
local  ActivityTotalLoginClaimReply  = {}
---@class pbcmessage.ActivityTotalLoginClaimRequest 
---@field ActivityID number 
---@field Ranks number[] 
local  ActivityTotalLoginClaimRequest  = {}
