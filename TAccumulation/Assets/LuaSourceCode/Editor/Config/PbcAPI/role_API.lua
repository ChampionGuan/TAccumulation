--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.DiaryOption @import "x3x3.proto";
---@field  PieceMap  table<number,pbcmessage.RoleDiaryPiece> 
---@field DialogueChoices number[] 
local  DiaryOption  = {}
---@class pbcmessage.GetRoleBaseDataReply 
---@field Data pbcmessage.RoleBase 
local  GetRoleBaseDataReply  = {}
---@class pbcmessage.GetRoleBaseDataRequest 
local  GetRoleBaseDataRequest  = {}
---@class pbcmessage.LPLevelReward 
---@field LPLevel number 
---@field LPLevelRewardList pbcmessage.S3Int[] 
local  LPLevelReward  = {}
---@class pbcmessage.Role @ role struct.
---@field Id number @ 男主ID
---@field LoveLevel number @ 好感度等级
---@field LovePoint number @ 好感度点
---@field KnewTime number @ 相识时间
---@field  DiaryMap     table<number,pbcmessage.RoleDiary> @ 日记列表
---@field Status number @ 状态，1：解锁
---@field  LvUpRewards  table<number,pbcmessage.S3IntList> @ key: love level value: 奖励
local  Role  = {}
---@class pbcmessage.RoleBase 
---@field  RoleMap             table<number,pbcmessage.Role> @ 男主Base信息
---@field LoveDefRoleId number @ 亲密度默认男主
---@field IsInit boolean @ 初始化标志
---@field  PieceMap  table<number,pbcmessage.RoleDiaryPiece> @ 日记碎片
local  RoleBase  = {}
---@class pbcmessage.RoleDiary 
---@field DiaryID number @ 日志ID
---@field CreateTime number @ 获得时间
---@field Favorite boolean @ 是否最爱
---@field DialogueChoices number[] @ Dialogue 选项
---@field  PieceMap  table<number,pbcmessage.RoleDiaryPiece> @ 日记碎片
local  RoleDiary  = {}
---@class pbcmessage.RoleDiaryFavoriteReply 
local  RoleDiaryFavoriteReply  = {}
---@class pbcmessage.RoleDiaryFavoriteRequest 
---@field DiaryID number 
---@field Favorite boolean 
local  RoleDiaryFavoriteRequest  = {}
---@class pbcmessage.RoleDiaryPiece 
---@field ID number 
---@field DialogueChoices number[] @ Dialogue 选项
---@field CreateTime number @ 获得时间
local  RoleDiaryPiece  = {}
---@class pbcmessage.RoleDiaryUpdateReply @ 主动推送(只需要Reply)
---@field ManID number 
---@field Diary pbcmessage.RoleDiary 
local  RoleDiaryUpdateReply  = {}
---@class pbcmessage.RoleLevelUpRewardReply 
---@field ManID number 
---@field RewardList pbcmessage.LPLevelReward[] 
local  RoleLevelUpRewardReply  = {}
---@class pbcmessage.RoleLoveLevelUpRewardsReply 
---@field RoleID number 
---@field LoveLevel number 
---@field Rewards pbcmessage.S3Int[] 
local  RoleLoveLevelUpRewardsReply  = {}
---@class pbcmessage.RoleUpdateReply @ 主动推送(只需要Reply)
---@field  RoleMap  table<number,pbcmessage.Role> 
local  RoleUpdateReply  = {}
---@class pbcmessage.SetLoveDefRoleReply 
local  SetLoveDefRoleReply  = {}
---@class pbcmessage.SetLoveDefRoleRequest 
---@field RoleId number 
local  SetLoveDefRoleRequest  = {}
---@class pbcmessage.UpdateRoleLoveDataReply 
---@field RoleID number 
---@field LoveLevel number 
---@field LovePoint number 
local  UpdateRoleLoveDataReply  = {}
