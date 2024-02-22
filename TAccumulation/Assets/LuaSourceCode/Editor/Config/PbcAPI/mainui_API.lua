--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.AddSpInteractiveNumReply 
local  AddSpInteractiveNumReply  = {}
---@class pbcmessage.AddSpInteractiveNumRequest 
---@field RoleID number 
---@field ActionType string 
---@field AddNum number 
---@field TaskCountHist boolean @ 是否记录当日历史最高
local  AddSpInteractiveNumRequest  = {}
---@class pbcmessage.GetMainUIInfoReply 
---@field MainUI pbcmessage.MainUIData 
local  GetMainUIInfoReply  = {}
---@class pbcmessage.GetMainUIInfoRequest @    rpc MainUIDailyRefresh(MainUIDailyRefreshRequest) returns (MainUIDailyRefreshReply) {}      凌晨5点的刷新函数
local  GetMainUIInfoRequest  = {}
---@class pbcmessage.MainIDState @import "x3x3.proto";
---@field StateID number @ 状态ID
---@field StateEndtime number @ State状态结束时间
---@field EventID number @ 特殊事件ID
---@field EventEndTime number @ 特殊事件结束时间
---@field MainIDAllTime number @ 看板娘已经持续的时间
---@field MainIDNowTime number @ 看板娘已经持续的时间 不包含历史
local  MainIDState  = {}
---@class pbcmessage.MainUICheckActiveReply 
local  MainUICheckActiveReply  = {}
---@class pbcmessage.MainUICheckActiveRequest 
local  MainUICheckActiveRequest  = {}
---@class pbcmessage.MainUIChooseData @ 主界面随机看板娘
---@field ChoiceIDs number[] @ 选择的看板娘ID
local  MainUIChooseData  = {}
---@class pbcmessage.MainUIChooseUpdateReply @ 主动推送(只需要Reply)
---@field Choose pbcmessage.MainUIChooseData @ 主界面随机看板娘
local  MainUIChooseUpdateReply  = {}
---@class pbcmessage.MainUIDailyRefreshReply 
local  MainUIDailyRefreshReply  = {}
---@class pbcmessage.MainUIDailyRefreshRequest 
local  MainUIDailyRefreshRequest  = {}
---@class pbcmessage.MainUIData 
---@field MainID number @ 当前看板娘ID
---@field EventID number @ 特殊事件ID
---@field EventEndTime number @ 特殊事件结束事件
---@field StateID number @ 状态ID
---@field MainIDSetTime number @ 看板娘ID设置时间
---@field StateEndtime number @ State状态结束时间
---@field MainIDAllTime number @ 看板娘已经持续的时间包含历史
---@field MainIDNowTime number @ 看板娘已经持续的时间不包含历史
---@field  EventNums             table<number,number> @ 事件累计次数 key:特殊事件id，value:次数
---@field  MainIDStateMap  table<number,pbcmessage.MainIDState> @ 不同看板娘的状态 key:看板娘id，value:看板娘状态集合
---@field Choose pbcmessage.MainUIChooseData @ 主界面随机看板娘
---@field InterActive boolean @ 是否交互模式 登录时清理为false
---@field LastRefreshTime number @ 上次刷新时间，用于判断凌晨5点的每日刷新
---@field  UnlockedMainID         table<number,boolean> @ 解锁的看板娘 key：看板娘ID, value: true表示首次解锁，false表示非首次解锁
local  MainUIData  = {}
---@class pbcmessage.MainUIEventFinishReply 
---@field RewardList pbcmessage.S3Int[] @ 奖励
---@field DialogueDone boolean @ 剧情校验是否完成
local  MainUIEventFinishReply  = {}
---@class pbcmessage.MainUIEventFinishRequest 
---@field EventID number 
---@field CheckList pbcmessage.DialogueCheck[] 
---@field ActionID number 
local  MainUIEventFinishRequest  = {}
---@class pbcmessage.MainUIEventSetReply 
local  MainUIEventSetReply  = {}
---@class pbcmessage.MainUIEventSetRequest 
---@field EventID number 
local  MainUIEventSetRequest  = {}
---@class pbcmessage.MainUIRefreshReply 
---@field IsRefresh boolean 
local  MainUIRefreshReply  = {}
---@class pbcmessage.MainUIRefreshRequest 
local  MainUIRefreshRequest  = {}
---@class pbcmessage.MainUISetActiveReply 
local  MainUISetActiveReply  = {}
---@class pbcmessage.MainUISetActiveRequest 
---@field InterActive boolean @ true:进入交互模式 false:退出交互模式
local  MainUISetActiveRequest  = {}
---@class pbcmessage.MainUIUpdateReply @ 主动推送(只需要Reply)
---@field MainUI pbcmessage.MainUIData @ 主界面数据更新的推送 MainIDStateMap、Choose 和DialogueData 不会推送
local  MainUIUpdateReply  = {}
---@class pbcmessage.SetMainUIIDReply 
local  SetMainUIIDReply  = {}
---@class pbcmessage.SetMainUIIDRequest 
---@field MainIDs number[] 
local  SetMainUIIDRequest  = {}
