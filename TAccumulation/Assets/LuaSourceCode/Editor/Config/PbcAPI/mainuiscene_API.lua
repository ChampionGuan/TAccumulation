--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.GetMainUISceneInfoReply 
---@field Scene pbcmessage.MainUISceneData @ 场景数据
local  GetMainUISceneInfoReply  = {}
---@class pbcmessage.GetMainUISceneInfoRequest @    rpc MainUISetCurPlace(MainUISetCurPlaceRequest) returns (MainUISetCurPlaceReply) {}            设置当前地点ID
local  GetMainUISceneInfoRequest  = {}
---@class pbcmessage.MainUISceneData @ 玩家第一次获取场景（初始化）的时候设置场景对应地点的默认的场景ID；后续获得场景的时候不设置默认场景
---@field  SceneMap             table<number,number> @ 解锁的主界面场景 key:场景ID value:数量
---@field CurScenePlaceID number @ 当前场景地点，初始化的时候设置默认的
---@field  PlaceMap  table<number,pbcmessage.MainUIScenePlace> @ key:地点ID value:场景昼夜变化信息
local  MainUISceneData  = {}
---@class pbcmessage.MainUIScenePlace @ 主界面场景变化
---@field Status pbcmessage.MainUISceneChangeStatus @ 场景开关
---@field HandedSceneID number @ 手动设置的场景ID
local  MainUIScenePlace  = {}
---@class pbcmessage.MainUISceneUpdateReply @ 主动推送(只需要Reply) 更新主界面场景
---@field Scene pbcmessage.MainUISceneData @ 场景数据
local  MainUISceneUpdateReply  = {}
---@class pbcmessage.MainUISetCurPlaceReply 
local  MainUISetCurPlaceReply  = {}
---@class pbcmessage.MainUISetCurPlaceRequest 
---@field CurPlaceID number 
local  MainUISetCurPlaceRequest  = {}
---@class pbcmessage.MainUISetPlaceSceneReply 
local  MainUISetPlaceSceneReply  = {}
---@class pbcmessage.MainUISetPlaceSceneRequest 
---@field PlaceID number 
---@field SceneID number 
local  MainUISetPlaceSceneRequest  = {}
---@class pbcmessage.MainUISetPlaceStatusReply 
local  MainUISetPlaceStatusReply  = {}
---@class pbcmessage.MainUISetPlaceStatusRequest 
---@field PlaceID number 
---@field Status pbcmessage.MainUISceneChangeStatus @ 场景开关
local  MainUISetPlaceStatusRequest  = {}
