--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.ActivityDropMultiple @ 多倍掉落活动
---@field  Details  table<number,pbcmessage.ActivityDropMultipleDetail> @ 子活动 key：ID, value：奖励次数和刷新时间
local  ActivityDropMultiple  = {}
---@class pbcmessage.ActivityDropMultipleDetail 
---@field LastUpdateTime number @ 上次刷新时间
---@field RewardTimes number @ 奖励次数
local  ActivityDropMultipleDetail  = {}
---@class pbcmessage.ActivityDropMultipleUpdateReply @ 多倍掉落活动次数和刷新时间变化通知
---@field ActivityID number @ 活动id
---@field ID number @ 内部id
---@field Detail pbcmessage.ActivityDropMultipleDetail @ 当前次数和刷新时间
local  ActivityDropMultipleUpdateReply  = {}
