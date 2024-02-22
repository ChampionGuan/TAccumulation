--- 警告：本脚本由 X3DataFileGenerator 导出，请勿手动修改!!!

---@class X3DataConst
local X3DataConst = {}
---@class X3DataConst.X3Data 用于获取X3Data命名空间下的Data
X3DataConst.X3Data = {
    AccompanyTypeRecord = 'AccompanyTypeRecord',
    AccompanyDayRecord = 'AccompanyDayRecord',
    AccompanyYearRecord = 'AccompanyYearRecord',
    AccompanyRoleRecords = 'AccompanyRoleRecords',
    AccompanyRoleData = 'AccompanyRoleData',
    AccompanyData = 'AccompanyData',
    Achievement = 'Achievement',
    Activity = 'Activity',
    ActivityDialogue = 'ActivityDialogue',
    ActivityDiyModel = 'ActivityDiyModel',
    ActivityGrowUpData = 'ActivityGrowUpData',
    ActivityTurntableData = 'ActivityTurntableData',
    ActivityTurntableDrawCountData = 'ActivityTurntableDrawCountData',
    ActivityTurntablePersistentData = 'ActivityTurntablePersistentData',
    ARPhotoData = 'ARPhotoData',
    ASMRData = 'ASMRData',
    ASMRRedPointData = 'ASMRRedPointData',
    ASMRPersistentData = 'ASMRPersistentData',
    BattlePassData = 'BattlePassData',
    CardData = 'CardData',
    CardLocalImgInfo = 'CardLocalImgInfo',
    CardManagedData = 'CardManagedData',
    CardPosDataList = 'CardPosDataList',
    CardManTypeDataList = 'CardManTypeDataList',
    CardInitAttrData = 'CardInitAttrData',
    CardAttrData = 'CardAttrData',
    CardSuitConfigData = 'CardSuitConfigData',
    CardQuestData = 'CardQuestData',
    CardSuitQuestData = 'CardSuitQuestData',
    OtherSuitPhaseData = 'OtherSuitPhaseData',
    ChargeData = 'ChargeData',
    ChargeRecord = 'ChargeRecord',
    DeliverOrder = 'DeliverOrder',
    PayInfo = 'PayInfo',
    Order = 'Order',
    CriticalLogPersistenceInfo = 'CriticalLogPersistenceInfo',
    DailyConfideData = 'DailyConfideData',
    DailyConfideCompleteRecord = 'DailyConfideCompleteRecord',
    DailyConfideRecord = 'DailyConfideRecord',
    DatePlanInvitationData = 'DatePlanInvitationData',
    DateContent = 'DateContent',
    DateGamePlayData = 'DateGamePlayData',
    DateMiaoData = 'DateMiaoData',
    DropMultipleData = 'DropMultipleData',
    ActivityDropMultipleData = 'ActivityDropMultipleData',
    PlayerVoice = 'PlayerVoice',
    Formation = 'Formation',
    PreFabFormation = 'PreFabFormation',
    GalleryRecord = 'GalleryRecord',
    GameplayInfo = 'GameplayInfo',
    GameplayContinueData = 'GameplayContinueData',
    GameplayCommonData = 'GameplayCommonData',
    GemCoreData = 'GemCoreData',
    GemCore = 'GemCore',
    HunterContestSeason = 'HunterContestSeason',
    HunterContest = 'HunterContest',
    HunterContestCards = 'HunterContestCards',
    HunterContestCard = 'HunterContestCard',
    HunterContestRewardData = 'HunterContestRewardData',
    Item = 'Item',
    SpItem = 'SpItem',
    Coin = 'Coin',
    KnockMoleLevelData = 'KnockMoleLevelData',
    KnockMoleHole = 'KnockMoleHole',
    KnockMoleData = 'KnockMoleData',
    ConflictedTest = 'ConflictedTest',
    LoginData = 'LoginData',
    LovePointTimeRecord = 'LovePointTimeRecord',
    LovePointRole = 'LovePointRole',
    MailParam = 'MailParam',
    MailRewardItem = 'MailRewardItem',
    Mail = 'Mail',
    DoubleTouchType = 'DoubleTouchType',
    MainHomeData = 'MainHomeData',
    ActionRecord = 'ActionRecord',
    MonthCardData = 'MonthCardData',
    PhoneContactHead = 'PhoneContactHead',
    PhoneContactSign = 'PhoneContactSign',
    PhoneContactMoment = 'PhoneContactMoment',
    PhoneContactBubble = 'PhoneContactBubble',
    PhoneContactChatBackground = 'PhoneContactChatBackground',
    ContactNudge = 'ContactNudge',
    PhoneContactHeadImgCache = 'PhoneContactHeadImgCache',
    PhoneContactData = 'PhoneContactData',
    PhoneContact = 'PhoneContact',
    NudgeInfo = 'NudgeInfo',
    PhoneMsgExtraInfo = 'PhoneMsgExtraInfo',
    PhoneMsgConversationData = 'PhoneMsgConversationData',
    PhoneMsgUIItem = 'PhoneMsgUIItem',
    PhoneMsgSimulatingData = 'PhoneMsgSimulatingData',
    PhoneMsgProgressData = 'PhoneMsgProgressData',
    PhoneMsgDetailData = 'PhoneMsgDetailData',
    PhoneMsgContactData = 'PhoneMsgContactData',
    PhoneMsgConditionRecord = 'PhoneMsgConditionRecord',
    PhoneMsgData = 'PhoneMsgData',
    PhotoData = 'PhotoData',
    Photo = 'Photo',
    ChooseRecord = 'ChooseRecord',
    PlayerChoose = 'PlayerChoose',
    PlayerRecommendRecord = 'PlayerRecommendRecord',
    PlayerRecommend = 'PlayerRecommend',
    PlayerTagRecord = 'PlayerTagRecord',
    PlayerTag = 'PlayerTag',
    FavoriteRecord = 'FavoriteRecord',
    PlayerFavorite = 'PlayerFavorite',
    RadioTimeRecord = 'RadioTimeRecord',
    ReturnActivityData = 'ReturnActivityData',
    SCore = 'SCore',
    Card2ScoreCfgData = 'Card2ScoreCfgData',
    Shop = 'Shop',
    ShopData = 'ShopData',
    AnecdoteList = 'AnecdoteList',
    AnecdoteItem = 'AnecdoteItem',
    AnecdoteSection = 'AnecdoteSection',
    AnecdoteContent = 'AnecdoteContent',
    LegendList = 'LegendList',
    LegendItem = 'LegendItem',
    LegendSection = 'LegendSection',
    Task = 'Task',
    TasksByConditionType = 'TasksByConditionType',
    TasksByTaskType = 'TasksByTaskType',
    TrainingRoomRedPointData = 'TrainingRoomRedPointData',
    UFOCatcherGame = 'UFOCatcherGame',
    UrlImageData = 'UrlImageData',
    VIPChargeData = 'VIPChargeData',
    CommonGestureOperatedModeData = 'CommonGestureOperatedModeData',
    Entry2WorldInfoList = 'Entry2WorldInfoList',
    Main2WorldInfoList = 'Main2WorldInfoList',
    WorldInfoData = 'WorldInfoData',
    TestPureProtoTypeData = 'TestPureProtoTypeData',
    RepeatedTestData = 'RepeatedTestData',
    MapTestData = 'MapTestData',
    CombineTestData = 'CombineTestData',
    AssociationTestData = 'AssociationTestData',
}

---@class X3DataConst.X3DataField 用于获取X3Data命名空间下Data的字段
X3DataConst.X3DataField = {}

--region X3DataField
---@class X3DataConst.X3DataField.AccompanyTypeRecord X3Data.AccompanyTypeRecord的字段名称枚举
X3DataConst.X3DataField.AccompanyTypeRecord = {
    PrimaryKey = 1,
    Cnt = 2,
    Duration = 3,
}

---@class X3DataConst.X3DataField.AccompanyDayRecord X3Data.AccompanyDayRecord的字段名称枚举
X3DataConst.X3DataField.AccompanyDayRecord = {
    PrimaryKey = 1,
    Records = 2,
}

---@class X3DataConst.X3DataField.AccompanyYearRecord X3Data.AccompanyYearRecord的字段名称枚举
X3DataConst.X3DataField.AccompanyYearRecord = {
    PrimaryKey = 1,
    Records = 2,
}

---@class X3DataConst.X3DataField.AccompanyRoleRecords X3Data.AccompanyRoleRecords的字段名称枚举
X3DataConst.X3DataField.AccompanyRoleRecords = {
    PrimaryKey = 1,
    CounterRefreshTime = 2,
    WeekRecord = 3,
    MonthRecord = 4,
    ConsecutiveWeekOne = 5,
    ConsecutiveWeekThree = 6,
    YearRecords = 7,
    WeekRecordCnt = 8,
}

