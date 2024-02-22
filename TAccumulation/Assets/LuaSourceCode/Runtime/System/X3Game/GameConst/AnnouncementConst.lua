---
--- AnnouncementConst
--- 公告常量定义
--- Created by zhanbo.
--- DateTime: 2021/7/7 18:02
---
---@class AnnouncementConst
local AnnouncementConst = {}

AnnouncementConst.Event = {
    SERVER_ANNOUNCEMENT_LIST_REPLY = "SERVER_ANNOUNCEMENT_LIST_REPLY",
    CLIENT_ANNOUNCEMENT_LIST_EMPTY = "CLIENT_ANNOUNCEMENT_LIST_EMPTY",
}

-- 公告类型
AnnouncementConst.AnnouncementType = {
    GAME_OUT_TEXT = 1,
    GAME_OUT_IMAGE = 2,
    GAME_IN_TEXT = 3,
    GAME_IN_TEXT = 4,
    GAME_AD_LINK = 5,
    GAME_IN_BANNER = 6,
    GAME_IN_BANNER_ROUND = 7,
    GAME_IN_SINGLE_IMAGE = 8 --拍脸公告
}

-- 长期短期的标志0长期,1限时
AnnouncementConst.FlagType = {
    LONG = 0,
    TIME_LIMIT = 1
}

-- Url接口相关
AnnouncementConst.LangOfUrl = {
    CN = "zh-cn", --: 简中 （pigeon zh）
    TW = "zh-tw", --: 繁中 （pigeon zh-CHT）
    KO = "ko", --:韩文
    TH = "th", --: 泰文
    EN = "en", --: 英文
    JP = "jp", --: 日文
}

return AnnouncementConst