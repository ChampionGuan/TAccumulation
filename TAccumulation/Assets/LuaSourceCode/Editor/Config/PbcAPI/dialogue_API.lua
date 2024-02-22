--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.Dialogue @    DialogueNodeTypeUI        = 6;   UI节点
---@field Stacks number[] @ 堆栈记录列表
---@field CurrentID number @ 当前节点
local  Dialogue  = {}
---@class pbcmessage.DialogueCheck 
---@field DialogueID number @ 剧情id
---@field NodeList pbcmessage.DialogueProcessNode[] @ 剧情校验节点
local  DialogueCheck  = {}
---@class pbcmessage.DialogueData @message DialogueData {                    具体玩法剧情播放记录
---@field  Dialogues  table<number,pbcmessage.Dialogue> @ 剧情数据,key:dialogueID
---@field     Variables  table<number,number> @ 剧情变量记录
local  DialogueData                     = {}
---@class pbcmessage.DialogueProcessNode 
---@field Id number @ 当前节点
---@field NextId number @ 下一个节点
---@field  VariableMap  table<number,number> @ 数据记录
local  DialogueProcessNode  = {}
---@class pbcmessage.DialogueRecord @ 单个剧情节点
---@field Id number @ 当前节点
---@field NextID number @ 下一个节点
local  DialogueRecord  = {}
---@class pbcmessage.DialogueRecordData 
---@field RewardRecords number[] @ 剧情奖励记录
local  DialogueRecordData  = {}
---@class pbcmessage.UpdateDialogueRewardReply @ 推送剧情奖励
---@field RewardItems pbcmessage.S3Int[] @ 奖励列表
local  UpdateDialogueRewardReply  = {}
