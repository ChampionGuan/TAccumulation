﻿---@class cfg.MiaoCardDifficulty  excel名称:MiaoCard.xlsx
---@field AllRewardForShow int &全奖励概率公示
---@field BgmEvent string 背景音乐名
---@field BigImage string 选择难度界面的难度大图
---@field Description int &难度描述
---@field DoubleSlotInit int 初始化随机池ID
---@field DoubleSlotMax int 翻倍格最大数量
---@field DoubleSlotMin int 翻倍格最小数量
---@field Drama int 关联剧本ID
---@field EndingWords string 实际积分区间[x,y)对应结算评语组（胜=2分、平=1分、败=0分）
---@field EventGroup int 该难度关联的约会事件
---@field FailEndingWords string 未完成出游时，实际积分区间[x,y)对应结算评语组（胜=2分、平=1分、败=0分）
---@field FailRewardDrop string 未完成出游时，实际积分区间[x,y)对应奖励掉落ID（胜=2分、平=1分、败=0分）
---@field FirstStartFuncCard int 初始先手功能手牌数
---@field FirstStartNumCard int 初始先手数字手牌数
---@field FirstStartType int 决定先手类型
---@field GenSlotAI string 牌桌生成AI
---@field Group int 组ID
---@field GuideCheck int[] 当前关卡是否完成新手引导检测条件
---@field HandCardLimit int 手牌上限
---@field ID int 唯一ID
---@field Image string 图标名
---@field LaterStartFuncCard int 初始后手功能手牌数
---@field LaterStartNumCard int 初始后手数字手牌数
---@field MaleAI string 男主BD的AI
---@field MaleActWaitMaxTime int 男主行动的等待最大时间（毫秒）
---@field MaleActWaitMinTime int 男主行动的等待最小时间（毫秒）
---@field MaleGetCardAI string 男主摸牌AI
---@field MaleGetFuncCardAI string 男主摸功能牌AI
---@field MaleServerAI string 男主服务器AI
---@field Man string ##男主注释
---@field ManType int 男主ID
---@field MiaoCardStack int 牌堆配置
---@field MiaoCardType int 喵喵牌类型枚举
---@field Model string 喵喵牌牌局桌面模型名称
---@field Name int &难度名称
---@field OpenCondition int 该难度开启条件
---@field OwnerModel string[] 标识格子所属人模型名称
---@field PLGetCardAI string 女主摸牌AI
---@field PLGetFuncCardAI string 女主摸功能牌AI
---@field Pos cfg.vector3xml 牌局桌面模型位置
---@field RandomRewardForShow int[] 额外奖励（显示用）
---@field RealRewardDrop string 实际积分区间[x,y)对应奖励掉落ID（胜=2分、平=1分、败=0分）
---@field Rot cfg.vector3xml 牌局桌面模型朝向
---@field Round int 单局轮数
---@field SPAction int[] 特殊行为
---@field Scene string 该难度喵喵牌场景
---@field ShowCondition int 该难度条目显示在列表中的条件
---@field StaticRewardForShow int[] 固定奖励（显示用）