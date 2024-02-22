--- 全局通用Const声明
--- Created by fusu
--- Created Date: 2023/12/4


local CS_CutSceneEventType = CS.PapeGames.CutScene.CutSceneEventType

CutSceneTag =
{
    Default = 0,
    MainUI = 1,
    SpecialDate = 2,
    Photo = 3,
    Other = 4,
}

CutSceneEventType =
{
    --- 播放前
    BeforePlay = CS_CutSceneEventType.__CastFrom(0),
    --- 开始播放
    Play = CS_CutSceneEventType.__CastFrom(1),
    --- 即将完成
    WillComplete = CS_CutSceneEventType.__CastFrom(2),
    --- 完成
    Complete = CS_CutSceneEventType.__CastFrom(3),
    --- 非自动播放完毕
    Stop = CS_CutSceneEventType.__CastFrom(4),
    --- 关键帧
    KeyFrame = CS_CutSceneEventType.__CastFrom(5),
    --- 播放到结束位置
    ReachEnd = CS_CutSceneEventType.__CastFrom(6),
}


--- CutScene播放模式
CutScenePlayMode =
{
    --- 打断（将当前正在播放的所有CutScene结束掉）
    Break = 0,
    --- 融合过渡（将当前正在播放的CutScene暂停，并丢入暂停队列，走过渡，下次再次播放此CutScene时会从上次进度继续播放）
    Crossfade = 1,
}

DirectorWrapMode =
{
    Hold = 0,
    Loop = 1,
    None = 2
}

EStaticSlot =
{
    Invalid = -1,
    Start = 0, --等于最开始的槽位
    Timeline = 0,
    Gameplay = 1,
    Battle = 2,
}
