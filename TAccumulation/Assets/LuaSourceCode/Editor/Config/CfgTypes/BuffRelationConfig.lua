﻿---@class cfg.BuffRelationConfig  excel名称:BattleBuff.xlsx
---@field ID int 唯一ID
---@field MainBuffID int 主BuffID*
---@field MainStackCount int 主buff对叠层数(0：表示没有要求）
---@field OperationArg int 操作参数（合成时表示新buffID）
---@field OperationType int 操作类型(1:合成2：覆盖3：互斥）
---@field SubBuffID int 辅BuffID*
