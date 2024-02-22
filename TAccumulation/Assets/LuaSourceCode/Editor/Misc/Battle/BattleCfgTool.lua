BattleCfgTool = {}

function BattleCfgTool.GetModelExportDummies(modelName)
    local result = {}
    ---@type table<Int, <Int, DummiesConfig>>
    local dummiesCfg = LuaCfgMgr.GetAll("Battle.Config.DummiesConfig")
    --for id, pathCfg in pairs(dummiesCfg) do
    --    for k, cfg in pairs(pathCfg) do
    --        if cfg.FormModel == modelName and cfg.IsExportLogic == 1 then
    --            local tb = { cfg.Key, cfg.XZAxisPath }
    --            table.insert(result, tb)
    --        end
    --    end
    --end
    return result
end

return BattleCfgTool