---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2019-11-26 14:20:23
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class Define
local Define = {}

Define.Enum_ConversationStatus = {
    Disable = 1,
    ChooseConversation = 2,
    Conversation = 3
}

Define.Enum_Teller = {
    Player = 0,
    Role = 1
}

Define.CornerShowType = {
    New = 1,
    Number = 2,
    Warning = 3
}

---@class Define.EStageType
Define.EStageType = {
    Default = 0, --首战剧情关
    Main = 1, --主线
    Opera = 2, --剧情调用
    TowerBattle = 3, --迷惘之塔
    Trial = 4, --试炼场
    Other = 5, --用于其他各类杂项副本；
    SoulTrial = 6, --心灵试炼；
    Arena = 7, --竞技场；
    WeaponTrial = 10, --武器试炼
    GemCoreStage = 11, --芯核 副本
    SCoreTry = 12, --搭档试用
    HunterContest = 13, --猎人锦标赛
}

Define.Enum_DifficultyLevel = {
    --普通
    Normal = 1,
    --精英
    Elite = 2,
}

---@class Define.Enum_StageType
Define.Enum_StageType = {
    MovieStage = 1, --剧情关
    FightStage = 2 --战斗关
}

---结算形式
Define.EndBattleShowType = {
    -- 0 默认结算UI， 1 nothing， 2 黑屏渐入， 3 白屏渐入
    -- 如果是 2 和 3 完成后要截屏
    NormalUI = 0, --默认结算UI
    Nothing = 1, --nothing
    BlackScreenIn = 2, --黑屏渐入
    WhiteScreenIn = 3, --白屏渐入
    Loading = 4, --无结算接剧情
    Battle = 5, --无结算接下一关战斗
}

Define.StageLimitType = {
    None = 0,
    All = 1,
    SCore = 2,
    Card = 3,
    ---中间缺省---
    WeaponType = 8,
    Weapon = 9,
}

Define.FetterCardListFuncType = {
    MineFetter = 1, --我的羁绊
    FetterFragment = 2, --碎片
    Decompose = 3 --分解
}

Define.PhoneMsgSimulationState = {
    Start = 1, --消息开始
    ----中间状态Star----
    None = 2, --无状态
    Wating = 3, --等待输入
    Read = 4, --等待输入
    BeginInputing = 5, --输入中
    Executing = 6, --输入完成,处理中
    Finish = 7, --处理完成
    ----中间状态End----
    End = 8 --消息结束
}

Define.MsgTalkPanelType = {
    None = 1, --消息开始
    Event = 2, --非激活状态事件
    Conver = 3, --闲聊
    Choose = 4, --选择
    Other = 5, --更换聊天气泡和头像
}

-- 注意：和配表SystemUnLock ID保持一致！！！
Define.ESystemType = {
    None = 0,
    -- 购买体力
    PowerBuy = 100,
    -- 商城
    Mall = 200,
    -- 出警
    Police = 10000,
    -- 源向探索（迷惘之塔）
    LostTower = 10100,
    -- 竞技场
    Arena = 10200,
    -- 试炼场
    TrialField = 10300,
    -- 男主线
    MaleMainline = 10400,
    -- 恋与市
    LoveAndCity = 20000,
    -- 我家
    MyHome = 20100,
    -- 背包
    Bag = 20101,
    -- 藏品柜
    CollectionCabinet = 20102,
    -- 衣柜
    Wardrobe = 20103,
    -- 福利
    Welfare = 20200,
    -- 活动
    Activity = 20300,
    -- 任务
    Task = 20400,
    -- 日常任务
    DailyTask = 20401,
    -- 成就任务
    AchievementTask = 20402,
    -- 邮件
    Mail = 20500,
    -- 好友
    Friend = 20600,
    -- 联盟
    Alliance = 20700,
    -- 许愿
    MakeWish = 20800,
    -- 商店
    Shop = 20900,
    -- 手机
    MobilePhone = 21000,
    -- 短信
    ShortMessage = 21001,
    -- 电话
    Phone = 21002,
    -- 朋友圈
    CircleOfFriends = 21003,
    -- 公众号
    PublicNumber = 21004,
    -- 培养
    Development = 21100,
    -- 誓约
    Pledge = 21101,
    -- 羁绊
    Fetters = 21102,
    -- 编队
    Formation = 21103,
    -- BC
    BC = 30000,
    -- 更换看板娘
    SwitchBC = 30100,
    -- 恋爱
    FallInLove = 40000,
    -- 约会
    Date = 40100,
    -- 出游
    Travel = 40200,
    -- 娃娃机
    CraneMachine = 40201,
    -- 叠叠乐
    Overlapping = 40202,
    -- 喵喵牌
    MeowMeowBrand = 40203,
    -- 包包赛(大富翁)
    Zillionaire = 40204,
    -- 秘密档案
    Intelligence = 40300,
    -- 好感度
    Goodwill = 40400,
    -- 在你身边
    ByYourSide = 40600,
    -- VR约会
    VRDate = 40700,
    --战斗普攻
    NormalAttack = 90100,
    --战斗闪避
    Dash = 90101,
    --战斗主动技
    PositiveSkill = 90102,
    --战斗协作技
    CoopSkill = 90103,
    --战斗爆发技
    PowerSkill = 90104,
    --自动战斗按钮
    BattleAuto = 90105,
    --精英难度
    ChapterElite = 20001,
    --成就系统
    Achievement = 20402,
    --分包系统
    Download = 21300,
}

