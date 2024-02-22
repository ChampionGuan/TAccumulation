--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.ActivityGamePlay @ 男主出游关卡活动
---@field  Details  table<number,pbcmessage.ActivityGamePlayDetail> @ 游戏次数相关数据 key:男主类型, -1为通配
---@field FinishSubID number[] @ 已经完成的关卡id(包含所有男主的)
local  ActivityGamePlay  = {}
---@class pbcmessage.ActivityGamePlayBuyCountReply 
---@field PlayCount number 
---@field BuyCount number 
local  ActivityGamePlayBuyCountReply  = {}
---@class pbcmessage.ActivityGamePlayBuyCountRequest 
---@field ActivityID number 
---@field ManType number 
local  ActivityGamePlayBuyCountRequest  = {}
---@class pbcmessage.ActivityGamePlayDetail 
---@field PlayCount number @ 剩余游戏次数
---@field BuyCount number @ 购买次数
---@field TotalBuyCount number @ 累计总购买次数
---@field LastUpdateTime number @ 上次跨天刷新时间
---@field LastSubID number @ 最后进行的活动关卡id,ActivityGameGroup.ID
local  ActivityGamePlayDetail  = {}
---@class pbcmessage.ActivityGamePlayEnterReply 
---@field PlayCount number 
local  ActivityGamePlayEnterReply  = {}
---@class pbcmessage.ActivityGamePlayEnterRequest 
---@field ActivityID number 
---@field ManType number 
---@field GameID number 
---@field Params number[] 
---@field Version string 
local  ActivityGamePlayEnterRequest  = {}
---@class pbcmessage.ActivityGamePlayInfo @ 出游关卡活动数据
---@field LastUpdateTime number @ 上次跨天刷新时间
---@field  MaleData  table<number,pbcmessage.ActivityGamePlay> @ roleID,ActivityGamePlay
local  ActivityGamePlayInfo  = {}
---@class pbcmessage.ActivityGamePlayUpdateReply 
---@field ActivityID number 
---@field roleID number 
---@field FinishSubID number 
---@field PlayCount number @ 剩余游戏次数
---@field LastSubID number @ 最后进行的活动关卡id,ActivityGameGroup.ID
local  ActivityGamePlayUpdateReply  = {}
