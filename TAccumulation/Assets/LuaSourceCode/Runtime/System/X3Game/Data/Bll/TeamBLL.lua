---@class TeamBLL:BaseBll
local TeamBLL = class("TeamBLL", BaseBll)

function TeamBLL:OnInit()
    self.reqMsg = {}
end

---@param guid int
---@param scoreId int
---@param plSuitId int
function TeamBLL:SaveScoreIdPlSuitId(guid, scoreId, plSuitId, weaponId)
    SelfProxyFactory.GetFormationProxy():UpdateScoreId(guid, scoreId)
    SelfProxyFactory.GetFormationProxy():UpdatePLSuitId(guid, plSuitId)
    SelfProxyFactory.GetFormationProxy():UpdateWeaponId(guid, weaponId)
    if guid > 0 and scoreId > 0 and plSuitId > 0 and weaponId > 0 then
        local formation = SelfProxyFactory.GetFormationProxy():GetFormation(guid)
        table.clear(self.reqMsg)
        self.reqMsg.Formation = formation
        GrpcMgr.SendRequest(RpcDefines.SetFormationRequest, self.reqMsg)
    end
end

function TeamBLL:GetSCoreData(scoreData, power, isChoose)
    local scoreInfo = {}
    scoreInfo.Info = LuaCfgMgr.Get("SCoreBaseInfo", scoreData.Id)
    scoreInfo.Level = scoreData.Level --等级
    scoreInfo.Star = scoreData.Star --星级
    scoreInfo.Quality = scoreData.Quality --品阶
    scoreInfo.Awaken = scoreData.Awaken  -- 觉醒
    scoreInfo.IsChoose = isChoose
    scoreInfo.Power = power
    return scoreInfo
end

function TeamBLL:GetScoreStruct(data, power, chooseID)
    local isChoose = chooseID == data.Id
    return self:GetSCoreData(data, power, isChoose)
end

---@param cfg_CommonStageEntry cfg.CommonStageEntry
---@param manType int
---@param scoreId int
function TeamBLL:IsLimitByManTypeScoreId(cfg_CommonStageEntry, manType, scoreId)
    if cfg_CommonStageEntry and cfg_CommonStageEntry.TeamLimit and #cfg_CommonStageEntry.TeamLimit > 0 then
        for i = 1, #cfg_CommonStageEntry.TeamLimit do
            ---@type cfg.TeamLimit
            local cfg_TeamLimit = LuaCfgMgr.Get("TeamLimit", cfg_CommonStageEntry.TeamLimit[i])
            local limitType = cfg_TeamLimit.LimitType
            local params = cfg_TeamLimit.Params
            if limitType == 2 then
                ---仅能使用指定男主
                return not table.containsvalue(params, manType)
            elseif limitType == 3 then
                ---不能使用指定男主
                return table.containsvalue(params, manType)
            elseif limitType == 4 then
                ---仅能使用指定Score
                if not scoreId then
                    for j = 1, #params do
                        ---@type cfg.SCoreBaseInfo
                        local cfg_SCoreBaseInfo = LuaCfgMgr.Get("SCoreBaseInfo", params[j])
                        if cfg_SCoreBaseInfo.ManType == manType then
                            return false
                        end
                    end
                    return true
                else
                    return not table.containsvalue(cfg_TeamLimit.Params, scoreId)
                end
            elseif limitType == 5 then
                ---不能使用指定Score
                if not scoreId then
                    for j = 1, #params do
                        ---@type cfg.SCoreBaseInfo
                        local cfg_SCoreBaseInfo = LuaCfgMgr.Get("SCoreBaseInfo", params[j])
                        if cfg_SCoreBaseInfo.ManType == manType then
                            return true
                        end
                    end
                    return false
                else
                    return table.containsvalue(cfg_TeamLimit.Params, scoreId)
                end
            end
        end
    end
    return false
end

return TeamBLL