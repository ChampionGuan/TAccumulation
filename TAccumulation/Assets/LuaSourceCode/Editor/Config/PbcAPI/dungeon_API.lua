--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.BattleRecord @ 战斗记录数据，用于战斗验证
---@field AttackType pbcmessage.EntityDungeonType @ 攻击者类型
---@field AttackID number @ 攻击者ID,怪物的时候表示怪物数值ID，召唤怪的时候表示召唤怪ID，类型是男主和女主的时候未使用
---@field AttackSummonLevel number @ 如果类型是召唤怪的话，表示召唤怪等级
---@field AttackSummonFromType pbcmessage.EntityDungeonType @ 如果类型是召唤怪的话，表示召唤怪来源，只能来源0、1、2
---@field AttackSummonFromID number @ 如果类型是召唤怪并且来源是怪物的时候，表示怪物数值ID
---@field AttackBuffs pbcmessage.S2Int[] @ 攻击者携带Buff列表，S2Int.Id表示BuffID，S2Int.Num表示BuffLevelConfig表的SubKey字段
---@field ReceiveType pbcmessage.EntityDungeonType @ 受击者类型
---@field ReceiveID number @ 受击者ID,怪物的时候表示怪物数值ID，召唤怪的时候表示召唤怪ID，类型是男主和女主的时候未使用
---@field ReceiveSummonLevel number @ 如果类型是召唤怪的话，表示召唤怪等级
---@field ReceiveSummonFromType pbcmessage.EntityDungeonType @ 如果类型是召唤怪的话，表示召唤怪来源，只能来源0、1、2
---@field ReceiveSummonFromID number @  如果类型是召唤怪并且来源是怪物的时候，表示怪物数值ID
---@field ReceiveBuffs pbcmessage.S2Int[] @ 受击者携带Buff列表，S2Int.Id表示BuffID，S2Int.Num表示BuffLevelConfig表的SubKey字段
---@field Skill pbcmessage.S2Int @ 技能，S2Int.Id表示技能ID，S2Int.Num表示技能类型（依据SkillSlotType），技能类型为-1时不参与计算
---@field DamageID number @ 伤害ID
---@field DamageRatio number @ 伤害数值权重百分比
---@field IsCritical boolean @ 是否暴击
---@field ClientDamage number @ 客户端伤害值
---@field IsCore boolean @ 是否破核
local  BattleRecord  = {}
---@class pbcmessage.BattleReview @ 战斗记录数据
---@field Records pbcmessage.BattleRecord[] @ 相同的伤害ID只记录最大伤害的
---@field Statistic pbcmessage.BattleStatistic[] @ 技能次数统计和累计伤害
local  BattleReview  = {}
---@class pbcmessage.BattleStatistic @ 战斗统计数据，用于战斗验证
---@field SkillID number @ 技能ID
---@field Count number @ 统计计数
---@field AccDamage number @ 累计伤害
local  BattleStatistic  = {}
---@class pbcmessage.DungeonCreateUpdateReply @ 主动推送(只需要Reply) 创建战斗的时候会推送
---@field DungeonID number @ 副本ID battleLevelConfig表的主键
---@field EntityList pbcmessage.BattleEntity[] @ 战斗数据
---@field Tag pbcmessage.DungeonTag @ tag信息
---@field Affixes pbcmessage.Skill[] @ 关卡词缀(被动技能)
---@field StageID number @ 关卡ID commonStageEntry表的主键
local  DungeonCreateUpdateReply  = {}
---@class pbcmessage.DungeonEndReply 
---@field Result pbcmessage.FinStageResult @ 用于战斗关卡结算
local  DungeonEndReply  = {}
---@class pbcmessage.DungeonEndRequest 
---@field Result pbcmessage.DungeonResult @ 战斗结果
---@field Review pbcmessage.BattleReview @ 战斗验证数据
local  DungeonEndRequest  = {}
---@class pbcmessage.DungeonRecordUpdateReply 
---@field RoleID number @ 男主ID
---@field Record pbcmessage.DungeonRecord @ 战斗记录
local  DungeonRecordUpdateReply  = {}
---@class pbcmessage.DungeonTag @ tag 信息
---@field ScoreTags number[] @ score的Tag列表
---@field StageTags number[] @ 关卡的Tag列表
---@field TipsShow boolean @ true：显示提示 false：不显示提示
local  DungeonTag  = {}
