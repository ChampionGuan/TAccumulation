local BattleServerProxy = {}

local csBattleUtil = CS.X3Battle.BattleUtil
local csRogueRewardType = CS.X3Battle.RogueRewardType

function BattleServerProxy:RollDoor(callback)
    if callback == nil then
        return
    end

    -- TODO 查配置表.
    local portalNums = g_csBattle.rogue.config.PortalNum
    local portalNum = 1;
    if portalNums == nil or portalNums.Length < 2 then
        Debug.LogError("【战斗】【Rogue】BattleRogue的PortalNum参数配置错误！")
    else
        portalNum = math.random(portalNums[0], portalNums[1])
    end

    local levelIDs = g_csBattle.rogue.config.RogueLevelIDs
    local portalWeightInfos = {}
    local portalIDs = {}
    if levelIDs ~= nil and levelIDs.Length > 0 then
        for i = 0, levelIDs.Length - 1 do
            local v = levelIDs[i]
            local canDuplicate = false
            if TbUtil.battleRogueLevelConfigs:ContainsKey(v.ID) then
                canDuplicate = TbUtil.battleRogueLevelConfigs[v.ID].CanDuplicate
            end
            -- 查配置是否允许重复.
            table.insert(portalWeightInfos, { ID=v.ID, Weight=v.Num, CanDuplicate=canDuplicate})
        end
    end

    -- 剔除必须选中的门.
    for i = #portalWeightInfos, 1, -1 do
        local portalWeightInfo = portalWeightInfos[i]
        if portalWeightInfo.Weight < 0 then
            table.insert(portalIDs, portalWeightInfo.ID)
            table.remove(portalWeightInfos, i)
        end
    end

    -- 权重随机逻辑.
    while #portalIDs < portalNum do
        local totalWeight = 0
        -- 统计总权重值.
        for i = 1, #portalWeightInfos do
            local portalWeightInfo = portalWeightInfos[i]
            totalWeight = totalWeight + portalWeightInfo.Weight
        end

        if totalWeight <= 0 then
            break
        end
        
        -- 随机出选中的门.
        local rangeWeight = 0
        local randomValue = math.random(1, totalWeight)
        for i = 1, #portalWeightInfos do
            local portalWeightInfo = portalWeightInfos[i]
            rangeWeight = rangeWeight + portalWeightInfo.Weight
            if randomValue <= rangeWeight then
                table.insert(portalIDs, portalWeightInfo.ID)
                if not portalWeightInfo.CanDuplicate then
                    table.remove(portalWeightInfos, i)
                end
                break
            end
        end
    end

    -- 保底给个门数据.
    if #portalIDs <= 0 then
        table.insert(portalIDs, g_csBattle.rogue.config.DefaultRogueLevelID)
    end

    local doorDatas = {}
    for i = 1, #portalIDs do
        local portalID = portalIDs[i]
        local doorData = CS.X3Battle.RogueDoorData()
        doorData.ID = portalID

        local levelID = 1
        -- 奖励参数.
        doorData.ExtraRewardType = RogueRewardType.None
        if TbUtil.battleRogueLevelConfigs:ContainsKey(portalID) then
            local battleRogueLevelConfig = TbUtil.battleRogueLevelConfigs[portalID]
            local extraRewardType = battleRogueLevelConfig.RewardType
            local extraRewardParams = battleRogueLevelConfig.RewardParams
            doorData.ExtraRewardType = extraRewardType

            local totalWeight = 0
            if extraRewardParams ~= nil then
                for i = 0, extraRewardParams.Length - 1 do
                    local v = extraRewardParams[i]
                    if v.Num < 0 then
                        doorData.ExtraRewardParam = v.ID
                        break
                    end
                end

                if doorData.ExtraRewardParam <= 0 then
                    for i = 0, extraRewardParams.Length - 1 do
                        local v = extraRewardParams[i]
                        totalWeight = totalWeight + v.Num
                    end

                    if totalWeight >= 1 then
                        local rangeWeight = 0
                        local randomValue = math.random(1, totalWeight)
                        for i = 0, extraRewardParams.Length - 1 do
                            local v = extraRewardParams[i]
                            rangeWeight = rangeWeight + v.Num
                            if randomValue <= rangeWeight then
                                doorData.ExtraRewardParam = v.ID
                                break
                            end
                        end
                    end
                end
            end

            local randomMode = battleRogueLevelConfig.RandomMode
            if randomMode == RogueRandomModeType.Average then
                -- 平均
                local battleLevelIDs = battleRogueLevelConfig.LevelIDs
                local index = math.random(0, battleLevelIDs.Length - 1)
                doorData.BattleLevelID = battleLevelIDs[index]
            elseif randomMode == RogueRandomModeType.Deduplication then
                -- 去重平均
                local battleLevelIDs = {}
                local levelUsed = {}
                local layerDatas = g_csBattle.rogue.arg.LayerDatas

                if layerDatas ~= nil then
                    for j = 0, layerDatas.Count -1 do
                        local d = layerDatas[j]
                        table.insert(levelUsed, d.LevelID)
                    end
                end

                for j = 0, battleRogueLevelConfig.LevelIDs.Length - 1 do
                    if not table.containsvalue(levelUsed, battleRogueLevelConfig.LevelIDs[j]) then
                        table.insert(battleLevelIDs, battleRogueLevelConfig.LevelIDs[j])
                    end
                end
                local index = math.random(1, #battleLevelIDs)
                doorData.BattleLevelID = battleLevelIDs[index]
            end

        end

        table.insert(doorDatas, doorData)
    end

    -- DONE:模拟服务器返回ack.
    XECS.XPCall(callback, doorDatas)

    -- DONE:模拟服务器保存数据
    CS.X3Battle.BattleUtil.SaveRogueData()
end

function BattleServerProxy:SelectDoor(index, callback)
    -- DONE:模拟服务器返回ack.
    XECS.XPCall(callback, index)

    -- DONE:模拟服务器保存数据
    CS.X3Battle.BattleUtil.SaveRogueData()
end

function BattleServerProxy:SelectRogueEntry(index, callback)
    -- DONE:模拟服务器返回ack.
    XECS.XPCall(callback, index,1)

    -- DONE:模拟服务器保存数据
    CS.X3Battle.BattleUtil.SaveRogueData()
end

g_battleServer = BattleServerProxy
return BattleServerProxy