---@class Define.ItemTipsType
Define.ItemTipsType = {
    None = 1, --不显示Tips
    Fixed = 2, --居中显示
    Fixed_EnableUse = 3, --居中显示包含使用按钮，用于背包
    Fixed_Get = 4,
    Float = 5, --迷你界面，根据点击物品所在坐标适配
    Fixed_Fashion = 6, --战斗套装
    Fixed_Get_DisableUse = 7, --显示Get但是要屏蔽Use
}

Define.SkillTipsType = {
    SCore = 1,
    Enemy = 2
}

Define.MobileTab = {
    Message = 1, --信息
    Call = 2, --电话
    Moment = 3, --朋友圈
    Official = 4, --公众号
}

Define.MobileCallStatus = {
    newStatus = 0, -- 新电话
    breakStatus = 1, --挂断
    doneStatus = 2, --完成
}

Define.DevelopTab = {
    SCore = 1,
    Card = 2,
}

Define.ManTabType = {
    Unlock = 1,
    Lock = 2,
    NotOpen = 3
}

---@class Define.CommonManListWndType
Define.CommonManListWndType = {
    GalleryChoose = 1,
    GalleryChange = 2,
    SpecialDate = 3,
    PhotoChoose = 4,
    ChangeClothes = 5,
    GachaChoose = 6,
    LovePointChoose = 7,
    RadioPlayChoose = 8,
    DailyDate = 9,
    GalleryCard = 11,
    GalleryCollection = 12,
    ---广播剧换人
    Radio = 13,
    ---约会计划
    DatePlan = 14,
    ---故事入口
    StoryEntrance = 15,
    ---小传
    ScoreStory = 16,
    ---ASMR
    ASMR = 17,
    ---小游戏统一选人
    GamePlay = 18,
    ---逸闻
    Anecdote = 19,
    ---传说
    Legend = 20,
    ---活动
    Activity = 21,
}

---好友系统
Define.SERVER_EVENT_TYPE = {
    SEARCH = 0, ---刷新搜索栏
    FRIENDED = 1, ---刷新好友信息
    FRIENDING = 2, ---刷新好友申请数据
}

---好友表现层Type
Define.VIEW_EVENT_TYPE = {
    NONE = 0,
    OPEN_FRIENDED = 1,
    OPEN_FRIENDING = 2,
}

---刷新间隔
Define.REFEASH_TIME_DELTA = 300
Define.REFEASHALL_TIME_DELTA = 1800

--- TopBar货币类型
---@class Define.ShowCurrencyType
Define.ShowCurrencyType = {
    None = 1,
    GoldCoin_Diamonds = 2,
    Power_Diamonds = 3,
    Power_GoldCoin_Diamonds = 4,
    Power_GoldCoin_Diamonds_StarJewel = 5,
    GoldCoin_Diamonds_StarJewel = 6,
    ExploreThreeCoins = 7,
    Diamonds = 8,
    Power = 9,
    Diamonds_StarJewel = 10,
    Gold = 11,
}

Define.PhotoModel = {
    Single = 1,
    Double = 2,
    AR = 3
}

Define.PhotoStage = {
    Before = 1,
    After = 2
}

Define.Direction = {
    Back = 1,
    Left = 2,
    Front = 3,
    Right = 4
}

Define.PhotoAfterStage = {
    None = 0,
    GenerateCard = 1,
    GenerateIcon = 2,
    UpLoad = 3
}

Define.Sex = {
    Female = 0,
    Male = 1
}

Define.PicType = {
    Photos = "Photos",
    HeadIcon = "profileHead",
    Card = "avatarHead"
}

Define.BTResult = {
    None = 0,
    Successful = 1,
    Fail = 2,
    Running = 3,

    Flag = 4,
}

Define.PlayerInfoWndShowType = {
    Normal = 0,
    BannerPreview = 1,
    ShowFrame = 2,
    ShowTitle = 3,
}

Define.Touch = {
    Begin = 1,
    Draging = 2,
    End = 3,
}

