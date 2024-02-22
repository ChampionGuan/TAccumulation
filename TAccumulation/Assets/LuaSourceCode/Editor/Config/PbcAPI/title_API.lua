--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.GetTitleDataReply 
---@field Title pbcmessage.TitleData 
local  GetTitleDataReply  = {}
---@class pbcmessage.GetTitleDataRequest @    rpc SetTitleID(SetTitleIDRequest) returns (SetTitleIDReply) {}         设置称号(独立称号和组合称号)
local  GetTitleDataRequest  = {}
---@class pbcmessage.SetTitleIDReply 
local  SetTitleIDReply  = {}
---@class pbcmessage.SetTitleIDRequest 
---@field TitlePrefix number 
---@field TitleSuffix number 
---@field TitleBg number 
---@field StandaloneTitle number 
local  SetTitleIDRequest  = {}
---@class pbcmessage.Title @ 称号(独立称号和组合称号)
---@field TitleID number @ 称号ID
---@field CreateTime number @ 称号创建时间
local  Title  = {}
---@class pbcmessage.TitleData 
---@field TitlePrefix number @ 组合称号前缀
---@field TitleSuffix number @ 组合称号后缀
---@field TitleBg number @ 组合称号背景
---@field  TitleMap  table<number,pbcmessage.Title> @ 称号列表(独立称号和组合称号)
---@field StandaloneTitle number @ 独立称号
local  TitleData  = {}
---@class pbcmessage.TitleUpdateReply @ 更新主动推送(只需要Reply)
---@field OpType number 
---@field TitleList pbcmessage.Title[] 
local  TitleUpdateReply  = {}
