--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.GemCore @ 单个芯核数据
---@field Id number @ 唯一实例ID
---@field TblID number @ 配置ID
---@field Level number 
---@field Exp number 
---@field Attrs number[] @ 列表 tblDropID(GemCoreAttrDrop.ID):24,RandCount:8,Val:32
local  GemCore  = {}
---@class pbcmessage.GemCoreBreakReply 
---@field CoreIDs number[] @ 分解成功的id返回
---@field Rewards pbcmessage.S3Int[] @ 分解所得
local  GemCoreBreakReply  = {}
---@class pbcmessage.GemCoreBreakRequest @ 芯核分解
---@field CoreIDs number[] 
local  GemCoreBreakRequest  = {}
---@class pbcmessage.GemCoreData @ 芯核数据
---@field  Cores   table<number,pbcmessage.GemCore> @ key ：唯一ID
---@field seqNum number @ 用于生成唯一ID
---@field  BindCard  table<number,number> @ key:gen val:被装备到cardId  (绑定的毕竟是少数,为节省内存所以放cores外)
---@field  LockCore   table<number,boolean> @ 是否锁定
local  GemCoreData  = {}
---@class pbcmessage.GemCoreLevelUpReply 
---@field UpdatedCore pbcmessage.GemCore @ 升级后芯核数据
---@field CostCoreIDs number[] 
---@field Rewards pbcmessage.S3Int[] @ 溢出经验转化为的经验道具
local  GemCoreLevelUpReply  = {}
---@class pbcmessage.GemCoreLevelUpRequest @ 芯核升级
---@field CoreID number 
---@field Materials pbcmessage.S3Int[] 
local  GemCoreLevelUpRequest  = {}
---@class pbcmessage.GemCoreLockReply 
local  GemCoreLockReply  = {}
---@class pbcmessage.GemCoreLockRequest @ 芯核锁定
---@field CoreID number 
---@field isLock boolean @ true:锁定 false:解锁
local  GemCoreLockRequest  = {}
---@class pbcmessage.GemCoreUpdateReply @ 主动推送(只需要Reply)
---@field UpdatedCore pbcmessage.GemCore @ 芯核数据
local  GemCoreUpdateReply  = {}
---@class pbcmessage.GetGemCoreDataReply 
---@field Data pbcmessage.GemCoreData 
local  GetGemCoreDataReply  = {}
---@class pbcmessage.GetGemCoreDataRequest @    rpc GemCoreBreak(GemCoreBreakRequest) returns (GemCoreBreakReply) {}         装备分解
local  GetGemCoreDataRequest  = {}