---分包枚举
---通过 SubPackageType ,SupPackageSubType , Key 去获取分包的唯一ID  Key 对应功能ID
---Type
---@class Define.SubPackageType
Define.SubPackageType = {
    ---特殊约会
    SPECIALDATE = 1,
    ---思念约会
    CardDate = 2,
    ---主线
    CHAPTER = 3,
    ---广播剧
    Radio = 4,
    ---ASMR
    ASMR = 5,
    ---思念
    DevelopCard = 6,
    ---传说
    Legend = 7,
    ---活动分包
    Activity = 8,
}

---@class Define.SupPackageSubType
Define.SupPackageSubType = {
    ---默认子类型
    DEFAULT = 1,
    ---拍照动作
    PHOTO_ACTION = 2,
    ---拍照贴纸
    PHOTO_STICKER = 3,
    ---拍照边框
    PHOTO_FRAME = 4,
}

---@class Define.ScatteredDownloadUIType
Define.ScatteredDownloadUIType = {
    ---不带暂停类型 --对应广播剧normal
    Type1 = 1,
    ---带暂停类型   --对应广播剧selected --ASMRitem
    Type2 = 2,
    ---没下开下，下了点不着类型 --对应广播剧播放界面小列表
    Type3 = 3,
}

---分包语言语音包类型定义
---@class Define.SubPackageZipType
Define.SubPackageZipType = {
    ---所有
    ALL = 1,
    ---语言包
    Language = 2,
    ---语音包
    Sound = 3,
}

Define.SkillType = {
    Main_Normal = 1,
    Main_Attack = 2,
    Main_Passive = 3,
    Main_QTE = 4,
}
---@class Define.EumTaskType
Define.EumTaskType = {
    Day = 1,
    Week = 2,
    Awake = 3,
    Chapter = 4,
    Love = 5,
    Special = 6,
    Achievement = 7,
    Activity = 9,
    BattlePassType = 11,
    Accompany = 12,
}

Define.ItemID = {
    Glod = 1,
    Jewel = 2,
    Power = 3,
    StartJewel = 6,
    Chocolate = 305,
    Marshmallow = 306,
}

---@class Define.ItemIDToEmojiID
---itemID 对应的EmojiID
Define.ItemIDToEmojiID = {
    [Define.ItemID.Glod] = 2001, --金币
    [Define.ItemID.Jewel] = 2002, --钻石
    [Define.ItemID.Power] = 2003, --体力
    [Define.ItemID.StartJewel] = 2004, --星钻
    [Define.ItemID.Chocolate] = 2005, --快乐巧克力
    [Define.ItemID.Marshmallow] = 2006, --心跳棉花糖
}

---@class Define.GachaChangeType
---itemID 对应的EmojiID
Define.GachaChangeType = {
    GachaGroupShow = 1,
    GachaGroupHide = 2,
    GachaGroupOpen = 3,
    GachaShow = 4,
    GachaHide = 5,
    GachaOpen = 6,
    GachaClose = 7,
    --Show = 1,
    --Update = 2,
    --Hide = 3,
}

---@class Define.DateRefreshType
Define.DateRefreshType = {
    ---不刷新
    None = 0,
    ---每日刷新
    Day = 1,
    ---每周刷新
    Week = 2,
    ---每月刷新
    Month = 3,
    ---每年刷新
    Year = 4,
    ---每周特定时间重置
    WeekTime = 5,
    ---特定时间重置
    Time = 6,
    ---指定时间后刷新
    AddTime = 7,
}

---@class Define.DateOpenType
Define.DateOpenType = {
    ---年月日=时间段：yyyymmdd=hh:mm:ss-hh:mm:ss
    Day = 0,
    ---星期限定=时间段：w=hh:mm:ss-hh:mm:ss
    Week = 1,
    ---绝对时间段：年月日=时间-年月日=时间：yyyymmdd=hh:MM:ss-yyyymmdd=hh:MM:ss
    Time = 2,
}

---照片编辑模式
Define.PhotoEditMode = {
    PhotoSticker = 101, --大头贴模式 单图与拼图模式
    Snapshot = 901, --单图模式 主界面抓拍
    AR = 102, --AR拍照模式
}

---照片编辑入口模式
Define.PhotoEntryMode = {
    Sticker = 1, -- 大头贴模式
    Snapshot = 2, -- 拍照模式
    Album = 3, -- 相册模式
    ARSingle = 4, -- AR单图编辑
    ARGroup = 5, -- AR多图编辑
}

---推送类型
Define.PushType = {
    ---推送模块-体力回满
    PUSH_TYPE_STAMINAMAX = 1,
    ---推送模块-领取体力补给
    PUSH_TYPE_STAMINAGIFT = 2,
    ---推送模块-每日单抽次数重置
    PUSH_TYPE_GACHA = 3,
    ---推送模块-挂机领奖推送
    PUSH_TYPE_HANGUP = 4,
    ---推送模块-玩家生日活动
    PUSH_TYPE_PLAYERBIRTHDAY = 5,
}

