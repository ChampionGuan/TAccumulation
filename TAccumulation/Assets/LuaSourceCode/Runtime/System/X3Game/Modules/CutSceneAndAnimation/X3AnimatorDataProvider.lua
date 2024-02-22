--- X3@X3AnimatorDataProvider
--- X3Animator数据提供器
--- Created by Tungway
--- Created Date: 2022/2/24

---@class X3AnimatorDataProvider
local X3AnimatorDataProvider = class("X3AnimatorDataProvider")

function X3AnimatorDataProvider:ctor()
    ---@type table[] ComAnimState[]
    self.cfgList = {}
    ---@type table[] PartType[]
    self.partTypeCfgList = {}
    ---@type boolean
    self.cfgInited = false
end

---将配置表信息写入ExternalX3AnimatorStateData
---@param cfg table
---@param stateData ExternalX3AnimatorStateData
---@return bool
local function readCfgToStateData(cfg, stateData)
    if cfg == nil or stateData == nil then
        return false
    end

    stateData.AssetType = cfg["SourceType"]
    stateData.AssetPathOrName = cfg["SourcePath"]
    stateData.TransitionDuration = cfg["Crossfade"]
    stateData.WrapMode = cfg["PlayType"]
    stateData.InheritTransform = cfg["CarryPos"]  == 1
    stateData.SetDefault = cfg["IsDefault"] == 1
    return true
end

---OnLoadStateData
---@param animator X3Animator
---@param stateName string
---@param stateData ExternalX3AnimatorStateData
---@return bool
function X3AnimatorDataProvider:OnLoadStateData(animator, stateName, stateData)
    local ins = animator.gameObject
    local partKeys = CharacterMgr.GetPartKeys(ins)
   --[[ if partKeys == nil or #partKeys == 0 then
        return false
    end]]

    if not self.cfgInited then
        local cfgList = LuaCfgMgr.GetAll("ComAnimState")
        for _, cfg in pairs(cfgList) do
            table.insert(self.cfgList, cfg)
        end
        table.sort(self.cfgList, function(lhs, rhs) return lhs["Index"] < rhs["Index"]  end)
        self.cfgInited = true
    end

    for _, cfg in ipairs(self.cfgList) do
        if stateName == cfg["StateName"] then
            ---@type int[]
            local partTypeLimit = cfg["PartTypeLimit"]
            ---没有限制，直接使用
            if partTypeLimit == nil or #partTypeLimit == 0 then
                readCfgToStateData(cfg, stateData)
                return true
            end

            for _, partKey in ipairs(partKeys) do
                local partTypeCfg = self:GetPartTypeCfg(partKey, cfg["State"])
                if partTypeCfg ~= nil and (table.indexof(partTypeLimit, partTypeCfg["ClothType"]) ~= false) then
                    readCfgToStateData(cfg, stateData)
                    return true
                end
            end
        end
    end
    return false
end

---根据partKey和state返回PartType，如果没有找到对应State的返回第一个
---@param partKey string
---@param state int
---@return cfg.PartType
function X3AnimatorDataProvider:GetPartTypeCfg(partKey, state)
    local partTypeCfg = LuaCfgMgr.Get("PartType", partKey, state)
    if partTypeCfg == nil then
        local cfgs = LuaCfgMgr.Get("PartType", partKey)
        if cfgs then
            partTypeCfg = cfgs[1]
        end
    end
    return partTypeCfg
end

return X3AnimatorDataProvider