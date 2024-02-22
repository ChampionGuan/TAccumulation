--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.BuyEnterCountReply 
local  BuyEnterCountReply  = {}
---@class pbcmessage.BuyEnterCountRequest 
---@field DailyDateId number 
---@field ManID number 
---@field CostTicket pbcmessage.S3Int[] @ 使用关联次数券列表
local  BuyEnterCountRequest  = {}
---@class pbcmessage.DailyDateData @ 日常约会
---@field  DifficultRewards  table<number,boolean> @ 难度解锁奖励领取记录, key: GameDifficultyType id
local  DailyDateData  = {}
---@class pbcmessage.EnterDailyDateReply 
local  EnterDailyDateReply  = {}
---@class pbcmessage.EnterDailyDateRequest @    rpc BuyEnterCount(BuyEnterCountRequest) returns (BuyEnterCountReply) {}      购买进入次数
---@field DailyDateId number 
---@field SubId number 
---@field Men number[] 
---@field Version string 
local  EnterDailyDateRequest  = {}
