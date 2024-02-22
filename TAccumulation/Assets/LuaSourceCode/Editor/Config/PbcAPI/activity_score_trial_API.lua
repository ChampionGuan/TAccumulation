--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.ActivitySCoreTrial @ 搭档试用活动
---@field FirstRewarded boolean @ 首通奖记录
local  ActivitySCoreTrial  = {}
---@class pbcmessage.ActivitySCoreTrialUpdateReply @ 主动推送(只需要Reply) 更新单个活动数据,估计很多修改都会附带奖励
---@field ID number @ 活动ID
---@field Trial pbcmessage.ActivitySCoreTrial 
---@field RewardList pbcmessage.S3Int[] @ 奖励
local  ActivitySCoreTrialUpdateReply  = {}
