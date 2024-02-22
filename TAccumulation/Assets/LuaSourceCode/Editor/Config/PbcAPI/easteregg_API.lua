--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.EasterEgg 
---@field ID number @ 彩蛋ID
---@field CounterNum number @ Counter计数(仅服务器使用)
---@field LastCounterTime number @ 上次Counter计数时间(仅服务器使用)
---@field TriggerNum number @ 已触发次数
---@field EffectTime number @ 生效时间(> 0 已生效)
---@field ReEffectTime number @ 再次生效时间
---@field HasRewarded pbcmessage.//bool @ 奖励是否已领取
---@field HasMailRewarded pbcmessage.//bool @ 邮件奖励是否已发送
local  EasterEgg  = {}
---@class pbcmessage.EasterEggData @ [彩蛋相关文档导航](https:papergames.feishu.cndocxDgjKd8xYnoxjGIxg7sQcYmnbnlh)
---@field  Eggs              table<number,pbcmessage.EasterEgg> @ 彩蛋
---@field  CounterExtras  table<number,pbcmessage.CounterExtra> @ counter附加数据
---@field LastRefreshTime number @ 上次刷新时间
---@field      RewardEggs         table<number,boolean> @ 奖励彩蛋
local  EasterEggData  = {}
---@class pbcmessage.EasterEggEffectInfo 
---@field Egg pbcmessage.EasterEgg @ 彩蛋信息
---@field RewardList pbcmessage.S3Int[] @ 奖励
local  EasterEggEffectInfo  = {}
---@class pbcmessage.EasterEggEffectReply @ 客户端彩蛋生效信息返回  服务器彩蛋生效推送
---@field Eggs pbcmessage.EasterEggEffectInfo[] 
local  EasterEggEffectReply  = {}
---@class pbcmessage.EasterEggEffectRequest @    rpc EasterEggTrigger(EasterEggTriggerRequest) returns (EasterEggTriggerReply) {}   彩蛋触发
---@field EffectiveEggIDs number[] @ 生效彩蛋ID
---@field IneffectiveEggIDs number[] @ 失效彩蛋ID
local  EasterEggEffectRequest  = {}
---@class pbcmessage.EasterEggTriggerInfo 
---@field EggID number @ 彩蛋ID
---@field Num number @ 次数
local  EasterEggTriggerInfo  = {}
---@class pbcmessage.EasterEggTriggerReply 
---@field Eggs pbcmessage.EasterEgg[] @ 彩蛋信息
local  EasterEggTriggerReply  = {}
---@class pbcmessage.EasterEggTriggerRequest 
---@field Eggs pbcmessage.EasterEggTriggerInfo[] 
local  EasterEggTriggerRequest  = {}
