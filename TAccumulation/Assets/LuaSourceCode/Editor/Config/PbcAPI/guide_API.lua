--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.GetGuideInfoReply 
---@field Guide pbcmessage.GuideData @ 引导信息
local  GetGuideInfoReply  = {}
---@class pbcmessage.GetGuideInfoRequest @    rpc SetCurrentGuide(SetCurrentGuideRequest) returns (SetCurrentGuideReply) {}   设置当前引导GuideGroupID(纯记录数据)
local  GetGuideInfoRequest  = {}
---@class pbcmessage.Guide 
---@field GroupID number @ 引导ID
---@field StepID number @ StepID
local  Guide  = {}
---@class pbcmessage.GuideData 
---@field  UserGuideMap  table<number,pbcmessage.UserGuide> @ key:groupID val:玩家引导信息
---@field SkipGuideByCMS boolean @ 是否通过cms跳过引导
---@field CurrentGroup number @ 当前引导GuideGroupID
---@field SkipGuideByCMSGroupID number @ 通过cms跳过指定引导
local  GuideData  = {}
---@class pbcmessage.GuideFinishReply 
local  GuideFinishReply  = {}
---@class pbcmessage.GuideFinishRequest 
---@field GroupList number[] 
---@field SkipGuide boolean @ 是否跳过引导
local  GuideFinishRequest  = {}
---@class pbcmessage.GuideReward 
---@field Guide pbcmessage.Guide @ 包含 GroupID 和 StepID
---@field RewardList pbcmessage.S3Int[] @ 奖励
local  GuideReward  = {}
---@class pbcmessage.GuideUpdateReply @ 主动推送(只需要Reply)
---@field OpType pbcmessage.GuideOpType 
---@field OpReason number 
---@field UserGuideList pbcmessage.UserGuide[] @ 引导信息 Key引导ID Val非0表示已引导
local  GuideUpdateReply  = {}
---@class pbcmessage.SetCurrentGuideReply 
local  SetCurrentGuideReply  = {}
---@class pbcmessage.SetCurrentGuideRequest @ 设置当前引导
---@field GroupID number 
local  SetCurrentGuideRequest  = {}
---@class pbcmessage.SetGuideReply 
---@field GuideRewardList pbcmessage.GuideReward[] @ 奖励
local  SetGuideReply  = {}
---@class pbcmessage.SetGuideRequest 
---@field Guides pbcmessage.Guide[] 
local  SetGuideRequest  = {}
---@class pbcmessage.UserGuide @    GuideOpTypeGuideReset  = 3;   引导重置（"guide reset"  "guide resetall" gm指令使用）
---@field StepID number @ step_id
---@field Status number @ 状态ID 0未完成 1完成
---@field GroupID number @ 组ID
---@field  RewardMap  table<number,number> @ 是否step领过奖励
local  UserGuide  = {}
