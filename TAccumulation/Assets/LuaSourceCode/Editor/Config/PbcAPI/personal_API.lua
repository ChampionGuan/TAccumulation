--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.GetPersonalDataReply 
---@field Personal pbcmessage.PersonalData 
local  GetPersonalDataReply  = {}
---@class pbcmessage.GetPersonalDataRequest @    rpc SetPersonalIPLocation(SetPersonalIPLocationRequest) returns (SetPersonalIPLocationReply) {}   设置新IPLocation信息
local  GetPersonalDataRequest  = {}
---@class pbcmessage.HeadIcon 
---@field ID number @ 头像ID
---@field CreateTime number @ 创建时间
local  HeadIcon  = {}
---@class pbcmessage.HeadIconUpdateReply @ 更新主动推送(只需要Reply)
---@field OpType number 
---@field List pbcmessage.HeadIcon[] 
local  HeadIconUpdateReply  = {}
---@class pbcmessage.PersonalCover 
---@field Cover pbcmessage.Photo 
local  PersonalCover  = {}
---@class pbcmessage.PersonalData 
---@field Desc string @ 个人介绍
---@field  CardMap                              table<number,number> @ Index, CardId 羁绊卡设置
---@field Head pbcmessage.PersonalHead @ 头像信息
---@field Cover pbcmessage.PersonalCover @ 封面照片
---@field  PhotoMap                 table<number,pbcmessage.PersonalShowPhoto> @ Index, 照片展示 设置
---@field IPLocation number @ IP属地
---@field  HeadIconMap                       table<number,pbcmessage.HeadIcon> @ 拥有的HeadIcon
---@field  LastAuditPermitPhotoMap  table<number,pbcmessage.PersonalShowPhoto> @ Index, 照片展示:上次过审展示照片
local  PersonalData  = {}
---@class pbcmessage.PersonalHead @import "x3x3.proto";
---@field Type number @ 头像信息 0:默认头像 1:表示 Card 头像 2:表示照片头像 3:娃娃 4:喵呜徽章 5:新增头像itemtype
---@field CardId number @ CardID(羁绊卡)
---@field HeadPhoto pbcmessage.Photo @ 照片
---@field HistoryPhoto pbcmessage.Photo[] @ 历史照片列表
---@field LastSetTime number @ 上次修改时间
---@field DollID number @ 娃娃
---@field MiaoCardID number @ 喵呜徽章
---@field HeadIconID number @ 新增头像itemtype
local  PersonalHead  = {}
---@class pbcmessage.PersonalShowPhoto 
---@field Url string 
---@field LastSetTime number @ 上次修改时间
---@field Status pbcmessage.PhotoStatus 
---@field RoleId number @ 男主
---@field GroupMode pbcmessage.PhotoGroup @ 合照模式
local  PersonalShowPhoto  = {}
---@class pbcmessage.SetPersonalCardMapReply 
local  SetPersonalCardMapReply  = {}
---@class pbcmessage.SetPersonalCardMapRequest 
---@field  CardMap  table<number,number> 
local  SetPersonalCardMapRequest  = {}
---@class pbcmessage.SetPersonalCoverReply 
local  SetPersonalCoverReply  = {}
---@class pbcmessage.SetPersonalCoverRequest 
---@field CoverPhoto pbcmessage.Photo 
---@field CardID number 
local  SetPersonalCoverRequest  = {}
---@class pbcmessage.SetPersonalDescReply 
local  SetPersonalDescReply  = {}
---@class pbcmessage.SetPersonalDescRequest 
---@field Desc string @ 个人介绍
local  SetPersonalDescRequest  = {}
---@class pbcmessage.SetPersonalHeadReply 
local  SetPersonalHeadReply  = {}
---@class pbcmessage.SetPersonalHeadRequest 
---@field Type number 
---@field CardId number 
---@field HeadPhoto pbcmessage.Photo 
---@field HistoryIndex number @ 替换的历史头像索引
---@field DollID number 
---@field MiaoCardID number 
---@field HeadIconID number 
local  SetPersonalHeadRequest  = {}
---@class pbcmessage.SetPersonalIPLocationReply 
local  SetPersonalIPLocationReply  = {}
---@class pbcmessage.SetPersonalIPLocationRequest 
---@field IPLocation number 
local  SetPersonalIPLocationRequest  = {}
---@class pbcmessage.SetPersonalPhotoMapReply 
local  SetPersonalPhotoMapReply  = {}
---@class pbcmessage.SetPersonalPhotoMapRequest 
---@field  PhotoMap  table<number,pbcmessage.Photo> 
local  SetPersonalPhotoMapRequest  = {}
---@class pbcmessage.UpdatePersonalCoverReply 
---@field Cover pbcmessage.PersonalCover 
local  UpdatePersonalCoverReply  = {}
---@class pbcmessage.UpdatePersonalHeadReply 
---@field Head pbcmessage.PersonalHead 
local  UpdatePersonalHeadReply  = {}
---@class pbcmessage.UpdatePersonalPhotoShowReply 
---@field  PhotoMap                 table<number,pbcmessage.PersonalShowPhoto> @ Index, 照片展示 设置
---@field  LastAuditPermitPhotoMap  table<number,pbcmessage.PersonalShowPhoto> @ Index, 照片展示:上次过审展示照片
local  UpdatePersonalPhotoShowReply  = {}
