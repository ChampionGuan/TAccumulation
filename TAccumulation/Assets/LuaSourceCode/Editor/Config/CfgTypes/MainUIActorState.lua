﻿---@class cfg.MainUIActorState  excel名称:MainUI.xlsx
---@field ActorDes string ##看板娘说明
---@field ActorID int *看板娘ID
---@field ActorPos Vector3 男主模型位置
---@field ActorRot Vector3 男主模型朝向
---@field CharacterLightSolution int 该状态下角色灯光组
---@field ConditionWeight cfg.s2int[] 状态条件及其对应权重
---@field DefaultAnim int 该状态下默认动画
---@field Des string ##说明
---@field DurationMax int 最大持续时长（秒）
---@field DurationMin int 最小持续时长（秒）
---@field ID int 唯一ID
---@field IsInteractive int 是否为可交互状态
---@field IsSpecial int 是否为特殊状态
---@field PosType int 该状态下男主位置类型
---@field SceneLimit int[] 该状态下限定的主界面场景
---@field StateConversation string 循环状态机ConversationName
---@field StateDes int 状态描述&
---@field StateDialogueID int 循环状态机DialogueID
---@field StateID int *状态ID