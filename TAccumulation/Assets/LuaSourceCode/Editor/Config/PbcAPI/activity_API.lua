--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.Activity 
---@field ID number @ 基础通用数据
---@field Point number @ 活动分数（累计获得活动代币的数量）
---@field Reward pbcmessage.ActivityReward @ 领奖活动数据
---@field TotalLogin pbcmessage.ActivityTotalLogin @ 登录活动数据
---@field GamePlay pbcmessage.ActivityGamePlay @ 小游戏活动数据
---@field StartTime number @ 活动开始时间
---@field EndTime number @ 活动结束时间
---@field SCoreTrial pbcmessage.ActivitySCoreTrial @ 搭档试用活动数据
---@field ScheduledReward pbcmessage.ActivityScheduledReward @ 定时发奖活动数据
---@field Jigsaw pbcmessage.ActivityJigsaw @ 拼图活动
---@field DropMultiple pbcmessage.ActivityDropMultiple @ 多倍掉落活动
---@field Dialogue pbcmessage.ActivityDialogue @ 剧情活动
---@field Interaction pbcmessage.ActivityInteraction @ 互动活动
---@field Turntable ActivityTurntable @ 转盘活动
local  Activity  = {}
---@class pbcmessage.ActivityCMSCondition 
---@field Params number[] @ 类型+参数列表
local  ActivityCMSCondition  = {}
---@class pbcmessage.ActivityCMSConfig 
---@field ID number @ 活动ID
---@field Status number @ 是否生效
---@field ShowEndTime number @ 活动隐藏时间
---@field StartTime number @ 实际有效开放时间
---@field EndTime number @ 实际有效关闭时间
---@field PicUrl string @ 红点类型
---@field Extra string @ 定制数据
---@field Name string 
---@field Conditions pbcmessage.ActivityCMSCondition[] @ 活动开放条件
local  ActivityCMSConfig  = {}
---@class pbcmessage.ActivityCMSConfigGetReply 
---@field Configs pbcmessage.ActivityCMSConfig[] 
---@field TypeConfigs pbcmessage.ActivityTypeCMSConfig[] 
local  ActivityCMSConfigGetReply  = {}
---@class pbcmessage.ActivityCMSConfigGetRequest 
local  ActivityCMSConfigGetRequest  = {}
---@class pbcmessage.ActivityCMSTable @ 活动CMS配置数据
---@field configs pbcmessage.ActivityCMSConfig[] 
local  ActivityCMSTable  = {}
---@class pbcmessage.ActivityData @import "x3x3.proto";
---@field  Activities     table<number,pbcmessage.Activity> 
---@field QuestInit boolean 
---@field  OngoingActivities  table<number,boolean> @ 生效中的活动ID
---@field  DrawCountRewards   table<number,boolean> @ key: 抽数奖励挡位ID ,不跟随特定活动，单独记录
---@field  DrawCounts        table<number,number> @ ActivityCountReward.RewardGroup -> 计数, 抽数奖励计数
local  ActivityData  = {}
---@class pbcmessage.ActivityQuestFinishReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励
---@field Quests pbcmessage.Quest[] @ 领奖成功的任务
---@field ActivityID number 
---@field Point number 
local  ActivityQuestFinishReply  = {}
---@class pbcmessage.ActivityQuestFinishRequest 
---@field QuestIDs number[] 
---@field ActivityID number 
local  ActivityQuestFinishRequest  = {}
---@class pbcmessage.ActivityTypeCMSConfig 
---@field ID number @ 活动分类ID
---@field Name string 
---@field Extra string @ 定制数据
local  ActivityTypeCMSConfig  = {}
---@class pbcmessage.GetActivityDataReply 
---@field Data pbcmessage.ActivityData 
local  GetActivityDataReply  = {}
---@class pbcmessage.GetActivityDataRequest 
local  GetActivityDataRequest  = {}
