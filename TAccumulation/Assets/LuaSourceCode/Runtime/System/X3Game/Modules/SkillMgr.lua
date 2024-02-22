---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-08-28 14:15:12
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class SkillMgr 技能管理

local SkillMgr = {}
--1女主普攻--2女主主动--3女主闪避--4女主QTE闪避--11Score普攻--12Score主动--13Score闪避--14Score被动--15Score羁绊
--21协作技--22爆发技--23连携技

---获取培养技能
function SkillMgr.GetSkillDataList(scoreID)
	local SkillData = {11,12,14,23,22}
	return SkillData
end

---获取技能信息
---@param id int 技能编号
---@return table 技能信息
function SkillMgr.GetSkillInfo(id)
	if id == nil then return nil end

	local result = {}
	local config = BattleUtil.GetSkillConfig(id)
	if config then
		result.ID = id
		result.Name = config.Name
		result.Type = config.SkillType
		result.Icon = config.SkillIcon
		result.Remark = ""
	end

	return result
end

---根据培养信息获取技能ID
---@param scoreID int SCoreID
---@param devSkillID int 培养系统配置的ID
---@return int 技能ID
function SkillMgr.GetSkillID(scoreID, devSkillID)
	local config = BattleUtil.GetActorConfig(scoreID)
	--local SkillData = {11,12,14,21,22}
	---@type CS.X3Battle.IDLevel
	local skill = nil
	if devSkillID == 11 then
		skill = config.AttackIDs
	elseif devSkillID == 12 then
		skill = config.ActiveSkillIDs
	elseif devSkillID == 14 then
		skill = config.PassiveSkillIDs
	elseif devSkillID == 23 then
		skill = config.ComboSkillIDs
	elseif devSkillID == 22 then
		skill = config.UltraSkillIDs
	else
		return skill
	end

	if skill == nil or skill.Length < 1 or skill[0].ID == 0 then return nil
	else return skill[0].ID end
end

return SkillMgr