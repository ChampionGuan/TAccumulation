﻿---@class cfg.MaleActorConfig  excel名称:BattleActor.xlsx
---@field ActiveSkillIDs int[] 主动技能
---@field ActiveSkillIDsAfter int[] 深化后主动技能
---@field AnimatorController string 动画状态机
---@field AnimatorFilename string Animator配置
---@field AttackIDs int[] 普攻
---@field BattleAIName string 战斗AI
---@field BattleAITriggerIDs int[] 战斗AI事件监听
---@field BattleFashionID int 男主战斗编号
---@field BattlePerform cfg.s2int[] 角色表演
---@field BattleType int 男主战斗类型
---@field ComboSkillIDs int[] 连携技能
---@field ComboSkillIDsAfter int[] 深化后连携技能
---@field ComboSkillStarter int 连携技能释放方
---@field CoopAtkIDs int[] 协作技攻击
---@field CoopSkillIDs int[] 协作技表演
---@field DeadSkillIDs int[] 死亡技能
---@field DisableRootMotion boolean 是否禁用RootMotion
---@field DodgeSkillIDs int[] 闪避技能
---@field DynamicCastSlots cfg.s2int[] 动态技能
---@field EditorVisible int 编辑器可见
---@field EnergyActionIDs int[] 能量获取途径
---@field FemaleComboSkillIDs int[] 女主自身连携技能
---@field FemaleComboSkillIDsAfter int[] 深化后女主自身连携技能
---@field IconName string 男主头像
---@field InitEnergy Fix[] 初始能量值
---@field LoveSkillIDs int[] 羁绊技能（誓约效果）
---@field MaxEnergy Fix[] 最大能量值
---@field ModelID int 模型索引
---@field Name string SCore名称
---@field PassiveSkillIDs int[] 被动技能
---@field PassiveSkillIDsAfter int[] 深化后被动技能
---@field RigidPoint Fix 刚性值
---@field SpecialSkillIDs int[] 特殊技能
---@field TalkAIName string 沟通AI
---@field TalkAITriggerIDs int[] 战斗沟通AI事件监听
---@field TimelineEvent string TimelineEvent配置
---@field Type int 角色类型
---@field UltraSkillIDs int[] 爆发技能（誓约技能）
---@field UltraSkillIDsAfter int[] 深化后爆发技能（誓约技能）
---@field WwiseID int[] 战斗语音