---@class X3DataConst.X3DataField.AccompanyRoleData X3Data.AccompanyRoleData的字段名称枚举
X3DataConst.X3DataField.AccompanyRoleData = {
    RoleId = 1,
    Type = 2,
    StartTime = 3,
    ExpectDuration = 4,
    AccumulateTime = 5,
    OfflineDuration = 6,
    Duration = 7,
    LastAccompanyTimes = 8,
    WaitDuration = 9,
    Records = 10,
}

---@class X3DataConst.X3DataField.AccompanyData X3Data.AccompanyData的字段名称枚举
X3DataConst.X3DataField.AccompanyData = {
    PrimaryKey = 1,
    RoleMap = 2,
}

---@class X3DataConst.X3DataField.Achievement X3Data.Achievement的字段名称枚举
X3DataConst.X3DataField.Achievement = {
    primaryKey = 1,
    HadShowAchievements = 2,
}

---@class X3DataConst.X3DataField.Activity X3Data.Activity的字段名称枚举
X3DataConst.X3DataField.Activity = {
    activityId = 1,
    active = 2,
}

---@class X3DataConst.X3DataField.ActivityDialogue X3Data.ActivityDialogue的字段名称枚举
X3DataConst.X3DataField.ActivityDialogue = {
    ActivityId = 1,
    MaleID = 2,
    UnlockIDs = 3,
    FinishIDs = 4,
}

---@class X3DataConst.X3DataField.ActivityDiyModel X3Data.ActivityDiyModel的字段名称枚举
X3DataConst.X3DataField.ActivityDiyModel = {
    ActivityID = 1,
    DiyMap = 2,
}

---@class X3DataConst.X3DataField.ActivityGrowUpData X3Data.ActivityGrowUpData的字段名称枚举
X3DataConst.X3DataField.ActivityGrowUpData = {
    Id = 1,
    RewardedList = 2,
}

---@class X3DataConst.X3DataField.ActivityTurntableData X3Data.ActivityTurntableData的字段名称枚举
X3DataConst.X3DataField.ActivityTurntableData = {
    ActivityID = 1,
    DropCount = 2,
    FreeResetTime = 3,
    NextFreeResetTime = 4,
    CountReward = 5,
}

---@class X3DataConst.X3DataField.ActivityTurntableDrawCountData X3Data.ActivityTurntableDrawCountData的字段名称枚举
X3DataConst.X3DataField.ActivityTurntableDrawCountData = {
    Index = 1,
    DrawCountMap = 2,
    DrawCountRewardMap = 3,
}

---@class X3DataConst.X3DataField.ActivityTurntablePersistentData X3Data.ActivityTurntablePersistentData的字段名称枚举
X3DataConst.X3DataField.ActivityTurntablePersistentData = {
    ActivityID = 1,
    TransferData = 2,
}

---@class X3DataConst.X3DataField.ARPhotoData X3Data.ARPhotoData的字段名称枚举
X3DataConst.X3DataField.ARPhotoData = {
    id = 1,
    backgroundID = 2,
    actionID = 3,
    clothDataList = 4,
    beautyDelta = 5,
    lightID = 6,
    lightIntensity = 7,
    useRealIntensity = 8,
    lightAngles = 9,
}

---@class X3DataConst.X3DataField.ASMRData X3Data.ASMRData的字段名称枚举
X3DataConst.X3DataField.ASMRData = {
    primary = 1,
    asmrWndShowMode = 2,
    isAsmrWndShowCustomize = 3,
    mainWndListSelectedIndex = 4,
    customizeWndListSelectedArray = 5,
    curRoleId = 6,
    curRoleCustomASMRSelectedMap = 7,
    roleLastPlayedASMRIdMap = 8,
}

---@class X3DataConst.X3DataField.ASMRRedPointData X3Data.ASMRRedPointData的字段名称枚举
X3DataConst.X3DataField.ASMRRedPointData = {
    asmrId = 1,
    isReward = 2,
    roleId = 3,
    isNotNew = 4,
    isUnLock = 5,
    isCustom = 6,
}

---@class X3DataConst.X3DataField.ASMRPersistentData X3Data.ASMRPersistentData的字段名称枚举
X3DataConst.X3DataField.ASMRPersistentData = {
    id = 1,
    oldAsmrIdMap = 2,
}

---@class X3DataConst.X3DataField.BattlePassData X3Data.BattlePassData的字段名称枚举
X3DataConst.X3DataField.BattlePassData = {
    primary = 1,
    ID = 2,
    WeeklyRewardClaim = 3,
    LastRefreshTime = 4,
    Exp = 5,
    RewardClaimed = 6,
    Level = 7,
    ExtraLevel = 8,
    PayIDs = 9,
}

---@class X3DataConst.X3DataField.CardData X3Data.CardData的字段名称枚举
X3DataConst.X3DataField.CardData = {
    Id = 1,
    UId = 2,
    Level = 3,
    Exp = 4,
    StarLevel = 5,
    PhaseLevel = 6,
    Awaken = 7,
    GemCores = 8,
}

---@class X3DataConst.X3DataField.CardLocalImgInfo X3Data.CardLocalImgInfo的字段名称枚举
X3DataConst.X3DataField.CardLocalImgInfo = {
    Id = 1,
    FaceVersion = 2,
}

---@class X3DataConst.X3DataField.CardManagedData X3Data.CardManagedData的字段名称枚举
X3DataConst.X3DataField.CardManagedData = {
    Id = 1,
    LevelMaxCardMap = 2,
    StarLevelMaxCardMap = 3,
    PhaseLevelMaxCardMap = 4,
    AwakeLevelMaxCardMap = 5,
    AllCardNum = 6,
}

---@class X3DataConst.X3DataField.CardPosDataList X3Data.CardPosDataList的字段名称枚举
X3DataConst.X3DataField.CardPosDataList = {
    PosId = 1,
    CardList = 2,
    CfgCardList = 3,
}

---@class X3DataConst.X3DataField.CardManTypeDataList X3Data.CardManTypeDataList的字段名称枚举
X3DataConst.X3DataField.CardManTypeDataList = {
    ManId = 1,
    CardList = 2,
    CfgCardList = 3,
}

---@class X3DataConst.X3DataField.CardInitAttrData X3Data.CardInitAttrData的字段名称枚举
X3DataConst.X3DataField.CardInitAttrData = {
    CardId = 1,
    InitAttr = 2,
}

---@class X3DataConst.X3DataField.CardAttrData X3Data.CardAttrData的字段名称枚举
X3DataConst.X3DataField.CardAttrData = {
    CardId = 1,
    UId = 2,
    BaseAttr = 3,
    GemCoreAttr = 4,
    TalentAttr = 5,
    FinalAttr = 6,
}

---@class X3DataConst.X3DataField.CardSuitConfigData X3Data.CardSuitConfigData的字段名称枚举
X3DataConst.X3DataField.CardSuitConfigData = {
    SuitId = 1,
    SuitQuality = 2,
    CardList = 3,
}

---@class X3DataConst.X3DataField.CardQuestData X3Data.CardQuestData的字段名称枚举
X3DataConst.X3DataField.CardQuestData = {
    CardId = 1,
    CardQuests = 2,
}

---@class X3DataConst.X3DataField.CardSuitQuestData X3Data.CardSuitQuestData的字段名称枚举
X3DataConst.X3DataField.CardSuitQuestData = {
    SuitId = 1,
    SuitQuests = 2,
}

---@class X3DataConst.X3DataField.OtherSuitPhaseData X3Data.OtherSuitPhaseData的字段名称枚举
X3DataConst.X3DataField.OtherSuitPhaseData = {
    SuitId = 1,
    Uid = 2,
    SuitPhase = 3,
}

---@class X3DataConst.X3DataField.ChargeData X3Data.ChargeData的字段名称枚举
X3DataConst.X3DataField.ChargeData = {
    PrimaryKey = 1,
    Total = 2,
    ChargeRecords = 3,
    DeliverOrders = 4,
    LastChargeTime = 5,
    PayLimitBirthday = 6,
    PaidOrders = 7,
    FirstState = 8,
}

---@class X3DataConst.X3DataField.ChargeRecord X3Data.ChargeRecord的字段名称枚举
X3DataConst.X3DataField.ChargeRecord = {
    PrimaryKey = 1,
    Charges = 2,
}

---@class X3DataConst.X3DataField.DeliverOrder X3Data.DeliverOrder的字段名称枚举
X3DataConst.X3DataField.DeliverOrder = {
    OrderId = 1,
    ChannelOrderId = 2,
    UniqueId = 3,
}

