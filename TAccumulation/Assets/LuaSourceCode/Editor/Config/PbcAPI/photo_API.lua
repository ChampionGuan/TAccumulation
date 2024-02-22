--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.FashionSet 
---@field  MarkMap  table<number,number> 
local  FashionSet  = {}
---@class pbcmessage.GetPhotoDataReply 
---@field Data pbcmessage.PhotoData 
local  GetPhotoDataReply  = {}
---@class pbcmessage.GetPhotoDataRequest 
local  GetPhotoDataRequest  = {}
---@class pbcmessage.Photo @    Audit_Reject  = 3;   审核未通过
---@field Url string 
---@field TimeStamp number @ 时间戳，个人照片的唯一标识
---@field Status pbcmessage.PhotoStatus 
---@field RoleId number 
---@field GroupMode pbcmessage.PhotoGroup 
---@field Mode number 
---@field PuzzleMode number 
---@field ActionList number[] 
---@field DecorationList number[] 
---@field SourcePhoto pbcmessage.Photo @ 源图片
local  Photo  = {}
---@class pbcmessage.PhotoActionMarkReply 
---@field Timestamp number 
local  PhotoActionMarkReply  = {}
---@class pbcmessage.PhotoActionMarkRequest 
---@field ActionID number 
---@field Mark number 
local  PhotoActionMarkRequest  = {}
---@class pbcmessage.PhotoCheck 
---@field Photo pbcmessage.Photo 
---@field Context number 
local  PhotoCheck  = {}
---@class pbcmessage.PhotoComponentUpdateReply @ 主动推送(只需要Reply)
---@field ComponentList number[] 
local  PhotoComponentUpdateReply  = {}
---@class pbcmessage.PhotoData 
---@field  Photos              table<string,pbcmessage.Photo> @ k:url v:照片信息
---@field LastInsertTime number @ 上次上传时间
---@field  PhotoComponentMap     table<number,boolean> @ 照片组件map
---@field  ActionMarkMap        table<number,number> @ 动作标记列表  key:action id value: mark time
---@field  FashionMarkMap  table<number,pbcmessage.FashionSet> 
---@field  PhotoGroupMap       table<number,string> @ 拍照组合映射表 key:组合id value:照片url
local  PhotoData  = {}
---@class pbcmessage.PhotoDeleteReply 
---@field UrlList string[] 
local  PhotoDeleteReply  = {}
---@class pbcmessage.PhotoDeleteRequest 
---@field UrlList string[] 
local  PhotoDeleteRequest  = {}
---@class pbcmessage.PhotoFashionMarkReply 
---@field Timestamp number 
local  PhotoFashionMarkReply  = {}
---@class pbcmessage.PhotoFashionMarkRequest 
---@field FashionID number 
---@field RoleID number 
---@field Mark number 
local  PhotoFashionMarkRequest  = {}
---@class pbcmessage.PhotoGroupCheckReply 
local  PhotoGroupCheckReply  = {}
---@class pbcmessage.PhotoGroupCheckRequest 
---@field PhotoGroupID number 
---@field PhotoUrl string 
local  PhotoGroupCheckRequest  = {}
---@class pbcmessage.PhotoGroupCheckResultUpdateReply 
---@field PhotoGroupID number 
---@field PhotoUrl string 
---@field IsSuccess boolean 
local  PhotoGroupCheckResultUpdateReply  = {}
---@class pbcmessage.PhotoInsertReply 
---@field PhotoList pbcmessage.Photo[] 
local  PhotoInsertReply  = {}
---@class pbcmessage.PhotoInsertRequest @    rpc PhotoGroupCheck(PhotoGroupCheckRequest) returns (PhotoGroupCheckReply) {}      拍照组合审核请求
---@field PhotoList pbcmessage.Photo[] 
local  PhotoInsertRequest  = {}
---@class pbcmessage.PhotoUpdateReply @ 主动推送(只需要Reply)
---@field Photo pbcmessage.Photo 
local  PhotoUpdateReply  = {}
