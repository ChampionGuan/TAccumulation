--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.DressUp 
---@field  DressUp  table<number,number> @ 当前穿着key:部位枚举 value:FashionId
---@field SuitId number @ 套装Id，不是套装时为0
---@field AutoDressUp boolean @ 是否可以自动换装
---@field DressUpTime number @ 换装时间
local  DressUp  = {}
---@class pbcmessage.Fashion @import "x3x3.proto";
---@field Id number @ 皮肤ID
local  Fashion  = {}
---@class pbcmessage.FashionData 
---@field  RoleFashionMap  table<number,pbcmessage.RoleFashion> @ key:roleId value:男主数据
---@field  FashionMap          table<number,pbcmessage.Fashion> @ 皮肤列表 key:fashionID value：时装
---@field  TypeDressMap        table<number,pbcmessage.DressUp> @ 女主穿戴类型map key:穿戴类型 value：穿戴数据
---@field IsInit boolean @ 是否初始化
local  FashionData  = {}
---@class pbcmessage.FashionUpdateReply @ 主动推送(只需要Reply)
---@field FashionList pbcmessage.Fashion[] 
local  FashionUpdateReply  = {}
---@class pbcmessage.GetFashionDataReply 
---@field Data pbcmessage.FashionData 
local  GetFashionDataReply  = {}
---@class pbcmessage.GetFashionDataRequest 
local  GetFashionDataRequest  = {}
---@class pbcmessage.PlayerDressUpReply 
local  PlayerDressUpReply  = {}
---@class pbcmessage.PlayerDressUpRequest 
---@field Type number 
---@field  DressUp  table<number,number> 
local  PlayerDressUpRequest  = {}
---@class pbcmessage.RoleDressUpReply 
local  RoleDressUpReply  = {}
---@class pbcmessage.RoleDressUpRequest @    rpc GetFashionData(GetFashionDataRequest) returns (GetFashionDataReply) {}               获取时装数据
---@field Role number 
---@field SuitId number 
---@field  DressUp  table<number,number> 
---@field Type number 
local  RoleDressUpRequest  = {}
---@class pbcmessage.RoleDressUpdateReply @ 主动推送(只需要Reply)
---@field RoleFashion pbcmessage.RoleFashion 
---@field AutoDressUp boolean 
local  RoleDressUpdateReply  = {}
---@class pbcmessage.RoleFashion 
---@field RoleId number @ 男主Id
---@field  TypeDressMap  table<number,pbcmessage.DressUp> @ 男主穿戴类型map key:穿戴类型 value：穿戴数据
local  RoleFashion  = {}
---@class pbcmessage.SetRoleAutoDressUpReply 
---@field Role number 
---@field SelfDress boolean 
local  SetRoleAutoDressUpReply  = {}
---@class pbcmessage.SetRoleAutoDressUpRequest 
---@field Role number 
---@field SelfDress boolean 
local  SetRoleAutoDressUpRequest  = {}