---@class X3DataConst.X3DataField.PayInfo X3Data.PayInfo的字段名称枚举
X3DataConst.X3DataField.PayInfo = {
    PayID = 1,
    Name = 2,
    Desc = 3,
    ProductId = 4,
    Money = 5,
    Currency = 6,
    Amount = 7,
    Align = 8,
    Symbol = 9,
    Pattern = 10,
}

---@class X3DataConst.X3DataField.Order X3Data.Order的字段名称枚举
X3DataConst.X3DataField.Order = {
    UniqueId = 1,
    OrderId = 2,
    Uid = 3,
    DepositId = 4,
    PayId = 5,
    Amount = 6,
    ChannelOrderId = 7,
    Status = 8,
    PlatformId = 9,
    DeliverTime = 10,
    ChargeOpType = 11,
    ChannelProductId = 12,
    CurrencyType = 13,
    CreateTime = 14,
    PaidTime = 15,
}

---@class X3DataConst.X3DataField.CriticalLogPersistenceInfo X3Data.CriticalLogPersistenceInfo的字段名称枚举
X3DataConst.X3DataField.CriticalLogPersistenceInfo = {
    filePath = 1,
    lastModifiedTime = 2,
    uploadState = 3,
}

---@class X3DataConst.X3DataField.DailyConfideData X3Data.DailyConfideData的字段名称枚举
X3DataConst.X3DataField.DailyConfideData = {
    Id = 1,
    Token = 2,
    TokenExpireTime = 3,
    LastDailyPhoneTime = 4,
    VoiceExpireTime = 5,
    Records = 6,
}

---@class X3DataConst.X3DataField.DailyConfideCompleteRecord X3Data.DailyConfideCompleteRecord的字段名称枚举
X3DataConst.X3DataField.DailyConfideCompleteRecord = {
    Id = 1,
    TodayRecord = 2,
    YesterdayRecord = 3,
}

---@class X3DataConst.X3DataField.DailyConfideRecord X3Data.DailyConfideRecord的字段名称枚举
X3DataConst.X3DataField.DailyConfideRecord = {
    Id = 1,
    RoleId = 2,
    Emotion = 3,
    MatterType = 4,
    SubMatterType = 5,
    NewTimestamp = 6,
}

---@class X3DataConst.X3DataField.DatePlanInvitationData X3Data.DatePlanInvitationData的字段名称枚举
X3DataConst.X3DataField.DatePlanInvitationData = {
    LetterID = 1,
    RoleID = 2,
    Timestamp = 3,
    ContentList = 4,
    Status = 5,
}

---@class X3DataConst.X3DataField.DateContent X3Data.DateContent的字段名称枚举
X3DataConst.X3DataField.DateContent = {
    ID = 1,
    Ongoing = 2,
    DateGamePlayData = 3,
}

---@class X3DataConst.X3DataField.DateGamePlayData X3Data.DateGamePlayData的字段名称枚举
X3DataConst.X3DataField.DateGamePlayData = {
    ID = 1,
    DateMiaoData = 2,
}

---@class X3DataConst.X3DataField.DateMiaoData X3Data.DateMiaoData的字段名称枚举
X3DataConst.X3DataField.DateMiaoData = {
    ID = 1,
    ResultList = 2,
}

---@class X3DataConst.X3DataField.DropMultipleData X3Data.DropMultipleData的字段名称枚举
X3DataConst.X3DataField.DropMultipleData = {
    index = 1,
    lastUpdateTime = 2,
    nextUpdateTime = 3,
    rewardTimes = 4,
}

---@class X3DataConst.X3DataField.ActivityDropMultipleData X3Data.ActivityDropMultipleData的字段名称枚举
X3DataConst.X3DataField.ActivityDropMultipleData = {
    activityId = 1,
    dropMultipleDataMap = 2,
}

---@class X3DataConst.X3DataField.PlayerVoice X3Data.PlayerVoice的字段名称枚举
X3DataConst.X3DataField.PlayerVoice = {
    Id = 1,
    Voice = 2,
}

---@class X3DataConst.X3DataField.Formation X3Data.Formation的字段名称枚举
X3DataConst.X3DataField.Formation = {
    Guid = 1,
    WeaponId = 2,
    PlSuitId = 3,
    SCoreID = 4,
    CardIDs = 5,
}

---@class X3DataConst.X3DataField.PreFabFormation X3Data.PreFabFormation的字段名称枚举
X3DataConst.X3DataField.PreFabFormation = {
    PreFabID = 1,
    Name = 2,
    WeaponId = 3,
    PlSuitId = 4,
    SCoreID = 5,
    CardIDs = 6,
}

---@class X3DataConst.X3DataField.GalleryRecord X3Data.GalleryRecord的字段名称枚举
X3DataConst.X3DataField.GalleryRecord = {
    RoleId = 1,
    CollectionMaxNum = 2,
}

---@class X3DataConst.X3DataField.GameplayInfo X3Data.GameplayInfo的字段名称枚举
X3DataConst.X3DataField.GameplayInfo = {
    Id = 1,
    SystemID = 2,
    CanHangOn = 3,
    PopId = 4,
    PopIdUnforced = 5,
    ContinueDatas = 6,
}

---@class X3DataConst.X3DataField.GameplayContinueData X3Data.GameplayContinueData的字段名称枚举
X3DataConst.X3DataField.GameplayContinueData = {
    SubID = 1,
    EnterType = 2,
    GameType = 3,
    IsGuideSkip = 4,
    Version = 5,
    CanHangOn = 6,
    PopId = 7,
}

---@class X3DataConst.X3DataField.GameplayCommonData X3Data.GameplayCommonData的字段名称枚举
X3DataConst.X3DataField.GameplayCommonData = {
    SubID = 1,
    EnterType = 2,
    GameType = 3,
    CurrentRoundIndex = 4,
    MaxRoundCount = 5,
    TurnCount = 6,
}

---@class X3DataConst.X3DataField.GemCoreData X3Data.GemCoreData的字段名称枚举
X3DataConst.X3DataField.GemCoreData = {
    Primary = 1,
    BindCard = 2,
    LockCore = 3,
}

---@class X3DataConst.X3DataField.GemCore X3Data.GemCore的字段名称枚举
X3DataConst.X3DataField.GemCore = {
    Id = 1,
    TblID = 2,
    Level = 3,
    Exp = 4,
    Attrs = 5,
    ResolveAddExp = 6,
    PlayerUid = 7,
}

---@class X3DataConst.X3DataField.HunterContestSeason X3Data.HunterContestSeason的字段名称枚举
X3DataConst.X3DataField.HunterContestSeason = {
    ID = 1,
    TotalStar = 2,
    Pass = 3,
}

---@class X3DataConst.X3DataField.HunterContest X3Data.HunterContest的字段名称枚举
X3DataConst.X3DataField.HunterContest = {
    RankLevel = 1,
    CurrentSeason = 2,
    LastSeason = 3,
    Cards = 4,
    FirstEnterSeason = 5,
}

---@class X3DataConst.X3DataField.HunterContestCards X3Data.HunterContestCards的字段名称枚举
X3DataConst.X3DataField.HunterContestCards = {
    UID = 1,
    CardIDs = 2,
}

---@class X3DataConst.X3DataField.HunterContestCard X3Data.HunterContestCard的字段名称枚举
X3DataConst.X3DataField.HunterContestCard = {
    UID = 1,
    Slot = 2,
    CardID = 3,
    GemCores = 4,
}

---@class X3DataConst.X3DataField.HunterContestRewardData X3Data.HunterContestRewardData的字段名称枚举
X3DataConst.X3DataField.HunterContestRewardData = {
    GroupID = 1,
    Rewarded = 2,
}

---@class X3DataConst.X3DataField.Item X3Data.Item的字段名称枚举
X3DataConst.X3DataField.Item = {
    Id = 1,
    Type = 2,
    Num = 3,
}

---@class X3DataConst.X3DataField.SpItem X3Data.SpItem的字段名称枚举
X3DataConst.X3DataField.SpItem = {
    Id = 1,
    Num = 2,
    Mid = 3,
    ExpTime = 4,
}

---@class X3DataConst.X3DataField.Coin X3Data.Coin的字段名称枚举
X3DataConst.X3DataField.Coin = {
    Key = 1,
    Value = 2,
}

---@class X3DataConst.X3DataField.KnockMoleLevelData X3Data.KnockMoleLevelData的字段名称枚举
X3DataConst.X3DataField.KnockMoleLevelData = {
    difficultyId = 1,
    integralNum = 2,
    knockMoleHoleMap = 3,
    gamePlayLeftTime = 4,
}

---@class X3DataConst.X3DataField.KnockMoleHole X3Data.KnockMoleHole的字段名称枚举
X3DataConst.X3DataField.KnockMoleHole = {
    id = 1,
    status = 2,
    knockMoleData = 3,
}

