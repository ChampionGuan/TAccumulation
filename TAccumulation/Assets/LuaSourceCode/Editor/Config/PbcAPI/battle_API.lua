--警告 文件内容通过菜单修改  请勿更改--

---@class pbcmessage.BattleEntity @    EGeneral        = 999;   通用的类型，限定关卡使用
---@field EntityID pbcmessage.EntityType @ 战斗实体 1女主 2男主
---@field SCoreID number @ 角色ID，男主有效，女主是0
---@field SuitID number @ 战斗套装ID
---@field CfgID number @ 配置ID，只有限定关卡使用
---@field HP number @ 血量
---@field  Attributes          table<number,number> @ 属性
---@field Level number @ 等级
---@field IsAwake number @ 是否觉醒
---@field WeaponSkinID number @ 女主武器皮肤id
---@field  Skills          table<number,pbcmessage.SkillList> @ key：技能类型(SkillTypeConfig表主键) value：技能列表
---@field  PassiveSkills  table<number,pbcmessage.SkillList> @ key: 对应PassiveSkillType,
---@field BuffList pbcmessage.Buff[] @ Buff列表
local  BattleEntity  = {}
---@class pbcmessage.Buff @option go_package = "witchpb";
---@field ID number @ buffID
---@field Level number @ buff等级
local  Buff  = {}
---@class pbcmessage.CheatInfo @ 便于后面扩展作弊信息
---@field CheatNum number @ 总作弊次数
local  CheatInfo = {}
---@class pbcmessage.DungeonData 
---@field DungeonID number @ 当前战斗副本ID
---@field ScoreSuitID number @ 当前战斗Score的套装ID
---@field Formation pbcmessage.Formation @ 当前战斗阵型
---@field Result pbcmessage.DungeonResult @ 当前战斗结果
---@field EntityList pbcmessage.BattleEntity[] @ 当前战斗实体属性
---@field  Records  table<number,pbcmessage.DungeonRecord> @ 记录当天最近一次男主的战斗记录 key：男主ID
---@field Cheat pbcmessage.CheatInfo @ 作弊信息
local  DungeonData  = {}
---@class pbcmessage.DungeonRecord 
---@field DungeonID number @ 副本ID
---@field ScoreSuitID number @ 男主战斗套装ID
---@field Formation pbcmessage.Formation @ 阵型ID
---@field Result pbcmessage.DungeonResult @ 战斗数据
---@field EndTime number @ 战斗结束时间
local  DungeonRecord  = {}
---@class pbcmessage.DungeonResult 
---@field Result pbcmessage.DungeonResultType @ 0胜利 其他都是失败
---@field BattleTime number @ 战斗持续时间
---@field IsBurst boolean @ 是否爆衫
---@field ResultList pbcmessage.S2Int[] @ 战斗结果 key来自StageCheckData配置(CommonStageEntry.xlsx)
---@field  MonsterResults  table<number,pbcmessage.MonsterResults> @ key:怪物ID， value:怪物的战斗结果
local  DungeonResult  = {}
---@class pbcmessage.MonsterResults @    DungeonResultTypeUnSet   = 999;  未设置战斗结果（初始化时使用，区别默认的0胜利）
---@field ResultList pbcmessage.S2Int[] @ 战斗结果 key来自StageCheckData配置(CommonStageEntry.xlsx)
local  MonsterResults  = {}
---@class pbcmessage.Skill 
---@field ID number @ 技能ID
---@field Level number @ 技能等级
---@field Slot number @ 槽待用
local  Skill  = {}
---@class pbcmessage.SkillList 
---@field Skills pbcmessage.Skill[] @ 技能列表
local  SkillList  = {}
