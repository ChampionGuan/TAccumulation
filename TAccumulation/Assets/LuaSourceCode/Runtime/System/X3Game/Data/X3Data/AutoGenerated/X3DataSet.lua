﻿--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---X3DataSet的任何方法使用前必须保证参数的可靠性
---X3DataSet中不负责数据的创建和回收，只有记录的变化   
---@class X3DataSet X3Data 所有数据的集合，用于序列化和反序列化整个数据库
---@field AccompanyTypeRecord X3Data.AccompanyTypeRecord[] 
---@field AccompanyDayRecord X3Data.AccompanyDayRecord[] 
---@field AccompanyYearRecord X3Data.AccompanyYearRecord[] 
---@field AccompanyRoleRecords X3Data.AccompanyRoleRecords[] 
---@field AccompanyRoleData X3Data.AccompanyRoleData[] 
---@field AccompanyData X3Data.AccompanyData[] 
---@field Achievement X3Data.Achievement[] 
---@field Activity X3Data.Activity[] 
---@field ActivityDialogue X3Data.ActivityDialogue[] 
---@field ActivityDiyModel X3Data.ActivityDiyModel[] 
---@field ActivityGrowUpData X3Data.ActivityGrowUpData[] 
---@field ActivityTurntableData X3Data.ActivityTurntableData[] 
---@field ActivityTurntableDrawCountData X3Data.ActivityTurntableDrawCountData[] 
---@field ActivityTurntablePersistentData X3Data.ActivityTurntablePersistentData[] 
---@field ARPhotoData X3Data.ARPhotoData[] 
---@field ASMRData X3Data.ASMRData[] 
---@field ASMRRedPointData X3Data.ASMRRedPointData[] 单个ASMR红点相关的数据
---@field ASMRPersistentData X3Data.ASMRPersistentData[] 
---@field BattlePassData X3Data.BattlePassData[] 
---@field CardData X3Data.CardData[] 思念基础数据
---@field CardLocalImgInfo X3Data.CardLocalImgInfo[] 
---@field CardManagedData X3Data.CardManagedData[] 思念管理数据，全局唯一
---@field CardPosDataList X3Data.CardPosDataList[] 记录槽位对应的可用思念列表
---@field CardManTypeDataList X3Data.CardManTypeDataList[] 记录男主对应的可用思念列表
---@field CardInitAttrData X3Data.CardInitAttrData[] 思念初始属性，和用户无关，只和卡相关
---@field CardAttrData X3Data.CardAttrData[] 思念属性数据，和思念一对一，思念基础数据变化后，进行属性预计算并存储在此结构中
---@field CardSuitConfigData X3Data.CardSuitConfigData[] 套装配置数据，不同用户用同一套配置数据
---@field CardQuestData X3Data.CardQuestData[] 单卡任务数据（只保存当前用户的数据）
---@field CardSuitQuestData X3Data.CardSuitQuestData[] 套装任务数据（只保存当前用户的数据）
---@field OtherSuitPhaseData X3Data.OtherSuitPhaseData[] 他人的套装阶数
---@field ChargeData X3Data.ChargeData[] 
---@field ChargeRecord X3Data.ChargeRecord[] 
---@field DeliverOrder X3Data.DeliverOrder[] 
---@field PayInfo X3Data.PayInfo[] 
---@field Order X3Data.Order[] 
---@field CriticalLogPersistenceInfo X3Data.CriticalLogPersistenceInfo[] 上传CriticalLog后留下的上传记录
---@field DailyConfideData X3Data.DailyConfideData[] 
---@field DailyConfideCompleteRecord X3Data.DailyConfideCompleteRecord[] 
---@field DailyConfideRecord X3Data.DailyConfideRecord[] 
---@field DatePlanInvitationData X3Data.DatePlanInvitationData[] 邀请函数据
---@field DateContent X3Data.DateContent[] 
---@field DateGamePlayData X3Data.DateGamePlayData[] 
---@field DateMiaoData X3Data.DateMiaoData[]  喵喵牌记录的数据: 局结果
---@field DropMultipleData X3Data.DropMultipleData[] 
---@field ActivityDropMultipleData X3Data.ActivityDropMultipleData[] 
---@field PlayerVoice X3Data.PlayerVoice[] 
---@field Formation X3Data.Formation[] Formation相关数据
---@field PreFabFormation X3Data.PreFabFormation[] PreFabFormation相关数据
---@field GalleryRecord X3Data.GalleryRecord[] 
---@field GameplayInfo X3Data.GameplayInfo[] 玩法
---@field GameplayContinueData X3Data.GameplayContinueData[] 
---@field GameplayCommonData X3Data.GameplayCommonData[] 
---@field GemCoreData X3Data.GemCoreData[]  芯核相关数据
---@field GemCore X3Data.GemCore[] 芯核实例数据
---@field HunterContestSeason X3Data.HunterContestSeason[] 
---@field HunterContest X3Data.HunterContest[] 
---@field HunterContestCards X3Data.HunterContestCards[]  设定大螺旋各段位等级的卡牌组
---@field HunterContestCard X3Data.HunterContestCard[]  设定大螺旋各段位等级的卡牌组
---@field HunterContestRewardData X3Data.HunterContestRewardData[] 
---@field Item X3Data.Item[] 
---@field SpItem X3Data.SpItem[] 
---@field Coin X3Data.Coin[] 
---@field KnockMoleLevelData X3Data.KnockMoleLevelData[] 打地鼠关卡数据
---@field KnockMoleHole X3Data.KnockMoleHole[] 地鼠洞数据
---@field KnockMoleData X3Data.KnockMoleData[] 地鼠数据
---@field ConflictedTest X3Data.ConflictedTest[] 测试基础数据类型的X3Data
---@field LoginData X3Data.LoginData[] 
---@field LovePointTimeRecord X3Data.LovePointTimeRecord[] 
---@field LovePointRole X3Data.LovePointRole[] 
---@field MailParam X3Data.MailParam[] 
---@field MailRewardItem X3Data.MailRewardItem[] 
---@field Mail X3Data.Mail[] 
---@field DoubleTouchType X3Data.DoubleTouchType[] 双指推进的类型
---@field MainHomeData X3Data.MainHomeData[] 主界面数据
---@field ActionRecord X3Data.ActionRecord[] 男主行为记录
---@field MonthCardData X3Data.MonthCardData[]  月卡数据
---@field PhoneContactHead X3Data.PhoneContactHead[] 
---@field PhoneContactSign X3Data.PhoneContactSign[] 
---@field PhoneContactMoment X3Data.PhoneContactMoment[] 
---@field PhoneContactBubble X3Data.PhoneContactBubble[] 
---@field PhoneContactChatBackground X3Data.PhoneContactChatBackground[] 
---@field ContactNudge X3Data.ContactNudge[] 
---@field PhoneContactHeadImgCache X3Data.PhoneContactHeadImgCache[] 
---@field PhoneContactData X3Data.PhoneContactData[] 
---@field PhoneContact X3Data.PhoneContact[] 
---@field NudgeInfo X3Data.NudgeInfo[] 
---@field PhoneMsgExtraInfo X3Data.PhoneMsgExtraInfo[]  ExtraInfo 短消息附加数据
---@field PhoneMsgConversationData X3Data.PhoneMsgConversationData[] 
---@field PhoneMsgUIItem X3Data.PhoneMsgUIItem[] 
---@field PhoneMsgSimulatingData X3Data.PhoneMsgSimulatingData[] 
---@field PhoneMsgProgressData X3Data.PhoneMsgProgressData[] 
---@field PhoneMsgDetailData X3Data.PhoneMsgDetailData[] 
---@field PhoneMsgContactData X3Data.PhoneMsgContactData[] 
---@field PhoneMsgConditionRecord X3Data.PhoneMsgConditionRecord[] 
---@field PhoneMsgData X3Data.PhoneMsgData[] 
---@field PhotoData X3Data.PhotoData[] 
---@field Photo X3Data.Photo[] 
---@field ChooseRecord X3Data.ChooseRecord[] 
---@field PlayerChoose X3Data.PlayerChoose[] 
---@field PlayerRecommendRecord X3Data.PlayerRecommendRecord[] 
---@field PlayerRecommend X3Data.PlayerRecommend[] 
---@field PlayerTagRecord X3Data.PlayerTagRecord[] 
---@field PlayerTag X3Data.PlayerTag[] 
---@field FavoriteRecord X3Data.FavoriteRecord[] 
---@field PlayerFavorite X3Data.PlayerFavorite[] 
---@field RadioTimeRecord X3Data.RadioTimeRecord[] 广播剧与ASMR共用
---@field ReturnActivityData X3Data.ReturnActivityData[] 
---@field SCore X3Data.SCore[] Score相关数据
---@field Card2ScoreCfgData X3Data.Card2ScoreCfgData[] 存储Card-Score的关联关系
---@field Shop X3Data.Shop[] 
---@field ShopData X3Data.ShopData[] 
---@field AnecdoteList X3Data.AnecdoteList[] 男主对应逸闻数据
---@field AnecdoteItem X3Data.AnecdoteItem[] 单个逸闻数据
---@field AnecdoteSection X3Data.AnecdoteSection[] 单个小节数据
---@field AnecdoteContent X3Data.AnecdoteContent[] 单行数据
---@field LegendList X3Data.LegendList[] 男主对应传说数据
---@field LegendItem X3Data.LegendItem[] 单个传说数据
---@field LegendSection X3Data.LegendSection[] 单个小节数据
---@field Task X3Data.Task[] 
---@field TasksByConditionType X3Data.TasksByConditionType[] 
---@field TasksByTaskType X3Data.TasksByTaskType[] 
---@field TrainingRoomRedPointData X3Data.TrainingRoomRedPointData[] 
---@field UFOCatcherGame X3Data.UFOCatcherGame[] 娃娃机玩法内数据，慢慢从BLL迁移过来
---@field UrlImageData X3Data.UrlImageData[] 
---@field VIPChargeData X3Data.VIPChargeData[] 
---@field CommonGestureOperatedModeData X3Data.CommonGestureOperatedModeData[] 
---@field Entry2WorldInfoList X3Data.Entry2WorldInfoList[] 世界情报词条列表数据
---@field Main2WorldInfoList X3Data.Main2WorldInfoList[] 
---@field WorldInfoData X3Data.WorldInfoData[] 
---@field TestPureProtoTypeData X3Data.TestPureProtoTypeData[] 测试基础数据类型的X3Data
---@field RepeatedTestData X3Data.RepeatedTestData[] 测试repeated的X3Data
---@field MapTestData X3Data.MapTestData[] 测试Map的X3Data
---@field CombineTestData X3Data.CombineTestData[]  测试合集
---@field AssociationTestData X3Data.AssociationTestData[] 用于测试关系传递性的数据
---@field __X3DataSetMap table<string, table<any, X3Data.X3DataBase>> 用于快速索引数据
local X3DataSet = require("Runtime.System.X3Game.Modules.X3Data.X3DataSet_Partial")
return X3DataSet