---@class X3DataConst.X3DataField.KnockMoleData X3Data.KnockMoleData的字段名称枚举
X3DataConst.X3DataField.KnockMoleData = {
    id = 1,
    moleId = 2,
    status = 3,
    endShowTime = 4,
}

---@class X3DataConst.X3DataField.ConflictedTest X3Data.ConflictedTest的字段名称枚举
X3DataConst.X3DataField.ConflictedTest = {
    primaryInt64Key = 1,
    uint32Field = 2,
    int64Field = 3,
    int32Field = 4,
    strField = 5,
    boolField = 6,
    doubleField = 7,
    floatField = 8,
    doubleField5 = 9,
}

---@class X3DataConst.X3DataField.LoginData X3Data.LoginData的字段名称枚举
X3DataConst.X3DataField.LoginData = {
    primaryKey = 1,
    serverId = 2,
    serverName = 3,
    zoneId = 4,
    zoneName = 5,
}

---@class X3DataConst.X3DataField.LovePointTimeRecord X3Data.LovePointTimeRecord的字段名称枚举
X3DataConst.X3DataField.LovePointTimeRecord = {
    PrimaryKey = 1,
    Time = 2,
}

---@class X3DataConst.X3DataField.LovePointRole X3Data.LovePointRole的字段名称枚举
X3DataConst.X3DataField.LovePointRole = {
    PrimaryKey = 1,
    RoleID = 2,
}

---@class X3DataConst.X3DataField.MailParam X3Data.MailParam的字段名称枚举
X3DataConst.X3DataField.MailParam = {
    Id = 1,
    ParamType = 2,
    Params = 3,
}

---@class X3DataConst.X3DataField.MailRewardItem X3Data.MailRewardItem的字段名称枚举
X3DataConst.X3DataField.MailRewardItem = {
    Uid = 1,
    Id = 2,
    Type = 3,
    Num = 4,
}

---@class X3DataConst.X3DataField.Mail X3Data.Mail的字段名称枚举
X3DataConst.X3DataField.Mail = {
    MailId = 1,
    RecvId = 2,
    Recver = 3,
    SendId = 4,
    Sender = 5,
    SendTime = 6,
    Title = 7,
    Content = 8,
    ExpTime = 9,
    IsRead = 10,
    IsReward = 11,
    Rewards = 12,
    TemplateId = 13,
    TemplateArgs = 14,
    MailType = 15,
    StaticID = 16,
    CustomParams = 17,
}

---@class X3DataConst.X3DataField.DoubleTouchType X3Data.DoubleTouchType的字段名称枚举
X3DataConst.X3DataField.DoubleTouchType = {
    ID = 1,
    TouchType = 2,
}

---@class X3DataConst.X3DataField.MainHomeData X3Data.MainHomeData的字段名称枚举
X3DataConst.X3DataField.MainHomeData = {
    ID = 1,
    SceneID = 2,
    ModeType = 3,
    ActorID = 4,
    EventID = 5,
}

---@class X3DataConst.X3DataField.ActionRecord X3Data.ActionRecord的字段名称枚举
X3DataConst.X3DataField.ActionRecord = {
    ActorID = 1,
    ActionID = 2,
}

---@class X3DataConst.X3DataField.MonthCardData X3Data.MonthCardData的字段名称枚举
X3DataConst.X3DataField.MonthCardData = {
    primaryKey = 1,
    MonthCardTimeMap = 2,
    DailyRewardFlagMap = 3,
    CardPowerMap = 4,
    LastRefreshTime = 5,
    RedPointState = 6,
}

---@class X3DataConst.X3DataField.PhoneContactHead X3Data.PhoneContactHead的字段名称枚举
X3DataConst.X3DataField.PhoneContactHead = {
    ContactId = 1,
    Type = 2,
    ScoreId = 3,
    CardId = 4,
    Photo = 5,
    PhotoId = 6,
    LastSetTime = 7,
    PersonalHeadID = 8,
}

---@class X3DataConst.X3DataField.PhoneContactSign X3Data.PhoneContactSign的字段名称枚举
X3DataConst.X3DataField.PhoneContactSign = {
    Sign = 1,
    Time = 2,
    SignId = 3,
}

---@class X3DataConst.X3DataField.PhoneContactMoment X3Data.PhoneContactMoment的字段名称枚举
X3DataConst.X3DataField.PhoneContactMoment = {
    ContactId = 1,
    CoverPhoto = 2,
    CoverId = 3,
}

---@class X3DataConst.X3DataField.PhoneContactBubble X3Data.PhoneContactBubble的字段名称枚举
X3DataConst.X3DataField.PhoneContactBubble = {
    ContactId = 1,
    ID = 2,
}

---@class X3DataConst.X3DataField.PhoneContactChatBackground X3Data.PhoneContactChatBackground的字段名称枚举
X3DataConst.X3DataField.PhoneContactChatBackground = {
    ContactId = 1,
    Type = 2,
    PhotoId = 3,
    CardId = 4,
}

---@class X3DataConst.X3DataField.ContactNudge X3Data.ContactNudge的字段名称枚举
X3DataConst.X3DataField.ContactNudge = {
    Contact = 1,
    Sign = 2,
    Verb = 3,
    Suffix = 4,
    AutoPatID = 5,
}

---@class X3DataConst.X3DataField.PhoneContactHeadImgCache X3Data.PhoneContactHeadImgCache的字段名称枚举
X3DataConst.X3DataField.PhoneContactHeadImgCache = {
    ContactId = 1,
    Url = 2,
    State = 3,
    SetTime = 4,
}

---@class X3DataConst.X3DataField.PhoneContactData X3Data.PhoneContactData的字段名称枚举
X3DataConst.X3DataField.PhoneContactData = {
    LastRefreshTime = 1,
    HeadPhotos = 2,
    Signs = 3,
    MomentCovers = 4,
    Bubbles = 5,
    ChatBackgrounds = 6,
}

---@class X3DataConst.X3DataField.PhoneContact X3Data.PhoneContact的字段名称枚举
X3DataConst.X3DataField.PhoneContact = {
    ID = 1,
    Remark = 2,
    CardId = 3,
    Head = 4,
    HeadImgCache = 5,
    Sign = 6,
    HistorySigns = 7,
    Moment = 8,
    Bubble = 9,
    ChatBackground = 10,
    PendantSwitch = 11,
    ChangeHeadHistory = 12,
    LastChangeTime = 13,
    ChangeHeadTimes = 14,
    ChangeBubbleTimes = 15,
    ChangeMomentTimes = 16,
    ChangeNudgeTimes = 17,
    NameUnlock = 18,
    Nudge = 19,
}

---@class X3DataConst.X3DataField.NudgeInfo X3Data.NudgeInfo的字段名称枚举
X3DataConst.X3DataField.NudgeInfo = {
    Uid = 1,
    Num = 2,
    LastTime = 3,
}

---@class X3DataConst.X3DataField.PhoneMsgExtraInfo X3Data.PhoneMsgExtraInfo的字段名称枚举
X3DataConst.X3DataField.PhoneMsgExtraInfo = {
    MsgId = 1,
    NudgeSign = 2,
    BubbleID = 3,
    HeadIcon = 4,
}

---@class X3DataConst.X3DataField.PhoneMsgConversationData X3Data.PhoneMsgConversationData的字段名称枚举
X3DataConst.X3DataField.PhoneMsgConversationData = {
    Uid = 1,
    CfgId = 2,
    Type = 3,
    State = 4,
    RewardState = 5,
    ReadState = 6,
    NextCfgId = 7,
    FireTime = 8,
}

---@class X3DataConst.X3DataField.PhoneMsgUIItem X3Data.PhoneMsgUIItem的字段名称枚举
X3DataConst.X3DataField.PhoneMsgUIItem = {
    idx = 1,
    MsgGuid = 2,
    info = 3,
    Verb = 4,
    Suffix = 5,
}

---@class X3DataConst.X3DataField.PhoneMsgSimulatingData X3Data.PhoneMsgSimulatingData的字段名称枚举
X3DataConst.X3DataField.PhoneMsgSimulatingData = {
    ContactId = 1,
    GUID = 2,
    CfgId = 3,
    History = 4,
    RewardMap = 5,
    RedPacketMap = 6,
    RecallMap = 7,
    UnreadList = 8,
    IsWaitingForFinish = 9,
    LastReadId = 10,
}

---@class X3DataConst.X3DataField.PhoneMsgProgressData X3Data.PhoneMsgProgressData的字段名称枚举
X3DataConst.X3DataField.PhoneMsgProgressData = {
    ContactId = 1,
    GUID = 2,
    LastConvId = 3,
    LastReadId = 4,
}

