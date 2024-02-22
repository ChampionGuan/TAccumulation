--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.CheckExpireFramesReply 
local  CheckExpireFramesReply  = {}
---@class pbcmessage.CheckExpireFramesRequest 
local  CheckExpireFramesRequest  = {}
---@class pbcmessage.Frame @ [头像框策划案](depotx3策划文档系统个人信息个人信息系统.xlsx)
---@field FrameID number @ 头像ID
---@field CreateTime number @ 创建时间
---@field ExpireTime number @ 失效时间戳(0代表永久不失效)
local  Frame  = {}
---@class pbcmessage.FrameData 
---@field FrameID number @ 当前头像ID
---@field  FrameMap  table<number,pbcmessage.Frame> @ 头像列表
---@field IsInit boolean 
local  FrameData  = {}
---@class pbcmessage.FrameUpdateReply @ 更新主动推送(只需要Reply)
---@field OpType number 
---@field FrameID number 
---@field FrameList pbcmessage.Frame[] 
local  FrameUpdateReply  = {}
---@class pbcmessage.GetFrameDataReply 
---@field Frame pbcmessage.FrameData 
local  GetFrameDataReply  = {}
---@class pbcmessage.GetFrameDataRequest @    rpc CheckExpireFrames(CheckExpireFramesRequest) returns (CheckExpireFramesReply) {}   客户端触发让服务器检查过期的头像框
local  GetFrameDataRequest  = {}
---@class pbcmessage.SetFrameIDReply 
local  SetFrameIDReply  = {}
---@class pbcmessage.SetFrameIDRequest 
---@field FrameID number 
local  SetFrameIDRequest  = {}
