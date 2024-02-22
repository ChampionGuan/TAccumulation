--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.GetSCoreInfoReply 
---@field SCore pbcmessage.SCoreData 
local  GetSCoreInfoReply  = {}
---@class pbcmessage.GetSCoreInfoRequest @ 请求搭档数据
local  GetSCoreInfoRequest  = {}
---@class pbcmessage.SCore @ score struct.
---@field Id number @ ID
---@field SuitID number @ 战斗套装id
---@field CTime number @ 首次获得创建时间
local  SCore  = {}
---@class pbcmessage.SCoreData 
---@field  SCoreMap  table<number,pbcmessage.SCore> 
local  SCoreData  = {}
---@class pbcmessage.SCoreSuitChangeReply 
---@field SCoreId number 
---@field SuitID number 
local  SCoreSuitChangeReply  = {}
---@class pbcmessage.SCoreSuitChangeRequest @ 请求更换搭档皮肤
---@field SCoreId number 
---@field SuitID number 
local  SCoreSuitChangeRequest  = {}
---@class pbcmessage.SCoreUpdateReply @ 主动推送(只需要Reply)
---@field OpType number 
---@field OpReason number 
---@field SCoreList pbcmessage.SCore[] 
local  SCoreUpdateReply  = {}