---@class X3DataConst.X3DataField.PhoneMsgDetailData X3Data.PhoneMsgDetailData的字段名称枚举
X3DataConst.X3DataField.PhoneMsgDetailData = {
    GUID = 1,
    ID = 2,
    CreateTime = 3,
    ContactID = 4,
    LastRefreshTime = 5,
    IsFinished = 6,
    ChoiceList = 7,
    NudgeNumMap = 8,
    Extra = 9,
}

---@class X3DataConst.X3DataField.PhoneMsgContactData X3Data.PhoneMsgContactData的字段名称枚举
X3DataConst.X3DataField.PhoneMsgContactData = {
    ContactId = 1,
    History = 2,
    CurMsgID = 3,
    LastMsgID = 4,
    AutoActiveMsgMap = 5,
    TopicMap = 6,
    NewTopicCount = 7,
    ShowTopicRed = 8,
    LastRefreshTime = 9,
    FinishMsgRedPoint = 10,
}

---@class X3DataConst.X3DataField.PhoneMsgConditionRecord X3Data.PhoneMsgConditionRecord的字段名称枚举
X3DataConst.X3DataField.PhoneMsgConditionRecord = {
    uid = 1,
    Record = 2,
}

---@class X3DataConst.X3DataField.PhoneMsgData X3Data.PhoneMsgData的字段名称枚举
X3DataConst.X3DataField.PhoneMsgData = {
    Uid = 1,
    LastRefreshTime = 2,
    ChatAllNum = 3,
    GuidGen = 4,
    CollectStickerMap = 5,
    CacheIDMap = 6,
    ActiveMessageMap = 7,
    MsgGUIDMap = 8,
    RewardMap = 9,
    RedPacket = 10,
}

---@class X3DataConst.X3DataField.PhotoData X3Data.PhotoData的字段名称枚举
X3DataConst.X3DataField.PhotoData = {
    Name = 1,
    Mode = 2,
    MaleID = 3,
    FemaleID = 4,
    PictureNum = 5,
    NumOfPeople = 6,
    UploadState = 7,
    ParentID = 8,
    PlayerID = 9,
    TimeStamp = 10,
    ActionString = 11,
    DressString = 12,
    ServerPhotoName = 13,
    FullUrl = 14,
    Md5String = 15,
}

---@class X3DataConst.X3DataField.Photo X3Data.Photo的字段名称枚举
X3DataConst.X3DataField.Photo = {
    Url = 1,
    TimeStamp = 2,
    Status = 3,
    RoleId = 4,
    GroupMode = 5,
    Mode = 6,
    PuzzleMode = 7,
    ActionList = 8,
    DecorationList = 9,
    SourcePhoto = 10,
}

---@class X3DataConst.X3DataField.ChooseRecord X3Data.ChooseRecord的字段名称枚举
X3DataConst.X3DataField.ChooseRecord = {
    Id = 1,
    Num = 2,
}

---@class X3DataConst.X3DataField.PlayerChoose X3Data.PlayerChoose的字段名称枚举
X3DataConst.X3DataField.PlayerChoose = {
    RoleID = 1,
    Chooses = 2,
    LastWeeklyRefreshTime = 3,
    ContinueAddScore = 4,
    ContinueDecScore = 5,
}

---@class X3DataConst.X3DataField.PlayerRecommendRecord X3Data.PlayerRecommendRecord的字段名称枚举
X3DataConst.X3DataField.PlayerRecommendRecord = {
    TagID = 1,
    RecommendNum = 2,
    LastRecommendTime = 3,
}

---@class X3DataConst.X3DataField.PlayerRecommend X3Data.PlayerRecommend的字段名称枚举
X3DataConst.X3DataField.PlayerRecommend = {
    RoleID = 1,
    RecommendMap = 2,
}

---@class X3DataConst.X3DataField.PlayerTagRecord X3Data.PlayerTagRecord的字段名称枚举
X3DataConst.X3DataField.PlayerTagRecord = {
    RoleID = 1,
    TagMap = 2,
}

---@class X3DataConst.X3DataField.PlayerTag X3Data.PlayerTag的字段名称枚举
X3DataConst.X3DataField.PlayerTag = {
    ID = 1,
    Score = 2,
    ChooseNum = 3,
    AppearNum = 4,
    SetTime = 5,
    InitScore = 6,
}

---@class X3DataConst.X3DataField.FavoriteRecord X3Data.FavoriteRecord的字段名称枚举
X3DataConst.X3DataField.FavoriteRecord = {
    RoleID = 1,
    FavoriteMap = 2,
}

---@class X3DataConst.X3DataField.PlayerFavorite X3Data.PlayerFavorite的字段名称枚举
X3DataConst.X3DataField.PlayerFavorite = {
    ID = 1,
    List = 2,
}

---@class X3DataConst.X3DataField.RadioTimeRecord X3Data.RadioTimeRecord的字段名称枚举
X3DataConst.X3DataField.RadioTimeRecord = {
    RadioId = 1,
    SubId = 2,
    Time = 3,
    LastRecordTime = 4,
    HandleOrder = 5,
    RecordType = 6,
    TotalTime = 7,
    SignList = 8,
    Upload = 9,
}

---@class X3DataConst.X3DataField.ReturnActivityData X3Data.ReturnActivityData的字段名称枚举
X3DataConst.X3DataField.ReturnActivityData = {
    primary = 1,
    StartTime = 2,
    ReturnID = 3,
    RoleID = 4,
    LastStartTime = 5,
    OpenLoginLastUpdateTime = 6,
    OpenLoginDay = 7,
    SignInRewardClaimed = 8,
    CardRead = 9,
    DoubleTimes = 10,
}

---@class X3DataConst.X3DataField.SCore X3Data.SCore的字段名称枚举
X3DataConst.X3DataField.SCore = {
    Id = 1,
    SuitID = 2,
    CTime = 3,
    Voices = 4,
}

---@class X3DataConst.X3DataField.Card2ScoreCfgData X3Data.Card2ScoreCfgData的字段名称枚举
X3DataConst.X3DataField.Card2ScoreCfgData = {
    CardId = 1,
    SCoreId = 2,
}

---@class X3DataConst.X3DataField.Shop X3Data.Shop的字段名称枚举
X3DataConst.X3DataField.Shop = {
    Id = 1,
    Rands = 2,
    Buys = 3,
    HandReNum = 4,
    LastRefreshTime = 5,
    ReSets = 6,
    LastBuyTime = 7,
}

---@class X3DataConst.X3DataField.ShopData X3Data.ShopData的字段名称枚举
X3DataConst.X3DataField.ShopData = {
    LastRefreshTime = 1,
    HistoryBuys = 2,
    ShopGoodsNextRefTime = 3,
}

---@class X3DataConst.X3DataField.AnecdoteList X3Data.AnecdoteList的字段名称枚举
X3DataConst.X3DataField.AnecdoteList = {
    PrimaryKey = 1,
    AnecdoteData = 2,
    LastStoryID = 3,
}

---@class X3DataConst.X3DataField.AnecdoteItem X3Data.AnecdoteItem的字段名称枚举
X3DataConst.X3DataField.AnecdoteItem = {
    PrimaryKey = 1,
    State = 2,
    SectionData = 3,
    LastReadSection = 4,
    LastReadSectionNum = 5,
    StateType = 6,
    isNew = 7,
}

---@class X3DataConst.X3DataField.AnecdoteSection X3Data.AnecdoteSection的字段名称枚举
X3DataConst.X3DataField.AnecdoteSection = {
    PrimaryKey = 1,
    State = 2,
    ContentData = 3,
    PageIndex = 4,
    LastNum = 5,
    PageNum = 6,
    isNew = 7,
    ReadState = 8,
    CanvasSizeX = 9,
    CanvasSizeY = 10,
}

---@class X3DataConst.X3DataField.AnecdoteContent X3Data.AnecdoteContent的字段名称枚举
X3DataConst.X3DataField.AnecdoteContent = {
    PrimaryKey = 1,
    SectionID = 2,
    Num = 3,
    Content = 4,
    NoRichContent = 5,
}

---@class X3DataConst.X3DataField.LegendList X3Data.LegendList的字段名称枚举
X3DataConst.X3DataField.LegendList = {
    PrimaryKey = 1,
    Legend = 2,
    LastStoryID = 3,
}

---@class X3DataConst.X3DataField.LegendItem X3Data.LegendItem的字段名称枚举
X3DataConst.X3DataField.LegendItem = {
    PrimaryKey = 1,
    State = 2,
    SectionData = 3,
    LastReadSection = 4,
    StateType = 5,
    isNew = 6,
}

---@class X3DataConst.X3DataField.LegendSection X3Data.LegendSection的字段名称枚举
X3DataConst.X3DataField.LegendSection = {
    PrimaryKey = 1,
    State = 2,
    isNew = 3,
    ReadState = 4,
}

