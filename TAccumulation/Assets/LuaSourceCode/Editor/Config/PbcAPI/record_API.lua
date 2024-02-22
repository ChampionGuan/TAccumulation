--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.CustomRecord 
---@field SubIDs number[] @ 子键列表
---@field Value number @ 具体记录数据
---@field LastRefreshTime number @ 上次刷新时间戳
local  CustomRecord  = {}
---@class pbcmessage.CustomRecordGroup 
---@field Records pbcmessage.CustomRecord[] @ 数据记录列表
local  CustomRecordGroup  = {}
---@class pbcmessage.CustomRecordUpdateReply @ 主动推送(只需要Reply) 更新单个定时刷新数据
---@field CustomRecordType pbcmessage.DataSaveCustomType 
---@field Record pbcmessage.CustomRecord 
local  CustomRecordUpdateReply  = {}
---@class pbcmessage.Record @    DataSaveCustomTypeReturnStageDoubleDrop = 9;   回流关卡双倍掉落次数统计（刷新周期内）
---@field Value number @ 具体记录数据
---@field Args number[] @ 特殊参数记录
---@field SubIDs number[] @ 子键列表
local  Record  = {}
---@class pbcmessage.RecordClearReply @ 删除单个记录
---@field RefreshType number 
---@field SaveType number 
---@field SubIDs number[] 
local  RecordClearReply  = {}
---@class pbcmessage.RecordData @ 玩家数据记录
---@field  RecordGroups        table<number,pbcmessage.RecordGroup> @ 所有数据记录, key:刷新类型：RefreshType
---@field  CustomGroups  table<number,pbcmessage.CustomRecordGroup> @ 所有定制刷新记录, key:数据类型：DataSaveCustomType
local  RecordData  = {}
---@class pbcmessage.RecordGroup 
---@field  SubGroups  table<number,pbcmessage.RecordSubGroup> @ 记录列表, key: DataSaveRecordType, DataSaveType
---@field LastRefreshTime number @ 上次刷新时间
local  RecordGroup  = {}
---@class pbcmessage.RecordGroupUpdateReply @ 主动推送(只需要Reply) 更新group记录
---@field RefreshType number 
---@field RecordGroup pbcmessage.RecordGroup 
local  RecordGroupUpdateReply  = {}
---@class pbcmessage.RecordSubGroup 
---@field Records pbcmessage.Record[] @ record记录列表
local  RecordSubGroup  = {}
---@class pbcmessage.RecordUpdateReply @ 主动推送(只需要Reply) 更新单个记录
---@field RefreshType number 
---@field SaveType number 
---@field Record pbcmessage.Record 
local  RecordUpdateReply  = {}
