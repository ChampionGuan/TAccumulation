--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.SnsBaseData @ SnsBaseData 玩家简单的个人信息 一般用于展现在列表
---@field Uid number @ UID
---@field Level number @ 等级
---@field Name string @ 名
---@field FamilyName string @ 姓
---@field FrameID number @ 头像框
---@field TitlePrefix number @ 称号
---@field TitleSuffix number @ 称号
---@field TitleBg number @ 称号
---@field StandaloneTitle number @ 独立称号
---@field Desc string @ 个人介绍
---@field Head pbcmessage.PersonalHead @ 头像信息
---@field KneadFaceUrl string @ 捏脸头像url
---@field LastLoginTime number @ 上一次登录的时间
---@field LastOfflineTime number @ 上一次下线的时间
---@field DelTime number @ 注销时间
---@field IPLocationShow boolean @ 是否显示IP属地
---@field IPLocation number @ IP属地
---@field LastUpdateTime number @ 最后一次同步时间
local  SnsBaseData  = {}
---@class pbcmessage.SnsBaseDataMap 
---@field  SnsBaseDatas  table<number,pbcmessage.SnsBaseData> 
local  SnsBaseDataMap  = {}
---@class pbcmessage.SnsCacheData 
---@field Base pbcmessage.SnsBaseData 
---@field Extra pbcmessage.SnsExtraData 
local  SnsCacheData  = {}
---@class pbcmessage.SnsCard 
---@field Id number @ ID
---@field Level number @ 等级
---@field Exp number @ 卡经验
---@field StarLevel number @ 卡星级
---@field PhaseLevel number @ 品阶
---@field Awaken pbcmessage.AwakenStatus @ 觉醒状态
---@field GemCores pbcmessage.GemCore[] @ 芯核
local  SnsCard  = {}
---@class pbcmessage.SnsExtraData 
---@field CreateTime number @ 创建时间
---@field CardShow boolean @ 是否显示card
---@field  CardMap     table<number,pbcmessage.SnsCard> @ idx -> Card 羁绊卡
---@field  SuitPhase     table<number,number> @ 展示思念相关,且激活的套装品阶
---@field CoverUrl string @ 封面url
---@field PhotoShow boolean @ 是否显示photo
---@field  PhotoMap     table<number,string> @ idx -> PhotoUrl
---@field KneadfaceData pbcmessage.SnsKneadfaceData @ 捏脸信息
---@field TotalLovePoint number @总牵绊度
local  SnsExtraData  = {}
---@class pbcmessage.SnsKneadfaceData 
---@field  EditDataKneadface  table<number,number> @ 捏脸数据:客户端透传数据 长度限制 600个元素
local  SnsKneadfaceData  = {}