---@class X3DataConst.X3DataField.Task X3Data.Task的字段名称枚举
X3DataConst.X3DataField.Task = {
    ID = 1,
    Num = 2,
    IsComplete = 3,
    RewardCnt = 4,
    CompleteTm = 5,
    CurProgressNum = 6,
    NeedNum = 7,
    Status = 8,
    IsShow = 9,
    IsAutoReward = 10,
}

---@class X3DataConst.X3DataField.TasksByConditionType X3Data.TasksByConditionType的字段名称枚举
X3DataConst.X3DataField.TasksByConditionType = {
    primaryKey = 1,
    Tasks = 2,
}

---@class X3DataConst.X3DataField.TasksByTaskType X3Data.TasksByTaskType的字段名称枚举
X3DataConst.X3DataField.TasksByTaskType = {
    primaryKey = 1,
    Tasks = 2,
}

---@class X3DataConst.X3DataField.TrainingRoomRedPointData X3Data.TrainingRoomRedPointData的字段名称枚举
X3DataConst.X3DataField.TrainingRoomRedPointData = {
    stageId = 1,
    isUnlock = 2,
    isOld = 3,
}

---@class X3DataConst.X3DataField.UFOCatcherGame X3Data.UFOCatcherGame的字段名称枚举
X3DataConst.X3DataField.UFOCatcherGame = {
    Id = 1,
    ChangePlayer = 2,
    ChangeRefused = 3,
    RefusedCount = 4,
}

---@class X3DataConst.X3DataField.UrlImageData X3Data.UrlImageData的字段名称枚举
X3DataConst.X3DataField.UrlImageData = {
    originName = 1,
    fakeName = 2,
    checkString = 3,
}

---@class X3DataConst.X3DataField.VIPChargeData X3Data.VIPChargeData的字段名称枚举
X3DataConst.X3DataField.VIPChargeData = {
    Id = 1,
    Level = 2,
    Exp = 3,
    Rewards = 4,
}

---@class X3DataConst.X3DataField.CommonGestureOperatedModeData X3Data.CommonGestureOperatedModeData的字段名称枚举
X3DataConst.X3DataField.CommonGestureOperatedModeData = {
    id = 1,
    dragState = 2,
    yawAngle = 3,
    yawLimits = 4,
    initYawAngle = 5,
    initPitchAngle = 6,
}

---@class X3DataConst.X3DataField.Entry2WorldInfoList X3Data.Entry2WorldInfoList的字段名称枚举
X3DataConst.X3DataField.Entry2WorldInfoList = {
    entryId = 1,
    itemIds = 2,
}

---@class X3DataConst.X3DataField.Main2WorldInfoList X3Data.Main2WorldInfoList的字段名称枚举
X3DataConst.X3DataField.Main2WorldInfoList = {
    mainInfoId = 1,
    itemIds = 2,
}

---@class X3DataConst.X3DataField.WorldInfoData X3Data.WorldInfoData的字段名称枚举
X3DataConst.X3DataField.WorldInfoData = {
    worldInfoId = 1,
    rewarded = 2,
}

---@class X3DataConst.X3DataField.TestPureProtoTypeData X3Data.TestPureProtoTypeData的字段名称枚举
X3DataConst.X3DataField.TestPureProtoTypeData = {
    primaryInt64Key = 1,
    uint32Field = 2,
    int32Field = 3,
    int64Field = 4,
    strField = 5,
    boolField = 6,
    floatField = 7,
    doubleField = 8,
}

---@class X3DataConst.X3DataField.RepeatedTestData X3Data.RepeatedTestData的字段名称枚举
X3DataConst.X3DataField.RepeatedTestData = {
    primaryStrKey = 1,
    x3DataTestArray = 2,
    int32TestArray = 3,
}

---@class X3DataConst.X3DataField.MapTestData X3Data.MapTestData的字段名称枚举
X3DataConst.X3DataField.MapTestData = {
    id = 1,
    int32StringMap = 2,
    x3DataTestMap = 3,
    TestString = 4,
}

---@class X3DataConst.X3DataField.CombineTestData X3Data.CombineTestData的字段名称枚举
X3DataConst.X3DataField.CombineTestData = {
    primaryInt64Key = 1,
    uint32Field = 2,
    int32Field = 3,
    int64Field = 4,
    strField = 5,
    boolField = 6,
    x3DataTestArray = 7,
    int32TestArray = 8,
    int32StringMap = 9,
    x3DataTestMap = 10,
    x3Data = 11,
    enumTestType = 12,
}

---@class X3DataConst.X3DataField.AssociationTestData X3Data.AssociationTestData的字段名称枚举
X3DataConst.X3DataField.AssociationTestData = {
    primaryInt64Key = 1,
    combineTestDataArray = 2,
}
--endregion X3DataField结束

--region 枚举类型
---@class X3DataConst.ActivityTurntableDropState 
X3DataConst.ActivityTurntableDropState = {
    ActivityTurntableDropStateNormal = 0, ---正常状态
    ActivityTurntableDropStateTransfer = 1, ---转化状态
    ActivityTurntableDropStateRemove = 2, ---移除状态
}

---@class X3DataConst.ASMRWndShowMode ASMRWnd的显示形式
X3DataConst.ASMRWndShowMode = {
    MainWnd = 0, 
    CustomizeWnd = 1, 
}

---@class X3DataConst.AwakenStatus 
X3DataConst.AwakenStatus = {
    UnAwake = 0, ---默认状态 未觉醒
    Awaken = 1, ---已经觉醒
}

---@class X3DataConst.FirstPayState 
X3DataConst.FirstPayState = {
    StateDefault = 0, ---默认状态 未充值
    StateFinish = 1, --- 可领取
    StateReward = 2, --- 已领取
}

---@class X3DataConst.CriticalLogUploadState 
X3DataConst.CriticalLogUploadState = {
    Fail = 0, ---失败
    Success = 1, ---成功
}

---@class X3DataConst.DatePlanInvitationStatusType 
X3DataConst.DatePlanInvitationStatusType = {
    DatePlanInvitationStatusTypeInitiated = 0, --- 发起邀请
    DatePlanInvitationStatusTypeOpen = 1, --- 打开邀请
    DatePlanInvitationStatusTypeAccept = 2, --- 接受邀请
    DatePlanInvitationStatusTypePutAway = 3, --- 收起邀请
    DatePlanInvitationStatusTypeOngoing = 4, --- 进行中
    DatePlanInvitationStatusTypeHangup = 5, --- 挂起 // TODO 可以不需要显示挂起状态
    DatePlanInvitationStatusTypeFinish = 6, --- 正常结束
    DatePlanInvitationStatusTypeAbort = 7, --- 提前结束
}

---@class X3DataConst.DialogueDarkChatType 
X3DataConst.DialogueDarkChatType = {
    DialogueDarkChatTypeNone = 0, 
    DialogueDarkChatTypeShowLoading = 1, 
    DialogueDarkChatTypeShowChatMsg = 2, 
    DialogueDarkChatTypeShowSystemTips = 3, 
    DialogueDarkChatTypeShowImgWidth = 4, 
    DialogueDarkChatTypeShowImgHigh = 5, 
    DialogueDarkChatTypeCloseComp = 6, 
}

---@class X3DataConst.DialogueDarkChatSubTypeChat 
X3DataConst.DialogueDarkChatSubTypeChat = {
    DialogueDarkChatSubTypeChatNone = 0, 
    DialogueDarkChatSubTypeChatOther = 1, 
    DialogueDarkChatSubTypeChatSelf = 2, 
    DialogueDarkChatSubTypeChatAudioShow = 3, 
    DialogueDarkChatSubTypeChatAudioPlaySingle = 4, 
    DialogueDarkChatSubTypeChatAudioPlayDouble = 5, 
    DialogueDarkChatSubTypeChatStopAudio = 6, 
}

---@class X3DataConst.DialogueDarkChatCompType 
X3DataConst.DialogueDarkChatCompType = {
    DialogueDarkChatCompTypeAll = 0, 
    DialogueDarkChatCompTypeLoading = 1, 
    DialogueDarkChatCompTypeChat = 2, 
    DialogueDarkChatCompTypeSystemTips = 3, 
    DialogueDarkChatCompTypeImgWidth = 4, 
    DialogueDarkChatCompTypeImgHigh = 5, 
}

---@class X3DataConst.DropMultipleEffectSystemType 系统类型枚举
X3DataConst.DropMultipleEffectSystemType = {
    DropMultipleEffectSystemTypeNone = 0, ---空类型
    DropMultipleEffectSystemTypeCommonStageEntry = 1, ---战斗关卡
    DropMultipleEffectSystemTypeDailyDateEntry = 2, ---小小快乐
}

