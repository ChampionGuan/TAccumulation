SkillCfgTool = {}

---@return Int
function SkillCfgTool.GetSkillCfgByTLName(timelineName)
    local result = {}
    ---@type table<number, SkillConfig>
    local cfg = LuaCfgMgr.GetAll("Battle.Config.SkillConfig")
    for k,v in pairs(cfg) do
        --print(v.EventTimelineID)
        if v.EventTimelineID == timelineName then
            table.insert(result, k)
        end
    end
    return result;
end


return SkillCfgTool