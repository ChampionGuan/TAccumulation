--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.AnnounceCMSConfig 
---@field ID number @ 跑马灯ID
---@field ClientId number 
---@field Type number 
---@field PlatId number[] 
---@field ZoneId number[] 
---@field Seq number 
---@field Title string 
---@field Content string 
---@field ShortTerm number 
---@field ActivityId number 
---@field Extra string 
---@field STime string 
---@field ETime string 
---@field STimeStr string 
---@field ETimeStr string 
local  AnnounceCMSConfig  = {}
---@class pbcmessage.AnnounceCMSConfigGetReply @ 返回跑马灯信息
---@field  Configs  table<number,pbcmessage.AnnounceCMSConfig> 
local  AnnounceCMSConfigGetReply  = {}
---@class pbcmessage.AnnounceCMSConfigGetRequest @ 客户端获取跑马灯请求
local  AnnounceCMSConfigGetRequest  = {}
---@class pbcmessage.AnnounceCMSTable @ 活动CMS配置数据
---@field configs pbcmessage.AnnounceCMSConfig[] 
local  AnnounceCMSTable  = {}
