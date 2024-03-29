﻿---@class cfg.MainUISpEvent  excel名称:MainUI.xlsx
---@field BackType int 事件结束后是否回到互动模式
---@field ByClient int 是否客户端发起
---@field Condition int 事件条件ID
---@field Des string #事件描述
---@field DurationTime int 事件触发后的有效时长（秒）
---@field EndConnectStateID int 事件结束后关联状态ID
---@field ID int 唯一ID
---@field ManLimit int 限定男主ID
---@field Name int 事件描述&
---@field Priority int 优先级
---@field Probability int 触发概率（万分比）
---@field ResetStayTime int 事件完成时是否重置当前看板娘计时
---@field RewardItem cfg.s3int[] 奖励道具
---@field SCoreLimit int 限定男主S-Core的ID
---@field StateID int 事件激活时关联状态ID
---@field Times int 可触发次数
---@field TimesRefreshDetail string 触发次数重置参数
---@field TimesRefreshType int 触发次数重置类型
