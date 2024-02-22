--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.FriendAppliedInfo 
---@field AppliedFriend pbcmessage.SnsBaseData 
---@field AppliedTime number 
local  FriendAppliedInfo  = {}
---@class pbcmessage.FriendApplyAcceptReply 
---@field FriendApplyAcceptList number[] 
local  FriendApplyAcceptReply  = {}
---@class pbcmessage.FriendApplyAcceptRequest 
---@field FriendApplyAcceptList number[] 
local  FriendApplyAcceptRequest  = {}
---@class pbcmessage.FriendApplyRejectReply 
---@field FriendApplyRejectList number[] 
local  FriendApplyRejectReply  = {}
---@class pbcmessage.FriendApplyRejectRequest 
---@field FriendApplyRejectList number[] 
local  FriendApplyRejectRequest  = {}
---@class pbcmessage.FriendApplyReply 
---@field FriendApplyList number[] 
local  FriendApplyReply  = {}
---@class pbcmessage.FriendApplyRequest @    rpc SetIPLocationShow(SetIPLocationShowRequest) returns (SetIPLocationShowReply) {}                        设置-允许其他玩家查看IP属地
---@field FriendApplyList number[] 
local  FriendApplyRequest  = {}
---@class pbcmessage.FriendData @import "x3x3.proto";
---@field FriendMaxNum number @ 历史最大好友数
---@field LastRefreshTime number @ 上次刷新时间
---@field FriendPermission number @ 设置-允许接受好友申请
---@field CardShow boolean @ 设置-允许其他玩家查看羁绊卡详情
---@field PhotoShow boolean @ 设置-允许其他玩家查看照片
---@field IPLocationShow boolean @ 是否显示IP属地
---@field LastCounterUpdateTime number @ 上次更新时间,每天重置时间戳
---@field FriendDailyApplyCount number @ 好友每日申请计数
---@field StaminaSends number[] @ 赠送体力列表
---@field StaminaRecveds number[] @ 收取体力列表
local  FriendData  = {}
---@class pbcmessage.FriendDelReply 
---@field DelFriendList number[] 
local  FriendDelReply  = {}
---@class pbcmessage.FriendDelRequest 
---@field DelFriendList number[] 
local  FriendDelRequest  = {}
---@class pbcmessage.FriendInfo 
---@field  FriendMap               table<number,pbcmessage.SnsBaseData> @ 好友简要信息map key为uid，value为简要信息
---@field  FriendAppliedMap  table<number,pbcmessage.FriendAppliedInfo> @ 被申请好友列表 key为uid，value为简要信息
---@field  StaminaUnRecvMap              table<number,number> @ 可取体力列表 key为uid，value为时间和接收信息
local  FriendInfo  = {}
---@class pbcmessage.FriendInfoUpdateReply 
---@field UpdateInfo pbcmessage.FriendUpdateInfo 
---@field ErrNo pbcmessage.Errno 
local  FriendInfoUpdateReply  = {}
---@class pbcmessage.FriendInfoUpdateRequest @    rpc FriendInfoUpdate(FriendInfoUpdateRequest) returns (FriendInfoUpdateReply) {}   好友信息增量更新
---@field AddFriend pbcmessage.SnsBaseData @ 增加好友
---@field AddAppliedFriend pbcmessage.SnsBaseData @ 增加被申请好友
---@field AddRecvStamina number @ 增加接收体力
---@field DelFriend number @ 删除好友
---@field RejectApply number @ 拒绝好友申请
---@field UpdateTime number @ 操作时间
---@field Uid number @ 目标uid
local  FriendInfoUpdateRequest  = {}
---@class pbcmessage.FriendStaminaRecvReply 
---@field FriendStaminaRecvList number[] 
local  FriendStaminaRecvReply  = {}
---@class pbcmessage.FriendStaminaRecvRequest 
---@field FriendStaminaRecvList number[] 
local  FriendStaminaRecvRequest  = {}
---@class pbcmessage.FriendStaminaSendReply 
---@field FriendStaminaSendList number[] 
local  FriendStaminaSendReply  = {}
---@class pbcmessage.FriendStaminaSendRequest 
---@field FriendStaminaSendList number[] 
local  FriendStaminaSendRequest  = {}
---@class pbcmessage.FriendTotalInfo 
---@field Db pbcmessage.FriendData 
---@field Info pbcmessage.FriendInfo 
local  FriendTotalInfo  = {}
---@class pbcmessage.FriendUpdateInfo 
---@field AddFriend pbcmessage.SnsBaseData @ 增加好友
---@field AddAppliedFriend pbcmessage.FriendAppliedInfo @ 增加被申请好友
---@field AddRecvStamina number @ 增加接收体力
---@field DelFriend number @ 删除好友
---@field RejectApply number @ 拒绝好友申请
local  FriendUpdateInfo  = {}
---@class pbcmessage.FriendsRecommendReply 
---@field  Users  table<number,pbcmessage.SnsBaseData> 
---@field Uids number[] @ 服务器转发使用
local  FriendsRecommendReply  = {}
---@class pbcmessage.FriendsRecommendRequest 
---@field RecommendNum number @ 推荐个数
local  FriendsRecommendRequest  = {}
---@class pbcmessage.GetFriendDataReply 
---@field TotalInfo pbcmessage.FriendTotalInfo 
local  GetFriendDataReply  = {}
---@class pbcmessage.GetFriendDataRequest 
local  GetFriendDataRequest  = {}
---@class pbcmessage.GetFriendSimpleDataReply 
---@field  FriendAppliedMap  table<number,number> @ 被申请好友列表 key为uid，申请时间
---@field  StaminaUnRecvMap  table<number,number> @ 可取体力列表 key为uid，value为时间和接收信息
---@field StaminaRecveds number[] @ 收取体力列表
---@field FriendMaxNum number @ 历史最大好友数
---@field FriendList number[] @ 好友列表
local  GetFriendSimpleDataReply  = {}
---@class pbcmessage.GetFriendSimpleDataRequest 
local  GetFriendSimpleDataRequest  = {}
---@class pbcmessage.QueryBaseInfoReply 
---@field TargetUid number[] 
---@field BaseInfo pbcmessage.SnsBaseData[] 
---@field State number 
---@field Applied number[] @ 申请过好友的
local  QueryBaseInfoReply  = {}
---@class pbcmessage.QueryBaseInfoRequest 
---@field TargetUid number[] 
---@field State number 
local  QueryBaseInfoRequest  = {}
---@class pbcmessage.SetApplyFriendPermissionReply 
local  SetApplyFriendPermissionReply  = {}
---@class pbcmessage.SetApplyFriendPermissionRequest 
---@field FriendPermission number 
local  SetApplyFriendPermissionRequest  = {}
---@class pbcmessage.SetCardShowReply 
local  SetCardShowReply  = {}
---@class pbcmessage.SetCardShowRequest 
---@field CardShow boolean @ 是否显示card
local  SetCardShowRequest  = {}
---@class pbcmessage.SetIPLocationShowReply 
local  SetIPLocationShowReply  = {}
---@class pbcmessage.SetIPLocationShowRequest 
---@field IPLocationShow boolean @ IP属地展示开关
local  SetIPLocationShowRequest  = {}
---@class pbcmessage.SetPhotoShowReply 
local  SetPhotoShowReply  = {}
---@class pbcmessage.SetPhotoShowRequest 
---@field PhotoShow boolean @ 照片大图展示开关
local  SetPhotoShowRequest  = {}
