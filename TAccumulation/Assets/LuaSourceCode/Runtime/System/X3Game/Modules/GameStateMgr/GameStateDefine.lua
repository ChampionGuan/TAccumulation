--- X3@PapeGames
--- GameStateDefine
--- Created by Tungway
--- Created Date: 2020/7/24

---@class GameStateDefine
local GameStateDefine = {}

GameState = {
    --- 第一次启动
    FirstStart = "FirstStart",
    --- 启动状态
    Entry = "Entry",
    --- 资源更新状态
    ResUpdate = "ResUpdate",
    --- 登录/注册状态
    Login = "Login",
    --- 主备进入游戏
    EnterGame = "EnterGame",
    --- 注销状态
    Logout = "Logout",
    --- 重启状态
    Reboot = "Reboot",
    --- 捏脸状态
    FaceEdit = "FaceEdit",
    --- 生成证件照状态
    HeadIcon = "HeadIcon",
    --- 主界面状态
    MainHome = "MainHome",
    --- 离线战斗入口状态
    OfflineBattleEntry = "OfflineBattleEntry",
    --- 战斗状态
    Battle = "Battle",
    --- 约会状态
    Dating = "Dating",
    --- 娃娃机状态
    UFOCatcher = "UFOCatcher",
    --- 喵喵牌状态
    CatCard = "CatCard",
    --- 叠叠乐状态
    BlockTower = "BlockTower",
    --- 拍照状态
    Photo = "Photo",
    --- 约会计划
    DatePlan = "DatePlan",
    --- 主线剧情
    MainStory = "MainStory",
    --- 连麦状态
    DailyPhone = "DailyPhone",
    --- 空场景（测试用）
    Empty = "Empty",
    --- 断线
    Disconnection = "Disconnection",
    --- 断线之后重连状态
    Reconnection = "Reconnection",
    --- 小传avg
    ScoreStoryAvg = "ScoreStoryAvg",
    --- 女主生日活动
    PlayerBirthdayDialogue = "PlayerBirthdayDialogue",
    --- 陪伴
    Accompany = "Accompany",
    ---快速打包
    FastBuild = "FastBuild",
    --- 思念高光时刻
    CardHighLight = "CardHighLight",
    --- 拼图小游戏AVG
    PuzzleGameAvg = "PuzzleGameAvg",
    ---回流活动
    ReturnActivity = "ReturnActivity",
    ---情人节活动状态
    ActivityDialogue = "ActivityDialogue",
}

---state can transition to {...}
GameStateDefine.StateTransitionDict = {
    [GameState.FirstStart] = { GameState.Entry },
    [GameState.Entry] = { GameState.ResUpdate, GameState.Login, GameState.Reconnection, GameState.Reboot },
    [GameState.FastBuild] = { GameState.Entry, GameState.Login, GameState.ResUpdate, GameState.Battle },
    [GameState.ResUpdate] = { GameState.Login, GameState.Reboot, GameState.Entry },
    [GameState.Login] = { GameState.Entry, GameState.EnterGame, GameState.MainHome, GameState.Battle, GameState.Empty, GameState.Reboot, GameState.FaceEdit },
    [GameState.EnterGame] = { GameState.Logout, GameState.Login, GameState.FaceEdit, GameState.MainHome, GameState.Battle, GameState.MainStory, GameState.Disconnection, GameState.PlayerBirthdayDialogue, GameState.ReturnActivity },
    [GameState.Logout] = { GameState.Entry, GameState.Login, GameState.Reboot },
    [GameState.FaceEdit] = { GameState.Logout, GameState.Login, GameState.MainHome, GameState.Battle, GameState.MainStory, GameState.Disconnection },
    [GameState.MainHome] = { GameState.Logout, GameState.Battle, GameState.FaceEdit, GameState.Dating, GameState.BlockTower, GameState.CatCard, GameState.UFOCatcher, GameState.Photo, GameState.MainStory, GameState.DailyPhone, GameState.Empty, GameState.Disconnection, GameState.ScoreStoryAvg, GameState.PlayerBirthdayDialogue, GameState.Accompany, GameState.CardHighLight, GameState.PuzzleGameAvg, GameState.DatePlan, GameState.ReturnActivity, GameState.ActivityDialogue },
    [GameState.OfflineBattleEntry] = { GameState.Battle, GameState.OfflineBattleEntry },
    [GameState.Battle] = { GameState.Logout, GameState.Battle, GameState.Login, GameState.MainHome, GameState.Dating, GameState.BlockTower, GameState.CatCard, GameState.UFOCatcher, GameState.MainStory, GameState.OfflineBattleEntry, GameState.Disconnection },
    [GameState.Dating] = { GameState.Logout, GameState.Login, GameState.MainHome, GameState.Battle, GameState.Disconnection },
    [GameState.BlockTower] = { GameState.Logout, GameState.Login, GameState.MainHome, GameState.Battle, GameState.Disconnection },
    [GameState.UFOCatcher] = { GameState.Logout, GameState.Login, GameState.MainHome, GameState.Battle, GameState.Disconnection, GameState.DatePlan },
    [GameState.CatCard] = { GameState.Empty, GameState.Logout, GameState.Login, GameState.MainHome, GameState.Battle, GameState.Disconnection, GameState.DatePlan },
    [GameState.Reboot] = { GameState.Logout, GameState.Entry, GameState.Disconnection, GameState.Login, GameState.Reconnection },
    [GameState.Photo] = { GameState.Logout, GameState.MainHome, GameState.Disconnection, GameState.DatePlan },
    [GameState.DatePlan] = { GameState.Logout, GameState.MainHome, GameState.Disconnection, GameState.UFOCatcher, GameState.CatCard, GameState.Photo },
    [GameState.MainStory] = { GameState.Logout, GameState.MainHome, GameState.Battle, GameState.Disconnection },
    [GameState.DailyPhone] = { GameState.MainHome, GameState.Logout, GameState.Login, GameState.Disconnection },
    [GameState.Empty] = { GameState.MainHome, GameState.Logout, GameState.Login, GameState.Disconnection, GameState.CatCard },
    [GameState.Disconnection] = { GameState.Entry, GameState.Login, GameState.Reboot },
    [GameState.Reconnection] = { GameState.EnterGame, GameState.MainHome, GameState.Logout, GameState.FaceEdit, GameState.Disconnection },
    [GameState.ScoreStoryAvg] = { GameState.MainHome, GameState.Logout, GameState.Login, GameState.Disconnection },
    [GameState.PlayerBirthdayDialogue] = { GameState.MainHome, GameState.Logout, GameState.Login, GameState.Disconnection, },
    [GameState.Accompany] = { GameState.MainHome, GameState.Logout, GameState.Login, GameState.Disconnection, },
    [GameState.CardHighLight] = { GameState.MainHome, GameState.Logout, GameState.Login, GameState.Disconnection, },
    [GameState.PuzzleGameAvg] = { GameState.MainHome, GameState.Logout, GameState.Login, GameState.Disconnection },
    [GameState.ReturnActivity] = { GameState.MainHome, GameState.Logout, GameState.Login, GameState.Disconnection },
    [GameState.ActivityDialogue] = { GameState.MainHome, GameState.Logout, GameState.Login, GameState.Disconnection },
}
return GameStateDefine