Define.StageLockType = {
    ExOpenConditionType = 1,
    LevelType = 2,
    PreStageType = 3,
}

---@class LangType
Define.LangType = {
    CN = "zh-cn", --: 简中 （pigeon zh）
    TW = "zh-tw", --: 繁中 （pigeon zh-CHT）
    KO = "ko", --:韩文
    TH = "th", --: 泰文
    EN = "en", --: 英文
    JP = "jp", --: 日文
}

---score和card进入类型
Define.DevelopEnterType = {
    ---默认
    DEFAULT = 1,
    ---好友系统
    FRIEND = 2,
    ---抽卡系统
    GACHA = 3,
    ---图鉴系统
    PICTURE = 4,
}

---思念详情界面模式
---@class Define.CardMainWndViewMode
Define.CardMainWndViewMode = {
    ---默认
    DEFAULT = 1,
    ---好友系统
    FRIEND = 2,
    ---抽卡系统
    Preview_GACHA = 3,
    ---图鉴系统
    Preview_PICTURE = 4,
    ---大螺旋（思念是自己的，思念上装备的芯核从大螺旋取）
    HunterContest = 5,
}

---玩法类型
---@class Define.GamePlayEnterType
Define.GamePlayEnterType = {
    GamePlayEnterTypeNope = 0,
    GamePlayEnterTypeDaily = 1, --日常约会
    GamePlayEnterTypeActivity = 2, --活动系统
    GamePlayEnterTypeDatePlan = 3, --约会计划
}

---@class Define.GamePlayType
Define.GamePlayType = {
    GamePlayTypeNope = 0,
    GamePlayTypeUfoCatcher = 1, --娃娃机
    GamePlayTypeBlockTower = 2, --叠叠乐
    GamePlayTypeMiao = 3, --喵喵牌
    --GamePlayTypeCircleChess = 5, --大富翁
    GamePlayTypeKnockMole = 4, --打地鼠
}

---@class Define.SpecialDateState
Define.SpecialDateState = {
    Deactived = 0, --未激活
    Locked = 1, --已激活未解锁
    Unlocked = 2, --已用道具解锁
}

---@class Define.SpecialDateType
Define.SpecialDateType = {
    Big = 1, --大特约
    Small = 2, --小特约
    Legend = 3, --传说
}

---@class Define.SpecialDateConditionType
Define.SpecialDateConditionType = {
    CommonCondition = 1, --CommonCondition条件判断
    LoveLevelCondition = 2, --牵绊度等级判断
    CardUnlockCondition = 3, --卡片解锁判断
    LegendCondition = 4, --传说专用解锁判断
}

---@class Define.FaceChangeType
Define.FaceChangeType = {
    None = 1, ---不做处理
    ReplaceHair = 2, ---替换发型 替换发色
    ReplaceHairNoColor = 3, ---替换发型不替换发色
}

---@class Define.BuyPowerWndType
Define.BuyPowerWndType = {
    BuyPower = 1, ---购买体力界面
    BuyDailyDateTimes = 2, ---购买日常约会次数界面
    ActivityGamePlayTimes = 3, ---购买活动玩法次数
}
---@class Define.VoiceDownloadState
Define.VoiceDownloadState = {
    None = 0, --未下载
    Normal = 1, --正常
    Used = 2, --使用中
    NeedUpdate = 3, --需要更新
    Pause = 4, --暂停
    DownLoading = 5, --下载中
    Failed = 6, --下载错误
    Wait = 7, --等待下载
}

---系统解锁类型
---@class Define.SystemUnlockType
Define.SystemUnlockType = {
    Invalid = 0, --无效，表里没配或者被ExamineInclude排除了
    Valid = 1, --有效
}

---培养默认数据
---@class Define.DevelopDefaultValue
Define.DevelopDefaultValue = {
    CardLevel = 1, --Card默认等级
    CardStarLevel = 1, --Card默认星级
    CardPhaseLevel = 0, --Card默认深化等级
    CardAwakeLevel = 0, --Score默认觉醒等级
    GemCoreLevel = 1, --GenCore默认等级
}

---各个业务CTS播放的Tag定义在这
---@class Define.CutScenePlayTag
Define.CutScenePlayTag = {
    DynamicCard = 1,
}

Define.TopBarStyle = {
    Style_1 = 0,
    Style_2 = 1,
    Style_3 = 2,
    Style_4 = 3,
}

---传说红点状态
---@class Define.LegendRedState
Define.LegendRedState = {
    None = 0,  --未解锁
    New = 1,   --新获得
    HaveRead = 2,  --已读
    ReadFinish = 3  --读完剧情
}

return Define
