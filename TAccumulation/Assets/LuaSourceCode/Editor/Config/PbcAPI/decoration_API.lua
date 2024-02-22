--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.CollectPrefabUpdateReply @ 主动推送(只需要Reply) 解锁、保存、装备的时候推送
---@field RoleID number @ 角色
---@field InUsePrefab number 
---@field PrefabData pbcmessage.DecorationPrefabData @ 该字段为空时不要清除本地数据
---@field PushType number @ 0:解锁 1:保存 2:装备
local  CollectPrefabUpdateReply  = {}
---@class pbcmessage.CollectionDecoration @ 摆件
---@field ID number 
---@field X number 
---@field Y number 
---@field GUID number 
---@field InteractiveState number @ 交互状态
local  CollectionDecoration  = {}
---@class pbcmessage.CollectionPendant @ 挂饰
---@field ID number 
---@field X number 
---@field Y number 
---@field R number @ 旋转
---@field GUID number 
---@field InteractiveState number @ 交互状态
local  CollectionPendant  = {}
---@class pbcmessage.CollectionSetUpdateReply @ 主动推送(只需要Reply)
---@field Role number 
---@field CollectionDecorationList pbcmessage.CollectionDecoration[] @ 摆件位置
---@field CollectionPendantList pbcmessage.CollectionPendant[] @ 挂饰位置
local  CollectionSetUpdateReply  = {}
---@class pbcmessage.Decoration 
---@field ID number 
---@field URL string @ 装修自定义Icon
local  Decoration  = {}
---@class pbcmessage.DecorationData 
---@field  RoleDecorationMap  table<number,pbcmessage.DecorationRoleData> @ 角色藏品信息 key: roleID, value: 装修信息
---@field  DecorationInfoMap          table<number,pbcmessage.Decoration> @ 装修物品信息 key: id
local  DecorationData  = {}
---@class pbcmessage.DecorationPrefabData 
---@field Id number 
---@field Url string 
---@field  DecorationMap                       table<number,number> @ 装修信息
---@field CollectionDecorationList pbcmessage.CollectionDecoration[] @ 摆件位置
---@field CollectionPendantList pbcmessage.CollectionPendant[] @ 挂饰位置
---@field Name string 
local  DecorationPrefabData  = {}
---@class pbcmessage.DecorationPrefabNameReply 
local  DecorationPrefabNameReply  = {}
---@class pbcmessage.DecorationPrefabNameRequest @ 保存自定义名字
---@field RoleID number 
---@field Id number 
---@field Name string 
local  DecorationPrefabNameRequest  = {}
---@class pbcmessage.DecorationPrefabOnReply 
local  DecorationPrefabOnReply  = {}
---@class pbcmessage.DecorationPrefabOnRequest @ 更新藏品数据并推送
---@field RoleID number 
---@field Id number 
local  DecorationPrefabOnRequest  = {}
---@class pbcmessage.DecorationPrefabSaveReply 
local  DecorationPrefabSaveReply  = {}
---@class pbcmessage.DecorationPrefabSaveRequest @ 保存服务器快照数据并推送
---@field RoleID number 
---@field Id number 
---@field Url string 
local  DecorationPrefabSaveRequest  = {}
---@class pbcmessage.DecorationPrefabUnlockReply 
local  DecorationPrefabUnlockReply  = {}
---@class pbcmessage.DecorationPrefabUnlockRequest 
---@field RoleID number 
---@field Id number 
local  DecorationPrefabUnlockRequest  = {}
---@class pbcmessage.DecorationRoleData 
---@field  DecorationMap                       table<number,number> @ 装修信息
---@field CollectionDecorationList pbcmessage.CollectionDecoration[] @ 摆件位置
---@field CollectionPendantList pbcmessage.CollectionPendant[] @ 挂饰位置
---@field  DecorationPrefabMap   table<number,pbcmessage.DecorationPrefabData> @ 预设数据 key: id, 与客户端约定从 1开始递增
---@field InUsePrefab number @ 使用中的预设id  保存、装备后更新；设置藏品信息时清空
local  DecorationRoleData  = {}
---@class pbcmessage.DecorationUpdateReply @ 主动推送(只需要Reply)
---@field Role number 
---@field OpType number 
---@field  DecorationMap  table<number,number> 
local  DecorationUpdateReply  = {}
---@class pbcmessage.GetDecorationDataReply 
---@field Decoration pbcmessage.DecorationData 
local  GetDecorationDataReply  = {}
---@class pbcmessage.GetDecorationDataRequest @    rpc DecorationPrefabName(DecorationPrefabNameRequest) returns (DecorationPrefabNameReply) {}                  预设名字
local  GetDecorationDataRequest  = {}
---@class pbcmessage.NewDecorationUpdateReply @ 主动推送(只需要Reply)
---@field DecorationList pbcmessage.Decoration[] 
local  NewDecorationUpdateReply  = {}
---@class pbcmessage.SetCollectionReply 
local  SetCollectionReply  = {}
---@class pbcmessage.SetCollectionRequest 
---@field RoleID number 
---@field CollectionDecorationList pbcmessage.CollectionDecoration[] @ 摆件位置
---@field CollectionPendantList pbcmessage.CollectionPendant[] @ 挂饰位置
local  SetCollectionRequest  = {}
---@class pbcmessage.SetDecorationReply 
local  SetDecorationReply  = {}
---@class pbcmessage.SetDecorationRequest 
---@field RoleID number 
---@field IDList number[] @ 装修项目
local  SetDecorationRequest  = {}