---@class X3DataConst.DropMultipleShowType 显示类型
X3DataConst.DropMultipleShowType = {
    DropMultipleShowTypeNone = 0, ---空类型
    DropMultipleShowTypeSystemEntry = 1, ---系统入口
    DropMultipleShowTypeDungeonEntry = 2, ---副本入口
    DropMultipleShowTypeStageEntry = 3, ---关卡入口
    DropMultipleShowTypeDropDetails = 4, ---掉落详情
    DropMultipleShowTypeItemBottom = 5, ---物品下标
    DropMultipleShowTypeItemRightCorner = 6, ---物品角标(右上)
}

---@class X3DataConst.DropMultipleFilterType 显示类型枚举
X3DataConst.DropMultipleFilterType = {
    DropMultipleFilterTypeAll = 0, ---所有
    DropMultipleFilterTypeActivity = 1, ---多倍活动
    DropMultipleFilterTypeReturnActivity = 2, ---回流活动
}

---@class X3DataConst.KnockMoleHoleStatus 
X3DataConst.KnockMoleHoleStatus = {
    KnockMoleHoleNone = 0, ---空闲状态
    KnockMoleHoleHaveMole = 1, ---已有地鼠
    KnockMoleHoleEnd = 2, ---游戏结束状态
    KnockMoleHoleClose = 3, ---关门
}

---@class X3DataConst.KnockMoleStatus 
X3DataConst.KnockMoleStatus = {
    KnockMoleNone = 0, ---默认状态
    KnockMoleShow = 1, ---地鼠出现
    KnockMoleStay = 2, ---地鼠停留
    KnockMoleKnock = 3, ---地鼠被击打
}

---@class X3DataConst.TestEnum1 
X3DataConst.TestEnum1 = {
    X = 0, 
}

---@class X3DataConst.TestEnum2 
X3DataConst.TestEnum2 = {
    X1 = 0, 
}

---@class X3DataConst.MailReward 
X3DataConst.MailReward = {
    MailRewardNo = 0, --- 邮件没奖励
    MailRewardCan = 1, --- 邮件可领取奖励
    MailRewardDone = 2, --- 邮件已领取奖励
}

---@class X3DataConst.MailType 
X3DataConst.MailType = {
    MailTypeSystem = 0, --- 系统邮件
    MailTypePlatform = 1, --- 个人平台邮件
    MailTypeGlobal = 2, --- 全服邮件
}

---@class X3DataConst.MailParamType 
X3DataConst.MailParamType = {
    MailParamDefault = 0, --- 占位，没用
    MailParamBattlePass = 1, --- bp
}

---@class X3DataConst.PhoneContactHeadState 
X3DataConst.PhoneContactHeadState = {
    ChangeFail = 0, 
    ChangeWaiting = 1, 
    ChangeSuccess = 2, 
}

---@class X3DataConst.PhoneConstChatBackgroundType 
X3DataConst.PhoneConstChatBackgroundType = {
    Default = 0, 
    PhotoType = 1, 
    CardType = 2, 
}

---@class X3DataConst.PhoneContactHeadType 
X3DataConst.PhoneContactHeadType = {
    DefaultHead = 0, 
    ScoreHead = 1, 
    CardHead = 2, 
    ImgHead = 3, 
    PhotoHead = 4, --- 静态图片
    PersonalHead = 5, 
}

---@class X3DataConst.PhoneMsgConversationStateType 
X3DataConst.PhoneMsgConversationStateType = {
    Begin = 0, ---开始节点
    Reading = 1, ---阅读
    Input = 2, ---输入
    Execute = 3, ---逻辑执行
    FakeFinish = 4, ---撤回消息内容结束
    Finish = 5, ---结束
}

---@class X3DataConst.PhoneMsgUIType 
X3DataConst.PhoneMsgUIType = {
    Msg = 0, ---消息
    Line = 1, ---分割线
    ManPokePlayer = 2, ---戳一戳
    Tips = 3, ---系统提示
}

---@class X3DataConst.PhoneMsgConversationRewardType 
X3DataConst.PhoneMsgConversationRewardType = {
    None = 0, 
    UnRewarded = 1, 
    Rewarded = 2, 
}

---@class X3DataConst.PhoneMsgConversationReadType 
X3DataConst.PhoneMsgConversationReadType = {
    Unread = 0, 
    Read = 1, 
}

---@class X3DataConst.UploadStateEnum 
X3DataConst.UploadStateEnum = {
    Local = 0, 
    HasUpload = 999, 
}

---@class X3DataConst.PhotoGroup 与服务器proto保持一致，供其他业务使用
X3DataConst.PhotoGroup = {
    Invalid = 0, 
    Single = 1, 
    Double = 2, 
    Other = 4, 
}

---@class X3DataConst.PhotoStatus 
X3DataConst.PhotoStatus = {
    Default = 0, --- 初始
    Auditting = 1, --- 审核中
    Permit = 2, --- 审核通过
    Reject = 3, --- 审核未通过
}

---@class X3DataConst.RadioRecordType 
X3DataConst.RadioRecordType = {
    Radio = 0, 
    ASMR = 1, 
}

---@class X3DataConst.StoryStatus 解锁状态类型
X3DataConst.StoryStatus = {
    Lock = 0, ---未解锁
    Normal = 1, ---已解锁
}

---@class X3DataConst.StoryReadState 
X3DataConst.StoryReadState = {
    NoRead = 0, ---未读 
    HaveRead = 1, ---已读
}

---@class X3DataConst.StoryType 
X3DataConst.StoryType = {
    StoryTypeNone = 0, 
    Anecdote = 1, ---逸闻
    Legend = 2, ---传说
}

---@class X3DataConst.StoryStateType  小传状态
X3DataConst.StoryStateType = {
    StoryStateTypeNone = 0, --- 无
    StoryStateTypeRead = 1, ---进行过阅读
    StoryStateTypeFinish = 2, --- 完成
    StoryStateTypeReward = 3, --- 已经领取
}

---@class X3DataConst.TaskStatus 
X3DataConst.TaskStatus = {
    TaskCanFinish = 0, ---可完成
    TaskNotFinish = 1, ---未完成
    TaskFinish = 2, ---已完成
}

---@class X3DataConst.CommonGestureOperatedModeRotateModel  测试proto的类型名枚举
X3DataConst.CommonGestureOperatedModeRotateModel = {
    Sphere = 0, ---球面
    Ellipsoid = 1, ---椭球面
}

---@class X3DataConst.CommonGestureOperatedModeDragState 
X3DataConst.CommonGestureOperatedModeDragState = {
    DragStart = 0, ---拖拽开始
    Dragging = 1, ---拖拽中
    DragEnd = 2, ---拖拽结束
    HorizontalReboundEnd = 3, ---水平回弹结束
}

---@class X3DataConst.CommonGestureOperatedModeFunctionFlag CommonGestureOperatedMode 的功能Flag
X3DataConst.CommonGestureOperatedModeFunctionFlag = {
    CommonGestureOperatedModeFunctionNone = 0, ---无
    HorizontalRotate = 1, ---水平旋转
    HorizontalRebound = 2, ---水平回弹
    VerticalRotate = 4, ---垂直旋转
    VerticalRebound = 8, ---垂直回弹
    VerticalMove = 16, ---垂直移动
    Zoom = 32, ---拉近拉远
}

---@class X3DataConst.X3DataTestUsageMessageType  测试proto的类型名枚举
X3DataConst.X3DataTestUsageMessageType = {
    ETypeTestPureProtoTypeData = 0, 
    ETypeRepeatedTestData = 1, 
    ETypeMapTestData = 2, 
    ETypeCombineTestData = 3, 
}
--endregion 枚举类型结束

