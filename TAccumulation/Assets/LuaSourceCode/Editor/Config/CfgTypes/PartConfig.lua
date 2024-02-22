﻿---@class cfg.PartConfig  excel名称:PartConfig.xlsx
---@field BaseModelKey string RoleBaseModel表中的裸模Key
---@field Des string ##备注
---@field IsValid string 是否是有效数据  是的话 填1 否则留空
---@field Owners string[] 归属角色（RoleBaseModel表中的裸模Keys）
---@field ShrinkHair int 类型为帽子时，此处配置头发缩小的百分比
---@field Sources string[] 从高到低，模型资产列表
---@field StringKey string 唯一StringKey
---@field SubType int 子类型：配饰：1=头饰 HE（头纱、发饰、帽子）2=耳饰 EA3=面饰 FA（眼镜，面纱，口罩）4=颈饰 NE（项链、围巾，领带领结）5=手饰 HA（手镯，戒指？）6=腰饰 WA7=胸饰 CH8=腿饰 LE9=特殊 SP
---@field Type int 类型1=头发2=身体3=饰品4=武器5=睫毛       6=脸
