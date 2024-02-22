--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.StoryData 
---@field  StoryTypeMap  table<number,pbcmessage.StoryTypeData> @ StoryType,StoryTypeData
local  StoryData  = {}
---@class pbcmessage.StoryDataReply 
---@field item pbcmessage.StoryItem 
local  StoryDataReply  = {}
---@class pbcmessage.StoryDataRequest @    rpc StoryReward(StoryRewardRequest) returns (StoryRewardReply) {}   领取某个小传完成奖励
---@field StoryType number 
---@field storyID number 
local  StoryDataRequest  = {}
---@class pbcmessage.StoryFinishReply 
local  StoryFinishReply  = {}
---@class pbcmessage.StoryFinishRequest 
---@field StoryType number 
---@field storyID number @ id
local  StoryFinishRequest  = {}
---@class pbcmessage.StoryItem @    StoryStateTypeReward = 3;   已经领取
---@field StoryID number @ StoryID
---@field LastReadSection number @最后一次读的小节
---@field LastReadSectionNum number @最后一次读取小节 的段落
---@field State pbcmessage.StoryStateType @是否完成
---@field UnlockSection number @ 解锁的最大sectionID 用于tLog标记
---@field MaxReadSection number @ 已经阅读的最大section 用于tLog去重
local  StoryItem  = {}
---@class pbcmessage.StoryRewardReply 
---@field Rewards pbcmessage.S3Int[] 
local  StoryRewardReply  = {}
---@class pbcmessage.StoryRewardRequest 
---@field StoryType number 
---@field storyID number @ id
local  StoryRewardRequest  = {}
---@class pbcmessage.StoryTypeData 
---@field  StoryMap  table<number,pbcmessage.StoryItem> @ ID,storyItem
---@field  LastStoryIDs  table<number,number> @ 每个男主,最后一次看的id
local  StoryTypeData  = {}
---@class pbcmessage.StoryUpdateReply @ 请求或者 主动更新通知
---@field StoryType number @ StoryType
---@field item pbcmessage.StoryItem 
local  StoryUpdateReply  = {}
---@class pbcmessage.StoryUpdateRequest 
---@field StoryType number 
---@field storyID number @小传id
---@field LastReadSection number @最后一次读的小节
---@field LastReadSectionNum number @最后一次读取小节 的段落
local  StoryUpdateRequest  = {}