---@class X3DataConst.X3DataRequire require路径
X3DataConst.X3DataRequire = {
    AccompanyTypeRecord = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Accompany.AccompanyTypeRecord',
    AccompanyDayRecord = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Accompany.AccompanyDayRecord',
    AccompanyYearRecord = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Accompany.AccompanyYearRecord',
    AccompanyRoleRecords = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Accompany.AccompanyRoleRecords',
    AccompanyRoleData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Accompany.AccompanyRoleData',
    AccompanyData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Accompany.AccompanyData',
    Achievement = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Achievement.Achievement',
    Activity = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Activity.Activity',
    ActivityDialogue = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.ActivityDialogue.ActivityDialogue',
    ActivityDiyModel = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.ActivityDIYModel.ActivityDiyModel',
    ActivityGrowUpData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.ActivityGrowUpData.ActivityGrowUpData',
    ActivityTurntableData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.ActivityTurntable.ActivityTurntableData',
    ActivityTurntableDrawCountData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.ActivityTurntable.ActivityTurntableDrawCountData',
    ActivityTurntablePersistentData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.ActivityTurntable.ActivityTurntablePersistentData',
    ARPhotoData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.ARPhotoInfo.ARPhotoData',
    ASMRData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.ASMR.ASMRData',
    ASMRRedPointData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.ASMR.ASMRRedPointData',
    ASMRPersistentData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.ASMR.ASMRPersistentData',
    BattlePassData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.BattlePass.BattlePassData',
    CardData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.CardData.CardData',
    CardLocalImgInfo = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.CardData.CardLocalImgInfo',
    CardManagedData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.CardData.CardManagedData',
    CardPosDataList = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.CardData.CardPosDataList',
    CardManTypeDataList = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.CardData.CardManTypeDataList',
    CardInitAttrData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.CardData.CardInitAttrData',
    CardAttrData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.CardData.CardAttrData',
    CardSuitConfigData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.CardData.CardSuitConfigData',
    CardQuestData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.CardData.CardQuestData',
    CardSuitQuestData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.CardData.CardSuitQuestData',
    OtherSuitPhaseData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.CardData.OtherSuitPhaseData',
    ChargeData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Charge.ChargeData',
    ChargeRecord = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Charge.ChargeRecord',
    DeliverOrder = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Charge.DeliverOrder',
    PayInfo = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Charge.PayInfo',
    Order = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Charge.Order',
    CriticalLogPersistenceInfo = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.CriticalLogPersistenceInfo.CriticalLogPersistenceInfo',
    DailyConfideData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.DailyConfide.DailyConfideData',
    DailyConfideCompleteRecord = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.DailyConfide.DailyConfideCompleteRecord',
    DailyConfideRecord = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.DailyConfide.DailyConfideRecord',
    DatePlanInvitationData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.DatePlan.DatePlanInvitationData',
    DateContent = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.DatePlan.DateContent',
    DateGamePlayData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.DatePlan.DateGamePlayData',
    DateMiaoData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.DatePlan.DateMiaoData',
    DropMultipleData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.DropMultiple.DropMultipleData',
    ActivityDropMultipleData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.DropMultiple.ActivityDropMultipleData',
    PlayerVoice = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Face.PlayerVoice',
    Formation = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Formation.Formation',
    PreFabFormation = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Formation.PreFabFormation',
    GalleryRecord = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Gallery.GalleryRecord',
    GameplayInfo = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Gameplay.GameplayInfo',
    GameplayContinueData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Gameplay.GameplayContinueData',
    GameplayCommonData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Gameplay.GameplayCommonData',
    GemCoreData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.GemCore.GemCoreData',
    GemCore = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.GemCore.GemCore',
    HunterContestSeason = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.HunterContestData.HunterContestSeason',
    HunterContest = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.HunterContestData.HunterContest',
    HunterContestCards = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.HunterContestData.HunterContestCards',
    HunterContestCard = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.HunterContestData.HunterContestCard',
    HunterContestRewardData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.HunterContestData.HunterContestRewardData',
    Item = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Item.Item',
    SpItem = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Item.SpItem',
    Coin = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Item.Coin',
    KnockMoleLevelData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.KnockMole.KnockMoleLevelData',
    KnockMoleHole = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.KnockMole.KnockMoleHole',
    KnockMoleData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.KnockMole.KnockMoleData',
    ConflictedTest = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.LocaleConflictedTest.ConflictedTest',
    LoginData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.LoginData.LoginData',
    LovePointTimeRecord = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.LovePoint.LovePointTimeRecord',
    LovePointRole = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.LovePoint.LovePointRole',
    MailParam = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Mail.MailParam',
    MailRewardItem = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Mail.MailRewardItem',
    Mail = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Mail.Mail',
    DoubleTouchType = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.MainHome.DoubleTouchType',
    MainHomeData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.MainHome.MainHomeData',
    ActionRecord = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.MainHome.ActionRecord',
    MonthCardData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.MonthCard.MonthCardData',
    PhoneContactHead = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PhoneContactData.PhoneContactHead',
    PhoneContactSign = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PhoneContactData.PhoneContactSign',
    PhoneContactMoment = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PhoneContactData.PhoneContactMoment',
    PhoneContactBubble = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PhoneContactData.PhoneContactBubble',
    PhoneContactChatBackground = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PhoneContactData.PhoneContactChatBackground',
    ContactNudge = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PhoneContactData.ContactNudge',
    PhoneContactHeadImgCache = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PhoneContactData.PhoneContactHeadImgCache',
    PhoneContactData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PhoneContactData.PhoneContactData',
    PhoneContact = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PhoneContactData.PhoneContact',
    NudgeInfo = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PhoneMsgData.NudgeInfo',
    PhoneMsgExtraInfo = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PhoneMsgData.PhoneMsgExtraInfo',
    PhoneMsgConversationData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PhoneMsgData.PhoneMsgConversationData',
    PhoneMsgUIItem = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PhoneMsgData.PhoneMsgUIItem',
    PhoneMsgSimulatingData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PhoneMsgData.PhoneMsgSimulatingData',
    PhoneMsgProgressData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PhoneMsgData.PhoneMsgProgressData',
    PhoneMsgDetailData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PhoneMsgData.PhoneMsgDetailData',
    PhoneMsgContactData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PhoneMsgData.PhoneMsgContactData',
    PhoneMsgConditionRecord = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PhoneMsgData.PhoneMsgConditionRecord',
    PhoneMsgData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PhoneMsgData.PhoneMsgData',
    PhotoData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Photo.PhotoData',
    Photo = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Photo.Photo',
    ChooseRecord = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PlayerTag.ChooseRecord',
    PlayerChoose = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PlayerTag.PlayerChoose',
    PlayerRecommendRecord = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PlayerTag.PlayerRecommendRecord',
    PlayerRecommend = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PlayerTag.PlayerRecommend',
    PlayerTagRecord = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PlayerTag.PlayerTagRecord',
    PlayerTag = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PlayerTag.PlayerTag',
    FavoriteRecord = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PlayerTag.FavoriteRecord',
    PlayerFavorite = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.PlayerTag.PlayerFavorite',
    RadioTimeRecord = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Radio.RadioTimeRecord',
    ReturnActivityData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.ReturnActivity.ReturnActivityData',
    SCore = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Score.SCore',
    Card2ScoreCfgData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Score.Card2ScoreCfgData',
    Shop = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Shop.Shop',
    ShopData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Shop.ShopData',
    AnecdoteList = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Story.AnecdoteList',
    AnecdoteItem = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Story.AnecdoteItem',
    AnecdoteSection = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Story.AnecdoteSection',
    AnecdoteContent = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Story.AnecdoteContent',
    LegendList = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Story.LegendList',
    LegendItem = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Story.LegendItem',
    LegendSection = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Story.LegendSection',
    Task = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Task.Task',
    TasksByConditionType = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Task.TasksByConditionType',
    TasksByTaskType = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.Task.TasksByTaskType',
    TrainingRoomRedPointData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.TrainingRoom.TrainingRoomRedPointData',
    UFOCatcherGame = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.UFOCatcherGame.UFOCatcherGame',
    UrlImageData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.UrlImage.UrlImageData',
    VIPChargeData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.VIPCharge.VIPChargeData',
    CommonGestureOperatedModeData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.VitrualCameraMode.CommonGestureOperatedModeData',
    Entry2WorldInfoList = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.WorldIntelligenceData.Entry2WorldInfoList',
    Main2WorldInfoList = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.WorldIntelligenceData.Main2WorldInfoList',
    WorldInfoData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.WorldIntelligenceData.WorldInfoData',
    TestPureProtoTypeData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.X3DataTestUsage.TestPureProtoTypeData',
    RepeatedTestData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.X3DataTestUsage.RepeatedTestData',
    MapTestData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.X3DataTestUsage.MapTestData',
    CombineTestData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.X3DataTestUsage.CombineTestData',
    AssociationTestData = 'Runtime.System.X3Game.Data.X3Data.AutoGenerated.X3DataTestUsage.AssociationTestData',
}

X3DataConst.BasicFieldType = {
    number = 'number',
    string = 'string',
    boolean = 'boolean',
    integer = 'integer',
    float = 'float'
}

X3DataConst.NumberFieldType = {
    number = 'number',
    integer = 'integer',
    float = 'float'
}

X3DataConst.MapOrArrayFieldType = {
    map = 'map',
    array = 'array'
}

---@class X3DataConst.X3DataChangeFlag
X3DataConst.X3DataChangeFlag = {
    Add = 1000,
    Remove = 1001,
    Modify = 1002,
    AddOrRemove = 1003,
    AddOrModify = 1004,
    RemoveOrModify = 1005,
    ALL = 1006
}

---@class X3DataConst.X3DataOperateType
X3DataConst.X3DataOperateType = {
    BasicSet = 1,
    ArrayCopy = 2,
    MapUpdate = 3,
    MapClear = 4
}

---代表数组的最后一个元素的下标
X3DataConst.Last = 1 << 63 - 1

---代表数组的第一个元素的下标
X3DataConst.First = 1
return X3DataConst