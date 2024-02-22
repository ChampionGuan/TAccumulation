---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: 峻峻
-- Date: 2020-09-05 21:18:57
---------------------------------------------------------------------
---@class QTEOptionData
---@field text string QTE文本
---@field variableID int 选择该QTE同步修改的VariableKey
---@field variableValue int 选择该QTE同步修改的VariableValue
---@field weight float QTE权重
---@field link Link QTE对应的link
---@field isSatisfiedCondition boolean 是否满足条件
---@field conditionCheckMessage string 条件不满足时的提示
---@field semanticGroupId int 语义组Id
---@field qteClickType DialogueEnum.QTEClickType
---@field qteStyleSetting QTEStyleSetting QTE样式设置
---@field qtePositionType DialogueEnum.QTEPositionType
---@field qtePosition Vector2
---@field followTransform Transform
---@field isQTEFollow boolean
---@field followOffset Vector2
---@field slideStartPosition Vector2 定点滑动QTE起始位置
---@field slideStartPosRange Vector2 定点滑动QTE起始位置范围
---@field slideEndPosition Vector2 定点滑动QTE结束位置
---@field slideRotation Vector2 滑动QTE旋转
---@field slideSpeed int 滑动速度最小值配置
---@field useTextDefaultPosition boolean 文字使用默认位置
---@field textPosition Vector2 文字位置
---@field textRotation Vector3 文字旋转
---@field longPressDuration float QTE长按时长
---@field slideQTEType DialogueEnum.QTESlideType
---@field useDefaultBlowSetting boolean 吹气使用默认设置
---@field blowVolume float 吹气音量
---@field frameCount int 吹气帧数
---@field continuousClickTimes int 连点次数
---@field touchTimes int 抚摸次数
---@field touchOffset Vector2 点击偏移

local QTEOptionData = class("QTEOptionData")

function QTEOptionData:ctor()
	self.text = nil
	self.variableID = 0
	self.variableValue = 0
	self.weight = 0
	self.link = 0
	self.isSatisfiedCondition = true
	self.conditionCheckMessage = nil
	self.semanticGroupID = 0

	--region qteSetting
	self.qteClickType = 0
	self.qteStyleSetting = nil
	self.qtePositionType = DialogueEnum.QTEPositionType.Position
	self.qtePosition = Vector2.zero
	self.followTransform = nil
	self.isQTEFollow = false
	self.followOffset = Vector2.zero
	self.slideStartPosition = Vector2.zero
	self.slideStartPosRange = Vector2.zero
	self.slideEndPosition = Vector2.zero
	self.slideRotation = Vector2.zero
	self.slideSpeed = 0
	self.useTextDefaultPosition = true
	self.textPosition = Vector2.zero
	self.textRotation = Vector2.zero
	self.longPressDuration = 0
	self.slideQTEType = DialogueEnum.QTESlideType.Direction
	--endregion
end

return QTEOptionData