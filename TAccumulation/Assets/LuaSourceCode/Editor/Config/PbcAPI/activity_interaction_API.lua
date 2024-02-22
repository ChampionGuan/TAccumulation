--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.ActivityInteraction @ 3D互动活动
---@field IDs number[] @ 交互id
local  ActivityInteraction  = {}
---@class pbcmessage.ActivityInteractionEndReply 
local  ActivityInteractionEndReply  = {}
---@class pbcmessage.ActivityInteractionEndRequest 
---@field ActivityID number 
---@field InteractionID number 
---@field Result number @ 0:失败,1:成功
---@field QteSec number @ qte 用的时间秒
local  ActivityInteractionEndRequest  = {}
---@class pbcmessage.ActivityInteractionStartReply 
local  ActivityInteractionStartReply  = {}
---@class pbcmessage.ActivityInteractionStartRequest 
---@field ActivityID number 
---@field InteractionID number 
local  ActivityInteractionStartRequest  = {}
